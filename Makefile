#--------------------#
#        Vars        #
#--------------------#

# Directories
SRC_DIR         := src

BOOT_DIR        := boot
MBR_DIR         := $(BOOT_DIR)/mbr
FAT32_DIR       := $(BOOT_DIR)/fat32

KERNEL_DIR      := kernel
LINKER_DIR      := link
BUILD_DIR       := build

# Files
MBR                  := $(MBR_DIR)/mbr.asm
VBR                  := $(FAT32_DIR)/vbr.asm
FS_INFO              := $(FAT32_DIR)/fs_info.asm
FAT                  := $(FAT32_DIR)/fat.asm
KERNEL_C             := $(KERNEL_DIR)/kernel.c
KERNEL_ENTRY_ASM     := $(KERNEL_DIR)/kernel_entry.asm
KERNEL_LINKER_SCRIPT := $(LINKER_DIR)/linker.ld

# Output Files
MBR_BIN         := $(BUILD_DIR)/mbr.bin
VBR_BIN         := $(BUILD_DIR)/vbr.bin
FS_INFO_BIN     := $(BUILD_DIR)/fs_info.bin
FAT_BIN         := $(BUILD_DIR)/fat.bin
KERNEL_O        := $(BUILD_DIR)/kernel.o
KERNEL_ENTRY_O  := $(BUILD_DIR)/kernel_entry.o
KERNEL_BIN      := $(BUILD_DIR)/kernel.bin
DISK_IMG        := $(BUILD_DIR)/disk.img

#--------------------#
#        Main        #
#--------------------#

all: clean $(DISK_IMG)

run: all
	qemu-system-x86_64 -drive file=$(DISK_IMG),format=raw

debug: all
	qemu-system-x86_64 -drive file=$(DISK_IMG),format=raw -d int,guest_errors -no-reboot -serial file:debug.log > output.log 2>&1

#----------------------#
#      Bootloader      #
#----------------------#

$(MBR_BIN): $(MBR) | $(BUILD_DIR)
	nasm -f bin $< -o $@

$(VBR_BIN): $(VBR) | $(BUILD_DIR)
	nasm -f bin $< -o $@

$(FS_INFO_BIN): $(FS_INFO) | $(BUILD_DIR)
	nasm -f bin $< -o $@

$(FAT_BIN): $(FAT) | $(BUILD_DIR)
	nasm -f bin $< -o $@

#----------------------#
#        Kernel        #
#----------------------#

$(KERNEL_O): $(KERNEL_C) | $(BUILD_DIR)
	i686-elf-gcc -nostdlib -nostdinc -ffreestanding -c $< -o $@

$(KERNEL_ENTRY_O): $(KERNEL_ENTRY_ASM) | $(BUILD_DIR)
	nasm -f elf $< -o $@

$(KERNEL_BIN): $(KERNEL_ENTRY_O) $(KERNEL_O) | $(BUILD_DIR)
	i686-elf-ld -T $(KERNEL_LINKER_SCRIPT) -o $@ $^ --oformat binary

#---------------------#
#        Image        #
#---------------------#

$(DISK_IMG): $(MBR_BIN) $(VBR_BIN) $(FS_INFO_BIN) $(FAT_BIN) $(KERNEL_BIN)
	dd if=/dev/zero of=$@ bs=512 count=200000
	dd if=$(MBR_BIN) of=$@ conv=notrunc bs=512 seek=0
	dd if=$(MBR_BIN) of=$@ conv=notrunc bs=512 seek=2
	dd if=$(VBR_BIN) of=$@ conv=notrunc bs=512 seek=20
	dd if=$(FS_INFO_BIN) of=$@ conv=notrunc bs=512 seek=21
	dd if=$(VBR_BIN) of=$@ conv=notrunc bs=512 seek=26
	dd if=$(FS_INFO_BIN) of=$@ conv=notrunc bs=512 seek=27
	dd if=$(FAT_BIN) of=$@ conv=notrunc bs=512 seek=52
	dd if=$(FAT_BIN) of=$@ conv=notrunc bs=512 seek=180

	sudo sh -c '\
		LOOPDEV=$$(losetup -fP --show $@); \
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
	rm -rf $(BUILD_DIR)/*

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)
