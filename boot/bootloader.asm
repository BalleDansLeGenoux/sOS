;--------------------------------------------;
;                                            ;
;        - A simple boot loader ! -          ;
;                                            ;
;--------------------------------------------;

lba_packet:
    db 0x10               ; Size of struct (16 bytes)
    db 0                  ; Reserve
    dw 4                  ; Number of sector to read
    dw KERNEL_ADDR        ; Offset (0x1000)
    dw 0x0000             ; Segment (ES = 0)
    dq 1                  ; LBA = sector 1

ORG 0x7C00
BITS 16

start:
    mov [BOOT_DRIVE], dl

    ; Clear screen
	mov ax, 0003h
	int 10h 

    call enable_a20                    ; Enable A20 to access more than 1MB

    mov si, LOADING_KERNEL_MSG
    call print16

    call load_kernel

    mov si, SUCCESS_LOAD_KERNEL_MSG
    call print16
    
    cli                                ; Disable BIOS interruptions
    
    ; Clear register
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax

    mov sp, 0x7C00                     ; Stack under bootloader

    lgdt [gdt_descriptor]              ; Load GDT

    call switch_to_protected           ; Switch CPU to protected mode (16 bits -> 32 bits)

    jmp code_segment:protected_mode_start      ; Jump to 32 bits code, and change CS to use GDT

load_kernel:
    mov si, LBA_PACKET_ADDR
    mov ah, 0x42
    mov dl, [BOOT_DRIVE]
    int 0x13
    jc .read_failed
    ret
.read_failed:
    mov si, FAILED_LOAD_KERNEL_MSG
    call print16
    jmp $

print16:
    mov ah, 0x0E
.loop:
    lodsb
    cmp al, 0
    je .done
    cmp al, 0x0A
    je .new_line
    int 0x10
    jmp .loop
.new_line:
    mov al, 0x0D
    int 0x10
    mov al, 0x0A
    int 0x10
    jmp .loop
.done:
    ret

switch_to_protected:
    mov eax, cr0
    or  eax, 1
    mov cr0, eax
    ret

enable_a20:
    in  al, 0x92
    or  al, 00000010b
    out 0x92, al
    ret

[BITS 32]

gdt_start:
gdt_null:
    dq 0

gdt_data:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10010010b
    db 11001111b
    db 0x00

gdt_code:
    dw 0xFFFF
    dw 0x0000
    db 0x00
    db 10011010b
    db 11001111b
    db 0x00
gdt_end:

data_segment equ gdt_data - gdt_null
code_segment equ gdt_code - gdt_null

gdt_descriptor:
    dw gdt_end - gdt_start - 1         ; Size GDT
    dd gdt_start                       ; Adress GDT


clear_screen:
    mov ebx, 0xB8000                   ; Address of video memory
    mov ecx, 2000                      ; 80 * 25 = 2000 characters (80 columns, 25 rows)

clear_loop:
    mov byte [ebx], 0x20               ; Place a space (0x20) in the current character
    mov byte [ebx+1], 0x0F             ; White text on black background (0x0F)
    add ebx, 2                         ; Move to the next character (2 bytes per character)
    loop clear_loop                    ; Repeat for 2000 characters
    ret

print32:
	mov ebx, 0xb8000
.loop:
	lodsb
	or al, al
	jz .done
	or eax, 0x0100
	mov word [ebx+320], ax
    mov byte [ebx+1+320], 0x0F
	add ebx, 2
	jmp .loop
.done
    ret

protected_mode_start:
    ; Update segments
    mov ax, data_segment
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov esp, 0x90000                   ; New stack higher in memory

    ; call clear_screen

	mov esi, message
    call print32
    
    jmp KERNEL_ADDR

LBA_PACKET_ADDR equ 0x0600

BOOT_DRIVE: db 0
KERNEL_ADDR equ 0x1000
message db "Bootloader in 32 bits - OK !", 0
LOADING_KERNEL_MSG db "Loading kernel ...", 0x0A, 0
SECTOR_ERROR_KERNEL_MSG db "Sector mismatch !", 0x0A, 0
FAILED_LOAD_KERNEL_MSG db "Failed to read kernel !", 0x0A, 0
SUCCESS_LOAD_KERNEL_MSG db "Success to load kernel !", 0x0A, 0

times 510 - ($-$$) db 0
dw 0xAA55


