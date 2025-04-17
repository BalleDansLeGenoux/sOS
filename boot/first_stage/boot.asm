;---------------------------------------------;
;                                             ;
;     -- First stage of the bootloader --     ;
;                                             ;
;---------------------------------------------;

[ORG 0x7C00]                           ; Set the starting address of this code to 0x7C00 (bootloader address in memory).
[BITS 16]                              ; Code is written for 16-bit mode (real mode).

start:
    mov [BOOT_DRIVE], dl               ; Save the current boot drive from the BIOS into the BOOT_DRIVE variable.

    ; Clear registers to initialize the system.
    xor ax, ax                         ; Clear the AX register.
    mov ds, ax                         ; Set DS to zero.
    mov es, ax                         ; Set ES to zero.
    mov ss, ax                         ; Set SS (stack segment) to zero.
    mov sp, 0x7C00                     ; Set stack pointer (SP) to just below the bootloader's address, 0x7C00.

    call enable_a20                    ; Call a function to enable A20 (to access memory beyond 1MB).

    mov si, WELLCOME_MSG               ; Load the address of the welcome message into SI.
    call print16                       ; Print the welcome message.

    mov si, LOADING_MSG                ; Load the address of the loading message into SI.
    call print16                       ; Print the loading message for the second stage.

    ; Load the second stage of the bootloader from disk.
    mov bx, SECOND_BOOT_ADDR           ; Load the address where the second stage will be loaded (0x1000).
    mov cl, 0x02                       ; Set the disk sector (where the second bootloader is located).
    mov dh, 2                          ; Set the number of sectors to read (2 sectors).
    mov dl, [BOOT_DRIVE]               ; Load the disk from which the second stage is being read (saved earlier).
    call disk_load                     ; Call a function to load the second stage of the bootloader from disk.

    mov si, SUCCESS_MSG                ; Load the address of the success message into SI.
    call print16                       ; Print the success message.

    mov dl, [BOOT_DRIVE]               ; Send the boot drive information to the second stage of the bootloader.
    
    jmp SECOND_BOOT_ADDR               ; Jump to the address of the second bootloader (0x1000).


%include "boot/display16.asm"
%include "boot/disk_loader.asm"
%include "boot/first_stage/enable_a20.asm"

BOOT_DRIVE: db 0
SECOND_BOOT_ADDR equ 0x1000

WELLCOME_MSG: db "[FIRST STAGE BOOTLOADER]", ENDL, 0
LOADING_MSG: db " Loading second stage ...", ENDL, 0
SUCCESS_MSG: db " Success to load second stage !", ENDL, 0

times 510 - ($-$$) db 0
dw 0xAA55