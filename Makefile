all: bin/os.img
	qemu-system-x86_64 -drive format=raw,file=bin/os.img

bin/os.img: bin/boot.bin bin/kernel.bin
	dd if=bin/boot.bin of=bin/os.img bs=512 count=1
	dd if=bin/kernel.bin of=bin/os.img bs=512 seek=1

bin/boot.bin: boot/bootloader.asm
	nasm -f bin boot/bootloader.asm -o bin/boot.bin

bin/kernel.bin: kernel/kernel.c
	i686-elf-gcc -ffreestanding -m32 -c kernel/kernel.c -o bin/kernel.o
	i686-elf-ld -T link/linker.ld bin/kernel.o -o bin/kernel.bin

clean:
	rm -rf bin/*


