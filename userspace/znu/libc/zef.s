__org equ 0x800000
ZNU_HDR equ 'ZNUX'
;; zicronix file format.
org __org
__FILE___START:
;; header (4-bytes)
db 'ZNUX'
;; jump to start
jmp __start
;; start point (4-bytes)
dd __start 
;; end point (4-bytes)
dd __end 
;; size of .text section
____APPLICATION_SIZE: dd __end - __FILE___START 
;; entry point (4-bytes)
dd _z_main
;; file creator name (11-bytes) 
____AUTHOR_NAME: db 'EXAMPLENAME'
;; kernel version (32-bit or 64-bit) (1 - byte)
____KERNEL_VER: db 32
;;Set Headers
__start:
;; Grab the arguments
mov [__args], esi
;; Grab the stack pointer
mov [__stack_ptr], esp
; call Z_MAIN
jmp _z_main
__args dd 0x00000000
;; stack pointer
dd __stack_ptr