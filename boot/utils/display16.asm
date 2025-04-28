; print16:
; Prints a null-terminated string using BIOS interrupt 0x10, function 0x0E (teletype output).
; This runs in real mode and prints characters to the screen using the BIOS TTY service.
;
; Each character is printed at the current cursor position, which is automatically updated.
; Newlines can be inserted using carriage return and line feed: 0x0D, 0x0A.
;
; Input:
;   - ESI: string to print
;   - Characters are printed in the current active text mode (usually 80x25 VGA text).

%define ENDL 0x0D, 0x0A     ; ENDL is a macro for move the cursor to the next line

print16:
    mov ah, 0x0E            ; BIOS TTY function: print character

.loop:
    lodsb                   ; Load next byte from [ESI] into AL, and increment ESI
    or  al, al              ; Check for null terminator (AL == 0)
    jz  .done               ; If zero, end of string reached
    int 0x10                ; Call BIOS interrupt to print character in AL
    jmp .loop               ; Repeat for next character

.done:
    ret