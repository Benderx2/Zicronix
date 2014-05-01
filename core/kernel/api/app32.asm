;; INT 0x50 - Application Services
app_services:
	;; Application Services
	clc
	;; AH = 0x00
	;; Exit
	cmp ah, 0x00
	je .exit
	;; AH = 0x01
	;; Gets the Keyboard Status
	;; OUT : AH = Scan Code, AL = ASCII Value, BH = keypressed(1) or not(0)
	cmp ah, 0x01
	je .keyb_stats
	;; AH = 0x02 Reserved
	;; AH = 0x03
	;; Load File - Loads a file into memory
	;; EDI - Memory Location to load
	;; ESI - File Name (FILENAME.TXT format)
	cmp ah, 0x03
	je .load_file
	;; AH = 0x04 
	;; ESI - Pointer to File
	;; Carry set if doesn't exist
	cmp ah, 0x04
	je .find_file
	;; AH = 0x05 - Reserved
	cmp ah, 0x05 
	je .reserved_0x05
	;; AH = 0x06
	;; Print Character, AL = Character
	cmp ah, 0x06
	je .printc
	;; AH = 0x07
	;; Print String
	;; DS:ESI - Pointer to String
	cmp ah, 0x07
	je .printf
	;; AH = 0x08
	;; Reserved
	cmp ah, 0x08
	je .reserved_0x08
	;; AH = 0x09
	;; Get PCI Status
	;; OUT: EAX = 1 (if PCI available), or EAX = 0 if not.
	cmp ah, 0x09
	je .pci_status
	;; DH = 0x10
	;; Read PCI Register (8-bit)
	;; EAX - Device to Read.
	;; OUT: DL
	cmp dh, 0x10
	je .pci_read_reg_8
	;; DH = 0x11
	;; Read PCI register (16-bit)
	;; OUT: DX
	cmp dh, 0x11
	je .pci_read_reg_16
	;; DH = 0x12
	;; Read PCI register (32-bit)
	;; OUT: EDX
	cmp dh, 0x12
	je .pci_read_reg_32
	;; CL = 0x13
	;; Write PCI Register (8-bit)
	;; EAX - Device to Read.
	;; IN: DL
	cmp cl, 0x13
	je .pci_write_reg_8
	;; CL = 0x14
	;; Write PCI register (16-bit)
	;; IN: DX
	cmp cl, 0x14
	je .pci_write_reg_16
	;; CL = 0x15
	;; Write PCI register (32-bit)
	;; IN: EDX
	cmp cl, 0x15
	je .pci_write_reg_32
	;; DH = 0x16
	;; Find PCI Device
	;; EAX = Device + Vendor ID
	;; OUT: EDX, Address of Device
	;; Carry set if not found
	cmp ah, 0x16
	je .pci_search_device
	;; AH = 0x17
	;; Pause
	;; ECX - Number of Units (seconds/10), to pause
	cmp ah, 0x17
	je .pit_pause
	;; AH = 0x18
	;; Get cursor position
	;; BL - X
	;; BH - Y
	cmp ah, 0x18
	je .get_cur
	;; AH = 0x19
	;; Set Cursor
	;; BL - X
	;; BL - Y
	cmp ah, 0x19
	je .set_cur
	;; AH = 0x20
	;; Get the current time
	;; EDI - Pointer to store the string
	cmp ah, 0x20
	je .get_time
	;; AH = 0x21
	;; Get date
	;; EDI - Pointer to buffer to store
	cmp ah, 0x21
	je .get_date
	;; Treat the rest as error
	;; Draw VGA Block :)
	;; IN : CH - Start point (X), AL - Start Point (Y), CL - Color, DH - End Point (X), DL - End point (Y)
	;; AH = 0x22
	cmp ah, 0x22
	je .draw_block
	;; start timer
	cmp ah, 0x23
	je .start_timer
	;; end timer
	cmp ah, 0x24
	je .end_timer
	;; get timer - ECX - seconds*10 units
	cmp ah, 0x25
	je .get_timer
	;; 0x26 - fyeah, clear screen
	cmp ah, 0x26
	je .clear_screen
	stc
	jmp app_call_exit
.exit:
	mov [.err_code], ebx
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
	mov ax, [shell_dir_buffer.cluster]
	mov [current_directory.cluster], ax
	mov ebx, [.err_code]
	cmp ebx, 0
	je .done
	mov cl, [textcolor]
	mov byte [textcolor], 0x05
	mov esi, ERR_MSG
	call printf32
	mov [textcolor], cl
	mov esi, .err_code
	call printf32
.done:
	jmp shell32
.err_code: dd 0x0
		   db 0x0
.keyb_stats:
	sti
	;; k wait for key press
	mov byte [key_pressed], 0x00
	mov byte [scan_code], 0x00
	mov byte [ascii_value], 0x00
.loop:
	hlt
	cmp byte [key_pressed], 0x00
	je .loop
	;; Return Values
	mov byte ah, [scan_code]
	mov byte al, [ascii_value]
	mov byte bh, [key_pressed]
	jmp app_call_exit
.load_file:
	;; Save EAX
	push eax
	;; File String in ESI, uppercase it.
	mov eax, esi
	call strcap
	;; Convert to 'FAT16   BIN' format
	call file_convert
	;; Set ESI to Convert file name
	mov esi, eax
	;; EDI is set by the application
	;; Load the File
	call loadfile32
	;; Restore EAX
	pop eax
	;; Carry set?
	jc .load_file_error
	;; Else exit
	jmp app_call_exit
.load_file_error:
	;; Error. Carry set.
	stc
	jmp app_call_exit
.find_file:
	;; Convert the filename
	push eax
	mov eax, esi
	call strcap
	call file_convert
	mov esi, eax
	call file_exists32
	cmp ax, 0x0000
	je .find_file_error
	pop eax
	jmp app_call_exit
.find_file_error:
	pop eax
	stc
	jmp app_call_exit
;; Reserved
.reserved_0x05:	
	jmp app_call_exit
;; Print char
.printc:
	push ebx
	mov bl, al
	call printc32
	pop ebx
	jmp app_call_exit
;; Print String
.printf:
	call printf32
	jmp app_call_exit
;; Reserved
.reserved_0x08:
	jmp app_call_exit
;; PCI Status
.pci_status:
	cmp byte [PCI_STATUS], 0x01
	jne .pci_error
	mov eax, 0x01
	jmp app_call_exit
.pci_error:
	xor eax, eax
	jmp app_call_exit
;; PCI Read Registers 8/16/32
.pci_read_reg_8:
	call pci32_read_register_8
	jmp app_call_exit
.pci_read_reg_16:
	call pci32_read_register_16
	jmp app_call_exit
.pci_read_reg_32:
	call pci32_read_register_32
	jmp app_call_exit
;; PCI Write Registers 8/16/32
.pci_write_reg_8:
	call pci32_write_register_8
	jmp app_call_exit
.pci_write_reg_16:
	call pci32_write_register_16
	jmp app_call_exit
.pci_write_reg_32:
	call pci32_write_register_32
	jmp app_call_exit
;; PCI Find Device
.pci_search_device:
	push eax
	mov eax, edx
	call pci32_find_device
	pop eax
	jmp app_call_exit
;; Pause
.pit_pause:
	call init_timer
	jmp app_call_exit
.get_cur:
	mov byte bl, [screen_x]
	mov byte bh, [screen_y]
	jmp app_call_exit
.set_cur:	
	mov byte [screen_x], bl
	mov byte [screen_y], bh
	call movecursor32_INTERNAL
	jmp app_call_exit
.get_time:
	call rtc_get_time_string
	jmp app_call_exit
.get_date:
	call rtc_get_date_string
	jmp app_call_exit
.draw_block:
	push eax
	mov ah, ch
	call drawblock32
	pop eax
	jmp app_call_exit
;; start timer
.start_timer:
	call pit_start_timer
	jmp app_call_exit
;; end timer
.end_timer:
	call pit_stop_timer
	jmp app_call_exit
;; get timer
.get_timer:
	call pit_get_timer
	jmp app_call_exit
;; clear screen
.clear_screen:
	call clearscreen
	jmp app_call_exit
app_call_exit:
	iretd
	
	;; Save the current directory, apps may change it
	shell_dir_buffer:
		.offset dd 0x00000000
		.cluster dw 0x0

ERR_MSG: 
		 db 0x0a, 'The previous execution did not go successful, please contact the application vendor for more information.', 0xA
		 db 'Event: os_abort(unsigned char* error_code)', 0x0A
		 db 'The application had returned zshell with the follwing error code: ', 0