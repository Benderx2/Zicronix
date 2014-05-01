;; ITOA32 - Int to String 32
;; Some of these were borrowed from MikeOS.
;; I converted it to 32-bit Mode, and FASM-Syntax
;; In : Decimal in EAX
;; Out : String in EAX
use32
define BASE_10 10
define BASE_16 16
itoa32:
	pushad
	xor ecx, ecx
	;; Decimal Calculation (BASE 10)
	mov ebx, BASE_10
	mov edi, .buffer			; Get our pointer ready
.push:
	xor edx, edx
	div ebx				; Remainder in EDX, quotient in EAX
	inc ecx				; Increase pop loop counter
	push edx				; Push remainder, so as to reverse order when popping
	test eax, eax			; Is quotient zero?
	jnz .push			; If not, loop again
.pop:
	pop edx				; Pop off values in reverse order, and add 48 to make them digits
	add dl, '0'			; And save them in the string, increasing the pointer each time
	mov [edi], dl
	inc edi
	dec ecx
	jnz .pop
	mov byte [edi], 0		; Zero-terminate string
	popad
	mov eax, .buffer			; Return location of string
	ret
	.buffer: times 7 db 0
strcmp:
	times 29 db 0

;; CMP_STR : Compare String (Uses REPE CMPSB)
;; IN : ES:ESI - String I
;; 	    DS:ESI - String II
;; OUT: Registers Preserved
;; 		Carry set if match	 
cmp_str:
	;; Push All Registers
	pushad                                            
	push es                                        
	push ds           
	;; Set DS and ES to proper selectors
	mov	ax, 0x18                                   
	mov	ds, ax			                    
	mov	es, ax   
	;; Is ECX a null character
	cmp	ecx, 0                                     
	je .failure    
	;; Clear Direction Flag for CMPSB
	cld
	;; REPE CMPSB - 
	;; CMPSB - Compares bytes,
	;; REPE - Repeat if equal
	repe cmpsb 
	;; If equal then good
	je .success                                               
.failure:   
	;; POP All the preserved registers
	pop	ds                                        
	pop	es                                        
	popad                                             
	clc                                               
	ret                                               
.success: 
	;; POP All the preserved registers
	pop	ds                                        
	pop	es                                        
	popad 
	;; Set carry
	stc                                               
	ret        
;; String Length
strlen:
	xor eax, eax
	push esi
.loop:
	mov byte bl, [esi]
	cmp bl, 0
	je .done
	inc esi
	inc eax
	jmp .loop
.done:
	pop esi
	ret
;; EAX - String Location	
;; Captalizes String
strcap:
	pushad
	mov esi, eax			
.loop:
	;; End of string
	cmp byte [esi], 0		
	je .finish
	;; Something lesser than 'a', nope
	cmp byte [esi], 'a'		
	jb .continue
	;; Something greater than z?
	cmp byte [esi], 'z'
	ja .continue
	sub byte [esi], 0x20
	inc esi
	jmp .loop
.continue:
	;; Increment ESI
	inc esi
	jmp .loop
.finish:
	;; POP registers
	popad
	ret
;; EAX - String Location	
;; Lower Cases Strings
strlow:
	pushad
	mov esi, eax			
.loop:
	;; End of string
	cmp byte [esi], 0		
	je .finish
	;; Something lesser than 'a', nope
	cmp byte [esi], 'A'		
	jb .continue
	;; Something greater than z?
	cmp byte [esi], 'Z'
	ja .continue
	add byte [esi], 0x20
	inc esi
	jmp .loop
.continue:
	;; Increment ESI
	inc esi
	jmp .loop
.finish:
	;; POP registers
	popad
	ret
;; Return separated string
;; BL - Separator
;; ESI - start
;; OUT:
;; EDI - Next String after separator
str_separate:
	push esi
.next:
	cmp byte [esi], bl
	je .finish_separator
	cmp byte [esi], 0
	jz .fail
	inc esi
	jmp .next
.finish_separator:
	mov byte [esi], 0
	inc esi
	mov edi, esi
	pop esi
	ret
.fail:
	mov edi, 0
	pop esi
	ret
;; Clear String
;; IN : EDI - String Location
;; 		ECX - Length
clear_string:
	pushad
	mov al, 0x00
	rep stosb
	popad
	ret
;; btoc32 bcd to ascii character
;; bcd in al.
;; output in bcd_data.value and AX.
btoc32:
	   pushad					
       mov ah, al					
       and ax, 0xF00F				
       mov cl, 4					
       shr ah, cl					
       or ax, 0x3030				  
       xchg ah, al					  
       mov     [bcd_data.value], ax 				  
       popad				
	   ;; Pass ax.
	   mov ax, [bcd_data.value]
       ret	
bcd_data:
	.value dw 0x0000
;; string to int
;; in: esi - string
;; out: ecx - Number
;; esi destroyed \* */
;				   _
atoi32:
	push eax
	push ebx
	xor ecx, ecx
	xor eax, eax
	mov bl, 9
	cld
.loop:
	lodsb
	sub al, '0'
	js .exit
	cmp al, bl
	ja .exit
	lea ecx, [ecx+4*ecx]
	lea ecx, [2*ecx+eax]
	jmp .loop
.exit:
	pop ebx
	pop eax
	ret