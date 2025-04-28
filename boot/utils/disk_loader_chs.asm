; disk_load_chs :
;
; Loads sectors from disk using BIOS interrupt 0x13 (function 0x02).
; Expects:
;   - DL: drive number (e.g., 0x00 for floppy, 0x80 for HDD)
;   - DH: number of sectors to read
;   - ES:BX: memory destination for the read data (must be set before calling)
;
; This function attempts to read sectors starting from cylinder 0, head 0, sector 1.
; If the read fails (carry flag set), or if fewer sectors are read than requested,
; it prints an error message and halts in an infinite loop.

disk_load_chs:
    push dx                            ; Save DX (DH = num sectors, DL = drive number)

    mov ah, 0x02                       ; BIOS function 0x02: Read sectors from disk
    mov al, dh                         ; AL = number of sectors to read
    mov ch, 0x00                       ; CH = cylinder number (0)
    mov dh, 0x00                       ; DH = head number (0)

    int 0x13                           ; Call BIOS interrupt to read from disk
    jc .disk_error                     ; Jump if carry flag is set (read failed)

    pop dx                             ; Restore DX (DH = original sector count)
    cmp al, dh                         ; Check if the BIOS read the expected number of sectors
    jne .sectors_error                 ; If not, show an error message
    ret                                ; Return successfully

.disk_error:
    mov si, DISK_ERROR                 ; Load error message address into SI
    call print16                       ; Print "Disk read error"
    jmp .loop                          ; Infinite loop to halt execution

.sectors_error:
    mov si, SECTORS_ERROR              ; Load sector mismatch error message
    call print16                       ; Print "Incorrect number of sectors read"

.loop:
    jmp $                              ; Infinite loop (halt)


DISK_ERROR: db "Disk read error", ENDL, 0
SECTORS_ERROR: db "Incorrect number of sectors read", ENDL, 0