SECTION .text
bits 16

; Generates a memory map of the system at [es:di], while also populating the Below_1MB_Memory_Size and Memory Map Pointer/Size
; Returns: 
;   es:di -> Pointer to the past-the-end element of the map (next blank spot)
; Trashed: None
Generate_Memory_Map:
    pushf
    push eax
    push ebx
    push ecx
    push edx
    xchg bx,bx
    clc
    ; Get the size of the area below the 1 MB limit (i.e. the address of the EBDA)
    int 0x12
    xchg bx,bx
    jc .error
    mov [Below_1MB_Memory_Size],ax

    ; Generate the memory map
    ; Start with EBX zero'd (do not modify during the loop)
    mov [Memory_Map_Pointer],di
    xor ebx,ebx
.loop:
    ; Int 0x15-EAX=0xE820 -> Gets a memory map list item
    mov eax,0xE820
    mov ecx,24 ; Size of data entry
    mov edx,0x534D4150 ; EDX = Magic number
    clc
    int 0x15
    xchg bx,bx

    ; Break out of the loop if any of the following happens:
    ; - Carry flag is set (Possible Error), ignore last entry
    ; - EAX != 0x534D4150 (Possible Error), ignore last entry
    ; - EBX = 0 (End of list), keep last entry
    jc .done
    cmp EAX,0x534D4150
    jne .done
    ; Keep last entry
    add di,24 ; di is not automatically incremented
    cmp EBX,0
    je .done
    ; More list entries
    jmp .loop

.done:
    movzx eax,di
    sub ax,[Memory_Map_Pointer]
    mov bl,24
    div bl
    xor ah,ah
    mov [Memory_Map_Size],ax

    pop edx
    pop ecx
    pop ebx
    pop eax
    popf
    ret


.error:
    mov si,.error_str
    call print_string
    jmp infinite_halt

SECTION .data
.error_str: db "An error occurred while generating the memory map!",0

SECTION .bss
Below_1MB_Memory_Size: resw 1
Memory_Map_Pointer: resw 1
Memory_Map_Size: resw 1