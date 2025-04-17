;----------------------------------------------;
;                                              ;
;     -- Second stage of the bootloader --     ;
;                                              ;
;----------------------------------------------;

[ORG 0x1000]                           ; Set the code's origin address to 0x1000 (second stage in memory).
[BITS 16]                              ; Define 16-bit mode for this part of the bootloader.

start:
    mov [BOOT_DRIVE], dl               ; Save the disk number (loaded from first stage) into BOOT_DRIVE.

    mov si, SECOND_WELLCOME_MSG        ; Load address of the welcome message.
    call print16                       ; Print the second stage welcome message.

    mov si, LOADING_KERNEL_MSG         ; Load message indicating that the kernel is being loaded.
    call print16

    call disable_bios_cursor           ; Disable the BIOS cursor (set it invisible).

    ; Load the kernel from disk.
    mov bx, KERNEL_ADDR                ; Load address where the kernel will be stored in memory.
    mov cl, 0x03                       ; Disk sector number where the kernel starts.
    mov dh, 2                          ; Number of sectors to read.
    mov dl, [BOOT_DRIVE]               ; Select the disk or image from which to load.
    call disk_load                     ; Load the kernel into memory using BIOS interrupt.

    mov si, SUCCESS_LOAD_KERNEL_MSG    ; Kernel loaded successfully message.
    call print16

    mov si, PRESS_KEY_MSG              ; Wait for a keypress before continuing.
    call print16

.wait_key:
    mov ah, 0x01                       ; BIOS function to wait for a keypress.
    int 0x16                           ; Call BIOS interrupt for keyboard input.
    jz .wait_key                       ; Loop until a key is pressed.

    ; Switch to protected mode (32-bit).
    cli                                ; Disable interrupts (prevents interrupts while switching modes).
    lgdt [gdt_descriptor]              ; Load the Global Descriptor Table (GDT) to set up the memory model.
    call switch_to_protected           ; Switch CPU from real mode (16-bit) to protected mode (32-bit).

    jmp code_segment:protected_mode_start  ; Far jump to the protected mode code (32-bit).



disable_bios_cursor:
    ; Disable the BIOS cursor by setting its start and end position beyond screen bounds.
    mov ah, 0x01                       ; BIOS function to control the cursor.
    mov ch, 0x20                       ; Set start row of the cursor (invisible position).
    mov cl, 0x00                       ; Set end row of the cursor (invisible position).
    int 0x10                           ; BIOS interrupt to disable the cursor.
    ret



[BITS 32]                              ; Switch to 32-bit mode after GDT is loaded.

protected_mode_start:
    ; Update segment registers to point to the new GDT entries.
    mov ax, data_segment
    mov ds, ax                         ; Data segment.
    mov es, ax                         ; Extra segment.
    mov fs, ax                         ; FS segment.
    mov gs, ax                         ; GS segment.
    mov ss, ax                         ; Stack segment.
    mov esp, 0x90000                   ; Set up a new stack pointer in the higher memory region.

    call clear_screen                  ; Clear the screen after switching to protected mode.

    call KERNEL_ADDR                   ; Jump to the loaded kernel's entry point.


BOOT_DRIVE: db 0
KERNEL_ADDR equ 0x3000

%include "boot/display16.asm"
%include "boot/disk_loader.asm"
%include "boot/second_stage/gdt.asm"
%include "boot/second_stage/display32.asm"
%include "boot/second_stage/switch_protected.asm"

SECOND_WELLCOME_MSG: db "[SECOND STAGE BOOTLOADER]", ENDL, 0
LOADING_KERNEL_MSG: db " Loding kernel ...", ENDL, 0
SUCCESS_LOAD_KERNEL_MSG: db " Success to load kernel !", ENDL, 0
PRESS_KEY_MSG: db "Press any key to continue in the kernel ...", ENDL, 0