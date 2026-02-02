%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR

; set up the stack
    mov sp, LOADER_STACK_TOP

; get current cursor
    mov ah, 0x03
    mov bh, 0x00
    int 0x10

; print log
    mov bp, message
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0x00
    mov bl, 0x09
    mov cx, 0x08
    int 0x10

; pause 
    jmp $


    message db "2 Loader"