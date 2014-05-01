include '../znu/libasm/applib.s'
_start:
	mystr string "Hello World"
	call mystr.display
	myint int32_t 3000
	call myint.display
	buffer 20
	Console.Read buffer, 20
	call os_exit