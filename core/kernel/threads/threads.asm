;; -- create thread ---
;; creates a thread
;; IN:
;; EAX - Pointer to EIP (of thread)
;; EBX - Stack buffer allocated for thread
;; ECX - Pointer to Process Context Block
;; Buffer for existing threads
thread_buf: resb 1152 ;; Maximum of 128 threads
create_thread:
	;; save gprs
	pushad
	;; store values for later use
	mov [.tmp_pointer_to_EIP], eax
	mov [.stack_buf], ebx
	mov [.process_PCB], ecx
	;; is number of tasks 128?
	mov eax, [number_of_threads]
	cmp eax, 128
	jge .task_error
	;; okay now browse through entries and create a thread 
	mov esi, thread_buf
	mov ecx, 128
;; get a byte from esi
.find_loop:
	mov al, [esi]
	;; is it 0? i.e. unused task buffer
	cmp al, 0
	;; Cool we found it.
	je .found_task
	;; else add 9 to esi, next task property
	add esi, 9
	loop .find_loop
.found_task:
	;; esi points to the property buffer
	;; now set the task to 1 - active
	mov al, 1
	stosb
	;; copy the stack pointer
	mov eax, [.stack_buf]
	stosd
	;; copy the PCB address
	mov eax, [.process_PCB]
	stosd
	;; null-out GPRs
	xor eax, eax
	xor ebx, ebx
	xor ecx, ecx
	xor edx, edx
	xor esi, esi
	xor edi, edi
	;; set eax to the start EIP of task.
	mov eax, [.tmp_pointer_to_EIP]
	;; Save stack ptr
	mov dword [kernel_stack_ptr_save], esp
	;; Switch to new thread stack
	mov esp, [.stack_buf]
	;; PUSH EFLAGS
	push dword 0x0202
	;; push code segment
	push dword CODE_SEL
	;; push EIP
	push eax
	xor eax, eax
	;; PUSHAD!
	pushad
	;; Next Push the other segments 
	;; DS=ES
	push dword DATA_SEL
	push dword DATA_SEL
	;; FS=0x08
	push dword 0x08
	;; GS=DS=ES
	push dword DATA_SEL
	;; Restore kernel stack
	mov esp, [kernel_stack_ptr_save]
	popad
	ret
.task_error:
	mov esi, task_fatal_error
	call printf32
	;; Halt! :-)
	cli
	hlt
	jmp $
	.stack_buf dd 0x0
	.tmp_pointer_to_EIP dd 0x0
	.process_PCB dd 0x0
	task_fatal_error db 0x0a, 'Maximum number of Tasks Created. System out of task buffers, Halting......', 0x0a, 0
	number_of_threads dd 0x0
	kernel_stack_ptr_save dd 0x0
	
	
	
	
	
	
	