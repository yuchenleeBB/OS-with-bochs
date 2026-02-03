; loader
LOADER_START_SECTOR  equ 1
LOADER_SECTOR_COUNT  equ 4
LOADER_BASE_ADDR     equ 0x0800
LOADER_STACK_TOP     equ LOADER_BASE_ADDR
LOADER_START_ADDR    equ LOADER_BASE_ADDR + 0x200 ;512 bytes offset for GDT

; ============================
; GDT
; ============================
; %1 : base address
; %2 : limit
; %3 : attributes
%macro DESCRIPTOR 3
    dw %2 & 0xFFFF             ; Limit Low
    dw %1 & 0xFFFF             ; Base Low
    db (%1 >> 16) & 0xFF       ; Base Middle
    dw ((%2 >> 8)& 0x0f00) | ((%3 >> 8) & 0xf0ff) ; Access Byte and Limit High
    db (%1 >> 24) & 0xFF        ; Base High
%endmacro

; ============================
; GDT Attributes
; ============================
GDT_G_1      equ (0x0 << 23)    ; Granularity: 1 byte
GDT_G_4K     equ (0x1 << 23)    ; Granularity: 4 KB
GDT_D_16     equ (0x0 << 22)    ; Default operation size: 16 bit
GDT_D_32     equ (0x1 << 22)    ; Default operation size: 32 bit
GDT_L_32      equ (0x0 << 21)    ; 32-bit code segment
GDT_L_64      equ (0x1 << 21)    ; 64-bit code segment
GDT_AVL_0        equ (0x0 << 20)    ; Not available for system use
GDT_AVL_1        equ (0x1 << 20)    ; Available for system use
GDT_P_0        equ (0x0 << 15)    ; Segment not present
GDT_P_1        equ (0x1 << 15)    ; Segment present
GDT_DPL_0     equ (0x0 << 13)    
GDT_DPL_1     equ (0x1 << 13)    
GDT_DPL_2     equ (0x2 << 13)   
GDT_DPL_3     equ (0x3 << 13)    
GDT_S_HW   equ (0x0 << 12)    ; Descriptor type: Hardware segment
GDT_S_SW   equ (0x1 << 12)    ; Descriptor type: Software segment
GDT_TYPE_CODE equ 0x8
GDT_TYPE_DATA equ 0x2

; ============================
; GDT Selector Attributes
; ============================
TI_GDT   equ (0x0 << 2)
TI_LDT   equ (0x1 << 2) 
RPL_0    equ 0x0
RPL_1    equ 0x1
RPL_2    equ 0x2
RPL_3    equ 0x3