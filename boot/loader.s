%include "boot.inc"
section loader vstart=LOADER_BASE_ADDR

; ====================
; GDT setup
; ====================
;                       base          limit         attributes
gdt_base:  DESCRIPTOR   0x00000000,   0x00000000,   0x00  ; Null segment
code_desc: DESCRIPTOR   0x00000000,   0x000FFFFF,   GDT_G_4K \
                                                + GDT_D_32 \
                                                + GDT_L_32 \
                                                + GDT_AVL_0 \
                                                + GDT_P_1 \
                                                + GDT_DPL_0 \
                                                + GDT_S_SW \
                                                + GDT_TYPE_CODE
data_desc: DESCRIPTOR   0x00000000,   0x000FFFFF,   GDT_G_4K \
                                                + GDT_D_32 \
                                                + GDT_L_32 \
                                                + GDT_AVL_0 \
                                                + GDT_P_1 \
                                                + GDT_DPL_0 \
                                                + GDT_S_SW \
                                                + GDT_TYPE_DATA
video_desc: DESCRIPTOR  0x000B8000,  0x00007FFF,   GDT_G_1 \
                                                + GDT_D_32 \
                                                + GDT_L_32 \
                                                + GDT_AVL_0 \
                                                + GDT_P_1 \
                                                + GDT_DPL_0 \
                                                + GDT_S_SW \
                                                + GDT_TYPE_DATA

GDT_SIZE equ $ - gdt_base
GDT_LIMIT equ GDT_SIZE - 1
times 256-($ - $$) db 0 ; pad GDT to 256 bytes

; ====================
; GDT selectors
; ====================
SELECTOR_CODE equ (code_desc - gdt_base) + TI_GDT + RPL_0
SELECTOR_DATA equ (data_desc - gdt_base) + TI_GDT + RPL_0
SELECTOR_VIDEO equ (video_desc - gdt_base) + TI_GDT + RPL_0

times 512 - ($ - $$) db 0 ; pad to 512 bytes
loader_start:   
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
    add dh, 1
    mov dl, 0
    int 0x10

; enable protected mode A20
    in al, 0x92
    or al, 00000010b
    out 0x92, al

; load GDT
    lgdt [gdtr]

; protected mode switch
    mov eax, cr0
    or eax, 0x00000001
    mov cr0, eax

    jmp SELECTOR_CODE:protected_mode_start

[bits 32]
protected_mode_start:
    ; update segment registers
    mov ax, SELECTOR_DATA
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, LOADER_STACK_TOP

    ; pause 
        jmp $


    message db "2 Loader"
    gdtr    dw GDT_LIMIT  ;[15:0] limit
            dd gdt_base   ;[47:16] base address of GDT
