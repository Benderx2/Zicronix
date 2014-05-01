;; serial calls.
define COM_1 0x3F8
;; al - serial to send
send_serial:
	push edx
	push eax		
	mov dx, COM_1+5		
.wait:
	in al, dx
	bt ax, 5		
	jnc .wait	
	pop eax			
	mov dx, COM_1	
	out dx, al		
	pop edx
	ret
;; al - byte received
recv_serial:
	push edx
	mov dx, COM_1+5		
	in al, dx
	bt ax, 0		
	jnc .done
	mov dx, COM_1		
	in al, dx		
.done:
	pop edx
	ret
;; serial write string - write string to serial.
;; esi - string
serial_write_string:
	push esi
	push eax
.loop:
	lodsb
	cmp al, 0
	je .done
	cmp al, 0x0A
	je .add_newline
	call send_serial
	jmp .loop
.add_newline:
	mov al, 13
	call send_serial
	mov al, 10
	call send_serial
	jmp .loop
.done:
	pop esi
	pop eax
	ret   