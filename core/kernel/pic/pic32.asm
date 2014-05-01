;; PIC - Programmable Interrupt Controller
;; Remaps the PICs
use32
define PIC_MASTER 0x20
define PIC_SLAVE 0xA0
define PIC_SLAVE_COMMAND 0xA1
define PIC_MASTER_COMMAND 0x21
remap_pic32:
	;; Put the PICs in Initialization Mode
	mov al, 0x11
	out PIC_MASTER, al
	out PIC_SLAVE, al
	;; Remap interrupts 0x20 - 0x27
	mov al, 0x20
	out PIC_MASTER_COMMAND, al
	mov al, 0x28
	out PIC_SLAVE_COMMAND, al
	;; PIC 1 - Master
	mov al, 4
	out PIC_MASTER_COMMAND, al
	mov al, 2
	out PIC_SLAVE_COMMAND, al
	mov al, 1
	out PIC_MASTER_COMMAND, al
	out PIC_SLAVE_COMMAND, al
MASK_IRQ:
	; Disable Interrupts
	cli
	mov al, 255
	; Mask all IRQs
	out PIC_SLAVE_COMMAND, al
	out PIC_MASTER_COMMAND, al
	ret
UNMASK_IRQ:
	mov al, 0x00
	out PIC_SLAVE_COMMAND, al
	out PIC_MASTER_COMMAND, al
	ret