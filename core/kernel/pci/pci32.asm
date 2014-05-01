;; PCI - Peripheral Component Interconnect is data bus like the USB
;; The PCI is useful while implementing Network Drivers, Sound
;; cards. It's pretty cheap, so manufacturers like it. :)
;; Guess What?
;; The Realtek NICs are also a part of this bus, they
;; are refferred to as planar devices in the specification.
;; PCI replaced VESA cards, and many other things.
;; So I thought, why not have support for such awesome stuff? ;0
;; Sounds Cool?
;; This part of the code uses PCI BIOS (16-bit Real Mode)
;; to detect whether the PCI bus is present by using BIOS 0x1A, 0xB101
;; function.
;; -If carry is set means invalid function (NO PCI-BIOS) :(
;; -If EDX != 'PCI ' then no PCI BIOS hence NO PCI :(
use16
bios_get_pci:
	;; BIOS INT 0x1A, AX equ B101 - Get PCI Status
	pusha
	mov ax, 0xB101
	int 0x1A
	jc .no_pci
	cmp edx, 'PCI '
	je .pci_ok
.no_pci:
	;; PCI Not Found Set PCI_STATUS to 0
	mov byte [PCI_STATUS], 0x00
	popa
	ret
.pci_ok:
	;; PCI Found set PCI_STATUS to 1
	mov byte [PCI_STATUS], 0x01
	popa 
	ret
;; These are some defines
;; for the bitflags in the PCI. Remember what bits are :)
;; Well, this table was gonna kick ass but I made it
;; a little readable.
;; Each bit is multiplied by it's previous one.
use32
;; PCI_INDEX Port
DEFINE PCI_INDEX 0xCF8
;; PCI_DATA Port
DEFINE PCI_DATA 0xCFC
PCI_BIT_1 equ 0x01
;; Laziness......
PCI_BIT_2 equ PCI_BIT_1 * 2
PCI_BIT_3 equ PCI_BIT_2 * 2
PCI_BIT_4 equ PCI_BIT_3 * 2
PCI_BIT_5 equ PCI_BIT_4 * 2
PCI_BIT_6 equ PCI_BIT_5 * 2
PCI_BIT_7 equ PCI_BIT_6 * 2
PCI_BIT_8 equ PCI_BIT_7 * 2
PCI_BIT_9 equ PCI_BIT_8 * 2
PCI_BIT_10 equ PCI_BIT_9 * 2
PCI_BIT_11 equ PCI_BIT_10 * 2
PCI_BIT_12 equ PCI_BIT_11 * 2
PCI_BIT_13 equ PCI_BIT_12 * 2
;; More Laziness
PCI_BIT_14 equ PCI_BIT_13 * 2
PCI_BIT_15 equ PCI_BIT_14 * 2
PCI_BIT_16 equ PCI_BIT_15 * 2
PCI_BIT_17 equ PCI_BIT_16 * 2
PCI_BIT_18 equ PCI_BIT_17 * 2
PCI_BIT_19 equ PCI_BIT_18 * 2
PCI_BIT_20 equ PCI_BIT_19 * 2
;; Even more....
PCI_BIT_21 equ PCI_BIT_20 * 2
PCI_BIT_22 equ PCI_BIT_21 * 2
PCI_BIT_23 equ PCI_BIT_22 * 2
PCI_BIT_24 equ PCI_BIT_23 * 2
PCI_BIT_25 equ PCI_BIT_24 * 2
PCI_BIT_26 equ PCI_BIT_25 * 2
PCI_BIT_27 equ PCI_BIT_26 * 2
PCI_BIT_28 equ PCI_BIT_27 * 2
PCI_BIT_29 equ PCI_BIT_28 * 2
PCI_BIT_30 equ PCI_BIT_29 * 2
;; Done with this shit
PCI_BIT_31 equ 0x80000000
PCI_32 equ 0x80000000
PCI_16 equ 0x40000000

;; pci32_read_register - Reads a 8/16/32 bit
;; register.
;; EAX - Device to Read.
;; Out Values:
;; DL - If it was 8 bit
;; DX - If it was 16 bit
;; EDX - If it was 32 bit
pci32_read_register:	
	;; Check whether we've PCI :)
	cmp byte [PCI_STATUS], 0x00
	je .END
	;; Save the required registers
	push ebx
	push cx
	;; Save EAX
	mov ebx, eax
	;; Save DH for now.
	mov cl, dh
	;; Clear Data Size Request
	and eax, not PCI_32 + PCI_16
	;; Set Access Request
	or eax, PCI_BIT_31
	;; Force it to be a DWORD value
	and al, not 3
	;; Write to selector
	mov dx, PCI_INDEX
	out dx, eax
	;; Figure out which port to do a 32-bit read on.
	mov dx, PCI_DATA
	mov al, bl
	and al, 3
	add dl, al
	in eax, dx
	;; Hang on....
	test ebx, PCI_32
	jz @f
	;; Return 32-bit Data
	mov edx, eax
@@:
	;; Return 16-bit data
	mov dx, ax
	test ebx, PCI_32 + PCI_16
	jnz @f
	;; Restore DH for 8-bit Read
	mov dh, cl
@@:
	;; Restore EAX
	mov eax, ebx
	;; Clear Data Size Request
	and eax, not PCI_32 + PCI_16
	;; Restore Registers and Return
	pop cx
	pop ebx
	ret
.END:
	ret
;; pci32_read_register_8:
;; Performs an 8-bit read
;; IN : EAX, OUT: (See pci32_read_register)
pci32_read_register_8:
	and eax, not PCI_32 + PCI_16
	jmp pci32_read_register
;; pci32_read_register_16:
;; Performs an 16-bit read
;; IN : EAX, OUT: (See pci32_read_register)
pci32_read_register_16:
	and eax, not PCI_32 + PCI_16
	or eax, PCI_16
	jmp pci32_read_register
;; pci32_read_register_32:
;; Performs an 32-bit read
;; IN : EAX, OUT: (See pci32_read_register)
pci32_read_register_32:
	and eax, not PCI_32 + PCI_16
	or eax, PCI_32
	jmp pci32_read_register
;; PCI Search Device:
;; Searches for a PCI Device in the bus. (No school btw)
;; IN : EAX - Device ID. (Device Number + Vendor ID)
;; OUT: EAX - If Device is found then address of 
;; the device.
;; Carry clear if found.
;; Set if not.
;; EAX Destroyed if not found. :) 
pci32_find_device:
	;; Save registers
	push ecx
	push edx
	push edi
	push esi
	;; Save Device ID
	mov esi, eax
	;; Start with the first device, Remember that we 
	;; subtracted 0x100 from 0x80000000 as 0x80000000 is 
	;; is the address of the first device, since
	;; we add 0x100 in the loop, the first add
	;; will correspond to 0x80000000.
	mov edi, (0x80000000 - 0x100)
	;; Enter a device scan loop
.continue_scan:
	;; Skip Each Device after check
	add edi, 0x100
	;; Did we scanned all the devices (EDI should be 0x80FFF800)
	cmp edi, 0x80FFF800
	;; Set carry
	stc
	;; Not Found
	jz .PCI_DONE
	;; Read the PCI bus
	mov eax, edi
	call pci32_read_register_32
	;; Did we find it?
	cmp edx, esi
	;; Nope? Continue the Scan
	jnz .continue_scan
	;; YESSS? Then Clear carry
	clc
	;; And we're done :)
.PCI_DONE:
	;; Return found PCI Address
	pushf
	mov eax, edi
	and eax, not 0x80000000
	popf
	pop edi
	pop esi
	pop edx
	pop ecx
	ret
	
;; pci32_write_register
;; Writes A register to the PCI Bus.
pci32_write_register:
	cmp byte [PCI_STATUS], 0x00
	je .END
	push ebx
	push ecx
	mov ebx, eax
	mov cx, dx
	or eax, PCI_BIT_31
	and eax, not PCI_16
	and al, not 3
	mov dx, PCI_INDEX
	out dx, ax
	mov dx, PCI_DATA
	mov al, bl
	and al, 3
	add dl, al
	mov eax, edx
	mov ax, cx
	out dx, al
	test ebx, PCI_32 + PCI_16
	jz @f
	out dx, ax
	test ebx, PCI_16
	jnz @f
	out dx, eax
@@:
	mov eax, ebx
	and eax, not PCI_32 + PCI_16
	mov dx, cx
	pop ecx
	pop edx
	ret
.END:
	ret
;; pci32_write_register_8:
;; DL - Value to Write
;; EAX - Device
pci32_write_register_8:
	and eax, not PCI_32 + PCI_16
	jmp pci32_write_register
;; pci32_write_register_16:
;; DX - Value to Write
;; EAX - Device
pci32_write_register_16:
	and eax, not PCI_32 + PCI_16
	or eax, PCI_16
	jmp pci32_write_register
;; pci32_write_register_32:
;; EDX - Value to Write
;; EAX - Device
pci32_write_register_32:
	and eax, not PCI_32 + PCI_16
	or eax, PCI_32
	jmp pci32_write_register
	

