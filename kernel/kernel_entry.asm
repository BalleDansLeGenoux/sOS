; Entry point after switching to 32-bit protected mode.
; Calls the external kernel initialization function (`initKernel`),
; then halts execution with an infinite loop.
;
; Assumes:
;   - GDT and segment registers are already properly set up.
;   - Paging is disabled (or identity mapped if enabled).
;   - A flat memory model is in place (CS, DS, ES, etc., covering full 4 GB).
;
; initKernel is defined in C or assembly and linked externally.

[BITS 32]                   ; Assemble this in 32-bit mode (protected mode)

[EXTERN kernel]         ; Declare an external function symbol (linked later)

call kernel             ; Call the kernel's main function (or kernel entry point)

jmp $                       ; Infinite loop (halt here forever)
                            ; Prevents returning to invalid address or undefined behavior
