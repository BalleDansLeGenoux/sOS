[ORG 0x2000]
[BITS 16]

start:
    mov [BOOT_DRIVE], dl
    mov [VBR_ADDR], ax
    mov [VBR_SECTOR], word bx

    mov si, MSG
    call print16
    
    ; Get all usefull values from VBR
    mov bx, [VBR_ADDR]

    mov al, [bx + 0x00D]
    mov [SECTORS_PER_CLUSTER], byte al

    mov ax, [bx + 0x00E]
    mov [RESERVED_SECTORS], word ax

    mov al, [bx + 0x010]
    mov [NUMBER_OF_FAT], byte al

    ; We are in 16-bit mode, so each register (ax, bx, cx, etc.) is 16 bits, 2 bytes.
    ; To copy a 4-byte value, we need to copy the lower 2 bytes first, then the upper 2 bytes.
    ; The same principle applies to values larger than 4 bytes: we copy 2 bytes at a time.
    mov ax, [bx + 0x024]
    mov [SECTORS_PER_FAT], ax
    mov ax, [bx + 0x024 + 2]
    mov [SECTORS_PER_FAT + 2], ax
    
    mov ax, [bx + 0x02C]
    mov [ROOT_CLUSTER], ax
    mov ax, [bx + 0x02C + 2]
    mov [ROOT_CLUSTER + 2], ax

    ; Calculate FAT_SECTOR (VBR_SECTOR + RESERVED_SECTOR + (SECTOR_PER_FAT * NUMBER_OF_FAT))
    mov si, FAT_SECTOR
    mov di, VBR_SECTOR
    call add

    mov si, FAT_SECTOR
    mov di, RESERVED_SECTORS
    call add

    ; Mult SECTOR_PER_FAT * NUMBER_OF_FAT
    mov si, ROOT_CLUSTER_SECTOR
    mov di, SECTORS_PER_FAT
    call add

    mov si, ROOT_CLUSTER_SECTOR
    mov di, NUMBER_OF_FAT
    call mult
    
    mov si, ROOT_CLUSTER_SECTOR
    mov di, FAT_SECTOR
    call add
    
    

    jmp $

VBR_ADDR:   dd 0
BOOT_DRIVE: db 0

VBR_SECTOR:          dd 0
SECTORS_PER_CLUSTER: dd 0
RESERVED_SECTORS:    dd 0
NUMBER_OF_FAT:       dd 0
SECTORS_PER_FAT:     dd 0
ROOT_CLUSTER:        dd 0

FAT_SECTOR:          dd 0
ROOT_CLUSTER_SECTOR: dd 0

%include "boot/maths/add.asm"
%include "boot/maths/mult.asm"
%include "boot/utils/display16.asm"

MSG: db "[PARSER]", ENDL, 0
TEST_MSG: db "OK", ENDL, 0