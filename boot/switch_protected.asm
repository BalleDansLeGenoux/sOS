; Switches the CPU from real mode to protected mode by setting the PE (Protection Enable) bit in CR0.
; This is a critical step in entering protected mode, where segmentation and memory protection features are enabled.
;
; Note: This must be done after setting up a valid GDT and before executing protected mode code.

switch_to_protected:
    mov eax, cr0         ; Load the current value of control register CR0 into EAX
    or  eax, 1           ; Set the PE bit (bit 0) to enable protected mode
    mov cr0, eax         ; Write the modified value back to CR0
    ret