;; RAMDISK - For Zicronix, 
;; (C) Bender
;; This module will both contain a 
;; pratical example of a RamDisk in Zicronix
;; as well as some theory. :)
;; Sit back and enjoy :)
;; Format
format binary as 'IMG'
org 0x200000
use32
;; End of file signature
define END_FILE_SIG 0xEBDAFFFF
define END_RAMD_SIG 0x5550FFF1
;; Set the RAMDISK Header.
db 'ZXRM' ; Zicronix Ramdisk Header
;; Root Directory starts here.
;; Max - 10 entries :(
;; An entry should be like
;; this :
;; db ATTR - Attribute 1 if used, 0 if not
;; db 'FILENAME' - File Name (11 bytes)
;; dd CONTENTS - Contents Location (1 DWORD, 4 bytes)
root_directory:
entry_1:
	;; 1 byte
	.attribute: db 1
	; 11 bytes
	.name: db 'CONFIG  CFG'
	;; 4 bytes
	.content_offset: dd entry_1_content
	;; 1 entry = 16 bytes
entry_2:
	.attribute: db 1
	.name: db 'FILENAMETXT'
	.content_offset: dd entry_2_content
entry_3:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_3_content
entry_4:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_4_content
entry_5:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_5_content
entry_6:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_6_content
entry_7:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_7_content
entry_8:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_8_content
entry_9:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_9_content
entry_10:
	.attribute: db 0
	.name: times 11 db 0
	.content_offset: dd entry_10_content
;; End of Root Directory
	db 'EOFD'
	dd 0xE0FD0000
;; Here the contents section starts
entry_1_content:
	;; Include a file here
	;; You may use NASM's incbin or FASM's file directive to include a file
	;; here
	.contents:
	file 'config.cfg'
	.end: dd END_FILE_SIG
entry_2_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_3_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_4_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_5_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_6_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_7_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_8_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_9_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
entry_10_content:
	;; Include a file here
	.contents:
	.end: dd END_FILE_SIG
	;; End of Ram Disk :)
	dd END_RAMD_SIG