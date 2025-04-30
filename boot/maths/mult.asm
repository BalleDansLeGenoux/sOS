; --------------------------------------------------------
; mult :
;
; Multiplies a 32-bit value by an 8-bit multiplier using
; repeated addition (slow but simple method).
;
; Expects:
;   - SI: pointer to a 32-bit value (source and destination)
;   - DI: pointer to an 8-bit multiplier (e.g., SECTORS_PER_CLUSTER)
;
; Operation:
;   - Loads the 32-bit value at [SI] into DX:AX (initial total)
;   - Also loads the same 32-bit value into CX:BX (value to add)
;   - Reads multiplier from [DI] into DI
;   - Repeats addition (multiplier - 1) times
;   - Result is stored back into [SI] (DX:AX)
;
; Destroys: AX, BX, CX, DX, SI, DI, BP
; Uses stack: pushes/pops SI and DI
; --------------------------------------------------------

mult:
    mov ax, word [si]         ; Load lower 16 bits of value into AX
    mov dx, word [si + 2]     ; Load upper 16 bits into DX

    mov bx, word [si]         ; Duplicate value into BX
    mov cx, word [si + 2]     ; And into CX

    mov bp, di                ; Save pointer to multiplier

    push si                   ; Save SI and DI
    push di

    xor si, si                ; SI = loop counter = 0
    xor di, di                ; Clear DI before use in loop

.loop
    movzx di, byte [bp]       ; Load multiplier (zero-extended)
    dec di                    ; We'll do (multiplier - 1) additions
    cmp si, di                ; Have we done enough?
    je .done

    add ax, bx                ; Add lower 16 bits
    adc dx, cx                ; Add upper 16 bits with carry

    inc si                    ; Next iteration
    jmp .loop

.done
    pop di                    ; Restore DI
    pop si                    ; Restore SI

    mov [si], word ax         ; Store result (low 16 bits)
    mov [si + 2], word dx     ; Store result (high 16 bits)

    ret
