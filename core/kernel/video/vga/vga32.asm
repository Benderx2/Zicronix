;; VGA32.ASM - Stuff regarding VGA in 32-bit Protected Mode
use32
;; Some constants
screen_x db 0
screen_y db 0
textcolor db 0x0A
video_memory equ 0xB8000
max_x = 90
max_y = 60
;; printc32 - Prints a char in BL
vga_printc32:
	;; Save regs
	pushad
	;; Set the pointer to Video Memory
	mov edi, video_memory
	;; Set the segment registers
	;; Null out EAX
	xor eax, eax
	mov ecx, max_x * 2
	mov al, byte [screen_y]
	mul ecx
	;; Save the multiplication
	push eax
	mov al, byte [screen_x]
	mov cl, 2
	mul cl
	pop ecx
	add eax, ecx
	xor ecx, ecx
	;; EDI = Video Memory
	;; EAX = Offset
	;; Add EDI and EAX to get exact memory location
	add edi, eax
	;; Newline Char?
	cmp bl, 0x0A
	je .newline
	;; Set DL to character
	mov dl, bl
	;; And DH to color
	mov dh, byte [textcolor]
	;; Write to Video Memory
	mov [fs:edi], dx
	;; Update Cursor
	inc byte [screen_x]
	;; Check for max_x
	cmp [screen_x], max_x
	je .newline
	jmp .done
.newline:
	cmp byte [screen_y], max_y - 1
	je .scroll
	inc byte [screen_y]
	mov byte [screen_x], 0
	jmp .done
.scroll:
	call scroll32
	jmp .done
.done:
	;; Update Hardware Cursor
	call movecursor32_INTERNAL
	popad
	ret
;; printf32 - Prints a string in ESI
vga_printf32:
		pushad
		;; Put ESI in EDI
		push esi
		pop edi
		;; Loop Down
._loop:
		;; Get one character at a time
		mov bl, byte [edi]
		;; A TAB? \t?
		cmp bl, 0x09
		je .tab
		;; If it's null then exit
		cmp bl, 0x00
		je .done
		;; Else print it.
		call printc32
		;; Increment EDI
		inc edi
		jmp ._loop
.tab:
		pushad
		mov ecx, 4
		mov bl, ' '
.looooooooop:
		call vga_printc32
		loop .looooooooop
		popad
		inc edi
		jmp ._loop
.done:
		popad
		ret
;; Print MEM - Prints a Memory Location should end with '0x55'
;; EAX should be set to number of chars to print		
printmem32:
		pushad
		;; Put ESI in EDI
		push esi
		pop edi
		;; Loop Down
._loop:
		;; Get one character at a time
		mov bl, byte [edi]
		;; Print it.
		call printc32
		;; Increment EDI
		inc edi
		;; Decrement Counter
		dec eax
		cmp eax, 0
		jne ._loop
.done:
		popad
		ret
		
vga_clearscreen:
		;; If you don't understand what this does, why are you even
		;; looking at this source :P
		;; Push all the regs to stack
		pushad
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
		;; Set the Cursor to 0,1 
		mov byte [screen_x], 0
		mov byte [screen_y], 1
		call movecursor32_INTERNAL
		jmp .done
.done:
		pop fs
		popad
		ret
;; Scroll - Scrolls the screen if EOS (End Of Screen) :P
vga_scroll32:
		;; Push all the stuff to be used
		pushad
		push fs
		push es
		push ds
		;; Set FS to data selector
		mov ax, 0x8
		mov fs, ax
		;; Set the Destination and Source
		;; Indexes to point to Video Memory
		mov edi, video_memory
		mov esi, video_memory
		add esi, max_x * 2
		mov ecx, max_x * 2 * max_y / 4
		;; Prepare to Enter loop
.scr_loop:
		;; EAX should be our block
		;; of memory
		mov eax, [fs:esi]
		;; Increment source by 4
		add esi, 4
		;; Put eax, into memory
		mov [fs:edi], eax
		;; Increment Destination by 4
		add edi, 4
		;; Decrement counter
		dec ecx
		;; Is ECX = 0?
		cmp ecx, 0x00000000
		jnz .scr_loop
		mov byte [screen_x], 0
		mov byte [screen_y], max_y - 1
		call movecursor32_INTERNAL
		pop ds
		pop es
		pop fs
		popad
		ret
movecursor32_INTERNAL:
	pushad
	push eax                                       
	push ebx                                       
	push ecx                                       
	push edx                                       
	xor	ebx,ebx                                   
	mov	bl, [screen_x]				       
	mov	ecx, ebx                                   
	mov	bl, [screen_y]				        
	mov	eax, max_x                           
	mul	bx                                        
	add	eax, ecx 				  
	mov	edx, 0x3D4                                 
	mov	ecx, eax                                   
	mov	al, 0x0F                                   
	out	dx, al                                     
	mov	eax, ecx                                   
	inc	edx                                       
	out	dx, al                                     
	mov	al, 0x0E                                   
	dec	edx                                       
	out	dx, al                                     
	mov	eax, ecx                                   
	mov	al, ah                                     
	inc	edx                                       
	out	dx, al					      
	pop	edx                                       
	pop	ecx                                       
	pop	ebx                                       
	pop	eax  
	popad
	ret      
set_palette16:
     push     ax
     push     cx
     push     dx

     xor     cx, cx
     .l1:
     mov     dx, 0x3DA
     in     al, dx
     mov     al, cl               ; color no.
     mov     dx, 0x3C0
     out     dx, al
     inc     dx                  ; port 0x3C1
     in     al, dx
     mov     dx, 0x3C8
     out     dx, al

     inc     dx                  ; port 0x3C9
     mov     al, byte [esi]            ; red
     out     dx, al
     inc     esi
     mov     al, byte [esi]            ; green
     out     dx, al
     inc     esi
     mov     al, byte [esi]            ; blue
     out     dx, al
     inc     esi

     inc     cx
     cmp     cx, 16
     jl     .l1

     mov     dx, 0x3DA
     in     al, dx
     mov     al, 0x20
     mov     dx, 0x3C0
     out     dx, al

     pop     dx
     pop     cx
     pop     ax
     ret
 
	 palette16:     
		   db   20, 30, 57 , 00, 00, 00, 00, 61, 54, 10, 42, 42, 42
           db   00, 00, 42, 00, 42, 42, 21, 00, 42, 42, 42, 21, 21
           db   21, 21, 21, 63, 00, 63, 21, 21, 63, 63, 63, 21, 21
           db   63, 21, 63, 63, 63, 21, 63, 63, 63
		   
;; Draw Block
;; IN : AH - Start point (X), AL - Start Point (Y), CL - Color, DH - End Point (X), DL - End point (Y)
drawblock32:
	pushad
	;; save co-ordinates
	mov ch, [screen_x]
	mov byte [.screen_save_x], ch
	mov ch, [screen_y]
	mov byte [.screen_save_y], ch
	;; save color
	mov byte ch, [textcolor]
	mov byte [.screen_save_color], ch
	;; Set cursor
	mov byte [screen_x], ah
	mov byte [screen_y], al
	;; Set color
	mov byte [textcolor], cl
.print_loop:
	;; Keep printing a Space
	mov bl, ' '
	call printc32
	;; Is screen_x end of line?
	cmp byte [screen_x], dh
	jne .print_loop
.newline:
	inc byte [screen_y]
	mov byte [screen_x], ah
	cmp byte [screen_y], dl
	je .done
	jmp .print_loop
.done:
	;; Set the original cursors back
	mov ch, [.screen_save_y]
	mov byte [screen_y], ch
	mov ch, [.screen_save_x]
	mov byte [screen_x], ch
	mov byte ch, [.screen_save_color]
	mov byte [textcolor], ch
	popad
	ret
	.screen_save_y db 0x00
	.screen_save_x db 0x00
	.screen_save_color db 0x00
;; change the cursor
changecur32:
		  pushad
          mov   dx,0x3D4
          mov   al,0x0A
          mov   ah,bh
          out   dx,ax
          inc   ax
          mov   ah,bl
          out   dx,ax
          popad
          ret