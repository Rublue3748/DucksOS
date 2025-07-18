
%include "includes.asm"

SECTION .boot.text
bits 16


 ; Loads the kernel from the given disk
 ; Parameters: dl = drive number (for int 0x13)
 ; Returns: eax = entry point of kernel, or 0 on failure
 ; Trashed: None
 ; TODO: Add support for CHS AND LBA (currently only LBA)
Kernel_Setup:
    ; Operations:
    ; - Search for kernel on disk (Sector-aligned ELF header, search to a maximum of 200?)
    ; - Load header into memory and parse for loadable sections
    ; - Load sections into memory
    ; - - Load some sectors into scratch
    ; - - Enter temporary 32-bit mode and transfer the data to >1MB
    ; - - Return to 16-bit mode and repeat
    ; - Return entry point

    pushf
    pushad

    mov [.drive_number],dx

    ; Search for kernel on disk (LBA Method)
    xor ebx,ebx ; Even though we add 1 shortly after, sector 0 shouldn't have a header, as that is the bootsector!
.search_loop:
    inc ebx
    cmp ebx,200 ; Search a maximum of 200 sectors for now
    jg .ELF_Not_Found

    ; Set up LBA Packet
    mov [.LBA_Packet],byte 0x10
    mov [.LBA_Packet+1],byte 0x0
    mov [.LBA_Packet+2],word 4 ; Load 4 sectors at once, that way we have the full ELF header if this is the correct sector
    mov [.LBA_Packet+4],word Sector_Storage
    mov [.LBA_Packet+6],word 0
    mov [.LBA_Packet+8],ebx

    mov eax,0x4200
    mov esi,.LBA_Packet
    mov dx,[.drive_number]
    int 0x13
    jc .disk_error

    ; Check if the sector contains an ELF header
    cmp dword [Sector_Storage],0x464c457f ; ELF Magic Word
    jne .search_loop

    ; ELF Header was found, now parse it for program headers

    ; Store entry point
    mov eax,[Sector_Storage+0x18]
    mov [.entry_point],eax
    ; Store sector offset
    mov [Sector_Offset],ebx


    ; Copy ELF Header
    mov si,Sector_Storage
    mov di,.ELF_Header
    mov cx,[Sector_Storage+0x28]
    cld
    rep movsb

    ; Copy Program Headers
    mov al,[Sector_Storage+0x2A] ; Bytes per header
    mul byte [Sector_Storage+0x2C] ; Multiply by number of headers
    ; ax = # of bytes to copy
    ; exchange with cx and use repsw
    xchg ecx,eax
    ; Copy program headers
    mov esi,[Sector_Storage+0x1C] ; From source
    add esi,Sector_Storage
    cld
    rep movsb

    ; Process each header
    ; ebx = header index
    xor ebx,ebx

.program_header_loop:
    cmp bx,[.ELF_Header+0x2C] ; If bx >= num of headers, then we're done
    jge .success

    ; Get offset of current program header and store it in cx
    movzx eax,bx
    mov cx,[.ELF_Header+0x2A] ; Size of program header * index
    mul cx
    and eax,0xFFFF
    add ax,[.ELF_Header+0x28] ; Add size of ELF header to get offset into ELF Storage
    add eax,.ELF_Header        ; Add physical address of the ELF Header

    ; Call helper function load this data (as this function is already getting too long)
    mov dx,[.drive_number]
    push ebx
    mov ebx,eax
    call Kernel_Load_Program_Header
    pop ebx
.continue:
    inc bx
    jmp .program_header_loop


.success:
    popad
    popf
    mov eax,[.entry_point]
    ret

.failure:
    popad
    popf
    xor eax,eax
    ret

.disk_error:
    mov si,.disk_error_str
    call print_string
    jmp .failure

.ELF_Not_Found:
    mov si,.ELF_Not_Found_str
    call print_string
    jmp .failure


SECTION .boot.data progbits write noexec
.disk_error_str: db `Error occurred reading from disk!`,0
.ELF_Not_Found_str: db `An ELF Header was not found!`,0

SECTION .boot.bss nobits write noexec
align 512
.ELF_Header: resb 512
.LBA_Packet: resb 16
.entry_point: resb 4
.drive_number: resb 2
Sector_Storage: resb 512*4
Sector_Offset: resb 4


SECTION .boot.text
bits 16
 ; Loads the pointed to program header into memory, swapping in and out of protected mode as needed
 ; NB: The program header has to be sector aligned (p_offset % 512 == 0)
 ; Parameters: ebx = pointer to the program header to parse
 ;             dx = drive letter to load from
 ; Global Variables used: Sector_Storage, Sector_Offset (Sector_Offset should be set to the sector containing the ELF Header)
 ; Trashed: Sector_Storage
 ; Return: None
Kernel_Load_Program_Header:

    pushf
    pushad

    cmp dword [ebx],1 ; If not loadable, then don't do anything
    jne .done_no_pop

    cmp dword [ebx+0x10], 0 ; If size is 0, then ignore
    je .done_no_pop

    mov eax, [ebx+0x04]
    and eax, 511 ; Check if the bottom bits are set. If so, then this isn't aligned on a 512 page
    jnz .alignment_error


    sub esp,16
    ; Stack:
    ; esp + 0 ->  dword: number of bytes left to transfer
    ; esp + 4 ->  qword: SGDT store location (technically only 6 bytes, but keep byte alignment)
    ; esp + 12 -> dword: Drive number

    mov eax,[ebx+0x10] ; Load size in bytes of program segment
    mov [esp],eax      ; Store that as number of bytes remaining

    ; Store drive number
    mov [esp+12],dx

.loop:
    cmp dword [esp],0  ; Check if there's still data to be loaded
    je .done 
    
    ; Offset into image file = (size of segment - number of bytes) + segment offset into image
    mov eax, [ebx + 0x10]
    sub eax, [esp]
    add eax, [ebx + 0x4]
    
    ; Sector position = Sector_Offset + (offset into image file / 512)
    ; Move offset into DX:AX and then divide by 512
    mov edx, eax
    shr edx, 16
    movzx eax, ax
    mov cx, 512
    div cx
    ; Quotient in AX, ignore remainded in dx
    add eax,[Sector_Offset]

    ; Now load from this offset at eax
    mov [.LBA_Packet],   byte 0x10
    mov [.LBA_Packet+1], byte 0x0
    mov [.LBA_Packet+2], word 4 ; Load 4 sectors at once
    mov [.LBA_Packet+4], word Sector_Storage
    mov [.LBA_Packet+6], word 0
    mov [.LBA_Packet+8], eax

    mov esi, .LBA_Packet
    mov eax, 0x4200
    mov dx, [esp+12]

    int 0x13
    jc .disk_error
    ; The next four sectors should be loaded into Sector Storage. Now switch to 32-bit protected mode
    ; Store old gdt to load later
    sgdt [esp+4]
    cli ; Disable interrupts while we're in protected mode (as the IVT is invalid during that time)
    ; Disable NMI (mask bit 7 of port 70h)
    in al,0x70
    or al,0x80
    out 0x70,al
    in al,0x71

    ; Set up temporary protected mode gdt
    mov word [.dummy_GDTR],31
    mov dword [.dummy_GDTR+2],.dummy_GDT
    ; xchg bx,bx
    lgdt [.dummy_GDTR]

    ; Enable Protected Mode
    mov eax, cr0
    or al, 1
    mov cr0, eax

    ; Assert cs
    jmp 0x8:.protected_mode

    bits 32
.protected_mode:
    ; Assert ds, es, and ss
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax

    ; Number of bytes to copy (ecx) = min(number of bytes left [esp], 4 * sector size)
    mov ecx,[esp]
    cmp ecx,4*512
    jle .not_too_much
    mov ecx,4*512
.not_too_much:

    ; Set source and destination
    mov esi, Sector_Storage

    ; Destination = (segment size - number of bytes remaining) + paddr
    mov edi, [ebx + 0x10]
    sub edi, [esp]
    add edi, [ebx + 0x0C]

    ; Decrement how many bytes are left to copy
    sub dword [esp],ecx

    ; Copy the bytes
    rep movsb
    ; xchg bx,bx

    mov word [.dummy_GDTR],31
    mov dword [.dummy_GDTR+2],.dummy_16_bit_GDT

    ; Load 16-bit selectors
    lgdt [.dummy_GDTR]
    ; Assert cs
    jmp 0x08:.little_protected_mode
bits 16
.little_protected_mode:
    mov ax,0x10
    mov ds,ax
    mov es,ax
    mov ss,ax

    ; Switch back to unprotected mode
    mov eax, cr0
    and eax, 0xFFFFFFFE
    mov cr0, eax

    jmp 0x00:.real_mode
.real_mode:
    xor ax,ax
    mov ds,ax
    mov es,ax
    mov ss,ax

    sti

    jmp .loop

.done:
    ; Clean up stack
    add esp,16
.done_no_pop:
    popad
    popf
    ret

.alignment_error:
    mov si,.alignment_error_str
    call print_string
    jmp infinite_halt
.disk_error:
    mov si,.disk_error_str
    call print_string
    jmp infinite_halt

SECTION .boot.data progbits write noexec
.dummy_GDTR: times 6 db 0
align 16
.dummy_GDT: times 8 db 0
    db 0xFF,0xFF,0,0,0,0x9B,0xCF,0x00
    db 0xFF,0xFF,0,0,0,0x93,0xCF,0x00
    db 0xFF,0xFF,0,0,0,0x9B,0xCF,0x00
.dummy_16_bit_GDT: times 8 db 0
    db 0xFF,0xFF,0,0,0,0x9B,0x00,0x00
    db 0xFF,0xFF,0,0,0,0x93,0x00,0x00
    db 0xFF,0xFF,0,0,0,0x9B,0x00,0x00

.alignment_error_str: db `Program segment not aligned on 512b page!`,0
.disk_error_str: db `An unexpected disk error has occurred!`,0
SECTION .boot.bss nobits write noexec
.LBA_Packet:
    resb 16