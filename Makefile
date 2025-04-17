#--------------------#
#        Main        #
#--------------------#

all: clean bin/floppy.img

run: all
	qemu-system-x86_64 -drive file=bin/floppy.img,format=raw,if=floppy

debug: all
	qemu-system-x86_64 -m 128 -drive format=raw,file=bin/floppy.img -M pc -d int,guest_errors -no-reboot


#----------------------#
#      Bootloader      #
#----------------------#

bin/boot.bin: boot/first_stage/boot.asm | bin
	nasm -f bin $< -o $@

bin/second_boot.bin: boot/second_stage/second_boot.asm | bin
	nasm -f bin $< -o $@


#-------------------------------------#
#        Kernel + Second stage        #
#-------------------------------------#

bin/kernel.o: kernel/kernel.c | bin
	i686-elf-gcc -nostdlib -nostdinc -ffreestanding -c $< -o $@

bin/kernel_entry.o: kernel/kernel_entry.asm | bin
	nasm -f elf $< -o $@

bin/kernel.bin: bin/kernel_entry.o bin/kernel.o | bin
	i686-elf-ld -T link/linker.ld -o $@ $^ --oformat binary


#---------------------#
#        Image        #
#---------------------#

bin/floppy.img: bin/boot.bin bin/second_boot.bin bin/kernel.bin
	dd if=/dev/zero of=$@ bs=512 count=2880

	dd if=bin/boot.bin of=$@ conv=notrunc bs=512 seek=0

	dd if=bin/second_boot.bin of=$@ conv=notrunc bs=512 seek=1

	dd if=bin/kernel.bin of=$@ conv=notrunc bs=512 seek=2


#---------------------#
#        Other        #
#---------------------#

clean:
	rm -rf bin/*

bin:
	mkdir -p bin