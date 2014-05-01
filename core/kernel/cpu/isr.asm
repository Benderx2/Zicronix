;; ISR - Interrupt Services routines
;; Used in the IDT
;; CPU Fatal Error
use32
;; Unhandled ISR
unhandled_isr:
	pushad
	mov esi, _unhandled
	call printf32
	popad
	iret
	_unhandled db 0x0A, 'Unhandled Interrupt Was executed!', 0
unhandled_irq:
	pushad
	push es
	push ds
	push eax
	mov al, 'U'
	mov ah, 0x4F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
cpu32_breakpoint:
	pushad
	push es
	push ds
	push ax
	mov ah, 0x2F
	mov al, 'B'
	mov [fs:0xB809C], ax
	pop ax
	pop es
	pop ds
	popad
	iret
gen_protect_fault:
	pushad
	push  es
	push  ds
	push ax
	mov ah, 0x2F
	mov al, 'G'
	mov [fs:0xB809C], ax
    pop ax
	pop   ds
	pop   es
	popad
	iret
x87_fpu_error:
	pushad
	push  es
	push  ds
	mov   byte [fs:0xB809C], "F"
	pop   ds
	pop   es
	popad
	iret
page_fault:
	pushad
	push  es
	push  ds
	mov   byte [fs:0xB809C], "P"
	pop   ds
	pop   es
	popad
	iret
	

;; Sends an End-Of-Interrupt Signal
send_eoi:
	push eax
	mov al, 0x20
    out 0x20, al
	out 0xA0, al
	pop eax
    ret
;; Double Faults
double_fault:
	mov esi, _DF_ERROR
	call printf32
	cli
	hlt
	jmp $
_DF_ERROR db 0x0A,'DOUBLE FAULT! SHIT SHIT SHIT SHIT!', 0
;; Co-Processor Segment Over Run
co_seg_ovrn:
	mov esi, _CS_OV
	call printf32
	cli
	hlt
	jmp $
_CS_OV: db 0x0A,'Co-Processor Segment Overrun, System Halted.', 0
;; Stack Faults
stack_seg_fault:
	mov esi, _STACK_FAULT
	call printf32
	cli
	hlt
	jmp $
_STACK_FAULT: db 0x0A, 'Stack Fault. System Halted', 0
;; Divide By Zero
cpu32_div_by_zero:
	mov esi, _DIV_ZERO
	call printf32
	cli
	hlt
	jmp $
_DIV_ZERO: db 0x0A, 'Divide By Zero. Seriously? U mad Bro? *Troll Face*.',0x0A, 'Btw System Halted. *YEAH!*', 0
;; CPU Overflow
cpu32_overflow:
	mov esi, _OVERFLOW
	call printf32
	cli
	hlt
	jmp $
_OVERFLOW: db 0x0A,'CPU32 Overflow Exception. Go Die.', 0
;; CPU Bound Range Exceeded
cpu32_bound_range:
	pop eax
	mov esi, _BND_RANGE_EX
	call printf32
	call itoa32
	mov esi, eax
	call printf32
	;; Get EIP
	;mov eax, [esp]
	;; Convert it to Integer
	;call itoa32
	;; Print it.
	;mov esi, eax
	;call printf32
	cli
	hlt
	jmp $
_BND_RANGE_EX: db 0x0A, 'CPU Bound Range Exceeded.', 0x0A, 'Current EIP: ', 0x0A, 0
;; NMI
cpu32_NMI:
	mov esi, _NMI_MSG
	call printf32
	cli
	hlt
	jmp $
	_NMI_MSG: db 0x0A, 'CPU NMI Interrupt System Halted', 0
;; Other Errors
virtual_excep:
	mov esi, _VIRTUAL_EXCEP
	call printf32
	cli
	hlt
	jmp $
_VIRTUAL_EXCEP db 0x0A, 'Virtualization Exception. System Halted', 0
simd_fpu_excep:
	mov esi, _SIMD_FPU_EXCEP_MSG
	call printf32
	cli
	hlt
	jmp $
_SIMD_FPU_EXCEP_MSG db 0x0A, 'SIMD Floating Point Exception.', 0
cpu32_machine_check:
	mov esi, MACHINE_CHECK_MSG
	call printf32
	cli 
	hlt 
	jmp $
	MACHINE_CHECK_MSG db 0x0A, 'CPU Machine Check.', 0
cpu32_align_check:
	mov esi, ALIGN_CHECK
	call printf32
	cli
	hlt
	jmp $
	ALIGN_CHECK db 0x0A, 'CPU Alignment Check.', 0
cpu32_invalid_seg:
	mov esi, _SEG_INVALID
	call printf32
	cli
	hlt
	jmp $
	_SEG_INVALID db 0x0A, 'Invalid Segment.', 0
cpu32_security_excep:
	mov esi, SECURITY_EXCEP
	call printf32
	cli
	hlt
	jmp $
	SECURITY_EXCEP db 0x0A, 'CPU Security Exception.', 0
cpu32_invalid_TSS:
	mov esi, _INVALID_TSS
	call printf32
	cli
	hlt
	jmp $
_INVALID_TSS db 0x0A, 'CPU Invalid TSS. System Halted.', 0
cpu32_opcode:
	pop eax
	mov esi, _OPCODE_ERR
	call printf32
	call itoa32
	mov esi, eax
	call printf32
	cli
	hlt
	jmp $
_OPCODE_ERR db 0x0A, 'Invalid Opcode.', 0x0A, 'Pointer to crap instruction: ', 0
cpu32_device_excep:
	mov esi, _DEVICE_EXCEP
	call printf32
	cli
	hlt
	jmp $
	_DEVICE_EXCEP db 0x0A, 'Device Exception.', 0
irq_7:
	pushad
	;; Check whether it was really IRQ7
	; PIC.OCW3 set function to read ISR (In Service Register)
    out32 0x23, 0x03      ; write to PIC.OCW3
    in al, 0x20            ; read ISR
	;; Do we have the IR7 bit set?
	test al, 0x80
	;; Well, it's a spurious IRQ
	jz .EOI
	;; Or maybe not?
	;; Then don't send EOI
	jmp .done
.EOI:
	SEND_EOI
.done:
	popad
	iret
fatal:
	pushad
	mov byte [textcolor], 0x4F
	push fs
	;; Clear Direction Flag
	cld
	mov ax, 0x08
	mov fs, ax
	;; Set EDI to Video Memory
	mov edi, video_memory
	;; Video Memory is 2000 bytes
	mov ecx, max_x * max_y
	;; AH should be text color
	mov ah, byte [textcolor]
	;; AL should be space character
	mov al, ' '
	;; And Copy it to Video Memory
.loop:
	;; Now put one byte of AL into FS:EDI
	mov byte [fs:edi], al
	;; Increment EDI, Next Address
	inc edi
	;; Put the Color
	mov byte [fs:edi], ah
	;; Increment it. Next Address
	inc edi
	;; Decrement ECX
	dec ecx
	;; Loop till ECX is zero.
	jnz .loop
	pop fs
	mov byte [screen_x], 45
	mov byte [screen_y], 30
	mov esi, _IRQ_7_EXCEP
	call printf32
	mov ah, 0x04
	int 0x30
	mov esi, _CPU_STATE
	call printf32
	popad
	ret
	_IRQ_7_EXCEP: db 0x0A, 'WARNING: IRQ7 Triggered', 0
	_CPU_STATE: db 0x0A, 'FA F4 EBFE',  0
irq1:
	pushad
	push es
	push ds
	push eax
	mov al, '1'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq2:
	pushad
	push es
	push ds
	push eax
	mov al, '2'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq3:
	pushad
	push es
	push ds
	push eax
	mov al, '3'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq4:
	pushad
	push es
	push ds
	push eax
	mov al, '4'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq5:
	pushad
	push es
	push ds
	push eax
	mov al, '5'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq6:
	pushad
	push es
	push ds
	push eax
	mov al, '6'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq7:
	pushad
	push es
	push ds
	push eax
	mov al, '7'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq8:
	pushad
	push es
	push ds
	push eax
	mov al, '8'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irq9:
	pushad
	push es
	push ds
	push eax
	mov al, '9'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irqa:
	pushad
	push es
	push ds
	push eax
	mov al, 'A'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irqb:
	pushad
	push es
	push ds
	push eax
	mov al, 'B'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irqc:
	pushad
	push es
	push ds
	push eax
	mov al, 'C'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irqd:
	pushad
	push es
	push ds
	push eax
	mov al, 'D'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irqe:
	pushad
	push es
	push ds
	push eax
	mov al, 'E'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
irqf:
	pushad
	push es
	push ds
	push eax
	mov al, 'F'
	mov ah, 0x2F
	mov [fs:0xB8000], ax
	mov   al, 0x20
	out   0xA0, al
	out   0x20, al
	pop eax
	pop ds
	pop es
	popad
	iret
	