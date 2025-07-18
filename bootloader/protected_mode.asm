SECTION .boot.text
bits 16

%include "includes.asm"
; This function is not meant to return (i.e. just jump to it)
Enter_Protected_Mode:
    ; Steps:
    ; - Disable interrupts
    ; - Set up GDT and load it
    ; - Modify CR0 to enter protected mode

    ; Disable interrupts
    cli

    ; Disable NMI (mask bit 7 of port 70h)
    in al,0x70
    or al,0x80
    out 0x70,al
    in al,0x71

    ; Setup GDT
    mov word [.GDTR],31
    mov dword [.GDTR+2],.dummy_GDT
    xchg bx,bx
    lgdt [.GDTR]

    ; Set up CR0 and pray
    mov eax,cr0
    or al,1 ; Set Protected Enable bit
    mov cr0,eax ; Now in protected mode

    ; Assert CS and jump to protected mode entry point
    jmp 0x8:Protected_Start

SECTION .boot.data
.GDTR: times 6 db 0
align 16
.dummy_GDT: times 8 db 0
    db 0xFF,0xFF,0,0,0,0x9B,0xCF,0x00
    db 0xFF,0xFF,0,0,0,0x93,0xCF,0x00
    db 0xFF,0xFF,0,0,0,0x9B,0xCF,0x00

bits 32
Protected_Start:
    ; Assert all data segment registers with new values
    mov eax,0x10
    mov ds,eax
    mov es,eax
    mov fs,eax
    mov gs,eax
    mov ss,eax
    mov esp,0x7C00

    xchg bx,bx
    mov eax,[Entry_Point]
    jmp far eax
    ; Setup the kernel and then jmp to it's start

.infinite_halt:
    hlt
    jmp .infinite_halt
