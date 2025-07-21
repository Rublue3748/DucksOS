; What needs to be done to boot:
; - (DONE) Enable A20
; - Setup FPU
; - (DONE) Generate Memory Map
; - (DONE) Select Video Mode
; - (Later, current kernel is small enough to be loaded with this bootstrapping stage) 
;       Load in kernel (might involve swapping back and forth w/ protected mode)
; - (Later) preserve old GDT and IVT, so that we can switch back to call bios interrupts
; - Set up kernel (Swapping between Real and Protected Mode)
; - Enter Protected Mode, setup stack and start the kernel

SECTION .boot.start
bits 16

%include "includes.asm"


boot:

    call Enable_A20
    xor ax,ax
    mov es,ax
    mov edi,0x500
    call Generate_Memory_Map

    mov [Video_Mode_Ptr],edi
    call Get_Current_Video_Mode


    call Kernel_Setup
    mov [Entry_Point],eax

    jmp Enter_Protected_Mode

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


SECTION .boot.data
global Video_Mode_Ptr
Video_Mode_Ptr: dd 0
Entry_Point: dd 0

; %include "a20.asm"
; %include "memory_map.asm"
; %include "video.asm"
; %include "protected_mode.asm"