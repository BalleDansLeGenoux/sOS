; Browse the partition table to find the find the first bootable partition it found
; Return:
;   ax -> sector (lba) where the first bootable partition start, if no one find, return 0x00

find_bootable_partition:
    mov si, 0x7C00 + 0x01BE   ; SI pointe sur le début de la table des partitions
    mov cx, 0                 ; Partition counter

.loop:
    mov al, [si]              ; Check bootable flag on partition entry
    cmp al, 0x80              ; 0x80 = bootable
    je .found

    add si, 0x10              ; Update to next partition entry
    inc cx

    cmp cx, 4                 ; Maximum 4 partitions
    je .no_find

    jmp .loop

.found:
    mov ax, [si+0x08]         ; Return value at offset 8 on current partition entry (LBA start address)
    ret

.no_find:
    xor ax, ax                ; Not find, return 0
    ret
