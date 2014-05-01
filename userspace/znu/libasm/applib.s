;; Assembler Application Interface for Zicronix.
;; (C) sid123 under BSD 2-clause license
;; Use as you wish provided you follow the terms and conditions
;; under license/znu.txt
;; Provides Class Based Library and Native Application Interface
format binary as 'znx'
;; define
DEFINE NEWLINE 		0x0A
DEFINE NULL 		0x0
DEFINE BASE_10 		10
DEFINE KEY_UP		72
DEFINE KEY_DOWN		80
DEFINE KEY_LEFT		75
DEFINE KEY_RIGHT	77
DEFINE KEY_ESC		27
DEFINE KEY_ENTER	13
;; Set the headers
use32
;; 8mb Virtual Address
org 0x800000
db 'ZNUX'
;; Intialize the Language Library
  include 'hll.s'
define_JNCONDEXPR
define_JCONDEXPR
define_JNCONDEL
define_JCONDEL
;; Jump to entry point
 jmp _main32
 include 'zicronix/native.s'
 include 'libclass.s'
 include 'machine/x86-32.s'
 include 'system/io.s'
_main32:
	;; grab arguments
	mov [__OS_ARGS], esi
	;; grab the stack pointer
	mov [__APP_STACK_PTR], esp
	jmp _z_main
	__OS_ARGS dd 0x0
	__APP_STACK_PTR dd 0x0
_z_main:
	;; include your app file
