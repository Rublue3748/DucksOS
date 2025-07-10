; What needs to be done to boot:
; - (DONE) Enable A20
; - Setup FPU
; - (DONE) Generate Memory Map
; - (DONE) Select Video Mode
; - Set up protected mode
; - Load in kernel (might involve swapping back and forth w/ protected mode)
; - Enter protected mode and kernel

SECTION .text
bits 16

boot:
    call Enable_A20
    xor ax,ax
    mov es,ax
    mov edi,0x500
    call Generate_Memory_Map

    mov [Video_Mode_Ptr],edi
    call Get_Current_Video_Mode

    movzx eax, word [Below_1MB_Memory_Size]
    movzx ebx, word [Memory_Map_Pointer]
    movzx ecx, word [Memory_Map_Size]
    xchg bx,bx

infinite_halt:
    hlt
    jmp infinite_halt


; Print a string
; Argument:
;   ds:si -> null-terminated string
; Trashed: si (points to the null of the string)
print_string:
    pushf
    push ax

.loop:
    mov al,[ds:si]
    cmp al,0
    je .done
    mov ah,0x0E
    mov bx,0x0F
    int 0x10
    inc si
    jmp .loop

.done:
    pop ax
    popf
    ret


SECTION .bss
Video_Mode_Ptr: resd 1

%include "a20.asm"
%include "memory_map.asm"
%include "video.asm"