SECTION .boot.text
bits 16

%include "includes.asm"

; Gets information about the current video mode and stores it at es:di
; NB: es:di should probably be 256 byte aligned.
; Returns: es:di => 256 byte record about the current video mode

Get_Current_Video_Mode:
    pushf
    push ax
    push bx
    push cx

    ; TODO: Get all video info for all display adapters. Could be useful
    ; for multiple screens or something (see int 0x10, AX=4F00)


    ; Get the current video mode id
    mov ax, 0x4F03
    int 0x10    ; int 0x10, AX=4F03 => Get current video mode
    cmp ax,0x004F ; Returns 0x004F in AX on success
    jne .error
    
    ; FIXME: Throws an error code of 1
    ; Video mode returned in bx, but int 0x10, AX=4F01 requires it in cx
    xchg bx,cx
    mov ax,0x4F01

    int 0x10 ; int 0x10, 4F01 => Returns info about the current video mode
    cmp ax,0x004F ; Returns 0x004F in AX on success
    ; jne .error

.exit:
    pop cx
    pop bx
    pop ax  
    popf
    ret

.error:
    ; FIXME: Temporary hack to avoid the error code
    push si
    mov si,.video_error_str
    call print_string
    pop si
    jmp .exit
    ; jmp infinite_halt

SECTION .boot.data
.video_error_str: db `A critical error has occurred finding video information. Halting!`,0