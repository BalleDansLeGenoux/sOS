#--------------------#
#        Vars        #
#--------------------#

# Directories
SRC_DIR         := src
BOOT_DIR        := boot
KERNEL_DIR      := kernel
LINKER_DIR      := link
BIN_DIR         := bin

# Files
BOOT_FIRST_STAGE     := $(BOOT_DIR)/first_stage/boot.asm
BOOT_SECOND_STAGE    := $(BOOT_DIR)/second_stage/second_boot.asm
KERNEL_C             := $(KERNEL_DIR)/kernel.c
KERNEL_ENTRY_ASM     := $(KERNEL_DIR)/kernel_entry.asm
KERNEL_LINKER_SCRIPT := $(LINKER_DIR)/linker.ld

# Output Files
BOOT_BIN        := $(BIN_DIR)/boot.bin
SECOND_BOOT_BIN := $(BIN_DIR)/second_boot.bin
KERNEL_O        := $(BIN_DIR)/kernel.o
KERNEL_ENTRY_O  := $(BIN_DIR)/kernel_entry.o
KERNEL_BIN      := $(BIN_DIR)/kernel.bin
DISK_IMG        := $(BIN_DIR)/disk.img

#--------------------#
#        Main        #
#--------------------#

all: clean $(DISK_IMG)

run: all
	qemu-system-x86_64 -drive file=$(DISK_IMG),format=raw,if=floppy

debug: all
	qemu-system-x86_64 -drive file=$(DISK_IMG),format=raw,if=floppy -d int,guest_errors -no-reboot

#----------------------#
#      Bootloader      #
#----------------------#

$(BOOT_BIN): $(BOOT_FIRST_STAGE) | $(BIN_DIR)
	nasm -f bin $< -o $@

$(SECOND_BOOT_BIN): $(BOOT_SECOND_STAGE) | $(BIN_DIR)
	nasm -f bin $< -o $@

#----------------------#
#        Kernel        #
#----------------------#

$(KERNEL_O): $(KERNEL_C) | $(BIN_DIR)
	i686-elf-gcc -nostdlib -nostdinc -ffreestanding -c $< -o $@

$(KERNEL_ENTRY_O): $(KERNEL_ENTRY_ASM) | $(BIN_DIR)
	nasm -f elf $< -o $@

$(KERNEL_BIN): $(KERNEL_ENTRY_O) $(KERNEL_O) | $(BIN_DIR)
	i686-elf-ld -T $(KERNEL_LINKER_SCRIPT) -o $@ $^ --oformat binary

#---------------------#
#        Image        #
#---------------------#

$(DISK_IMG): $(BOOT_BIN) $(SECOND_BOOT_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$@ bs=512 count=131072
	dd if=$(BOOT_BIN) of=$@ conv=notrunc bs=512 seek=0
	dd if=$(SECOND_BOOT_BIN) of=$@ conv=notrunc bs=512 seek=1

	sudo sh -c '\
		LOOPDEV=$$(losetup -fP --show $@); \
		echo "Using $$LOOPDEV"; \
		mkfs.fat -F 32 $${LOOPDEV}p1; \
		mkdir -p /mnt/tmp; \
		mount $${LOOPDEV}p1 /mnt/tmp; \
		cp $(KERNEL_BIN) /mnt/tmp; \
		umount /mnt/tmp; \
		losetup -d $${LOOPDEV}; \
	'

# LOOPDEV=$$(losetup -fP --show $@)      -> Map the disk image to the next available loop device and store the device name in LOOPDEV
# echo "Using $$LOOPDEV"                 -> Print the name of the loop device being used
# mkfs.fat -F 32 $${LOOPDEV}p1           -> Format the first partition as FAT32
# mkdir -p /mnt/tmp                      -> Create a temporary directory to mount the loop device
# mount $${LOOPDEV}p1 /mnt/tmp           -> Mount the first partition of the loop device
# cp $(KERNEL_BIN) /mnt/tmp              -> Copy the kernel binary to the mounted partition
# umount /mnt/tmp                        -> Unmount the partition
# losetup -d $${LOOPDEV}                 -> Detach the loop device


#---------------------#
#        Other        #
#---------------------#

clean:
	rm -rf $(BIN_DIR)/*

$(BIN_DIR):
	mkdir -p $(BIN_DIR)
