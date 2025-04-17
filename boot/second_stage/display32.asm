; Text-mode VGA basics:
; In x86 real and protected mode, the VGA text buffer is mapped at memory address 0xB8000.
; This is a 2-byte per character buffer:
;   - First byte: ASCII character to display
;   - Second byte: attribute byte (foreground/background color)
;
; Default mode is 80 columns by 25 rows (80x25), so the full buffer is 80 * 25 * 2 = 4000 bytes.
; Each character cell is laid out as:
;     [char][attr][char][attr]...

%define VIDEO_MEMORY 0xb8000           ; Defines the starting address of the VGA text mode video memory.


print32:
    mov ebx, VIDEO_MEMORY

.loop:
    lodsb                              ; Load next byte from string pointed by ESI into AL
    or al, al                          ; Check for null terminator
    jz .done                           ; If AL is zero, end of string reached

    mov word [ebx], ax                 ; Write character + attribute into video memory
    mov byte [ebx+1], 0x0F             ; Set attribute explicitly: 0x0F -> white on black 
    add ebx, 2                         ; Move to next character cell (2 bytes)
    jmp .loop                          ; Repeat for next character

.done
    ret


clear_screen:
    mov ebx, VIDEO_MEMORY
    mov ecx, 2000                      ; Total characters: 80 columns * 25 rows = 2000 (VGA standards)

clear_loop:
    mov byte [ebx], 0x20               ; Write ASCII space (' ') to current character cell
    mov byte [ebx+1], 0x0F             ; Set attribute: white text on black background
    add ebx, 2                         ; Move to next character cell
    loop clear_loop                    ; Decrement ECX and repeat until zero
    ret