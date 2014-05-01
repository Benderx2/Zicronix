;; Place where programs are loaded
LOAD_POINT equ 0x800000
use32
shell32:
	;; Empty input buffer
	mov edi, shell_input_buffer			
	mov ecx, 256
	call clear_string
	;; Change Color
	;mov ah, 0x03
	;mov al, 0xF0
	;int 0x30
	;; Print current directory
	mov esi, shell_msg_str
	call printf32
	;; Change color
	;mov ah, 0x03
	;mov al, 0x0E
	;int 0x30
	;mov al, [textcolor]
	;mov [textcolor], 0x7E
	mov byte [textcolor], 0x70
	;; Print the prompt
	mov esi, shell_prompt_str
	call printf32
	;mov [textcolor], al
	;; Change Color again
	;mov ah, 0x03
	;mov al, 0x0F
	;int 0x30
	mov eax, shell_input_buffer
	call GetString
	;; Change output color
	;; Change Color again
	;mov ah, 0x03
	;mov al, 0x0F
	;int 0x30
	;; Convert it to captial letters
	mov eax, shell_input_buffer
	call strcap
	mov esi, shell_input_buffer
	;; Is it null?
	cmp byte [esi], 0
	je shell32
	;; Separate it into tokens
	mov esi, shell_input_buffer
	mov bl, ' '
	call str_separate
	mov dword [shell_args], edi
	;; Well does it contain './'
	cmp word [shell_input_buffer.identifier], './'
	;; Yes it's a executable
	je load_file
	;; Now compare the strings
	;; HELP
	mov edi, shell_help_str
	call cmp_str
	jc shell_help
	;; REGDUMP
	mov edi, shell_reg_dump_str
	call cmp_str
	jc shell_dump
	;; CLEAR
	mov edi, shell_clear_str
	call cmp_str
	jc shell_clear
	;; TOTALMEM
	mov edi, shell_total_mem_str
	call cmp_str
	jc shell_total_mem
	;; CPUID
	mov edi, shell_cpuid_str
	call cmp_str
	jc shell_cpuid
	;; UPTIME
	mov edi, shell_uptime_str
	call cmp_str
	jc shell_uptime
	;; REBOOT
	mov edi, shell_reboot_str
	call cmp_str
	jc shell_reboot
	;; BOCHS 
	mov edi, shell_bochs_str
	call cmp_str
	jc shell_bochs
	;; DIR
	mov edi, shell_dir_str
	push ecx
	mov ecx, 2
	call cmp_str
	pop ecx
	jc shell_dir
	;; CHDIR?
	mov edi, shell_ch_dir_str
	push ecx
	mov ecx, 2
	call cmp_str
	pop ecx
	jc ch_dir
	mov edi, shell_mkdir_str
	push ecx
	mov ecx, 5
	call cmp_str
	pop ecx
	jc shell_mkdir
	;; CAT?
	mov edi, shell_cat_str
	push ecx
	mov ecx, 3
	call cmp_str
	pop ecx
	jc shell_cat
	;; RMDIR?
	mov edi, shell_rmdir_str
	push ecx
	mov ecx, 5
	call cmp_str
	pop ecx
	jc shell_rmdir
	;; RM?
	mov edi, shell_rm_str
	push ecx
	mov ecx, 2
	call cmp_str
	pop ecx
	jc shell_rm
	;; MK?
	mov edi, shell_mk_str
	push ecx
	mov ecx, 2
	call cmp_str
	pop ecx
	jc shell_mk
	;; TIME?
	mov edi, shell_time_str
	call cmp_str
	jc shell_time
	;; DATE?
	mov edi, shell_date_str
	call cmp_str
	jc shell_date
	;; COLOR?
	mov edi, shell_color_str
	push ecx
	mov ecx, 5
	call cmp_str
	pop ecx
	jc shell_color
	;; ECHO
	mov edi, shell_echo_str
	push ecx
	mov ecx, 4
	call cmp_str
	pop ecx
	jc shell_echo
	;; SIZE?
	mov edi, shell_size_str
	push ecx
	mov ecx, 4
	call cmp_str
	pop ecx
	jc shell_size
	;; PWD?
	mov edi, shell_pwd_str
	call cmp_str
	jc shell_pwd
	jmp shell_error
;; If the command has been preceeded by a './' that means it's an executable
load_file:
	;; Well let's see if there's a executable?
	;; First Convert it
	mov esi, shell_input_buffer.command
	mov eax, esi
	call file_convert
	;; Check for existence
	;mov esi, eax
	;call file_exists32
	; Is AX = 0x00000
	;cmp ax, 0x0000
	;jne .ok
	;; ERROR
	;jmp shell_error
	;; ESI contains the Name of the File
	;; EDI should point to program load point
.ok:
	mov esi, eax
	mov edi, LOAD_POINT
	call loadfile32
	;; search continues in usr/bin
	jc search_in_bin
	;; ZNU Header?
	cmp dword [LOAD_POINT], 'ZNUX'
	je .jump_to
	jmp format_error
.jump_to:	
	;; Save current directory
	mov eax, [current_directory.offset]
	mov [shell_dir_buffer.offset], eax
	;; save cluster
	mov ax, [current_directory.cluster]
	mov [shell_dir_buffer.cluster], ax
	mov ax, DATA_SEL
	mov ds, ax
	mov es, ax
	;; Set the application stack buffer
	mov esp, APP_STACK_BUFFER
	dec esi
	;; Give the application the arguments
	mov esi, dword [shell_args]
	;; Jump!
	call CODE_SEL:LOAD_POINT+4
.sys_return:
	;; In case if the application does not 
	;; call a proper interrupt to switch
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
	;; Restore values
	mov eax, [shell_dir_buffer.offset]
	mov [current_directory.offset], eax
	jmp shell32
;; FORMAT ERROR
format_error:
	mov esi, shell_format_err_msg
	call printf32
	mov esi, LOAD_POINT
	mov eax, 200
	call printmem32
	jmp shell32
search_in_bin:
	push esi
	push edi
	mov eax, [current_directory.offset]
	mov [.save_0], eax
	mov ax, [current_directory.cluster]
	mov [.clust], ax
	mov eax, [BPB.root_dir_start]
	mov [current_directory.offset], eax
	mov eax, USR_DIR
	call chdir
	mov eax, BIN_DIR
	call chdir
	pop edi
	pop esi
	call loadfile32
	jc .error
	mov eax, [.save_0]
	mov [current_directory.offset], eax
	mov ax, [.clust]
	mov [current_directory.cluster], ax
	jmp load_file.jump_to
.error:
	mov eax, [.save_0]
	mov [current_directory.offset], eax
	mov ax, [.clust]
	mov [current_directory.cluster], ax
	jmp shell_error
	.clust dw 0
	.save_0 dd 0x0
;; SHELL ERROR
shell_error:
	mov esi, shell_error_str
	call printf32
	mov esi, shell_input_buffer
	call printf32
	mov esi, shell_error_str_2
	call printf32
	jmp shell32
;; SHELL HELP MESSAGES
shell_help:
	mov esi, shell_help_info
	call printf32
	jmp shell32
;; SHELL REGISTER DUMP
shell_dump:
	mov ah, 0x03
	mov al, 0x9F
	int 0x30
	mov ah, 0x04
	int 0x30
	jmp shell32
;; SHEL TOTAL MEMORY
shell_total_mem:
	mov dword eax, [total_memory]
	call itoa32
	mov esi, mem_string
	call printf32
	mov esi, eax
	call printf32
	jmp shell32
;; SHELL CLEAR SCREEN
shell_clear:
	call clearscreen
	jmp shell32
;; SHELL CPUID
shell_cpuid:
	mov esi, cpu_string
	call printf32
	xor eax, eax
	mov ah, [KERNEL_BOOT_DEVICE]
	call itoa32
	mov esi, _BOOT_DEVICE_MSG
	call printf32
	mov esi, eax
	call printf32
	jmp shell32
;; SHELL UPTIME FUNCTION
shell_uptime:
	mov esi, _SHELL_UPTIME
	call printf32
	mov eax, [system_timer_mS]
	call itoa32
	mov esi, eax
	call printf32
	jmp shell32
;; SHELL REBOOT
shell_reboot:
	mov esi, _REBOOT_MSG
	call printf32
	;; Write to Bochs Console
	mov esi, _REBOOT_MSG
	call BOCHS_WRITE_TO_CONSOLE
	mov ecx, 30
	call init_timer
	out32 0x64, 0xFE
	hlt
	jmp $
;; SHELL BOCHS DEBUG
shell_bochs:
	mov esi, _BOCHS_SETTING_DEBUGGER
	call BOCHS_WRITE_TO_CONSOLE
	call BOCHS_MAGIC_BREAK
	jmp shell32
shell_dir:
	mov dword eax, [shell_args]
	;; Check whether the user is asking for /mnt
	cmp dword [eax], '/MNT'
	je .list_mnt
	;; Check whether the user is asking for /ramdisk
	cmp dword [eax], '/RDK'
	je .ramdisk
	mov esi, _ROOT_DIR_CONTENT
	call printf32
	mov esi, shell_msg_str.msg
	call printf32
	mov bl, 0xA
	call printc32
	mov edi, _DIR_BUFFER
	call get_dir_list_32
	mov esi, _DIR_BUFFER
	call printf32
	jmp shell32
.list_mnt:
	mov esi, _LIST_OF_DEVICES
	call printf32
	jmp shell32
.ramdisk:
	mov esi, _RAM_DISK_MSG
	call printf32
	;; Print Contents
	mov edi, _RAMDISK_CONTENT
	call ram_disk_get_dir
	mov esi, edi
	call printf32
	jmp shell32
;; CD
ch_dir:
	mov dword eax, [shell_args]
	push eax
	cmp dword [eax], '..'
	je .switch_parent
	cmp eax, 0x00
	je .error
	;; Is eax BS?
	cmp byte [eax+1], 0
	je .ok
	call chdir_f
	jnc .error
	pop eax
	;; Well EAX contains shell args
	;; Convert to lowercase, uppercase names
	;; don't look cool.
	call strlow
	;; Set ESI to filename
	mov esi, eax
	;; Is ESI '.'
	;; Same Directory
	cmp word [esi], dot_null
	;; Don't do anything, simply exit to shell
	je .ok
	;; Is ESI '..'?
	cmp word [esi], '..'
	je .decrement
	mov edi, shell_msg_str.directory_buffer
.find_zero_loop:
	;; Loop till we find any empty space.
	cmp byte [edi], 0
	je .done_find_zero
	inc edi
	jmp .find_zero_loop
.done_find_zero:
	;; Add a '/'
	mov al, '/'
	stosb
.loop:
	;; Get one byte from ESI
	lodsb
	cmp al, 0
	je .done
	;; Or else copy it.
	stosb
	jmp .loop
.decrement:
	;; Okay, we need to decrement the directory
	;; buffer.
	;; Empty out slash counter '/'
	xor ecx, ecx
	;; Set EDI to buffer end
	mov edi, shell_msg_str.directory_end
.find_slash_loop:
	;; Find the first slash from the end
	cmp byte [edi], '/'
	je .first_slash_found
	;; Decrement counter by 1
	dec edi
	jmp .find_slash_loop
.first_slash_found:
	;; EDI holds pointer to '/'
	;; Set to AL to NULL.
	mov al, 0x00
	;; Check whether we found another '/'
	cmp byte [edi], '/'
	;; Good Everything cleared out.
	je .done_decrement
	;; Else copy it into EDI
	mov byte [edi], al
	;; Decrement pointer
	dec edi
	;; And loop
	jmp .first_slash_found
.done:
	;; Null Terminate
	mov al, 0
	stosb
	jmp shell32
.done_decrement:
	;; Remember to Null terminate
	mov al, 0x00
	stosb
	jmp shell32
.error:
	pop eax
	mov esi, ch_dir_error
	call printf32
	jmp shell32
.switch_root:
	mov dword eax, [BPB.root_dir_start]
	mov dword [current_directory.offset], eax
	jmp .ok
.switch_parent:
	pop eax
	mov eax, dot_dot
	call chdir
	jmp .decrement
.ok:
	jmp shell32
;; SHELL CAT
shell_cat:
	mov eax, [shell_args]
	call file_convert
	mov esi, eax
	call file_exists32
	cmp ax, 0x0000
	je .error
	;; Buffer Location - 3MB
	mov edi, 0x300000
	call loadfile32
	mov esi, 0x300000
.loop:
	lodsb
	cmp al, 0x00
	je .done
	cmp al, 13
	je .loop
	mov bl, al
	call printc32
	jmp .loop
.done:
	jmp shell32
.error:
	mov esi, _CAT_ERROR
	call printf32
	jmp shell32
;; MKDIR
shell_mkdir:
	mov eax, dword [shell_args]
	call dir_convert
	mov esi, eax
	call mkdir32
	jmp shell32
;; PWD
shell_pwd:
	mov esi, shell_msg_str
	call printf32
	jmp shell32
;; RMDIR
shell_rmdir:
	mov eax, [shell_args]
	call dir_convert
	mov esi, eax
	call rm_file
	cmp eax, 0x0000
	je .error
	jmp shell32
.error:
	mov esi, RM_DIR_ERROR
	call printf32
	jmp shell32
;; RM
shell_rm:
	mov eax, [shell_args]
	call file_convert
	mov esi, eax
	call rm_file
	cmp eax, 0x00000000
	je .error
	jmp shell32
.error:
	mov esi, RM_DIR_ERROR
	call printf32
	jmp shell32
;; MK
shell_mk:
	mov eax, [shell_args]
	call file_convert
	mov esi, eax
	;; At least 1 byte
	mov ecx, 1
	call createfile32
	jmp shell32
;; Time
shell_time:
	mov edi, time_buf
	call rtc_get_time_string
	mov esi, time_buf
	call printf32
	jmp shell32
;; Date
shell_date:
	mov edi, time_buf
	call rtc_get_date_string
	mov esi, time_buf
	call printf32
	jmp shell32
;; size
shell_size:
	mov esi, size_msg
	call printf32
	mov eax, dword [shell_args]
	call file_convert
	mov esi, eax
	call entry_exists
	cmp ax, 0x00
	je .error
	mov eax, ecx
	call itoa32
	mov esi, eax
	call printf32
	jmp shell32
.error:
	mov esi, doesnt_exist
	call printf32
	jmp shell32
SHELL_DATA:
	;; Put all the shell data here
	shell_color_str: db 'COLOR',0 
	shell_mk_str db 'MK'
	shell_rm_str db 'RM', 0
	shell_help_str db 'HELP', 0
	shell_clear_str db 'CLEAR', 0
	shell_reg_dump_str db 'REGDUMP', 0
	shell_mode_13_str db 'VGA13', 0
	shell_total_mem_str db 'TOTALMEM', 0
	shell_time_str db 'TIME', 0
	shell_date_str db 'DATE', 0
	shell_cpuid_str db 'CPU32', 0
	shell_uptime_str db 'UPTIME', 0
	shell_bochs_str db 'BOCHS', 0
	shell_reboot_str db 'REBOOT', 0
	shell_dir_str db 'LS', 0
	shell_ch_dir_str db 'CD', 0
	shell_cat_str db 'CAT', 0
	shell_pwd_str db 'PWD', 0
	shell_error_str db 'zshell: ', 0
	shell_rmdir_str db 'RMDIR', 0
	shell_echo_str db 'ECHO', 0
	shell_size_str db 'SIZE', 0
	dot_null: db '.', 0
	shell_mkdir_str: db 'MKDIR', 0
	shell_error_str_2 db ' -command not found', 0
	shell_help_info db '==============================================', 0x0a
					db 'Zicronix Shell Version 0.25.6', 0x0a
					db '==============================================', 0x0a
	db 0x0A, 'Alpha (Or whatever BS)', 0x0A, 'help - Shows This', 0x0A, 'clear - Do I need to Explain this stuff?', 0x0A, 'regdump - Shows the CPU registers', 'uptime - Shows Uptime (in 1/10s)', 0x0A, 'reboot - Reboots The Computer',0x0A
	db 'debug - Switches to Internal Debugger',0x0A,'cpu32 - Shows CPU Name and Boot Device Number', 0x0A, 'ls - Shows files and directories', 0x0A, 'cd - Switches to a Directory', 0x0A, 'mk - Create a file', 0x0A, 'rm - Remove a file', 0x0A, 'time - Get the time', 0x0A, 'date - Get the date', 0xa, 'cat - Show the contents of a file', 0x0a, 'color - change text color (MUST BE IN DECIMAL)', 0x0a, 'echo - Prints String as argument'
	db 0x0a, 'size - Query the size of a file', 0
	shell_msg_str: 
	.newline:
	db 0x0A
	.msg:
	db '/usr'
	;; Buffer for directories
	.directory_buffer:
	times 1080 db 0
	;; End of directory buffer
	.directory_end:
	RM_DIR_ERROR: db 'Error Removing Entry', 0
	doesnt_exist db 'Entry does not exist', 0
	shell_prompt_str: db ' ~', 0x0A, '$: ', 0 
	shell_format_err_msg db 'Invalid File Format.', 0x0A, 'First 200 bytes of the File: ', 0xA,  0
	;; messages.
	_RAM_DISK_MSG: db 'Contents of /ramdisk', 0xA, 0
	_BOOT_DEVICE_MSG db 0x0A, 'Kernel Boot Device Number : ', 0
	mem_string db 'Total Memory (Bytes) : ', 0x0A, 0
	_SHELL_UPTIME db 'System Uptime: ', 0
	_REBOOT_MSG: db 'System will now reboot in 3 seconds.', 0
	_CAT_ERROR: db 'CAT: Cannot Find File.', 0
	_BOCHS_SETTING_DEBUGGER: db 'Debugger will now continue......', 0
	shell_args: times 32 db 0
	ch_dir_error: db 'Error Changing Directory.', 0
	_ROOT_DIR_CONTENT: db 0x0A, 'Contents of '
					   db 0
	size_msg: db 'Size of file: ', 0
	dot_dot db '..', 0
	dot_dot_padded: db '..         '
	root db 'ROOT', 0
	_MEM_MSG db 0x0A, 'Total Memory (Bytes): ', 0
	_DIR_BUFFER: times 1024 db 0
	_LIST_OF_DEVICES:
		db 0x0A, 'ramdisk'
		db 0x0A, 'hd0'
		db 0x0A, 'ps2keyb'
		db 0x0A, 'vga32'
		db 0x00
	shell_input_buffer:
	.identifier: dw 0x00
	.command:
	times 254 db 0
	include 'zsi.asm'
	input_buffer dd 0x000000