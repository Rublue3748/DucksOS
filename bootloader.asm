NUM_SECTORS equ 50

org 0x7c00
bits 16

entry:
    ; Assert CS = 0
    jmp 0:start

start:
    ; Reset all segment registers
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    ; Set up stack
    mov ss, ax
    mov esp,0x7c00
    mov ebp,0x7c00

    ; Store drive number for later use
    mov [.current_drive_number],dl

    ; Check for drive extensions
    mov ax,0x4100
    mov bx,0x55AA

    int 0x13

    jnc .extensions_available
    mov si,0
    jmp .error

.extensions_available:

    ; Load NUM_SECTORS into memory after this address
    ; Setup transfer packet
    mov [.LBA_Packet],byte 16
    mov [.LBA_Packet + 1],byte 0
    mov [.LBA_Packet + 2],word NUM_SECTORS
    mov [.LBA_Packet + 4],word 0x7e00
    mov [.LBA_Packet + 6],word 0
    mov esi,[.load_start_address]
    mov [.LBA_Packet + 8],esi
    mov esi,[.load_start_address + 4]
    mov [.LBA_Packet + 12],esi

    ; Set up interrupt call
    mov esi,.LBA_Packet
    mov ax,0x4200
    int 0x13

    jnc .successful_load
    mov si,1
    jmp .error

.successful_load:
    mov si,2
    jmp .error
    jmp .halting_loop


    

.error:
    ; Print error string
    mov ax,0x1301
    mov bx,0x004f
    mov cx,12
    mov dx,0
    mov bp,.error_string
    int 0x10

    ; Print error code
    mov ax,si
    mov ah,0x0e
    add al,'0'
    mov bx,0x004f
    int 0x10

.halting_loop:
    hlt
    jmp .halting_loop

align 2
.LBA_Packet:
    times 16 db 0

.error_string:
    db "Error code: "

.load_start_address:
    dq 1 ; By default, start loading from LBA 1. Can be modified beforehand by something like the MBR

.current_drive_number:
    db 0

    times 510-($-$$) db 0 
    dw 0xAA55