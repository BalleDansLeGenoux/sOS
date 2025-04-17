ENTRY(_start)

SECTIONS
{
    . = 0x3000; /* Adresse du noyau en mémoire après le bootloader */

    .text : {
        *(.text)          /* Section pour le code */
    }

    .data : {
        *(.data)          /* Section pour les données initialisées */
    }

    .bss : {
        *(.bss)           /* Section pour les données non initialisées */
    }

    .rodata : {
        *(.rodata)
    }

    /DISCARD/ : {
        *(.note.gnu.build-id)   /* Éliminer les sections inutiles */
        *(.comment)
    }
}