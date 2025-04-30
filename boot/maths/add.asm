; --------------------------------------------------------
; add :
;
; Adds two 32-bit integers stored at memory addresses
; pointed by SI and DI respectively.
;
; Expects:
;   - SI: pointer to the first 32-bit value (destination)
;   - DI: pointer to the second 32-bit value (source)
;
; Operation:
;   - Loads the 32-bit value at [SI] into DX:AX
;   - Loads the 32-bit value at [DI] into CX:BX
;   - Adds BX to AX (lower 16 bits)
;   - Adds CX to DX with carry (upper 16 bits)
;   - Stores the result back into [SI] (DX:AX)
;
; Destroys: AX, BX, CX, DX
; --------------------------------------------------------

add:
    mov ax, word [si]         ; Load lower 16 bits from [SI] into AX
    mov dx, word [si + 2]     ; Load upper 16 bits from [SI] into DX

    mov bx, word [di]         ; Load lower 16 bits from [DI] into BX
    mov cx, word [di + 2]     ; Load upper 16 bits from [DI] into CX

    add ax, bx                ; Add lower 16 bits
    adc dx, cx                ; Add upper 16 bits with carry

    mov [si], word ax         ; Store result lower 16 bits back to [SI]
    mov [si + 2], word dx     ; Store result upper 16 bits back to [SI + 2]

    ret
