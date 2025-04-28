; disk_load_lba :
;
; Loads a sector from disk using BIOS interrupt 0x13 (function 0x42, Extended Read).
; Expects:
;   - AX: memory offset where the data should be loaded
;   - BX: 64-bit LBA (Logical Block Address) of the sector to read
;   - DL: drive number (e.g., 0x80 for first hard drive) must be set before calling
;
; This function prepares an LBA packet and uses INT 13h (AH=42h) to perform the read.
; It attempts to read exactly 1 sector into the specified memory address.
; If the read fails (carry flag set), it prints an error message and halts in an infinite loop.


disk_load_lba:
    mov [SECTOR_PACKET], ax       ; Store the address where data will be loaded into memory
    mov [ADDR_PACKET], bx         ; Store the starting LBA address into the LBA packet

    mov si, LBA_PACKET            ; SI points to the LBA packet structure
    mov ah, 0x42                  ; BIOS extended read function
    mov dl, [BOOT_DRIVE]          ; Load boot drive number
    int 0x13
    jc read_error                 ; If BIOS read failed (carry flag set), go to error handler
    ret

read_error:
    mov si, READ_ERROR
    call print16
    jmp $


align 4                           ; Align LBA_PACKET to 4 bytes (required for BIOS)

; LBA Packet structure for INT 13h AH=42h
LBA_PACKET:
    db 0x10                       ; Packet size (16 bytes)
    db 0x00                       ; Reserved (must be zero)
    dw 1                          ; Number of sectors to read (1 sector)
ADDR_PACKET:
    dw 0x1000                     ; Offset where data will be loaded
    dw 0x0000                     ; Segment where data will be loaded
SECTOR_PACKET:
    dq 0x00                       ; 64-bit address (LBA) to read from

READ_ERROR: db "Error: Cannot load from disk (LBA) !", ENDL, 0