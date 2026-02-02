%include "boot.inc"
section mbr vstart=0x7C00

; init segment registers
    mov ax, 0x0000
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax

; set mbr stack pointer
    mov sp, 0x8000

; get current cursor
    mov ah, 0x03
    mov bh, 0x00
    int 0x10

; print log
    mov bp, message
    mov ah, 0x13
    mov al, 0x01
    mov bh, 0x00
    mov bl, 0x02
    mov cx, 0x5
    int 0x10

; load loader from disk
    mov eax, LOADER_START_SECTOR
    mov bx, LOADER_BASE_ADDR
    mov cl, LOADER_SECTOR_COUNT
    call read_hard_disk

; jump to loader
    jmp LOADER_START_ADDR


; read hard disk function
; eax: lba sector
; ebx: RAM address
;  cl: sector count
read_hard_disk:
    ; set sector count
    mov esi, eax ;backup lba sector
    mov dx, 0x1f2  ;port 
    mov al, cl
    out dx, al
    mov eax, esi

    ; set lba28 sector
    ; LBA[7:0]
    mov dx, 0x1f3
    out dx, al

    ; LBA[15:8]
    shr eax, 8
    mov dx, 0x1f4
    out dx, al

    ; LBA[23:16]
    shr eax, 8
    mov dx, 0x1f5
    out dx, al

    ; LBA[27:24] and drive/head
    shr eax, 8
    and al, 0x0f
    or al, 0xe0 ; 1110
    mov dx, 0x1f6
    out dx, al

    ; start read 
    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; wait for read to complete
    polling:
        nop
        in al, dx
        and al, 0x88
        cmp al, 0x08
        jnz polling

    ; read data
    mov al, cl     ;sector count * 512(bytes) / 2(bytes)
    mov dx, 256
    mul dx

    mov cx, ax   ;total word count
    mov dx, 0x1f0  ;data port
    read:
        in ax, dx
        mov [bx], ax
        add bx, 2
        loop read

    ret

; data
    message db "1 MBR"
    times 510-($-$$) db 0
    db 0x55, 0xAA
