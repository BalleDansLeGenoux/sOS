; Enables the A20 line using port 0x92 (Fast A20 Gate).
; The A20 line must be enabled to access memory above 1MB, which is necessary for protected mode.
; On legacy x86 systems, the A20 line was disabled by default to maintain compatibility with
; real-mode software that expected 20-bit address wraparound (like on the 8086).

enable_a20:
    in  al, 0x92                       ; Read the value of the system control port (port 0x92)
    or  al, 00000010b                  ; Set bit 1 (A20 Gate) to enable the A20 line
    out 0x92, al                       ; Write the modified value back to port 0x92
    ret