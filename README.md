# - sOS: An OS Development Project -

sOS is an operating system development project to help me learn the fundamentals of low-level programming.

## Introduction

The goal of this project is to understand the basics of operating system development by creating a bootloader and switching to protected mode, using low-level techniques. The project is written in Assembly and low-level C.

## Objectives

* Develop a simple bootloader in Assembly.
* Switch the processor to protected mode and use memory in a more modern way.
* Create a minimal kernel that will run after the bootloader.

## 1. Creating the Bootloader

The bootloader is the first code that runs when a PC starts. For this project, I chose a 1.44 MB floppy image. This simplifies the handling, even though it has a fixed size and no partitioning.

### The Boot Process

When the PC starts, the BIOS (or UEFI, if more modern) is the first to run. It reads the first sector of each disk (sector 0), and if it contains the signature `0xAA55` at the end, it loads that sector into memory at address `0x7C00`. This sector is our bootloader (512 bytes).

The bootloader first enables the A20 line at port `0x92`, which allows access to more than 1 MB of memory, a limitation of early processors (16-bit mode).

### Disk Reading

There are two methods to read from a disk:
* **CHS (Cylinder, Head, Sector)**: The older method used for traditional hard drives.
* **LBA (Logical Block Addressing)**: A more modern method, using a linear structure like a 1D array of sectors.

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

For the kernel, I kept things as simple as possible. The goal was just to show something on the screen to confirm that the kernel is loaded, and then enter an infinite loop. Since BIOS interrupts are disabled, we can’t use the BIOS to print text. A common method in this situation is to use **VGA text mode**. It’s part of the VGA standard and works well for basic output. So, the kernel clears the screen and displays the message "Welcome in the kernel!", then it loops forever.

## 3. Technical Details

### Interrupt Handling

One of the first steps in the bootloader is to **disable interrupts**. This ensures that our code runs without interference from the BIOS or other systems. Once in protected mode, we can re-enable and manage interrupts ourselves.

### GDT (Global Descriptor Table)

The **GDT** is crucial for running in protected mode. It defines descriptors that specify the limits, access rights, and privilege levels of each memory segment. Once in protected mode, the GDT ensures separation between the kernel's code and user code, while allowing fine-grained control of memory access.

### Transition to a Minimal Kernel

The kernel I created is still very simple. Once in protected mode, the kernel takes over and can begin to handle more complex tasks, such as memory management and process execution.

### VGA text mode

As mentioned earlier, VGA text mode is a standard feature of basic VGA. It’s a simple way to display text on the screen using an **80 x 25** character grid. The displayed text is stored directly in memory at address **`0xB8000`**. The memory layout alternates between character bytes and attribute bytes: [character, attribute, character, attribute, ...]. Each character takes 2 bytes in total — one for the ASCII character and one for its style (text color, background color, etc.). So the whole screen uses 80 x 25 x 2 = **4000 bytes** of memory.

## 4. Resources and References

The main reference I used to learn OS development is that web site : [OSDev Wiki](https://wiki.osdev.org/Expanded_Main_Page).

## Conclusion

This project is still in development. The bootloader and protected mode switch are working, and the kernel takes control after these steps. The next steps will include adding features to the kernel, such as process management, I/O handling, and advanced memory management.

# - Transition to a two-stage bootloader

## Why ?

Most modern operating systems use a two-stage bootloader, like GRUB or similar. It's a common and practical design, and fairly easy to implement once you've created a basic single-stage bootloader.

In my current setup, the bootloader consists of only one stage — it directly loads the kernel. However, this approach is limited by the size of the boot sector (512 bytes), which is not enough for more advanced functionality.

To overcome this limitation, instead of loading the kernel directly, the first-stage bootloader loads a second-stage bootloader, which then loads the kernel. The second stage is not restricted to 512 bytes — it can be much larger (limited only by available disk space), allowing it to perform more complex tasks. For example, if we use a hard disk image instead of a floppy, the second stage can read partition tables or access filesystems.

## New structure

### First stage :
* Enable A20 line
* Load the second-stage bootloader into memory using BIOS interrupts
* Jump to the second stage

### Second stage :
* Load the kernel into memory using BIOS interrupts
* Disable hardware interrupts
* Set up the GDT (Global Descriptor Table) and load it
* Switch the CPU to protected mode
* Perform a far jump to the kernel

# - Transition from a floppy image to a disk image -

## Introduction

To make this transition, I had several choices to make. First, I had to decide which partitioning system to use: **MBR** or **GPT**. If I chose GPT, I would need to switch to **UEFI**, as **BIOS** does not support it. Since I want my OS to be compatible with BIOS, I chose MBR. Next, I had to decide which file system to use. For ease, I could have chosen **FAT12** or **FAT16**, but I preferred **FAT32**, so that’s the one I chose. After making these decisions, I began to implement them.

## Objectives
* Change bootloader to make it work with MBR & FAT32
    * Code a MBR in sector 0 of disk in ASM (stage 1)
    * Code a VBR in sector 0 of FAT32 partition in ASM (stage 2)
    * Code a FAT32 parser in ASM and load kernel (stage 3)
* Change makefile to build a disk image instead a floppy image

## New structure

### Frist stage :
* Enable A20 line
* Load VBR of first bootable partition
* Jump on VBR if find
* Define a partition table

### Second stage :

## 1. Modify Bootloader 

### Stage 1 -> MBR

The MBR is code in ASM, still in 

The MBR table partition is on the sector 0 and start at address `0x01BE`, so I define it in the bootloader (stage 1), it allow us to define 4 partitions, I juste define 1 FAT32 partition and let other at 0.

Now I have a partition table with maximum 4 partitions, my code need to work differenty, instead of load a static second stage on disk, it load sector 0 of the first bootable partition it find in partition table, and then, it jump where it's load.

### Stage 2 -> VBR

### Stage 3 -> FAT32 parser to find kernel

## 2. Modify Makefile

The only thing I changed here is how the kernel is stored: instead of writing it to a specific sector on the disk image, I store it in a FAT32 partition.

Since I'm working with a disk image file rather than a physical device, I use a loop device to access the partition as if it were a real disk. I map the image to a loop device, mount the partition, copy the kernel.bin file into it, then unmount and detach the loop device.

## 3. Technical details

### MBR (Master Boot Record)

The **MBR** (Master Boot Record) is a traditional partitioning system used on BIOS-based systems. It's located in the very first sector of the disk (sector 0) and serves two main purposes:

1. It contains the bootloader **code** (usually the first-stage loader).
2. It includes a **partition table**, which can define up to **4 primary partitions**.

Structure MBR:

| Offset   | Bytes    | Description     |
| :------- | :------- | :-------------- |
| `0x0000` | 446      | Boot code       |
| `0x01BE` | 64       | Partition table |
| `0x01FE` | 2        | Boot signature  |

The boot code will load sector 0 of the first bootable partition it finds in the partition table. If it doesn't find one, it will print a message and enter an infinite loop. If you have multiple bootable partitions, you can modify it to allow the user to choose which partition they want to load. Personally, I choose the first bootable partition because it's simpler.

> The sector 0 of a bootable partition is called a VBR (Volume Boot Record).

In partition table, each entry is **16 bytes long**. Here's the structure of a single partition entry:

| Offset | Bytes   | Description                | Usefull ? | 
| :----- | :------ | :------------------------- | :-------- |
| `0x00` | 1 byte  | Boot indicator bit flag    | ✅        |
| `0x01` | 1 byte  | Starting head              | ❌        |
| `0x02` | 6 bits  | Starting sector            | ❌        |
| `0x03` | 10 bits | Starting Cylinder          | ❌        |
| `0x04` | 1 byte  | System ID                  | ✅        |
| `0x05` | 1 byte  | Ending Head                | ❌        |
| `0x06` | 6 bits  | Ending Sector              | ❌        |
| `0x07` | 10 bits | Ending Cylinder            | ❌        |
| `0x08` | 4 bytes | Relative Sector LBA value  | ✅        |
| `0x0C` | 4 bytes | Total Sectors in partition | ✅        |

> **\- Notes:**
> * At offset `0x00` : The value 0x80 means the partition is bootable, and 0x00 means it is not bootable.
> * At offset `0x02` : Bits 6-7 are the upper two bits for the starting cylinder field (offset `0x03`)
> * At offset `0x06` : Bits 6-7 are the upper two bits for the ending cylinder field (offset `0x07`)


## FAT32 (File Allocation Table 32 bits)

### Structure :
* VBR (Boot sector)
* FSInfo <- Sector with complementary infos (n° free clusters, etc.)
* Reserved sectors <- Define in VBR
* FAT 1 <- First allocation table & size define in VBR
* FAT 2 <- Copy of the first (not necessary but recommended) & size define in VBR
* Data Area
    * Cluster 2     
    * Cluster 3
    * etc.

### VBR (Volume Boot Record)

The VBR parameter the partition, it define size of cluster, and other usefull parameters.

Here's the structure of a FAT32's VBR :

| Offset  | Bytes | Name                    | Description                                 | Usefull ? |
| :------ | :---- | :---------------------- | :------------------------------------------ | :-------- |
| `0x000` | 3     | Jump instruction        | Jump to boot code                           | ✅        |
| `0x003` | 8     | OEM Name                | OS identifier (e.g., "MSDOS5.0")            | ❌        |
| `0x00B` | 2     | Bytes per sector        | Usually 512                                 | ✅        |
| `0x00D` | 1     | Sectors per cluster     | Determines cluster size                     | ✅        |
| `0x00E` | 2     | Reserved sectors        | Before FAT starts                           | ✅        |
| `0x010` | 1     | Number of FATs          | Normally 2                                  | ✅        |
| `0x011` | 2     | Root entry count        | 0 for FAT32                                 | ✅        |
| `0x013` | 2     | Total sectors (16-bit)  | Used if < 65535 sectors total               | ✅        |
| `0x015` | 1     | Media descriptor        | Media type (F8 = HDD)                       | ⚠️        |
| `0x016` | 2     | Sectors per FAT (FAT16) | 0 for FAT32                                 | ✅        |
| `0x018` | 2     | Sectors per track       | Legacy CHS layout                           | ❌        |
| `0x01A` | 2     | Number of heads         | Legacy CHS layout                           | ❌        |
| `0x01C` | 4     | Hidden sectors          | Offset of partition start from disk start   | ✅        |
| `0x020` | 4     | Total sectors (32-bit)  | Used if > 65535 sectors total               | ✅        |
| `0x024` | 4     | Sectors per FAT (FAT32) | Size of each FAT                            | ✅        |
| `0x028` | 2     | Flags                   | Used for mirroring FATs                     | ⚠️        |
| `0x02A` | 2     | FAT version             | 0x0000 expected                             | ✅        |
| `0x02C` | 4     | Root cluster            | Starting cluster of root dir                | ✅        |
| `0x030` | 2     | FSInfo sector number    | Sector number of FSInfo                     | ✅        |
| `0x032` | 2     | Backup boot sector      | Where backup VBR is stored                  | ⚠️        |
| `0x036` | 12    | Reserved                | Reserved                                    | ❌        |
| `0x042` | 1     | Drive number            | BIOS ID (80h = HDD)                         | ⚠️        |
| `0x043` | 1     | Reserved (NT)           | Reserved for Windows                        | ❌        |
| `0x044` | 1     | Boot signature          | 0x29 = indicates next fields exist          | ⚠️        |
| `0x045` | 4     | Volume ID               | Random serial number                        | ❌        |
| `0x049` | 11    | Volume label            | Volume name, padded with spaces             | ❌        |
| `0x054` | 8     | File system type        | "FAT32 " string                             | ⚠️        |
| `0x05C` | 420   | Boot code               | Actual bootloader code                      | ✅        |
| `0x1FE` | 2     | Boot sector signature   | Must be 0x55AA to be recognized as bootable | ✅        |

### FSInfo

| Offset | Bytes | Description                              |
| :----- | :---  | :--------------------------------------- |
| `0x000`| 4     | Signature 1 : `0x41615252`               |
| `0x004`| 480   | Reserved (fill with 0)                   |
| `0x1E4`| 4     | Signature 2 : `0x61417272`               |
| `0x1E8`| 4     | Number of free clusters                  |
| `0x1EC`| 4     | Next free cluster                        |
| `0x1F0`| 12    | Reserved (fill with 0)                   |
| `0x1FC`| 4     | Signature 3 : `0xAA550000`               |

### FAT (File Allocation Table)

The FAT contains entries, where each entry corresponds to one cluster. The content of an entry is just one of the following values :

| Hex value                   | Description                 |
| :-------------------------- | :-------------------------- |
| `0x00000000`                | Free cluster                |
| `0x0FFFFFFF`                | EOC - End Of Chain          |
| `0x0FFFFFF7`                | Corrupted cluser            |
| `0x0FFFFFF0` – `0x0FFFFFF6` | Reserved                    |
| Other                       | Address of the next cluster |

> Only the first 28 bytes are used, the remaining 4 bytes are reserved.

### Cluster

There is two type of cluster, file and directory, each cluster size usually 4096 bytes. A file cluster is simple, it just contain the content of the file that is affected to it. A directory cluster is still simple, they all have this structure :

| Offset  | Bytes | Description           |
| :------ | :---- | :-------------------- |
| `0x000` | 32    | Directory entry n°1   |
| `0x020` | 32    | Directory entry n°2   |
| `0x040` | 32    | Directory entry n°3   |
| `...`   | ...   | ...                   |
| `0xFFF` | 32    | Directory entry n°128 |

And each entry has this structure :

| Offset  | Bytes | Description                                                  |
| :------ | :---- | :----------------------------------------------------------- |
| `0x00`  | 8     | Filename (8 characters, upper case, padded with spaces)      |
| `0x08`  | 3     | File extension (3 characters)                                |
| `0x0B`  | 1     | Attributes (e.g. read-only, hidden, system, directory, etc.) |
| `0x0C`  | 1     | Reserved (for Windows NT)                                    |
| `0x0D`  | 1     | Creation time (fine resolution: tenths of a second)          |
| `0x0E`  | 2     | Creation time (hour, minute, second)                         |
| `0x10`  | 2     | Creation date                                                |
| `0x12`  | 2     | Last access date                                             |
| `0x14`  | 2     | High 16 bits of first cluster number                         |
| `0x16`  | 2     | Last modified time                                           |
| `0x18`  | 2     | Last modified date                                           |
| `0x1A`  | 2     | Low 16 bits of first cluster number                          |
| `0x1C`  | 4     | File size (in bytes)                                         |

## 4. Resources and References

* [MBR](https://wiki.osdev.org/MBR_(x86))
* [FAT32 detailed](https://www.cs.fsu.edu/~cop4610t/assignments/project3/spec/fatspec.pdf)
* [FAT32 simplified](https://github.com/zacherygentry/FAT32-File-System/blob/master/FAT.pdf)