use16
get_total_memory:
	  push dx
	  push cx
	  push ebx
	  xor eax, eax
	  xor ebx, ebx
	  ;; BIOS 0xE801 - Get total Memory
	  mov ax, 0xE801
	  xor dx, dx
	  xor cx, cx
	  int 0x15
	  jnc .NEXT
	  xor eax, eax
	  jmp .done				   
.NEXT:
	  mov si, ax
	  or si, bx
	  jne .NEXT_2
	  mov ax, cx
	  mov bx, dx
.NEXT_2:
	  cmp ax, 0x3C00
	  jb .TOTAL_MEM_UNDER_16
	  movzx eax, bx
	  add eax, 0x100
	  shl eax, 16			      
	  jmp .done
.TOTAL_MEM_UNDER_16:
	  shl	  eax, 10			      
.done:
	  pop ebx
	  pop cx
	  pop dx
	  ret