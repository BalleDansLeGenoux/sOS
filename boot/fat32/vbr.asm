;---------------------------------------------;
;                                             ;
;                  -- VBR --                  ;
;                                             ;
;---------------------------------------------;

[ORG 0x1000]
[BITS 16]

jmp vbr_start
nop                                 ; <- Important to align at 3 bytes

db "mkfs.fat"                       ; OEM Name (8 bytes)

dw 512                              ; Bytes per sector
db 8                                ; Sectors per cluster
dw 32                               ; Reserved sectors (minimum 32 for FAT32)
db 2                                ; Number of FATs
dw 0                                ; Root entries (0 for FAT32)
dw 0                                ; Small total sectors (0 because > 64k)
db 0xF8                             ; Media descriptor
dw 0                                ; Sectors per FAT (FAT16, not used)

dw 32                               ; Sectors per track (standard)
dw 8                                ; Number of heads (standard)

dd 20                               ; Hidden sectors (lba start partition)
dd 131072                           ; Total sectors (64 MiB)

dd 128                              ; Sectors per FAT
dw 0                                ; Flags
dw 0                                ; FAT version
dd 2                                ; Root cluster (usually cluster 2)
dw 1                                ; FSInfo sector (sector 1)
dw 6                                ; Backup boot sector (sector 6)

times 12 db 0x00                    ; Reserved

db 0x80                             ; Drive number (hard drive)
db 0x00                             ; Reserved
db 0x29                             ; Boot signature
dd 0xD920E511                       ; Volume ID (aléatoire)
db "NO NAME    "                    ; Volume Label (11 bytes)
db "FAT32   "                       ; File system type (8 bytes)

vbr_start:
    mov [BOOT_DRIVE], dl
    
    mov si, VBR_MSG
    call print16

    jmp $

BOOT_DRIVE: db 0x00
KERNEL_ADDR equ 0x3000

%include "boot/utils/display16.asm"
%include "boot/utils/disk_loader_lba.asm"

VBR_MSG: db "[VBR]", ENDL, "TODO : FAT32 parseur to load kernel", ENDL, 0

times 510-($-$$) db 0
dw 0xAA55

