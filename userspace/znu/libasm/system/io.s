;; System.IO Class
;; @macro - Console.Write 
;; Write a formatted string to console.
macro Console.Write string_address
{
	pushad
	mov esi, string_address
	call os_print_string
	popad
}
;; macro - Console.Read 
;; Read from Console
macro Console.Read string_address, len
{	
	pushad
	mov edi, string_address
	mov ecx, len
	call os_input_string
	popad
}
;; Write a single char to console
macro Console.WriteChar char*
{
	push eax
	mov al, a
	call os_print_char
	pop eax
}
;; Load a file into memory
macro System.LoadFile file_name, file_addr
{
	pushad
	mov esi, file_name
	mov edi, file_addr
	call os_load_file
	popad
}
;; Write to a File
macro System.WriteFile file_name, file_addr, file_size
{
	pushad
	mov esi, file_name
	mov edi, file_addr
	mov ecx, file_size
	call os_write_file
	popad
}
;; Create a file
macro System.Createfile file_name, file_size
{
	
}