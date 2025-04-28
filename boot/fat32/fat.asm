;---------------------------------------------;
;                                             ;
;                  -- FAT --                  ;
;                                             ;
;---------------------------------------------;

dd 0x0FFFFFF8    ; Cluster 0 - Media descriptor (F8) + FAT32 end of chain
dd 0x0FFFFFFF    ; Cluster 1 - Reserved
dd 0x0FFFFFF8    ; Cluster 2 - Libre (root directory)

; Then, fill all of the fat with 0x00000000

times (512 * 128 - 3*4) db 0   ; (128 sectors, 512 bytes/sector, - 12 bytes used)

