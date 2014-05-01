;; First off, this code is only for temporary usage, reasons?
;; 1. I don't want to switch to s**t real mode.
;; 2. The code is crap btw.
;; 3. The OS will be dead if such s**t happens in Real Mode.
;; 4. ?????
;; Anyways,
;; INT86 - Call a INT86 Function
;; NOTE: BULLS**T BIOS IRQs are not bothered to be remapped, why?
;; I want full control :D
;; AX/BX/CX/DX/SI/DI/BP - For real mode
use32
int86:
	;; save registers
	pushad
	;; save status.
	mov word [RM_AX], ax
	mov word [RM_BX], bx
	mov word [RM_CX], cx 
	mov word [RM_DX], dx 
	mov word [RM_SI], si 
	mov word [RM_DI], di 
	mov word [RM_BP], bp 
	;; shit dude, we need to clear interrupts crap!
	;; good bye irqs :(
	cli
	;; Mask All IRQs, good day.
	call MASK_IRQ
	;; Remap the Real Mode PIC
	mov al, 0x11
	out 0x20, al
	out 0xA0, al
	mov al, 0x08
	out 0x21, al
	mov al, 0x70
	out 0xA1, al
	mov al, 4
	out 0x21, al
	mov al, 2
	out 0xA1, al
	mov al, 1
	out 0x21, al
	out 0xA1, al
	;; okay, now jump to a low memory location. 
