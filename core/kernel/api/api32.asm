;; API32 - Interrupts used as an API 8)
use32
sys_api_32:
	pushad
	cmp ah, 0x00
	je .exit
	;; Check whether AH = 1
	cmp ah, 0x01
	;; AH = 0x01 - Print String 
	;; ESI = Print String
	je .printf
	;; AH = 0x02 - Set Interrupt Vector.
	;; Sets an entry in the IDT
	;; EDX = Pointer to Entry
	;; AL = Interrupt Number
	cmp ah, 0x02
	je .set_int_vector
	;; AH = 0x03
	;; Set Text Color
	;; AL = Color
	cmp ah, 0x03
	je .set_text_color
	;; Dump Registers
	cmp ah, 0x04
	je .dmp_reg
	;; ITOA32
	cmp ah, 0x05
	je .itoa
	;; Beep
	cmp ah, 0x06
	je .beep32
	;; AH = 0x07 Wait For Key
	cmp ah, 0x07
	je .waitkey32
	;; AH = 0x08 Get String Input
	cmp ah, 0x08
	je .getstrinpt32
	;; ah = 0x09
	;; start speaker
	;; bx - freq
	;; ecx  - seconds*10
	cmp ah, 0x09
	je .speaker_beep
	cmp ah, 0x10
	je .print_color
	mov esi, _int_error
	call printf32
	jmp api_32_exit
.printf:
	call printf32
	jmp api_32_exit
.set_int_vector:
	;; Sets the Interrupt Vector
	;; Save the registers that we'll
	;; be using.
	push es
	push ds
	;; We'll be using ECX later
	push ecx
	; DS should be the Data Selector
	mov cx, DATA_SEL_32
	mov ds, cx
	pop ecx
	movzx eax, al
	shl eax, 3
	;; Get linear address in IDT
	add eax, idt
	;; Clear Interrupts
	cli
	;; And add the entry to IDT
	mov word [ds:eax], dx
	shr edx, 16
	mov word [ds:eax + 6], dx
	sti
	;; Restore Registers
	pop ds
	pop es
	;; Just in case
	mov ax, DATA_SEL
	mov ds, ax
	mov es, ax
	;; Clear Carry (for success)
	clc
	;; And return
	jmp api_32_exit
.set_text_color:
	;; Set the TextColor Variable to AL
	mov byte [textcolor], al
	jmp api_32_exit
.dmp_reg:
	push eax
	mov eax, [esp]
	mov dword [.pre_eip], eax
	pop eax
	;; Save EAX and ESI :)
	mov dword[.pre_esi], esi
	mov dword [.pre_eax], eax
	;; Push CS
	push cs
	;; Pop into EAX
	pop eax
	call itoa32
	mov esi, _CS_string
	call printf32
	mov esi, eax
	call printf32
	;; Print EAX
	mov dword eax, [.pre_eax]
	call itoa32
	mov esi, _EAX_string
	call printf32
	mov esi, eax
	call printf32
	;; Print EBX
	mov eax, ebx
	call itoa32
	mov esi, _EBX_string
	call printf32
	mov esi, eax
	call printf32
	;; Print ECX
	mov eax, ecx
	call itoa32
	mov esi, _ECX_string
	call printf32
	mov esi, eax
	call printf32
	;; Print EDX
	mov eax, edx
	call itoa32
	mov esi, _EDX_string
	call printf32
	mov esi, eax
	call printf32
	;; Time to Get SS
	push ss
	pop eax
	call itoa32
	mov esi, _SS_string
	call printf32
	mov esi, eax
	call printf32
	;; Time to get ESP
	push esp
	pop eax
	call itoa32
	mov esi, _ESP_string
	call printf32
	mov esi, eax
	call printf32
	;; Time to Print ESI
	mov dword eax, [.pre_esi]
	call itoa32
	mov esi, _ESI_string
	call printf32
	mov esi, eax
	call printf32
	;; Print EDI
	mov eax, edi
	call itoa32
	mov esi, _EDI_string
	call printf32
	mov esi, eax
	call printf32
	;; Print DS
	push ds
	pop eax
	call itoa32
	mov esi, _DS_string
	call printf32
	mov esi, eax
	call printf32
	;; Print ES
	push es
	pop eax
	call itoa32
	mov esi, _ES_string
	call printf32
	mov esi, eax
	call printf32
	;; Print FS
	push fs
	pop eax
	call itoa32
	mov esi, _FS_string
	call printf32
	mov esi, eax
	call printf32
	;; Print GS
	push gs
	pop eax
	call itoa32
	mov esi, _GS_string
	call printf32
	mov esi, eax
	call printf32
	;; Print EFLAGS
	;; Push flags onto stack
	pushfd
	;; Pop it into EAX
	pop eax
	call itoa32
	mov esi, _EF_string
	call printf32
	mov esi, eax
	call printf32
	mov eax, [.pre_eip]
	sub eax, 7
	call itoa32
	mov esi, _EIP_string
	call printf32
	mov esi, eax
	call printf32
	jmp api_32_exit
	.pre_esi: times 8 dw 0
	.pre_eax: times 8 dw 0
	.pre_eip: times 8 dw 0
.itoa:
	call itoa32
	jmp api_32_exit
.beep32:
	jmp api_32_exit
.waitkey32:
	call WaitKey
	jmp api_32_exit
.getstrinpt32:
	call GetString
	jmp api_32_exit
.print_color:
	push ecx
	push ebx
	mov cl, [textcolor]
	mov [textcolor], bl
	mov bl, al
	call printc32
	mov [textcolor], cl
	pop ebx
	pop ecx
	jmp api_32_exit
.exit:
	popad
	;; Well do stuff
	mov ax, DATA_SEL
	mov ds, ax
	mov ss, ax
	nop
	mov es, ax
	mov gs, ax
	mov ax, 0x08
	mov fs, ax
	mov esp, KERNEL_STACK_BUFFER
	;; BUG HERE - IRQs are masked after return
	call remap_pic32
	call UNMASK_IRQ
	mov ebx, 10
	call pit_init
	sti
	jmp shell32
.speaker_beep:
	push eax
	mov ax, bx
	call os_speaker_on
	pop eax
	call init_timer
	call os_speaker_off
	jmp api_32_exit
api_32_exit:
	popad
	iret
;; DATA Here :
_int_error: 
	db 0x0A,'SYS API 32 - Error, Invalid Argument Passed to INT 0x30', 0x0A, 0
_CS_string:
		db 0x0A, ' CS : ', 0
_EAX_string:
		db 0x0A, 'EAX : ', 0
_EBX_string:
		db 0x0A, 'EBX : ', 0
_ECX_string:
		db 0x0A, 'ECX : ', 0
_EDX_string:
		db 0x0A, 'EDX : ', 0
_SS_string:
		db 0x0A, ' SS : ', 0
_ESP_string:
		db 0x0A, 'ESP : ', 0
_ESI_string:
		db 0x0A, 'ESI : ', 0
_EDI_string:
		db 0x0A, 'EDI : ', 0
_DS_string:
		db 0x0A, ' DS:  ', 0
_ES_string:
		db 0x0A, ' ES:  ', 0
_FS_string:
		db 0x0A, ' FS:  ', 0
_GS_string:
		db 0x0A, ' GS:  ', 0
_EF_string:
		db 0x0A, 'EFLAGS: ', 0
_EIP_string:
		db 0x0A, 'EIP : ', 0
