; 80387.ASM - Initializes the 80387 FPU
init_80387:
	use16
	finit				  ; Initialize the FPU
	mov word [TEST_WORD], 0x8855	; Set TEST_WORD to 0x8855 (Any non-zero digit)
	fnstsw	[TEST_WORD]		; Save the FPU State
	cmp word [TEST_WORD], 0 ; FPU State should be 0
	jne NO_FPU			; Bad luck :(
	mov si, _fpu
	call bios_printf
	ret
	_fpu:
		db '80387 FPU Detected!', 13, 10, 0
NO_FPU:
	mov si, _no_fpu
	call bios_printf
	ret
	_no_fpu:
		db '80387 FPU Detection Failure.', 13, 10, 0
	TEST_WORD dw 0
