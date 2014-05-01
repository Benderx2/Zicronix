;; Taken and based from ReturnInfinity's BareMetalOS
;; Copyright (C) 2008-2014 Return Infinity -- http://www.returninfinity.com
;; All rights reserved. 
;; Please see credits/baremetal.txt
;; I only modded it a little bit but the original credits
;; to the BareMetal guys.
;; Well I just add stuff for completness and some more
;; comments, hats off to those guys for this.
;; Boot Signature
define BOOT_SIGN 0x55AA
;; Offset of the First Partition
define FIRST_PARTITION 0x1C6
;; These are some defines that were
;; extracted from Wikipedia page about BPB.
;; This is given for completeness, not all
;; of them are used. They contain the offsets
;; of the data that they represent.
;; WORD - Bytes Per Sector, Tells us how many
;; bytes does 1 sector take. (Usually 512)
define BYTES_PER_SECTOR 0x000B
;; BYTE - 1 cluster consists of sectors
;; this attribute tells us how many sectors
;; do we've per cluster
define SECTORS_PER_CLUSTER 0x0D
;; WORD - On a disk there are some sectors
;; that are reserved and shouldn't be touched.
;; They may contain vital data, usually there's
;; one which is the boot sector.
define RESERVED_SECTORS 0x000E
;; BYTE - A OS may make several copies of the FAT 
;; Just in Case, if data gets lost, usually there
;; are two.
define NUMBER_OF_FATS 0x10
;; WORD - The FAT12/FAT16 root directory
;; is what we need, when you open a drive
;; in Windows/Linux/Mac you first access 
;; the root directory.
define ROOT_DIR_ENTRIES 0x0011
;; WORD - Number of Small Sectors
define NUMBER_OF_SECTORS 0x0013
;; BYTE - Media Type (HD/FD/CD)
define MEDIA_TYPE 0x15
;; WORD - This value will tell us how
;; many sectors do we have "PER FAT",
;; this is useful when computing the location
;; of the root directory, The root directory 
;; is located like:
;; |BOOT SECTOR|RESERVED SECTORS|FAT (1, 2, 3....)|ROOT DIRECTORY|BS..........
;; In FAT16 the Boot Sector is 512 bytes, 
;; The number of bytes taken up by reserved sectors
;; can be computer by RESERVED_SECTORS * BYTES_PER_SECTOR,
;; And thus the root directory can be computed by:
;; 512 + RESERVED_SECTORS * BYTES_PER_SECTOR + NUMBER_OF_FATS * SECTORS_PER_FAT * BYTES_PER_SECTOR
;; Cool?
define SECTORS_PER_FAT 0x0016
;; WORD - Sectors per track
define SECTORS_PER_TRACK 0x0018
;; WORD - Number of Heads
define NUMBER_OF_HEADS 0x001A
;; DWORD - This value contains the number of sectors before a partition
;; in a partitioned disk.
define HIDDEN_SECTORS 0x0000001C
;; DWORD - Number of Big Sectors
define SECTORS_BIG 0x00000020
;;;;;;;;;;;;;;;;;;;;;;;	
init_hdd:
	;; Intializes the HDD
	call ide32_detect
	jc .error
	xor eax, eax
	mov edi, ATA_BUFFER
	push edi
	mov ecx, 1
	call readsector32
	pop edi
	mov eax, [ATA_BUFFER + FIRST_PARTITION]
	mov edi, ATA_BUFFER
	push edi
	mov ecx, 1
	call readsector32
	pop edi
	jc .ok
	mov esi, _FATAL_HDD_ERROR
	call printf32
	hlt
	jmp $
.error:
	mov esi, _IDE_CONTROLLER_ERROR
	call printf32
	hlt
	jmp $
.ok:
	;; Store the partition number
	dec eax
	mov dword [BPB.fat_16_partition], eax
	call hdd_get_drive_params
	ret
;; HDD Get Values
hdd_get_drive_params:
;; Good we have the sector in ATA_BUFFER
;; Now we will grab the values off the MBR.
	mov ax, [ATA_BUFFER + BYTES_PER_SECTOR]
	;; Store this.
	mov [BPB.fat_16_bytes_per_sector], ax
	;; Get Sectors per cluster
	mov al, [ATA_BUFFER + SECTORS_PER_CLUSTER]
	mov [BPB.fat_16_sectors_per_cluster], al
	;; Get Reserved Sectors
	mov ax, [ATA_BUFFER + RESERVED_SECTORS]
	mov [BPB.fat_16_reserved_sectors], ax
	;; The FATs should also start here.
	mov [BPB.fat_16_start], eax
	;; Get Number of FATs
	mov al, [ATA_BUFFER + NUMBER_OF_FATS]
	mov [BPB.fat_16_fat_copies], al
	;; Get the total number of root directory entries
	mov ax, [ATA_BUFFER + ROOT_DIR_ENTRIES]
	mov [BPB.fat_16_root_dir_entries], ax
	;; Get Media Type
	mov al, [ATA_BUFFER + MEDIA_TYPE]
	mov [BPB.fat_16_media_type], al
	;; Get Sectors per FAT
	mov ax, [ATA_BUFFER + SECTORS_PER_FAT]
	mov [BPB.sectors_per_FAT], ax
	;; Get number of Sectors
	mov ax, [ATA_BUFFER + NUMBER_OF_SECTORS]
	cmp ax, 0x0000
	jne .less_65536
	mov eax, [ATA_BUFFER + SECTORS_BIG]
.less_65536:
	mov [BPB.total_sectors], eax
	;; Calculate the size in MiB (MebIByte)
	xor eax, eax
	mov eax, [BPB.total_sectors]
	mov [BPB.max_lba], eax
	shr eax, 11
	mov [BPB.hd_size], eax
.calculate_data_start:
	xor eax, eax
	xor ebx, ebx
	mov ax, [BPB.sectors_per_FAT]
	shl ax, 1			; quick multiply by two
	add ax, [BPB.fat_16_reserved_sectors]
	mov [BPB.root_dir_start], eax
	;; Set current directory as root directory
	mov [current_directory.offset], eax
	mov bx, [BPB.fat_16_root_dir_entries]
	shr ebx, 4			; bx = (bx * 32) / 512
	add ebx, eax			; BX now holds the datastart sector number
	mov [BPB.data_start], ebx
	ret
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
HDD_DATA_SECTION:	
	_IDE_CONTROLLER_ERROR: db 0x0A,'IDE Controller Error. Cannot Initialize HDD', 0
	_FATAL_HDD_ERROR: db 0x0A, "Fatal HDD error, Can't read sector 0."
;; Fat 16 BPB
BPB:
	.fat_16_bytes_per_sector dw 0x0000
	.fat_16_sectors_per_cluster db 0x00
	.fat_16_reserved_sectors dw 0x0000
	.fat_16_fat_copies db 0x00
	.fat_16_root_dir_entries dw 0x0000
	.fat_16_number_of_sectors dw 0x0000
	.fat_16_media_type db 0x00
	.sectors_per_FAT dw 0x0000
	.sectors_per_track dw 0x0000
	.number_of_heads dw 0x0000
	.fat_16_hidden_sectors dd 0x00000000
	.big_sectors dd 0x00000000
	.fat_16_partition dd 0x00000000
	.fat_16_start dd 0x00000000
	.total_sectors dd 0x00000000
	.max_lba dd 0x00000000
	.hd_size dd 0x00000000
	.root_dir_start dd 0x00000000
	.data_start dd 0x00000000
	;; Write the Boot Signature
	dw BOOT_SIGN