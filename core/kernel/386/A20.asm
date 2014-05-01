;; Enables the A20 Line through the Keyboard port
;; 16-bit Real Mode Code
use16
Enable_A20: 
	;; Push all 16-bit Registers
	pusha
	;; Check For A20 Line 
	call check_a20
	jnc .done
	;; Print a error message if not found
	mov si, _A20_ERROR
	call bios_printf
	xor ax, ax
	int 0x16
	;; First Try the BIOS Method.
	mov ax, 0x2401
	int 0x15
	;; Is it now enabled?
	call check_a20
	jnc .done
	mov si, _A20_BIOS_ERROR
	call bios_printf
	xor ax, ax
	int 0x16
	;; Clear Interrupts Don't wanna be interrupted
	cli	  
	;; Clear Direction Flag
	cld                                          
	;; Mask All IRQs                                 		       
	out32 PIC1_COMMAND, 255                                   
	out32 PIC2_COMMAND, 255                                   
.A20_1:	
	in al, KEYBOARD	                                  		       
	test al, 2	                                  		       
	jnz .A20_1                                 		       
	out32 KEYBOARD, 0xD1                                  		       
.A20_2:	
	in al, KEYBOARD	                                  	       
	test al, 2                                      
	jnz .A20_2	                                 
	out32 0x60, 0xDF	
	;; Loop 0x14 Times
	mov cx, 0x14                                    
.A20_3:					                    
	out 0xED, ax			                  
	loop .A20_3
	;; Restore Interrupts
	sti
	;; Check Again.
	call check_a20
	jnc .done
	mov si, _A20_KEYBOARD_ERROR
	call bios_printf
	xor ax, ax
	int 0x16
	;; Use the FastA20 Method
.done:
	sti                 
	;; Restore registers and return
	popa                                              
	ret  

check_a20:
    push ds
    push es
    mov ax, 0x0000
    mov bx, 0xFFFF
    mov ds, ax
    mov es, bx
    mov ax, [ds:0x0000]           ;ax = word at 0x0000:0x0000 (or 0x00000000)
    cmp [es:0x0010], ax           ;Is it the same as the word at 0xFFFF:0x0010 (or 0x00100000)?
    jne .enabled                ; no, A20 must be enabled
    inc word [es:0x0010]         ;Change the word at 0xFFFF:0x0010 (or 0x00100000)
    cmp [ds:0x0000], ax           ;Did the word at 0x0000:0x0000 (or 0x00000000) change?
    je .disabled                 ; yes, A20 must be disabled

    dec word [es:0x0010]         ;Restore the word at 0xFFFF:0x0010
.enabled:
    pop es
    pop ds
    clc                          ;carry = return status
    ret

.disabled:
    dec word [es:0x0010]         ;Restore the word at 0xFFFF:0x0010 and 0x0000:0x0000 (it's the same word)
    pop es
    pop ds
    stc                          ;carry = return status
    ret
_A20_ERROR: db 13,10, 'A20 Not Enabled by Machine. Press a key to try all possible methods.', 0
_A20_BIOS_ERROR: db 13, 10, 'A20 BIOS ERROR!. Trying the Keyboard Controller. Press a Key to Continue...', 0
_A20_KEYBOARD_ERROR: db 13, 10, 'A20 KEYBOARD ERROR!. Press a key to use the FASTA20 Method.', 0