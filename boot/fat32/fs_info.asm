;-------------------------------------------------;
;                                                 ;
;                  -- FS INFO --                  ;
;                                                 ;
;-------------------------------------------------;

dd 0x41615252    ; first signature
times 480 db 0   ; fill with 0
dd 0x61417272    ; second signature
dd 0xFFFFFFFF    ; number of free cluster (OS will recalculate them when it mount to cp kernel into image)
dd 0xFFFFFFFF    ; next free cluster      (OS will recalculate them when it mount to cp kernel into image)
times 12 db 0    ; reserved
dd 0xAA550000    ; boot signature