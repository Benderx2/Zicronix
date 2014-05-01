;; Random Task Switching Code
;; task_switch - Switches tasks
task_switch:
	cmp dword [current_task], 128
	je .first_thread
.task_switch:
	;; push the registers of the current thread
	pushad
	push ds        ;Push segment d
	push es        ;Push segmetn e
	push fs        ; ''
	push gs        ; ''
	;; Now get the current task
	mov eax, [current_task]
	mov esi, thread_buf
	mov ecx, 9
	mul ecx
	add esi, eax
	lodsb
	cmp al, 0
	je .next_task
	lodsd
	mov esp, eax
	pop gs
	pop fs
	pop es
	pop ds
	popa         
	iret
.first_thread:	
	mov dword [current_thread], 0
	jmp .task_switch
	current_task dd 0x0