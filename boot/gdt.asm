; Define a basic Global Descriptor Table (GDT) with three entries:
; - A null descriptor (required by Intel architecture)
; - A data segment descriptor
; - A code segment descriptor
;
; The GDT is necessary when entering protected mode, where segmentation is handled
; by the CPU using segment selectors and descriptors rather than real-mode addressing.
;
; Each descriptor defines properties such as base address, segment limit, access rights, and granularity.

gdt_start:

gdt_null:
    dq 0                               ; Null descriptor

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b                       ; Access : data segment, readable, writable
    db 11001111b
    db 0x00

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b                       ; Access : code segment, readable, executable
    db 11001111b
    db 0x00

gdt_end:

data_segment equ gdt_data - gdt_null   ; Offset of the data segment in the GDT
code_segment equ gdt_code - gdt_null   ; Offset of the code segment in the GDT

gdt_descriptor:
    dw gdt_end - gdt_start - 1         ; Size of the GDT
    dd gdt_start                       ; Address of the GDT