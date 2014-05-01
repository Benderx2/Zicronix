;; Zicronix Virtual Machine
;; Include applib
include '../libasm/applib.s'
zvm_init:
	;; Load the File
	call os_get_args
	call os_load_file
	;; 