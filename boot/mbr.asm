;---------------------------------------------;
;                                             ;
;                  -- MBR --                  ;
;                                             ;
;---------------------------------------------;

[ORG 0x7C00]                            ; Set the starting address of this code to 0x7C00 (bootloader address in memory).
[BITS 16]                               ; Code is written for 16-bit mode (real mode).

start:
    mov  [BOOT_DRIVE], dl               ; Save the current boot drive from the BIOS into the BOOT_DRIVE variable.

    ; Clear registers to initialize the system.
    xor  ax, ax                         ; Clear the AX register.
    mov  ds, ax                         ; Set DS to zero.
    mov  es, ax                         ; Set ES to zero.
    mov  ss, ax                         ; Set SS (stack segment) to zero.
    mov  sp, 0x7C00                     ; Set stack pointer (SP) to just below the bootloader's address, 0x7C00.

    call enable_a20                     ; Call a function to enable A20 (to access memory beyond 1MB).

    mov  si, WELLCOME_MSG               ; Load the address of the welcome message into SI.
    call print16                        ; Print the welcome message.

    call find_bootable_partition

    cmp  ax, 0x00
    je   no_bootable_found


    ; Load the VBR from disk.
    mov  bx, SECOND_BOOT_ADDR           ; Load the address where the VBR will be loaded (0x1000).
    mov  cl, al                         ; Set the disk sector (where the VBR is located).
    mov  dh, 1                          ; Set the number of sectors to read (1 sectors).
    mov  dl, [BOOT_DRIVE]               ; Load the disk from which the VBR is being read (saved earlier).
    call disk_load                      ; Call a function to load the VBR from disk.

    mov  dl, [BOOT_DRIVE]               ; Send the boot drive information to the VBR.
    
    jmp SECOND_BOOT_ADDR                ; Jump to the address of the second bootloader (0x1000).

no_bootable_found:
    mov  si, NO_BOOTABLE_PARTITION
    call print16
    jmp  $

%include "boot/display16.asm"
%include "boot/disk_loader.asm"
%include "boot/enable_a20.asm"
%include "boot/find_bootable_partition.asm"

BOOT_DRIVE: db 0
SECOND_BOOT_ADDR equ 0x1000

WELLCOME_MSG: db "[MBR]", ENDL, 0
NO_BOOTABLE_PARTITION: db "No bootable partition found !", ENDL, 0

times 0x01BE - ($-$$) db 0   ; Fill until partitions table (0x01BE -> 446)

; Partition table (1 FAT32 start at sector 20)
; Each entry is 16 bytes
; This is 1 FAT32 partition and 3 void

    ; Partition 1
    db 0x80              ; Bootable
    db 0xFF, 0xFF, 0xFF  ; CHS start (random values)
    db 0x0B              ; Type FAT32 CHS (0x0C for FAT32 LBA)
    db 0xFF, 0xFF, 0xFF  ; CHS end (random values)
    dd 20                ; start LBA (sector 20)
    dd 100000            ; Size (in sectors)

    times 3*16 db 0      ; 3 others are void

times 0x01FE - ($-$$) db 0 ; 0x01FE -> 510
dw 0xAA55                  ; Boot signature