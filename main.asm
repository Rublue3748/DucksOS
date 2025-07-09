; What needs to be done to boot:
; - Enable A20
; - Setup FPU
; - Generate Memory Map
; - Select Video Mode
SECTION .text
bits 16

boot:
    call Check_A20

    jnc .not_set0
    mov si, A20_enabled_str
    call print_string
    jmp .cont

.not_set0:
    mov si,A20_not_enabled_str
    call print_string



.cont:

    call Enable_A20

    call Check_A20
    jnc .not_set

    mov si, A20_enabled_str
    call print_string
    jmp infinite_halt

.not_set:
    mov si,A20_not_enabled_str
    call print_string
    jmp infinite_halt


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




%include "a20.asm"
SECTION .data
A20_enabled_str: db `A20 line enabled!\n\r`,0
A20_not_enabled_str: db `A20 was not enabled!\n\r`,0