# sOS: An OS Development Project

sOS is an operating system development project to help me learn the fundamentals of low-level programming.

## Introduction

The goal of this project is to understand the basics of operating system development by creating a bootloader and switching to protected mode, using low-level techniques. The project is written in Assembly and low-level C.

## Objectives

- Develop a simple bootloader in Assembly.
- Switch the processor to protected mode and use memory in a more modern way.
- Create a minimal kernel that will run after the bootloader.

## 1. Creating the Bootloader

The bootloader is the first code that runs when a PC starts. For this project, I chose a 1.44 MB floppy image. This simplifies the handling, even though it has a fixed size and no partitioning.

### The Boot Process

When the PC starts, the BIOS (or UEFI, if more modern) is the first to run. It reads the first sector of each disk (sector 0), and if it contains the signature `0xAA55` at the end, it loads that sector into memory at address `0x7C00`. This sector is our bootloader (512 bytes).

The bootloader first enables the A20 line at port `0x92`, which allows access to more than 1 MB of memory, a limitation of early processors (16-bit mode).

### Disk Reading

There are two methods to read from a disk:
- **CHS (Cylinder, Head, Sector)**: The older method used for traditional hard drives.
- **LBA (Logical Block Addressing)**: A more modern method, using a linear structure like a 1D array of sectors.

For this project, I chose to use **CHS**. The bootloader then loads the kernel, which is placed right after it on the disk image. The bootloader is 512 bytes (one sector), and the kernel is placed in the next sector (sector 2).

### Switching to Protected Mode

Initially, processors are in **real mode** (16-bit) for compatibility with older systems. To use more than 1 MB of memory and manage memory access, we need to switch to **protected mode**.

We must define a **GDT (Global Descriptor Table)**. The GDT defines memory segments (code, data, stack) with access rights and privilege levels. For this project, I used a "flat" GDT, meaning all segments cover the entire memory and are set to kernel mode (privilege level 0).

### Enabling 32-bit Mode

Before switching to protected mode, we need to **disable interrupts** to prevent interference from the BIOS. Then we load the GDT and enable 32-bit mode by setting the **PE (Protection Enable)** bit in the **CR0** register.

### Handing Control to the Kernel

Once the GDT is loaded, we need to hand control over to the kernel. This is done using a **far jump**. A far jump changes the memory segment and loads a new segment selector into the **CS** register, which is required to use the descriptors defined in the GDT.

Once this step is done, the kernel takes control, and we are running in protected mode, ready to execute more complex code and manage memory in a modern way.

## 2. The kernel

For the kernel, I kept things as simple as possible. The goal was just to show something on the screen to confirm that the kernel is loaded, and then enter an infinite loop. Since BIOS interrupts are disabled, we can’t use the BIOS to print text. A common method in this situation is to use VGA text mode. It’s part of the VGA standard and works well for basic output. So, the kernel clears the screen and displays the message "Welcome in the kernel!", then it loops forever.

## 3. Technical Details

### Interrupt Handling

One of the first steps in the bootloader is to **disable interrupts**. This ensures that our code runs without interference from the BIOS or other systems. Once in protected mode, we can re-enable and manage interrupts ourselves.

### GDT (Global Descriptor Table)

The **GDT** is crucial for running in protected mode. It defines descriptors that specify the limits, access rights, and privilege levels of each memory segment. Once in protected mode, the GDT ensures separation between the kernel's code and user code, while allowing fine-grained control of memory access.

### Transition to a Minimal Kernel

The kernel I created is still very simple. Once in protected mode, the kernel takes over and can begin to handle more complex tasks, such as memory management and process execution.

### VGA text mode

As mentioned earlier, VGA text mode is a standard feature of basic VGA. It’s a simple way to display text on the screen using an 80 by 25 character grid. The displayed text is stored directly in memory at address 0xB8000. The memory layout alternates between character bytes and attribute bytes: [character, attribute, character, attribute, ...]. Each character takes 2 bytes in total — one for the ASCII character and one for its style (text color, background color, etc.). So the whole screen uses 80 x 25 x 2 = 4000 bytes of memory.

## 4. Resources and References

If you want to learn more about the concepts I've used, here are some useful resources:
- [Documentation on BIOS and UEFI](#)
- [Tutorials on GDT and protected mode](#)
- [Assembly tutorials for bootloader development](#)

## Conclusion

This project is still in development. The bootloader and protected mode switch are working, and the kernel takes control after these steps. The next steps will include adding features to the kernel, such as process management, I/O handling, and advanced memory management.


# !!! Will be updated for MBR !!!