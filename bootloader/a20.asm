
SECTION .boot.text
bits 16

%include "includes.asm"

Enable_A20:
    pushf
    push ax
    ; If the A20 is already enabled, then don't bother
    call Check_A20
    jc .A20_enabled

    ; Enable A20 via the 8042 controller
    ; TODO: Implement proper 8042 functions
    ; TODO: Double check this at some point, as Bochs auto-enables the A20 line

    ; Mask interrupts while working with the 8042
    cli
    call .wait_8042_input_ready

    ; Read in the output port byte
    mov al, 0xD0
    out 0x64, al

    call .wait_8042_output_ready
    in al, 0x60

    ; Set bit 1 to enable the A20
    or al, 0b10
    
    ; Write back the output byte
    xchg ah, al
    call .wait_8042_input_ready
    
    mov al, 0xD1
    out 0x64, al
    call .wait_8042_input_ready

    xchg al, ah
    out 0x60, al

    ; A20 should now be enabled
    jmp .A20_enabled


.wait_8042_input_ready:
    pushf
    push ax
.wait_8042_input_loop:
    ; Spin until bit 1 from port 0x64 is clear
    in al,0x64
    and al,0b10
    jnz .wait_8042_input_loop
    pop ax
    popf
    ret

.wait_8042_output_ready:
    pushf
    push ax
.wait_8042_output_loop:
    ; Spin until bit 0 is set
    in al,0x64
    and al,0b1
    jz .wait_8042_output_loop
    pop ax
    popf
    ret

.A20_enabled:
    pop ax
    popf
    ret


; Checks if the A20 pin is enabled
; Return: Carry flag set if A20 is enabled, Not set if disabled
; Trashed: A word at address 0x1XXXX if the A20 is enabled
; (I.E. Call this function before you load anything above 0x10000)

Check_A20:
    pushf
    push ds
    push ax

    ; Check for if A20 is enabled by writing a value at (effective) address X and then shifting address X + 0x10000
    ; If the value at address X gets changed, then the A20 line is disabled (Address X + 0x10000 wrapped around)
    ; Otherwise, the A20 is enabled

    ; Write the value at address X
    ; xor ax,ax
    ; mov ds,ax
    ; mov [ds:test_value],word 0x5555

    ; Shift the value at address X + 0x10000
    ; mov ax,0xFFFF
    ; mov ds,ax
    ; shl word [ds:(test_value+0x10)],1

    mov ax,0xFFFF
    mov ds,ax
    mov [ds:(test_value+0x10)], word 0x5555

    xor ax,ax
    mov ds,ax
    shl word [ds:test_value],1


    ; If the value at address X changed, then the A20 is disabled
    xor ax,ax
    mov ds,ax
    cmp word [ds:test_value],0x5555
    jne .disabled

.enabled:
    pop ax
    pop ds
    popf
    stc
    ret

.disabled:
    pop ax
    pop ds
    popf
    clc
    ret   

SECTION .boot.data
test_value: dw 0