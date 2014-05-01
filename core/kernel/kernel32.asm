;; Zicronix - A 32-bit Operating System
;; (C) Bender/sid123 under the 2-clause BSD License
format binary as 'bin'
org 0x100
		;; For now Use 16-bit as we've been loaded from DOS
		;; No DPMI BS. ;)
		;; entry point
		;; should always align code to a power of 2
		;; 2^2 = 4 :)
		align 4 
_start:
		use16
		jmp init
		;; Common Code
		include '../_common/zmac.asm'
		include 'ver/version.asm'
		;; Stack Buffer
		EMPTY_SPACE rb 1024 * 6
		KERNEL_STACK_BUFFER:
		APP_SPACE: rb 1024 * 6
		APP_STACK_BUFFER: 
		;; Some equ's	
		;; Where RAMDisk is loaded
		;; 0x200000 - 2MB in RAM
		RAMDISK_LOAD_POINT equ 0x200000
		VGA_DRIVER_LOAD_POINT equ 0x300000
		file_exists32 equ entry_exists
		NULL equ 0
		? equ 0
		KERNEL_SIZE equ 1024
		DATA_SEL_32 equ 0x18
		;; Protected Mode Code Segment
		LINEAR_SEL  equ  GDT32.LINEAR_SEL - GDT32		    
		CODE_SEL    equ  GDT32.CODE_SEL - GDT32 		    
		DATA_SEL    equ  GDT32.DATA_SEL - GDT32
		;; User Segment
		USER_CODE_SEL	 equ  GDT32.USER_CODE_SEL - GDT32
		USER_DATA_SEL	 equ  GDT32.USER_DATA_SEL - GDT32
		;; Real Mode Code Segment
		RM_CODE     equ  GDT32.RM_CODE - GDT32			  
		RM_DATA     equ  GDT32.RM_DATA - GDT32 
		KERNEL_PHYSICAL_REMAP equ 0x100000
		KERNEL_VIRTUAL_REMAP equ 0xC0000000
		ATA_BUFFER  equ 0x00070000
init:
		;; Setting the segments and stack anyone?
		;; Push the current CS onto stack
		push cs
		;; Pop the CS value into DS
		pop ds
		;; Now DS contains the value of CS.
		;; Now do the same thing again and again
		push ds
		pop es
		;; Set SS
		push es
		pop ss
		;; Set the SP - Stack Pointer
		mov sp, KERNEL_STACK_BUFFER
		;; Get the current Boot Device passed by boot sector
		mov byte [KERNEL_BOOT_DEVICE], dl
check_80386:
		;; Check for 386
		mov ax, 0x7202
		push ax
		popf
		pushf
		pop bx
		cmp ax, bx
		je CHECK_MODE
		mov si, _error
		call bios_printf
		xor ax, ax
		int 0x16
		cli
		hlt
		jmp $
		_error db 'PROCESSOR FATAL ERROR! PROCESSOR IS NOT A 386-COMPATIBLE PROCESSOR!', 0
CHECK_MODE:
		;; Check for V8086
		smsw ax
		test al, 1
		jz ok_386
		mov si, _v8086_err
		call bios_printf
		xor ax, ax
		int 0x16
		ret
		_v8086_err db 'PROCESSOR UNDER VIRTUAL 8086 MODE! CANNOT INITIALIZE PROTECTED MODE!', 13, 10, 0
ok_386:
			;; Set a known text mode
			mov ax, 0x0003
			int 0x10
			;; Configure Serial Port
			xor dx, dx			
			mov ax, 11100011b
			int 0x14
			;; Disable blinking - Looks kinda ugly
			mov ax, 0x1003
			xor bx, bx
			int 0x10
			;; 90x60 text mode.
			call set90x60
			;; Load our font
			mov   bp, _fonts 
			mov   cx,00FFh 
			xor   dx,dx 
			mov   bx,0800h 
			mov   ax,1100h 
			int   10h	       
			;; Print ok message
			mov si, _check_ok
			call bios_printf
			;; Check for 80387
			call init_80387
			;; Get total memory
			call get_total_memory
			;; Store it.
			mov dword [total_memory], eax
			;; Get memory map
			call get_mem_map
			;; Get the CPU Vendor String
			mov di, cpu_string
			call get_cpu_string
			;; Get the PCI Status
			call bios_get_pci
			jmp KERNEL_SET_PMODE
KERNEL_SET_PMODE:
		;; Done with 386 Checks, Memory Checks, and other Real Mode BS.
		;; Time to switch to protected Mode.
		;; First to access all the memory above 1 MB, we need 
		;; to enable this crappy line A20, which is at the 
		;; keyboard port. Crappy because it was for some 
		;; 8086 Compatibility BS purposes which no-one needs
		;; except DOS and it's crappy programs. *Does anyone
		;; remember the PSP?*
		call Enable_A20
;; Load the GDT and the IDT
load_descriptors:
		; Okay here's the interesting part
		; Our process of loading the GDT32
		xor ebx, ebx
		mov bx, ds
		shl ebx, 4
		;; well the LGDT instruction is crap,
		;; it expects the LINEAR address of the GDT and NOT the offset.
		;; since we're in a segmented mem model this'll cause problems,
		;; so we NEED to calculate the linear address so that the LGDT instruction
		;; will need it.
		mov [KERNEL_BASE], ebx
		mov	eax, ebx				  
		mov	[GDT32.CODE_SEL + 2], ax				    
		mov	[GDT32.DATA_SEL + 2], ax			  
		mov	[GDT32.RM_CODE + 2], ax 				    
		mov	[GDT32.RM_DATA + 2], ax 		  
		shr	eax, 16 				  
		mov	[GDT32.CODE_SEL + 4], al			  
		mov	[GDT32.DATA_SEL+ 4], al 		  
		mov	[GDT32.RM_CODE + 4], al 		  
		mov	[GDT32.RM_DATA + 4], al 		  
		mov	[GDT32.CODE_SEL + 7], ah			  
		mov	[GDT32.DATA_SEL + 7], ah			  
		mov	[GDT32.RM_CODE + 7], ah 		  
		mov	[GDT32.RM_DATA + 7], ah 		  
		add	ebx, GDT32				  
		mov	[GDT_DESC + 2], ebx		
		add ebx, idt - GDT32
		mov [IDT_DESC + 2], ebx
		;; DISABLE ALL INTERRUPTS WHILE PROTECTED MODE SWITCH!
		cli		
		;; Get Current CS for Future purposes.
		mov	ax, cs					  
		mov	word [RM_CS], ax			
		lgdt [GDT_DESC]
		; Load the IDT
		lidt [IDT_DESC]
		jmp SET_PROCESSOR_MODE
SET_PROCESSOR_MODE:
		; GDT Loaded, IDT Loaded, A20 Enabled, Time to enable the PE
		; bit in CR0
		mov eax, cr0
		or	al, 1
		mov cr0, eax
		;; And make a far jump to Fix CS
		jmp CODE_SEL:KERNEL32
KERNEL32:
		;; Welcome 8) to protected mode.
		use32
		;; Here we set the segment registers, the stack buffer, 
		;; and also, the selectors
		;; empty ALL the registers
		xor edi, edi
		xor esi, esi
		xor eax, eax
		xor ebx, ebx
		xor ecx, ecx
		xor edx, edx
		mov ax, DATA_SEL
		mov ds, ax
		mov ss, ax
		nop
		mov es, ax
		mov gs, ax
		mov ax, 0x08
		mov fs, ax
		mov esp, KERNEL_STACK_BUFFER
		;; Set text color
		mov byte [textcolor], 0x70
		;; Clear Screen 
		call clearscreen
		mov esi, kern_start_seg_msg
		call printf32
		mov eax, init
		call itoa32
		mov esi, eax
		call printf32
		mov esi, kernel_ver_msg
		call printf32
		;; okay copy the code
		mov esi, next_code
		mov ecx, [kernel_32_size]
		mov edi, KERNEL_PHYSICAL_REMAP
		rep movsb
		jmp CODE_SEL:KERNEL_PHYSICAL_REMAP
next_code:
		mov esi, PMM_INIT_MSG
		call printf32
		call print_ok
		;; init acpi
		call init_acpi
		;; Tell the user we're in PMode
		mov byte [fs:0xB809E], 'P'
		;; Initialize Memory Manager
		call init_pmm
		;; Intialize PCI
		mov esi, PCI_INIT
		call printf32
		;; Check for PCI BIOS
		cmp byte [PCI_STATUS], 0x00
		je .continue
		call print_ok
.continue:
		;; set cursor
		mov bx, 0x0007
		call changecur32
		;; Remap the PICs
		call remap_pic32
		;; Unmask all IRQs - Judgement Day of Interrupt handler :P
		call UNMASK_IRQ
		;; Initialize RTC
		call rtc_init
		;; Intialize PIT
		;; 10 hz = 0.1 seconds
		mov ebx, 10
		call pit_init
		;; initialize sse
		call init_sse
		;; initialize VMX
		call init_vmx
		mov byte [fs:0xB809E], 'H'
		;; CPU initialization went ok
		call print_ok
		;; Initialize HDD
		mov esi, HDD_INIT
		call printf32
		;; call init_hdd routine
		call init_hdd
		call print_ok
		;; ok.
		mov esi, _pmode_ok
		call printf32
		call serial_write_string
		call print_ok
		;; check for network device
		;mov esi, RTL8139_STRING
		;c;all printf32
		;; RTL8139
		;mov eax, 0x813910EC
		;; find that device
		;call pci32_find_device
		;; error.
		;jc .err
		;call print_ok
.err:
		;; init done. 
		jmp init_done
ShouldNeverReach:
		HALT_ALL
;; 386 Stuff
include '386/GDT.asm'
include '386/IDT.asm'
include '386/A20.asm'
include '386/mem16.asm'
include '386/E820.asm'
;; 80387 Code
include '80387/80387.asm'
;; Video Output
include 'video/vga/bios.asm'
include 'video/vga/vga32.asm'
include 'video/vga/vga90x60.asm'
include 'video/vga/font.asm'
;; Stuff Related to CPU
include 'cpu/isr.asm'
include 'cpu/pit32.asm'
include 'cpu/cpuid.asm'
include 'cpu/beep.asm'
;; PIC 8259A Routines
include 'pic/pic32.asm'
;; System API Code
include 'api/api32.asm'
include 'api/app32.asm'
include 'api/fatapi.asm'
;; IO - Strings/Keyboard etc.
include 'io32/keyboard.asm'
include 'io32/string32.asm'
include 'io32/screen32.asm'
;; Shell stuff
include 'shell/shell32.asm'
;; Bochs Debugging
include 'debug/bochs.asm'
;; PCI 
include 'pci/pci32.asm'
;; IDE Code
include 'ide/ide32.asm'
;; HDD Stuff.
include 'hdd/hdd.asm'
;; FileSystems Code
include 'filesystems/fat16/fat16.asm'
;; Module Dependant Code
include '_modules/ramdisk/ramdisk.asm'
;; sse bs.
include 'sse/sse.asm'
;; rtc
include 'rtc/rtc.asm'
;; pmm
include '_pmm/pmm.asm'
include '_pmm/mmap.asm'
;; acpi
include 'acpi/acpi.asm'
;; debug
include 'debug/debug.asm'
;; vmx
include 'vmx/vmx.asm'
;; file i/o 
include 'file/file.asm'
include 'file/chdir_f.asm'
;; serial code
include 'serial/serial.asm'
;; Kernel Executable Code 
init_done:
	;; Enables Interrupts in Case...
	sti
	;;call mm_output
	mov byte [fs:0xB809E], '4'
	;; Make sure memory range from 2MB to 14MB is cleared i.e. nulled out (Programs, drivers, etc.)
	mov edi, 0x200000
	;; Number of Bytes
	mov ecx, 0xC00000
	mov al, 0x00
	rep stosb
	;; load ramdisk
	mov eax, RAMDISK_FILE_NAME
	call file_convert
	mov esi, eax
	mov edi, RAMDISK_LOAD_POINT
	call loadfile32
	jc .fatal
	mov eax, VGA_DRV_FILE_NAME
	call file_convert
	;; load vga driver
	mov esi, eax
	mov edi, VGA_DRIVER_LOAD_POINT
	call loadfile32
	mov edi, VGA_DRIVER_LOAD_POINT
	cmp dword [edi], 'ZDRV'
	jne .fatal
	call CODE_SEL:VGA_DRIVER_LOAD_POINT+8
	mov esi, KERNEL_PHYSICAL_REMAP
	mov eax, _KERNEL_FILE_NAME
	call file_convert
	mov edi, eax
	mov ecx, 500
	call writefile32
	; Cool. RAMDISK Loaded :)
	mov esi, _MOUNTING_USR
	call printf32
	mov byte [fs:0xB809E], 'U'
	;; Switch to USR/BIN
	mov eax, USR_DIR
	call chdir
	jnc .fatal
	mov al, 'A'
	call send_serial
.goto_shell:
	call print_ok
	mov ax, 0x0C80
	call os_speaker_on
	mov ecx, 02 
	call init_timer
	call os_speaker_off
	mov ax, 0x0B70
	call os_speaker_on
	mov ecx, 02
	call init_timer
	call os_speaker_off
	mov esi, _time_msg
	call printf32
	mov edi, time_buf
	call rtc_get_time_string
	mov esi, time_buf
	call printf32
	mov edi, time_buf
	call rtc_get_date_string
	mov bl, ' '
	call printc32
	mov esi, time_buf
	call printf32
	mov byte [fs:0xB809E], ''
	jmp shell32
.fatal:
	mov esi, FATAL_ERROR_INIT
	call printf32
	cli
	hlt
	jmp $
;; a bs routine
print_ok:
	push esi
	mov ch, [textcolor]
	mov byte [textcolor], 0x72
	mov esi, _OK_STRING
	call printf32
	mov byte [textcolor], ch
	pop esi
	ret
KERNEL_DATA:
	;; Put all the DATA here.
	compilation_time: dd %t
	kernel_ver_msg db 0x0a, '[KERNEL]Zicronix Kernel Version: ', VER_STRING, 0x0a, 0
	kern_start_seg_msg db 0x0a, '[KERNEL]Kernel Loaded Physical Address: ', 0
	_pmode_ok db '[CPU0:]CPU Intialization           ', 0
	_check_ok db '386+ Processor Found!', 13, 10, 0
	_paging db '[CPU0:]386 Paging                  ', 0
	Enabling_PIT db '[CPU0:]Programmable Interrupt Timer', 0
	PCI_INIT db 0x0A,'[CPU0:]Configuring PCI.....        ', 0
	FATAL_ERROR_INIT: db 0x0A, 'A very important driver or directory is missing. Press a key to reboot', 0
	_MOUNTING_USR: db 0x0a,'[CPU0:]Intializing FAT16 on hd0    ', 0
	HDD_INIT: db		   '[CPU0:]HDD Intialization           ', 0
	_time_msg db '[CPU0:]System Initialized successfully on : (0.67 seconds) ', 0
	_OK_STRING: db '                            [OK]', 0x0a, 0
	_TIME = %t
	COMPILE_TIME: dd _TIME
	;; Kernel Boot Device
	KERNEL_BOOT_DEVICE db 0
	;; Kernel Base Address
	KERNEL_BASE dd 0
	;; Real Mode CS
	RM_CS dw 0
	;; PCI Status
	PCI_STATUS db 0
	KernelSize dw 0x00
	total_memory dd 0
	cpu_string: times 48 db 0
	;; Saves Stack Location
	_esp:	dd 0x00007100
	USR_DIR db 'USR', 0
	BIN_DIR db 'BIN', 0
	_RAMDISK_CONTENT: times 110 db 0
	_KERNEL_FILE_NAME db "TROLL.TXT", 0
	LOG_NAME db 'LOG.TXT', 0
	VESA_MODE db 0
	RAMDISK_FILE_NAME: db 'RAMDISK.IMG', 0
	VGA_DRV_FILE_NAME: db 'VGA32.BIN', 0
	RTL8139_STRING: db '[CPU0:]Network Card (RTL8139)      ',0 
	PMM_INIT_MSG db 0x0A, '[CPU0:]Intializing Memory Managers ', 0
	AHCI_OK db 0x00
	usr_dir_offset dd 0x0
	time_buf: times 20 db 0
	db 0x00
	;; kernel size
kernel_size: dd _end - _start
kernel_32_size: dd $ - next_code
;; end symbol
_end: