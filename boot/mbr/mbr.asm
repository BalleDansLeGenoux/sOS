;---------------------------------------------;
;                                             ;
;                  -- MBR --                  ;
;                                             ;
;---------------------------------------------;

[ORG 0x7C00]                      ; Set the starting address to 0x7C00 (where BIOS loads the MBR)
[BITS 16]                         ; Use 16-bit instructions (real mode)

mbr_start:
    mov [BOOT_DRIVE], dl          ; Save the BIOS boot drive number into BOOT_DRIVE

    ; Initialize all segment registers and stack
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00                ; Set stack pointer just below the MBR

    call enable_a20               ; Enable A20 line to access memory above 1MB

    mov si, MBR_MSG
    call print16                  ; Display welcome message "[MBR]"

    call find_bootable_partition  ; Find the first bootable partition

    cmp ax, 0x00
    je no_bootable_found          ; If no bootable partition found, jump to error handler

    mov bx, VBR_ADDR
    call disk_load_lba

    mov dl, [BOOT_DRIVE]          ; Pass the boot drive number to the next stage

    jmp VBR_ADDR                  ; Jump to the loaded VBR (Volume Boot Record) at 0x1000

no_bootable_found:
    mov si, NO_BOOTABLE_PARTITION
    call print16                  ; Display error message if no bootable partition is found
    jmp $                         ; Infinite loop (halt the system)

; Include necessary utilities
%include "boot/utils/display16.asm"
%include "boot/utils/disk_loader_lba.asm"
%include "boot/mbr/enable_a20.asm"
%include "boot/mbr/find_bootable_partition.asm"

; ---------------------------------------
; Data Section
; ---------------------------------------

BOOT_DRIVE: db 0                  ; Variable to store the boot drive number
VBR_ADDR equ 0x1000               ; Address where VBR (second stage) will be loaded

MBR_MSG: db "[MBR]", ENDL, 0      ; Welcome message string
NO_BOOTABLE_PARTITION: db "No bootable partition found !", ENDL, 0  ; Error message

times 0x01BE - ($-$$) db 0        ; Pad with zeros up to 0x01BE (partition table starts)

; ---------------------------------------
; Partition table
; ---------------------------------------

    ; Partition Entry 1
    db 0x80                       ; Bootable flag (0x80 = active partition)
    db 0xFF, 0xFF, 0xFF           ; CHS address of first absolute sector (ignored)
    db 0x0B                       ; Partition type (0x0B = FAT32 CHS)
    db 0xFF, 0xFF, 0xFF           ; CHS address of last absolute sector (ignored)
    dd 20                         ; LBA of first sector (partition starts at sector 20)
    dd 131072                     ; Number of sectors in partition (64MB)

    times 3*16 db 0               ; Remaining 3 partition entries (empty)

times 510 - ($-$$) db 0           ; Pad with zeros up to 510 bytes

dw 0xAA55                         ; Boot sector signature (required by BIOS)