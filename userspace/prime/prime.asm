use32

; glb size_t : unsigned
; glb uint32_t : unsigned
; glb sint32_t : int
; glb uint16_t : unsigned short
; glb sint16_t : short
; glb uint8_t : unsigned char
; glb sint8_t : char
; glb caddr_t : * void
; glb bool : unsigned
; glb string : * char
; glb time_t : struct <something>
; glb _end : * int
; glb _start : * int
; glb _stack_ptr : * int
; glb ___APPLICATION_SIZE : * int
; glb ___AUTHOR_NAME : * int
; glb ___KERNEL_VER : * unsigned char
; glb _args : * unsigned
%include "..\znu\libc\zef.s"
; glb video_mode : (
; prm     mode : int
;     ) void
; glb prints : (
; prm     string : * unsigned char
;     ) void
section .text
_prints:
	push	ebp
	mov	ebp, esp
	jmp	L2
L1:
; loc     string : (@8): * unsigned char
; loc     count : (@-4): int
; for
; RPN'ized expression: "count 0 = "
; Expanded expression: "(@-4) 0 =(4) "
; Fused expression:    "=(204) *(@-4) 0 "
	mov	eax, 0
	mov	[ebp-4], eax
L5:
; RPN'ized expression: "count ( string strlen ) < "
; Expanded expression: "(@-4) *(4)  (@8) *(4)  strlen ()4 < "
; Fused expression:    "( *(4) (@8) , strlen )4 < *(@-4) ax IF! "
	push	dword [ebp+8]
	call	_strlen
	sub	esp, -4
	mov	ecx, eax
	mov	eax, [ebp-4]
	cmp	eax, ecx
	jge	L8
	jmp	L7
L6:
; RPN'ized expression: "count ++p "
; Expanded expression: "(@-4) ++p(4) "
; Fused expression:    "++p(4) *(@-4) "
	mov	eax, [ebp-4]
	inc	dword [ebp-4]
	jmp	L5
L7:
; {
; RPN'ized expression: "( string count + *u printc ) "
; Expanded expression: " (@8) *(4) (@-4) *(4) + *(1)  printc ()4 "
; Fused expression:    "( + *(@8) *(@-4) *(1) ax , printc )4 "
	mov	eax, [ebp+8]
	add	eax, [ebp-4]
	mov	ebx, eax
	mov	al, [ebx]
	movzx	eax, al
	push	eax
	call	_printc
	sub	esp, -4
; }
	jmp	L6
L8:
L3:
	leave
	ret
L2:
	sub	esp, 4
	jmp	L1

; glb printc : (
; prm     c : unsigned char
;     ) void
section .text
_printc:
	push	ebp
	mov	ebp, esp
	jmp	L10
L9:
; loc     c : (@8): unsigned char
; if
; RPN'ized expression: "c 10 == "
; Expanded expression: "(@8) *(1) 10 == "
; Fused expression:    "== *(@8) 10 IF! "
	mov	al, [ebp+8]
	movzx	eax, al
	cmp	eax, 10
	jne	L13
; {
; RPN'ized expression: "( newline ) "
; Expanded expression: " newline ()0 "
; Fused expression:    "( newline )0 "
	call	_newline
; }
	jmp	L14
L13:
; else
; {
push eax
mov ah, 0x06
mov byte al, [ebp + 8]
int 0x50
pop eax
; }
L14:
L11:
	leave
	ret
L10:
	jmp	L9

; glb newline : () void
section .text
_newline:
	push	ebp
	mov	ebp, esp
	jmp	L16
L15:
push eax
mov ah, 0x06
mov al, 0x0A
int 0x50
pop eax
L17:
	leave
	ret
L16:
	jmp	L15

; glb set_text_color : (
; prm     color : unsigned
;     ) void
section .text
_set_text_color:
	push	ebp
	mov	ebp, esp
	jmp	L20
L19:
; loc     color : (@8): unsigned
push eax
mov ah, 0x03
mov al, byte [ebp + 8]
int 0x30
pop eax
L21:
	leave
	ret
L20:
	jmp	L19

; glb getcursor : () void
section .text
_getcursor:
	push	ebp
	mov	ebp, esp
	jmp	L24
L23:
call getcur_c
L25:
	leave
	ret
L24:
	jmp	L23

; glb setcursor : (
; prm     x : unsigned
; prm     y : unsigned
;     ) void
section .text
_setcursor:
	push	ebp
	mov	ebp, esp
	jmp	L28
L27:
; loc     x : (@8): unsigned
; loc     y : (@12): unsigned
mov al, [ebp + 8]
mov ah, [ebp + 16]
mov byte [screen_x], al
mov byte [screen_y], ah
call movecursor32
L29:
	leave
	ret
L28:
	jmp	L27

; glb drawblock : (
; prm     start_x : unsigned char
; prm     start_y : unsigned char
; prm     end_x : unsigned char
; prm     end_y : unsigned char
; prm     color : unsigned char
;     ) void
section .text
_drawblock:
	push	ebp
	mov	ebp, esp
	jmp	L32
L31:
; loc     start_x : (@8): unsigned char
; loc     start_y : (@12): unsigned char
; loc     end_x : (@16): unsigned char
; loc     end_y : (@20): unsigned char
; loc     color : (@24): unsigned char
mov ch, [ebp + 8]
mov al, [ebp + 16]
mov dh, [ebp + 24]
mov dl, [ebp + 32]
mov cl, [ebp + 40]
mov ah, 0x22
int 0x50
L33:
	leave
	ret
L32:
	jmp	L31

%include "..\znu\libc\video.s"
; glb read : (
; prm     file_name : * unsigned char
; prm     file_location : * unsigned
;     ) void
section .text
_read:
	push	ebp
	mov	ebp, esp
	jmp	L36
L35:
; loc     file_name : (@8): * unsigned char
; loc     file_location : (@12): * unsigned
push eax
mov ah, 0x03
mov esi, [ebp + 8]
mov edi, [ebp + 12]
int 0x50
pop eax
L37:
	leave
	ret
L36:
	jmp	L35

; glb write : (
; prm     file_name : * unsigned
; prm     file_location : * unsigned
; prm     bytes : unsigned
;     ) void
section .text
_write:
	push	ebp
	mov	ebp, esp
	jmp	L40
L39:
; loc     file_name : (@8): * unsigned
; loc     file_location : (@12): * unsigned
; loc     bytes : (@16): unsigned
mov dh, 0x08
mov edi, [ebp + 8]
mov esi, [ebp + 12]
mov ecx, [ebp + 16]
int 0x31
L41:
	leave
	ret
L40:
	jmp	L39

; glb file_query : (
; prm     file_name : * unsigned char
; prm     result : * unsigned char
;     ) unsigned
section .text
_file_query:
	push	ebp
	mov	ebp, esp
	jmp	L44
L43:
; loc     file_name : (@8): * unsigned char
; loc     result : (@12): * unsigned char
push esi
mov ah, 0x04
mov esi, [ebp + 8]
int 0x50
jnc .ok
jmp .error
.error: 
mov edi, [ebp + 16]
mov al, 1
stosb
pop esi
leave
ret
.ok: 
mov edi, [ebp + 16]
mov al, 0
stosb
pop esi
L45:
	leave
	ret
L44:
	jmp	L43

; glb pci_write_8 : (
; prm     pci_reg : unsigned char
; prm     pci_device : unsigned
;     ) void
section .text
_pci_write_8:
	push	ebp
	mov	ebp, esp
	jmp	L48
L47:
; loc     pci_reg : (@8): unsigned char
; loc     pci_device : (@12): unsigned
mov ah, 0x10
mov dl, [ebp + 8]
mov eax, [ebp + 16]
int 0x50
L49:
	leave
	ret
L48:
	jmp	L47

; glb pci_write_16 : (
; prm     pci_reg : unsigned short
; prm     pci_device : unsigned
;     ) void
section .text
_pci_write_16:
	push	ebp
	mov	ebp, esp
	jmp	L52
L51:
; loc     pci_reg : (@8): unsigned short
; loc     pci_device : (@12): unsigned
mov ah, 0x10
mov dx, [ebp + 8]
mov eax, [ebp + 16]
int 0x50
L53:
	leave
	ret
L52:
	jmp	L51

; glb pci_write_32 : (
; prm     pci_reg : unsigned
; prm     pci_device : unsigned
;     ) void
section .text
_pci_write_32:
	push	ebp
	mov	ebp, esp
	jmp	L56
L55:
; loc     pci_reg : (@8): unsigned
; loc     pci_device : (@12): unsigned
mov ah, 0x10
mov edx, [ebp + 8]
mov eax, [ebp + 16]
int 0x50
L57:
	leave
	ret
L56:
	jmp	L55

; glb exit : () void
section .text
_exit:
	push	ebp
	mov	ebp, esp
	jmp	L60
L59:
leave
xor eax, eax
xor ebx, ebx
int 0x50
L61:
	leave
	ret
L60:
	jmp	L59

; glb abort : () void
section .text
_abort:
	push	ebp
	mov	ebp, esp
	jmp	L64
L63:
leave
xor eax, eax
mov ebx, 'ERR '
int 0x50
L65:
	leave
	ret
L64:
	jmp	L63

; glb strlen : (
; prm     str : * char
;     ) unsigned
section .text
_strlen:
	push	ebp
	mov	ebp, esp
	jmp	L68
L67:
; loc     str : (@8): * char
; loc     retval : (@-4): unsigned
; for
; RPN'ized expression: "retval 0 = "
; Expanded expression: "(@-4) 0 =(4) "
; Fused expression:    "=(204) *(@-4) 0 "
	mov	eax, 0
	mov	[ebp-4], eax
L71:
; RPN'ized expression: "str *u 0 != "
; Expanded expression: "(@8) *(4) *(-1) 0 != "
; Fused expression:    "*(4) (@8) != *ax 0 IF! "
	mov	eax, [ebp+8]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	je	L74
	jmp	L73
L72:
; RPN'ized expression: "str ++p "
; Expanded expression: "(@8) ++p(4) "
; Fused expression:    "++p(4) *(@8) "
	mov	eax, [ebp+8]
	inc	dword [ebp+8]
	jmp	L71
L73:
; RPN'ized expression: "retval ++p "
; Expanded expression: "(@-4) ++p(4) "
; Fused expression:    "++p(4) *(@-4) "
	mov	eax, [ebp-4]
	inc	dword [ebp-4]
	jmp	L72
L74:
; return
; RPN'ized expression: "retval "
; Expanded expression: "(@-4) *(4) "
; Fused expression:    "*(4) (@-4) "
	mov	eax, [ebp-4]
	jmp	L69
L69:
	leave
	ret
L68:
	sub	esp, 4
	jmp	L67

; glb outportb : (
; prm     port : unsigned short
; prm     value : unsigned char
;     ) unsigned
section .text
_outportb:
	push	ebp
	mov	ebp, esp
	jmp	L76
L75:
; loc     port : (@8): unsigned short
; loc     value : (@12): unsigned char
push EDX
push EAX
mov dx, [ebp + 8]
mov al, [ebp + 16]
out dx, al
pop EAX
pop EDX
L77:
	leave
	ret
L76:
	jmp	L75

; glb inportb : (
; prm     port : unsigned short
;     ) unsigned
section .text
_inportb:
	push	ebp
	mov	ebp, esp
	jmp	L80
L79:
; loc     port : (@8): unsigned short
push EDX
xor eax, eax
mov dx, [ebp + 8]
in al, dx
pop edx
L81:
	leave
	ret
L80:
	jmp	L79

; glb reverse : (
; prm     s : * char
;     ) void
section .text
_reverse:
	push	ebp
	mov	ebp, esp
	jmp	L84
L83:
; loc     s : (@8): * char
; loc     j : (@-4): * char
; loc     i : (@-8): int
; =
; RPN'ized expression: "( s strlen ) "
; Expanded expression: " (@8) *(4)  strlen ()4 "
; Fused expression:    "( *(4) (@8) , strlen )4 =(204) *(@-8) ax "
	push	dword [ebp+8]
	call	_strlen
	sub	esp, -4
	mov	[ebp-8], eax
; RPN'ized expression: "( s , j strcpy ) "
; Expanded expression: " (@8) *(4)  (@-4) *(4)  strcpy ()8 "
; Fused expression:    "( *(4) (@8) , *(4) (@-4) , strcpy )8 "
	push	dword [ebp+8]
	push	dword [ebp-4]
	call	_strcpy
	sub	esp, -8
; while
; RPN'ized expression: "i --p 0 >= "
; Expanded expression: "(@-8) --p(4) 0 >= "
L87:
; Fused expression:    "--p(4) *(@-8) >= ax 0 IF! "
	mov	eax, [ebp-8]
	dec	dword [ebp-8]
	cmp	eax, 0
	jl	L88
; RPN'ized expression: "s ++p *u j i + *u = "
; Expanded expression: "(@8) ++p(4) (@-4) *(4) (@-8) *(4) + *(-1) =(-1) "
; Fused expression:    "++p(4) *(@8) push-ax + *(@-4) *(@-8) =(119) **sp *ax "
	mov	eax, [ebp+8]
	inc	dword [ebp+8]
	push	eax
	mov	eax, [ebp-4]
	add	eax, [ebp-8]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
	jmp	L87
L88:
; RPN'ized expression: "s *u 0 = "
; Expanded expression: "(@8) *(4) 0 =(-1) "
; Fused expression:    "*(4) (@8) =(124) *ax 0 "
	mov	eax, [ebp+8]
	mov	ebx, eax
	mov	eax, 0
	mov	[ebx], al
	movsx	eax, al
L85:
	leave
	ret
L84:
	sub	esp, 8
	jmp	L83

; glb itoa : (
; prm     n : int
; prm     buffer : * char
; prm     base : int
;     ) void
section .text
_itoa:
	push	ebp
	mov	ebp, esp
	jmp	L90
L89:
; loc     n : (@8): int
; loc     buffer : (@12): * char
; loc     base : (@16): int
; loc     ptr : (@-4): * char
; =
; RPN'ized expression: "buffer "
; Expanded expression: "(@12) *(4) "
; Fused expression:    "=(204) *(@-4) *(@12) "
	mov	eax, [ebp+12]
	mov	[ebp-4], eax
; loc     lowbit : (@-8): int
; RPN'ized expression: "base 1 >>= "
; Expanded expression: "(@16) 1 >>=(4) "
; Fused expression:    ">>=(204) *(@16) 1 "
	mov	eax, [ebp+16]
	sar	eax, 1
	mov	[ebp+16], eax
; do
L93:
; {
; RPN'ized expression: "lowbit n 1 & = "
; Expanded expression: "(@-8) (@8) *(4) 1 & =(4) "
; Fused expression:    "& *(@8) 1 =(204) *(@-8) ax "
	mov	eax, [ebp+8]
	and	eax, 1
	mov	[ebp-8], eax
; RPN'ized expression: "n n 1 >> 32767 & = "
; Expanded expression: "(@8) (@8) *(4) 1 >> 32767 & =(4) "
; Fused expression:    ">> *(@8) 1 & ax 32767 =(204) *(@8) ax "
	mov	eax, [ebp+8]
	sar	eax, 1
	and	eax, 32767
	mov	[ebp+8], eax
; RPN'ized expression: "ptr *u n base % 1 << lowbit + = "
; Expanded expression: "(@-4) *(4) (@8) *(4) (@16) *(4) % 1 << (@-8) *(4) + =(-1) "
; Fused expression:    "*(4) (@-4) push-ax % *(@8) *(@16) << ax 1 + ax *(@-8) =(124) **sp ax "
	mov	eax, [ebp-4]
	push	eax
	mov	eax, [ebp+8]
	cdq
	idiv	dword [ebp+16]
	mov	eax, edx
	shl	eax, 1
	add	eax, [ebp-8]
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
; if
; RPN'ized expression: "ptr *u 10 < "
; Expanded expression: "(@-4) *(4) *(-1) 10 < "
; Fused expression:    "*(4) (@-4) < *ax 10 IF! "
	mov	eax, [ebp-4]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 10
	jge	L96
; RPN'ized expression: "ptr *u 48 += "
; Expanded expression: "(@-4) *(4) 48 +=(-1) "
; Fused expression:    "*(4) (@-4) +=(124) *ax 48 "
	mov	eax, [ebp-4]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	add	eax, 48
	mov	[ebx], al
	movsx	eax, al
	jmp	L97
L96:
; else
; RPN'ized expression: "ptr *u 55 += "
; Expanded expression: "(@-4) *(4) 55 +=(-1) "
; Fused expression:    "*(4) (@-4) +=(124) *ax 55 "
	mov	eax, [ebp-4]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	add	eax, 55
	mov	[ebx], al
	movsx	eax, al
L97:
; RPN'ized expression: "ptr ++ "
; Expanded expression: "(@-4) ++(4) "
; Fused expression:    "++(4) *(@-4) "
	inc	dword [ebp-4]
	mov	eax, [ebp-4]
; }
; while
; RPN'ized expression: "n base /= "
; Expanded expression: "(@8) (@16) *(4) /=(4) "
L94:
; Fused expression:    "/=(204) *(@8) *(@16) "
	mov	eax, [ebp+8]
	cdq
	idiv	dword [ebp+16]
	mov	[ebp+8], eax
; JumpIfNotZero
	test	eax, eax
	jne	L93
L95:
; RPN'ized expression: "ptr *u 0 = "
; Expanded expression: "(@-4) *(4) 0 =(-1) "
; Fused expression:    "*(4) (@-4) =(124) *ax 0 "
	mov	eax, [ebp-4]
	mov	ebx, eax
	mov	eax, 0
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "( buffer reverse ) "
; Expanded expression: " (@12) *(4)  reverse ()4 "
; Fused expression:    "( *(4) (@12) , reverse )4 "
	push	dword [ebp+12]
	call	_reverse
	sub	esp, -4
L91:
	leave
	ret
L90:
	sub	esp, 8
	jmp	L89

; glb strcpy : (
; prm     dest : * char
; prm     source : * char
;     ) void
section .text
_strcpy:
	push	ebp
	mov	ebp, esp
	jmp	L99
L98:
; loc     dest : (@8): * char
; loc     source : (@12): * char
; loc     i : (@-4): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(204) *(@-4) 0 "
	mov	eax, 0
	mov	[ebp-4], eax
; while
; RPN'ized expression: "1 "
; Expanded expression: "1 "
; Expression value: 1
L102:
; Fused expression:    "1 "
	mov	eax, 1
; JumpIfZero
	test	eax, eax
	je	L103
; {
; RPN'ized expression: "dest i + *u source i + *u = "
; Expanded expression: "(@8) *(4) (@-4) *(4) + (@12) *(4) (@-4) *(4) + *(-1) =(-1) "
; Fused expression:    "+ *(@8) *(@-4) push-ax + *(@12) *(@-4) =(119) **sp *ax "
	mov	eax, [ebp+8]
	add	eax, [ebp-4]
	push	eax
	mov	eax, [ebp+12]
	add	eax, [ebp-4]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
; if
; RPN'ized expression: "dest i + *u 0 == "
; Expanded expression: "(@8) *(4) (@-4) *(4) + *(-1) 0 == "
; Fused expression:    "+ *(@8) *(@-4) == *ax 0 IF! "
	mov	eax, [ebp+8]
	add	eax, [ebp-4]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	jne	L104
; break
	jmp	L103
L104:
; RPN'ized expression: "i ++p "
; Expanded expression: "(@-4) ++p(4) "
; Fused expression:    "++p(4) *(@-4) "
	mov	eax, [ebp-4]
	inc	dword [ebp-4]
; }
	jmp	L102
L103:
L100:
	leave
	ret
L99:
	sub	esp, 4
	jmp	L98

; glb memcpy : (
; prm     dest : * void
; prm     src : * void
; prm     count : unsigned
;     ) void
section .text
_memcpy:
	push	ebp
	mov	ebp, esp
	jmp	L107
L106:
; loc     dest : (@8): * void
; loc     src : (@12): * void
; loc     count : (@16): unsigned
; loc     sp : (@-4): * char
; =
; loc     <something> : * char
; RPN'ized expression: "src (something110) "
; Expanded expression: "(@12) *(4) "
; Fused expression:    "=(204) *(@-4) *(@12) "
	mov	eax, [ebp+12]
	mov	[ebp-4], eax
; loc     dp : (@-8): * char
; =
; loc     <something> : * char
; RPN'ized expression: "dest (something111) "
; Expanded expression: "(@8) *(4) "
; Fused expression:    "=(204) *(@-8) *(@8) "
	mov	eax, [ebp+8]
	mov	[ebp-8], eax
; while
; RPN'ized expression: "count 0 != "
; Expanded expression: "(@16) *(4) 0 != "
L112:
; Fused expression:    "!= *(@16) 0 IF! "
	mov	eax, [ebp+16]
	cmp	eax, 0
	je	L113
; {
; RPN'ized expression: "dp ++p *u sp ++p *u = "
; Expanded expression: "(@-8) ++p(4) (@-4) ++p(4) *(-1) =(-1) "
; Fused expression:    "++p(4) *(@-8) push-ax ++p(4) *(@-4) =(119) **sp *ax "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
	push	eax
	mov	eax, [ebp-4]
	inc	dword [ebp-4]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "count --p "
; Expanded expression: "(@16) --p(4) "
; Fused expression:    "--p(4) *(@16) "
	mov	eax, [ebp+16]
	dec	dword [ebp+16]
; }
	jmp	L112
L113:
L108:
	leave
	ret
L107:
	sub	esp, 8
	jmp	L106

; glb memset : (
; prm     dest : * void
; prm     val : char
; prm     count : unsigned
;     ) void
section .text
_memset:
	push	ebp
	mov	ebp, esp
	jmp	L115
L114:
; loc     dest : (@8): * void
; loc     val : (@12): char
; loc     count : (@16): unsigned
; loc     temp : (@-4): * char
; =
; loc     <something> : * char
; RPN'ized expression: "dest (something118) "
; Expanded expression: "(@8) *(4) "
; Fused expression:    "=(204) *(@-4) *(@8) "
	mov	eax, [ebp+8]
	mov	[ebp-4], eax
; while
; RPN'ized expression: "count 0 != "
; Expanded expression: "(@16) *(4) 0 != "
L119:
; Fused expression:    "!= *(@16) 0 IF! "
	mov	eax, [ebp+16]
	cmp	eax, 0
	je	L120
; {
; RPN'ized expression: "temp ++p *u val = "
; Expanded expression: "(@-4) ++p(4) (@12) *(-1) =(-1) "
; Fused expression:    "++p(4) *(@-4) =(119) *ax *(@12) "
	mov	eax, [ebp-4]
	inc	dword [ebp-4]
	mov	ebx, eax
	mov	al, [ebp+12]
	movsx	eax, al
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "count --p "
; Expanded expression: "(@16) --p(4) "
; Fused expression:    "--p(4) *(@16) "
	mov	eax, [ebp+16]
	dec	dword [ebp+16]
; }
	jmp	L119
L120:
L116:
	leave
	ret
L115:
	sub	esp, 4
	jmp	L114

; glb memsetw : (
; prm     dest : * unsigned short
; prm     val : unsigned short
; prm     count : unsigned
;     ) unsigned short
section .text
_memsetw:
	push	ebp
	mov	ebp, esp
	jmp	L122
L121:
; loc     dest : (@8): * unsigned short
; loc     val : (@12): unsigned short
; loc     count : (@16): unsigned
; loc     temp : (@-4): * unsigned short
; =
; loc     <something> : * unsigned short
; RPN'ized expression: "dest (something125) "
; Expanded expression: "(@8) *(4) "
; Fused expression:    "=(204) *(@-4) *(@8) "
	mov	eax, [ebp+8]
	mov	[ebp-4], eax
; while
; RPN'ized expression: "count 0 != "
; Expanded expression: "(@16) *(4) 0 != "
L126:
; Fused expression:    "!= *(@16) 0 IF! "
	mov	eax, [ebp+16]
	cmp	eax, 0
	je	L127
; {
; RPN'ized expression: "temp ++p *u val = "
; Expanded expression: "(@-4) 2 +=p(4) (@12) *(2) =(2) "
; Fused expression:    "+=p(4) *(@-4) 2 =(170) *ax *(@12) "
	mov	eax, [ebp-4]
	add	dword [ebp-4], 2
	mov	ebx, eax
	mov	ax, [ebp+12]
	movzx	eax, ax
	mov	[ebx], ax
	movzx	eax, ax
; RPN'ized expression: "count --p "
; Expanded expression: "(@16) --p(4) "
; Fused expression:    "--p(4) *(@16) "
	mov	eax, [ebp+16]
	dec	dword [ebp+16]
; }
	jmp	L126
L127:
L123:
	leave
	ret
L122:
	sub	esp, 4
	jmp	L121

; glb isdigit : (
; prm     c : int
;     ) int
section .text
_isdigit:
	push	ebp
	mov	ebp, esp
	jmp	L129
L128:
; loc     c : (@8): int
; return
; RPN'ized expression: "c 48 >= c 57 <= && "
; Expanded expression: "(@8) *(4) 48 >= [sh&&->132] (@8) *(4) 57 <= &&[132] "
; Fused expression:    ">= *(@8) 48 [sh&&->132] <= *(@8) 57 &&[132] "
	mov	eax, [ebp+8]
	cmp	eax, 48
	setge	al
	movzx	eax, al
; JumpIfZero
	test	eax, eax
	je	L132
	mov	eax, [ebp+8]
	cmp	eax, 57
	setle	al
	movzx	eax, al
L132:
	jmp	L130
L130:
	leave
	ret
L129:
	jmp	L128

; glb atoi : (
; prm     p : * char
;     ) int
section .text
_atoi:
	push	ebp
	mov	ebp, esp
	jmp	L134
L133:
; loc     p : (@8): * char
; loc     k : (@-4): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(204) *(@-4) 0 "
	mov	eax, 0
	mov	[ebp-4], eax
; while
; RPN'ized expression: "p *u "
; Expanded expression: "(@8) *(4) *(-1) "
L137:
; Fused expression:    "*(4) (@8) *(-1) ax "
	mov	eax, [ebp+8]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
; JumpIfZero
	test	eax, eax
	je	L138
; {
; RPN'ized expression: "k k 3 << k 1 << + p *u + 48 - = "
; Expanded expression: "(@-4) (@-4) *(4) 3 << (@-4) *(4) 1 << + (@8) *(4) *(-1) + 48 - =(4) "
; Fused expression:    "<< *(@-4) 3 push-ax << *(@-4) 1 + *sp ax push-ax *(4) (@8) + *sp *ax - ax 48 =(204) *(@-4) ax "
	mov	eax, [ebp-4]
	shl	eax, 3
	push	eax
	mov	eax, [ebp-4]
	shl	eax, 1
	mov	ecx, eax
	pop	eax
	add	eax, ecx
	push	eax
	mov	eax, [ebp+8]
	mov	ebx, eax
	movsx	ecx, byte [ebx]
	pop	eax
	add	eax, ecx
	sub	eax, 48
	mov	[ebp-4], eax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@8) ++p(4) "
; Fused expression:    "++p(4) *(@8) "
	mov	eax, [ebp+8]
	inc	dword [ebp+8]
; }
	jmp	L137
L138:
; return
; RPN'ized expression: "k "
; Expanded expression: "(@-4) *(4) "
; Fused expression:    "*(4) (@-4) "
	mov	eax, [ebp-4]
	jmp	L135
L135:
	leave
	ret
L134:
	sub	esp, 4
	jmp	L133

; glb mem_32_start : unsigned
section .data
	align 4
_mem_32_start:
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	dd	0

; glb mem_32_end : unsigned
section .data
	align 4
_mem_32_end:
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	dd	0

; glb mem_32_count : unsigned
section .data
	align 4
_mem_32_count:
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	dd	0

; glb malloc : (
; prm     length : unsigned
;     ) int
section .text
_malloc:
	push	ebp
	mov	ebp, esp
	jmp	L140
L139:
; loc     length : (@8): unsigned
; if
; RPN'ized expression: "mem_32_end 4294967295u >= "
; Expanded expression: "mem_32_end *(4) 4294967295u >=u "
; Fused expression:    ">=u *mem_32_end 4294967295u IF! "
	mov	eax, [_mem_32_end]
	cmp	eax, -1
	jb	L143
; {
; return
; RPN'ized expression: "1 -u "
; Expanded expression: "-1 "
; Expression value: -1
; Fused expression:    "-1 "
	mov	eax, -1
	jmp	L141
; }
L143:
; RPN'ized expression: "mem_32_count length += "
; Expanded expression: "mem_32_count (@8) *(4) +=(4) "
; Fused expression:    "+=(204) *mem_32_count *(@8) "
	mov	eax, [_mem_32_count]
	add	eax, [ebp+8]
	mov	[_mem_32_count], eax
; RPN'ized expression: "mem_32_end mem_32_count mem_32_start + += "
; Expanded expression: "mem_32_end mem_32_count *(4) mem_32_start *(4) + +=(4) "
; Fused expression:    "+ *mem_32_count *mem_32_start +=(204) *mem_32_end ax "
	mov	eax, [_mem_32_count]
	add	eax, [_mem_32_start]
	mov	ecx, eax
	mov	eax, [_mem_32_end]
	add	eax, ecx
	mov	[_mem_32_end], eax
; return
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "0 "
	mov	eax, 0
	jmp	L141
L141:
	leave
	ret
L140:
	jmp	L139

; glb get_total_used_memory : () unsigned
section .text
_get_total_used_memory:
	push	ebp
	mov	ebp, esp
	jmp	L146
L145:
; return
; RPN'ized expression: "mem_32_count "
; Expanded expression: "mem_32_count *(4) "
; Fused expression:    "*(4) mem_32_count "
	mov	eax, [_mem_32_count]
	jmp	L147
L147:
	leave
	ret
L146:
	jmp	L145

; glb get_memory_end : () unsigned
section .text
_get_memory_end:
	push	ebp
	mov	ebp, esp
	jmp	L150
L149:
; return
; RPN'ized expression: "mem_32_end "
; Expanded expression: "mem_32_end *(4) "
; Fused expression:    "*(4) mem_32_end "
	mov	eax, [_mem_32_end]
	jmp	L151
L151:
	leave
	ret
L150:
	jmp	L149

; glb get_mem_start : () unsigned
section .text
_get_mem_start:
	push	ebp
	mov	ebp, esp
	jmp	L154
L153:
; return
; RPN'ized expression: "mem_32_start "
; Expanded expression: "mem_32_start *(4) "
; Fused expression:    "*(4) mem_32_start "
	mov	eax, [_mem_32_start]
	jmp	L155
L155:
	leave
	ret
L154:
	jmp	L153

; glb sbrk : (
; prm     incr : int
;     ) * void
section .text
_sbrk:
	push	ebp
	mov	ebp, esp
	jmp	L158
L157:
; loc     incr : (@8): int
; loc     heap_end : (@-4): * char
; loc     prev_heap_end : (@-8): * char
; if
; RPN'ized expression: "heap_end 0 == "
; Expanded expression: "(@-4) *(4) 0 == "
; Fused expression:    "== *(@-4) 0 IF! "
	mov	eax, [ebp-4]
	cmp	eax, 0
	jne	L161
; {
; RPN'ized expression: "heap_end _end &u = "
; Expanded expression: "(@-4) _end =(4) "
; Fused expression:    "=(204) *(@-4) _end "
	mov	eax, __end
	mov	[ebp-4], eax
; }
L161:
; RPN'ized expression: "prev_heap_end heap_end = "
; Expanded expression: "(@-8) (@-4) *(4) =(4) "
; Fused expression:    "=(204) *(@-8) *(@-4) "
	mov	eax, [ebp-4]
	mov	[ebp-8], eax
; if
; RPN'ized expression: "heap_end incr + _stack_ptr > "
; Expanded expression: "(@-4) *(4) (@8) *(4) + _stack_ptr *(4) >u "
; Fused expression:    "+ *(@-4) *(@8) >u ax *_stack_ptr IF! "
	mov	eax, [ebp-4]
	add	eax, [ebp+8]
	cmp	eax, [__stack_ptr]
	jbe	L163
; {
; RPN'ized expression: "( 25 , L165 , 1 printf ) "
; Expanded expression: " 25  L165  1  printf ()12 "

section .data
L165:
	db	"Heap and stack collision",10,0

section .text
; Fused expression:    "( 25 , L165 , 1 , printf )12 "
	push	25
	push	L165
	push	1
	call	_printf
	sub	esp, -12
; RPN'ized expression: "( abort ) "
; Expanded expression: " abort ()0 "
; Fused expression:    "( abort )0 "
	call	_abort
; }
L163:
; RPN'ized expression: "heap_end incr += "
; Expanded expression: "(@-4) (@8) *(4) +=(4) "
; Fused expression:    "+=(204) *(@-4) *(@8) "
	mov	eax, [ebp-4]
	add	eax, [ebp+8]
	mov	[ebp-4], eax
; return
; loc     <something> : * void
; RPN'ized expression: "prev_heap_end (something167) "
; Expanded expression: "(@-8) *(4) "
; Fused expression:    "*(4) (@-8) "
	mov	eax, [ebp-8]
	jmp	L159
L159:
	leave
	ret
L158:
	sub	esp, 8
	jmp	L157

; glb idt_set_gate : (
; prm     isr_ptr : * unsigned
; prm     isr_number : unsigned char
;     ) void
section .text
_idt_set_gate:
	push	ebp
	mov	ebp, esp
	jmp	L169
L168:
; loc     isr_ptr : (@8): * unsigned
; loc     isr_number : (@12): unsigned char
push eax
 push edx
mov edx, [ebp + 8]
mov ah, 0x02
mov byte al, [ebp + 16]
int 0x30
pop edx
pop eax
L170:
	leave
	ret
L169:
	jmp	L168

; glb x86_disable_exception_gates : () void
section .text
_x86_disable_exception_gates:
	push	ebp
	mov	ebp, esp
	jmp	L173
L172:
cli
L174:
	leave
	ret
L173:
	jmp	L172

; glb x86_enable_exception_gates : () void
section .text
_x86_enable_exception_gates:
	push	ebp
	mov	ebp, esp
	jmp	L177
L176:
sti
L178:
	leave
	ret
L177:
	jmp	L176

; glb start_timer : () void
section .text
_start_timer:
	push	ebp
	mov	ebp, esp
	jmp	L181
L180:
mov ah, 0x23
int 0x50
L182:
	leave
	ret
L181:
	jmp	L180

; glb stop_timer : () void
section .text
_stop_timer:
	push	ebp
	mov	ebp, esp
	jmp	L185
L184:
mov ah, 0x24
int 0x50
L186:
	leave
	ret
L185:
	jmp	L184

; glb get_timer : () int
section .text
_get_timer:
	push	ebp
	mov	ebp, esp
	jmp	L189
L188:
push ecx
mov ah, 0x25
int 0x50
mov eax, ecx
pop ecx
L190:
	leave
	ret
L189:
	jmp	L188

; glb sleep : (
; prm     time : unsigned
;     ) void
section .text
_sleep:
	push	ebp
	mov	ebp, esp
	jmp	L193
L192:
; loc     time : (@8): unsigned
push ecx
push eax
mov ah, 0x17
mov ecx, [ebp + 8]
int 0x50
pop eax
pop ecx
L194:
	leave
	ret
L193:
	jmp	L192

; glb ascii_value : unsigned char
%include "..\znu\libc\keyboard.s"
; glb waitkey : () unsigned char
section .text
_waitkey:
	push	ebp
	mov	ebp, esp
	jmp	L197
L196:
call wait_key
; return
; RPN'ized expression: "ascii_value "
; Expanded expression: "ascii_value *(1) "
; Fused expression:    "*(1) ascii_value "
	mov	al, [_ascii_value]
	movzx	eax, al
	jmp	L198
L198:
	leave
	ret
L197:
	jmp	L196

; glb getch : (void) unsigned
section .text
_getch:
	push	ebp
	mov	ebp, esp
	jmp	L201
L200:
call get_char
L202:
	leave
	ret
L201:
	jmp	L200

; glb run_kbd_interrupt : () unsigned short
section .text
_run_kbd_interrupt:
	push	ebp
	mov	ebp, esp
	jmp	L205
L204:
xor eax, eax
call get_kbd_status
L206:
	leave
	ret
L205:
	jmp	L204

; glb get_scan_code : () unsigned char
section .text
_get_scan_code:
	push	ebp
	mov	ebp, esp
	jmp	L209
L208:
; RPN'ized expression: "( run_kbd_interrupt ) "
; Expanded expression: " run_kbd_interrupt ()0 "
; Fused expression:    "( run_kbd_interrupt )0 "
	call	_run_kbd_interrupt
mov byte al, [scan_code]
L210:
	leave
	ret
L209:
	jmp	L208

; glb getstr : (
; prm     buffer : * unsigned char
;     ) unsigned char
section .text
_getstr:
	push	ebp
	mov	ebp, esp
	jmp	L213
L212:
; loc     buffer : (@8): * unsigned char
; RPN'ized expression: "256 "
; Expanded expression: "256 "
; Expression value: 256
; loc     internal_buffer : (@-256): [256u] unsigned char
; loc     scan_code : (@-260): unsigned char
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(204) *(@-260) 0 "
	mov	eax, 0
	mov	[ebp-260], eax
; while
; RPN'ized expression: "scan_code 7181 != "
; Expanded expression: "(@-260) *(1) 7181 != "
L216:
; Fused expression:    "!= *(@-260) 7181 IF! "
	mov	al, [ebp-260]
	movzx	eax, al
	cmp	eax, 7181
	je	L217
; {
; RPN'ized expression: "scan_code ( getch ) = "
; Expanded expression: "(@-260)  getch ()0 =(1) "
; Fused expression:    "( getch )0 =(156) *(@-260) ax "
	call	_getch
	mov	[ebp-260], al
	movzx	eax, al
; if
; RPN'ized expression: "scan_code 126 > "
; Expanded expression: "(@-260) *(1) 126 > "
; Fused expression:    "> *(@-260) 126 IF! "
	mov	al, [ebp-260]
	movzx	eax, al
	cmp	eax, 126
	jle	L218
; {
; continue
	jmp	L216
; }
L218:
; if
; RPN'ized expression: "scan_code 32 < "
; Expanded expression: "(@-260) *(1) 32 < "
; Fused expression:    "< *(@-260) 32 IF! "
	mov	al, [ebp-260]
	movzx	eax, al
	cmp	eax, 32
	jge	L220
; {
; continue
	jmp	L216
; }
	jmp	L221
L220:
; else
; {
; RPN'ized expression: "( scan_code printf ) "
; Expanded expression: " (@-260) *(1)  printf ()4 "
; Fused expression:    "( *(1) (@-260) , printf )4 "
	mov	al, [ebp-260]
	movzx	eax, al
	push	eax
	call	_printf
	sub	esp, -4
; continue
	jmp	L216
; }
L221:
; }
	jmp	L216
L217:
L214:
	leave
	ret
L213:
	sub	esp, 260
	jmp	L212

; glb vprintf : (
; prm     fmt : * char
; prm     vl : * void
;     ) int
section .text
_vprintf:
	push	ebp
	mov	ebp, esp
	jmp	L223
L222:
; loc     fmt : (@8): * char
; loc     vl : (@12): * void
; loc     pp : (@-4): * int
; =
; RPN'ized expression: "vl "
; Expanded expression: "(@12) *(4) "
; Fused expression:    "=(204) *(@-4) *(@12) "
	mov	eax, [ebp+12]
	mov	[ebp-4], eax
; loc     cnt : (@-8): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(204) *(@-8) 0 "
	mov	eax, 0
	mov	[ebp-8], eax
; loc     p : (@-12): * char
; loc     phex : (@-16): * char
; RPN'ized expression: "12 "
; Expanded expression: "12 "
; Expression value: 12
; loc     s : (@-28): [12u] char
; loc     pc : (@-32): * char
; loc     n : (@-36): int
; loc     sign : (@-40): int
; loc     msign : (@-44): int
; loc     minlen : (@-48): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(204) *(@-48) 0 "
	mov	eax, 0
	mov	[ebp-48], eax
; loc     len : (@-52): int
; for
; RPN'ized expression: "p fmt = "
; Expanded expression: "(@-12) (@8) *(4) =(4) "
; Fused expression:    "=(204) *(@-12) *(@8) "
	mov	eax, [ebp+8]
	mov	[ebp-12], eax
L226:
; RPN'ized expression: "p *u 0 != "
; Expanded expression: "(@-12) *(4) *(-1) 0 != "
; Fused expression:    "*(4) (@-12) != *ax 0 IF! "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	je	L229
	jmp	L228
L227:
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-12) ++p(4) "
; Fused expression:    "++p(4) *(@-12) "
	mov	eax, [ebp-12]
	inc	dword [ebp-12]
	jmp	L226
L228:
; {
; if
; RPN'ized expression: "p *u 37 != p 1 + *u 37 == || "
; Expanded expression: "(@-12) *(4) *(-1) 37 != [sh||->232] (@-12) *(4) 1 + *(-1) 37 == ||[232] "
; Fused expression:    "*(4) (@-12) != *ax 37 [sh||->232] + *(@-12) 1 == *ax 37 ||[232] "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 37
	setne	al
	movzx	eax, al
; JumpIfNotZero
	test	eax, eax
	jne	L232
	mov	eax, [ebp-12]
	inc	eax
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 37
	sete	al
	movzx	eax, al
L232:
; JumpIfZero
	test	eax, eax
	je	L230
; {
; RPN'ized expression: "( p *u putchar ) "
; Expanded expression: " (@-12) *(4) *(-1)  putchar ()4 "
; Fused expression:    "( *(4) (@-12) *(-1) ax , putchar )4 "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "p p p *u 37 == + = "
; Expanded expression: "(@-12) (@-12) *(4) (@-12) *(4) *(-1) 37 == + =(4) "
; Fused expression:    "*(4) (@-12) == *ax 37 + *(@-12) ax =(204) *(@-12) ax "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 37
	sete	al
	movzx	eax, al
	mov	ecx, eax
	mov	eax, [ebp-12]
	add	eax, ecx
	mov	[ebp-12], eax
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; continue
	jmp	L227
; }
L230:
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-12) ++p(4) "
; Fused expression:    "++p(4) *(@-12) "
	mov	eax, [ebp-12]
	inc	dword [ebp-12]
; RPN'ized expression: "minlen 0 = "
; Expanded expression: "(@-48) 0 =(4) "
; Fused expression:    "=(204) *(@-48) 0 "
	mov	eax, 0
	mov	[ebp-48], eax
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-44) 0 =(4) "
; Fused expression:    "=(204) *(@-44) 0 "
	mov	eax, 0
	mov	[ebp-44], eax
; if
; RPN'ized expression: "p *u 43 == "
; Expanded expression: "(@-12) *(4) *(-1) 43 == "
; Fused expression:    "*(4) (@-12) == *ax 43 IF! "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 43
	jne	L233
; {
; RPN'ized expression: "msign 1 = "
; Expanded expression: "(@-44) 1 =(4) "
; Fused expression:    "=(204) *(@-44) 1 "
	mov	eax, 1
	mov	[ebp-44], eax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-12) ++p(4) "
; Fused expression:    "++p(4) *(@-12) "
	mov	eax, [ebp-12]
	inc	dword [ebp-12]
; }
	jmp	L234
L233:
; else
; if
; RPN'ized expression: "p *u 45 == "
; Expanded expression: "(@-12) *(4) *(-1) 45 == "
; Fused expression:    "*(4) (@-12) == *ax 45 IF! "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 45
	jne	L235
; {
; RPN'ized expression: "msign 1 -u = "
; Expanded expression: "(@-44) -1 =(4) "
; Fused expression:    "=(204) *(@-44) -1 "
	mov	eax, -1
	mov	[ebp-44], eax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-12) ++p(4) "
; Fused expression:    "++p(4) *(@-12) "
	mov	eax, [ebp-12]
	inc	dword [ebp-12]
; }
L235:
L234:
; if
; RPN'ized expression: "( p *u isdigit ) "
; Expanded expression: " (@-12) *(4) *(-1)  isdigit ()4 "
; Fused expression:    "( *(4) (@-12) *(-1) ax , isdigit )4 "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_isdigit
	sub	esp, -4
; JumpIfZero
	test	eax, eax
	je	L237
; {
; while
; RPN'ized expression: "( p *u isdigit ) "
; Expanded expression: " (@-12) *(4) *(-1)  isdigit ()4 "
L239:
; Fused expression:    "( *(4) (@-12) *(-1) ax , isdigit )4 "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_isdigit
	sub	esp, -4
; JumpIfZero
	test	eax, eax
	je	L240
; RPN'ized expression: "minlen minlen 10 * p ++p *u + 48 - = "
; Expanded expression: "(@-48) (@-48) *(4) 10 * (@-12) ++p(4) *(-1) + 48 - =(4) "
; Fused expression:    "* *(@-48) 10 push-ax ++p(4) *(@-12) + *sp *ax - ax 48 =(204) *(@-48) ax "
	mov	eax, [ebp-48]
	imul	eax, eax, 10
	push	eax
	mov	eax, [ebp-12]
	inc	dword [ebp-12]
	mov	ebx, eax
	movsx	ecx, byte [ebx]
	pop	eax
	add	eax, ecx
	sub	eax, 48
	mov	[ebp-48], eax
	jmp	L239
L240:
; if
; RPN'ized expression: "msign 0 < "
; Expanded expression: "(@-44) *(4) 0 < "
; Fused expression:    "< *(@-44) 0 IF! "
	mov	eax, [ebp-44]
	cmp	eax, 0
	jge	L241
; RPN'ized expression: "minlen minlen -u = "
; Expanded expression: "(@-48) (@-48) *(4) -u =(4) "
; Fused expression:    "*(4) (@-48) -u =(204) *(@-48) ax "
	mov	eax, [ebp-48]
	neg	eax
	mov	[ebp-48], eax
L241:
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-44) 0 =(4) "
; Fused expression:    "=(204) *(@-44) 0 "
	mov	eax, 0
	mov	[ebp-44], eax
; }
L237:
; if
; RPN'ized expression: "msign 0 == "
; Expanded expression: "(@-44) *(4) 0 == "
; Fused expression:    "== *(@-44) 0 IF! "
	mov	eax, [ebp-44]
	cmp	eax, 0
	jne	L243
; {
; if
; RPN'ized expression: "p *u 43 == "
; Expanded expression: "(@-12) *(4) *(-1) 43 == "
; Fused expression:    "*(4) (@-12) == *ax 43 IF! "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 43
	jne	L245
; {
; RPN'ized expression: "msign 1 = "
; Expanded expression: "(@-44) 1 =(4) "
; Fused expression:    "=(204) *(@-44) 1 "
	mov	eax, 1
	mov	[ebp-44], eax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-12) ++p(4) "
; Fused expression:    "++p(4) *(@-12) "
	mov	eax, [ebp-12]
	inc	dword [ebp-12]
; }
	jmp	L246
L245:
; else
; if
; RPN'ized expression: "p *u 45 == "
; Expanded expression: "(@-12) *(4) *(-1) 45 == "
; Fused expression:    "*(4) (@-12) == *ax 45 IF! "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 45
	jne	L247
; {
; RPN'ized expression: "msign 1 -u = "
; Expanded expression: "(@-44) -1 =(4) "
; Fused expression:    "=(204) *(@-44) -1 "
	mov	eax, -1
	mov	[ebp-44], eax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-12) ++p(4) "
; Fused expression:    "++p(4) *(@-12) "
	mov	eax, [ebp-12]
	inc	dword [ebp-12]
; }
L247:
L246:
; }
L243:
; RPN'ized expression: "phex L249 = "
; Expanded expression: "(@-16) L249 =(4) "

section .data
L249:
	db	"0123456789abcdef",0

section .text
; Fused expression:    "=(204) *(@-16) L249 "
	mov	eax, L249
	mov	[ebp-16], eax
; switch
; RPN'ized expression: "p *u "
; Expanded expression: "(@-12) *(4) *(-1) "
; Fused expression:    "*(4) (@-12) *(-1) ax "
	mov	eax, [ebp-12]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	jmp	L253
; {
; case
; RPN'ized expression: "99 "
; Expanded expression: "99 "
; Expression value: 99
	jmp	L254
L253:
	cmp	eax, 99
	jne	L255
L254:
; while
; RPN'ized expression: "minlen 1 > "
; Expanded expression: "(@-48) *(4) 1 > "
L257:
; Fused expression:    "> *(@-48) 1 IF! "
	mov	eax, [ebp-48]
	cmp	eax, 1
	jle	L258
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-48) --p(4) "
; Fused expression:    "--p(4) *(@-48) "
	mov	eax, [ebp-48]
	dec	dword [ebp-48]
; }
	jmp	L257
L258:
; RPN'ized expression: "( pp ++p *u putchar ) "
; Expanded expression: " (@-4) 4 +=p(4) *(4)  putchar ()4 "
; Fused expression:    "( +=p(4) *(@-4) 4 *(4) ax , putchar )4 "
	mov	eax, [ebp-4]
	add	dword [ebp-4], 4
	mov	ebx, eax
	push	dword [ebx]
	call	_putchar
	sub	esp, -4
; while
; RPN'ized expression: "minlen -u 1 > "
; Expanded expression: "(@-48) *(4) -u 1 > "
L259:
; Fused expression:    "*(4) (@-48) -u > ax 1 IF! "
	mov	eax, [ebp-48]
	neg	eax
	cmp	eax, 1
	jle	L260
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-48) ++p(4) "
; Fused expression:    "++p(4) *(@-48) "
	mov	eax, [ebp-48]
	inc	dword [ebp-48]
; }
	jmp	L259
L260:
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; break
	jmp	L251
; case
; RPN'ized expression: "115 "
; Expanded expression: "115 "
; Expression value: 115
	jmp	L256
L255:
	cmp	eax, 115
	jne	L261
L256:
; RPN'ized expression: "pc pp ++p *u = "
; Expanded expression: "(@-32) (@-4) 4 +=p(4) *(4) =(4) "
; Fused expression:    "+=p(4) *(@-4) 4 =(204) *(@-32) *ax "
	mov	eax, [ebp-4]
	add	dword [ebp-4], 4
	mov	ebx, eax
	mov	eax, [ebx]
	mov	[ebp-32], eax
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-52) 0 =(4) "
; Fused expression:    "=(204) *(@-52) 0 "
	mov	eax, 0
	mov	[ebp-52], eax
; if
; RPN'ized expression: "pc "
; Expanded expression: "(@-32) *(4) "
; Fused expression:    "*(4) (@-32) "
	mov	eax, [ebp-32]
; JumpIfZero
	test	eax, eax
	je	L263
; RPN'ized expression: "len ( pc strlen ) = "
; Expanded expression: "(@-52)  (@-32) *(4)  strlen ()4 =(4) "
; Fused expression:    "( *(4) (@-32) , strlen )4 =(204) *(@-52) ax "
	push	dword [ebp-32]
	call	_strlen
	sub	esp, -4
	mov	[ebp-52], eax
L263:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-48) *(4) (@-52) *(4) > "
L265:
; Fused expression:    "> *(@-48) *(@-52) IF! "
	mov	eax, [ebp-48]
	cmp	eax, [ebp-52]
	jle	L266
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-48) --p(4) "
; Fused expression:    "--p(4) *(@-48) "
	mov	eax, [ebp-48]
	dec	dword [ebp-48]
; }
	jmp	L265
L266:
; if
; RPN'ized expression: "len "
; Expanded expression: "(@-52) *(4) "
; Fused expression:    "*(4) (@-52) "
	mov	eax, [ebp-52]
; JumpIfZero
	test	eax, eax
	je	L267
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-32) *(4) *(-1) 0 != "
L269:
; Fused expression:    "*(4) (@-32) != *ax 0 IF! "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	je	L270
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-32) ++p(4) *(-1)  putchar ()4 "
; Fused expression:    "( ++p(4) *(@-32) *(-1) ax , putchar )4 "
	mov	eax, [ebp-32]
	inc	dword [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; }
	jmp	L269
L270:
L267:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-48) *(4) -u (@-52) *(4) > "
L271:
; Fused expression:    "*(4) (@-48) -u > ax *(@-52) IF! "
	mov	eax, [ebp-48]
	neg	eax
	cmp	eax, [ebp-52]
	jle	L272
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-48) ++p(4) "
; Fused expression:    "++p(4) *(@-48) "
	mov	eax, [ebp-48]
	inc	dword [ebp-48]
; }
	jmp	L271
L272:
; break
	jmp	L251
; case
; RPN'ized expression: "105 "
; Expanded expression: "105 "
; Expression value: 105
	jmp	L262
L261:
	cmp	eax, 105
	jne	L273
L262:
; case
; RPN'ized expression: "100 "
; Expanded expression: "100 "
; Expression value: 100
	jmp	L274
L273:
	cmp	eax, 100
	jne	L275
L274:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-32) (@-17) =(4) "
; Fused expression:    "=(204) *(@-32) (@-17) "
	lea	eax, [ebp-17]
	mov	[ebp-32], eax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-32) *(4) 0 =(-1) "
; Fused expression:    "*(4) (@-32) =(124) *ax 0 "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	eax, 0
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-52) 0 =(4) "
; Fused expression:    "=(204) *(@-52) 0 "
	mov	eax, 0
	mov	[ebp-52], eax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-36) (@-4) 4 +=p(4) *(4) =(4) "
; Fused expression:    "+=p(4) *(@-4) 4 =(204) *(@-36) *ax "
	mov	eax, [ebp-4]
	add	dword [ebp-4], 4
	mov	ebx, eax
	mov	eax, [ebx]
	mov	[ebp-36], eax
; RPN'ized expression: "sign 1 2 n 0 < * - = "
; Expanded expression: "(@-40) 1 2 (@-36) *(4) 0 < * - =(4) "
; Fused expression:    "< *(@-36) 0 * 2 ax - 1 ax =(204) *(@-40) ax "
	mov	eax, [ebp-36]
	cmp	eax, 0
	setl	al
	movzx	eax, al
	mov	ecx, eax
	mov	eax, 2
	mul	ecx
	mov	ecx, eax
	mov	eax, 1
	sub	eax, ecx
	mov	[ebp-40], eax
; do
L277:
; {
; RPN'ized expression: "pc -- *u 48 n n 10 / 10 * - sign * + = "
; Expanded expression: "(@-32) --(4) 48 (@-36) *(4) (@-36) *(4) 10 / 10 * - (@-40) *(4) * + =(-1) "
; Fused expression:    "--(4) *(@-32) push-ax / *(@-36) 10 * ax 10 - *(@-36) ax * ax *(@-40) + 48 ax =(124) **sp ax "
	dec	dword [ebp-32]
	mov	eax, [ebp-32]
	push	eax
	mov	eax, [ebp-36]
	cdq
	mov	ecx, 10
	idiv	ecx
	imul	eax, eax, 10
	mov	ecx, eax
	mov	eax, [ebp-36]
	sub	eax, ecx
	mul	dword [ebp-40]
	mov	ecx, eax
	mov	eax, 48
	add	eax, ecx
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "n n 10 / = "
; Expanded expression: "(@-36) (@-36) *(4) 10 / =(4) "
; Fused expression:    "/ *(@-36) 10 =(204) *(@-36) ax "
	mov	eax, [ebp-36]
	cdq
	mov	ecx, 10
	idiv	ecx
	mov	[ebp-36], eax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-52) ++p(4) "
; Fused expression:    "++p(4) *(@-52) "
	mov	eax, [ebp-52]
	inc	dword [ebp-52]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-36) *(4) "
L278:
; Fused expression:    "*(4) (@-36) "
	mov	eax, [ebp-36]
; JumpIfNotZero
	test	eax, eax
	jne	L277
L279:
; if
; RPN'ized expression: "sign 0 < "
; Expanded expression: "(@-40) *(4) 0 < "
; Fused expression:    "< *(@-40) 0 IF! "
	mov	eax, [ebp-40]
	cmp	eax, 0
	jge	L280
; {
; RPN'ized expression: "pc -- *u 45 = "
; Expanded expression: "(@-32) --(4) 45 =(-1) "
; Fused expression:    "--(4) *(@-32) =(124) *ax 45 "
	dec	dword [ebp-32]
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	eax, 45
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-52) ++p(4) "
; Fused expression:    "++p(4) *(@-52) "
	mov	eax, [ebp-52]
	inc	dword [ebp-52]
; }
	jmp	L281
L280:
; else
; if
; RPN'ized expression: "msign 0 > "
; Expanded expression: "(@-44) *(4) 0 > "
; Fused expression:    "> *(@-44) 0 IF! "
	mov	eax, [ebp-44]
	cmp	eax, 0
	jle	L282
; {
; RPN'ized expression: "pc -- *u 43 = "
; Expanded expression: "(@-32) --(4) 43 =(-1) "
; Fused expression:    "--(4) *(@-32) =(124) *ax 43 "
	dec	dword [ebp-32]
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	eax, 43
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-52) ++p(4) "
; Fused expression:    "++p(4) *(@-52) "
	mov	eax, [ebp-52]
	inc	dword [ebp-52]
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-44) 0 =(4) "
; Fused expression:    "=(204) *(@-44) 0 "
	mov	eax, 0
	mov	[ebp-44], eax
; }
L282:
L281:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-48) *(4) (@-52) *(4) > "
L284:
; Fused expression:    "> *(@-48) *(@-52) IF! "
	mov	eax, [ebp-48]
	cmp	eax, [ebp-52]
	jle	L285
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-48) --p(4) "
; Fused expression:    "--p(4) *(@-48) "
	mov	eax, [ebp-48]
	dec	dword [ebp-48]
; }
	jmp	L284
L285:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-32) *(4) *(-1) 0 != "
L286:
; Fused expression:    "*(4) (@-32) != *ax 0 IF! "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	je	L287
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-32) ++p(4) *(-1)  putchar ()4 "
; Fused expression:    "( ++p(4) *(@-32) *(-1) ax , putchar )4 "
	mov	eax, [ebp-32]
	inc	dword [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; }
	jmp	L286
L287:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-48) *(4) -u (@-52) *(4) > "
L288:
; Fused expression:    "*(4) (@-48) -u > ax *(@-52) IF! "
	mov	eax, [ebp-48]
	neg	eax
	cmp	eax, [ebp-52]
	jle	L289
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-48) ++p(4) "
; Fused expression:    "++p(4) *(@-48) "
	mov	eax, [ebp-48]
	inc	dword [ebp-48]
; }
	jmp	L288
L289:
; break
	jmp	L251
; case
; RPN'ized expression: "117 "
; Expanded expression: "117 "
; Expression value: 117
	jmp	L276
L275:
	cmp	eax, 117
	jne	L290
L276:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-32) (@-17) =(4) "
; Fused expression:    "=(204) *(@-32) (@-17) "
	lea	eax, [ebp-17]
	mov	[ebp-32], eax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-32) *(4) 0 =(-1) "
; Fused expression:    "*(4) (@-32) =(124) *ax 0 "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	eax, 0
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-52) 0 =(4) "
; Fused expression:    "=(204) *(@-52) 0 "
	mov	eax, 0
	mov	[ebp-52], eax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-36) (@-4) 4 +=p(4) *(4) =(4) "
; Fused expression:    "+=p(4) *(@-4) 4 =(204) *(@-36) *ax "
	mov	eax, [ebp-4]
	add	dword [ebp-4], 4
	mov	ebx, eax
	mov	eax, [ebx]
	mov	[ebp-36], eax
; do
L292:
; {
; loc                 nn : (@-56): unsigned
; =
; RPN'ized expression: "n "
; Expanded expression: "(@-36) *(4) "
; Fused expression:    "=(204) *(@-56) *(@-36) "
	mov	eax, [ebp-36]
	mov	[ebp-56], eax
; RPN'ized expression: "pc -- *u 48 nn 10 % + = "
; Expanded expression: "(@-32) --(4) 48 (@-56) *(4) 10 %u + =(-1) "
; Fused expression:    "--(4) *(@-32) push-ax %u *(@-56) 10 + 48 ax =(124) **sp ax "
	dec	dword [ebp-32]
	mov	eax, [ebp-32]
	push	eax
	mov	eax, [ebp-56]
	mov	edx, 0
	mov	ecx, 10
	div	ecx
	mov	eax, edx
	mov	ecx, eax
	mov	eax, 48
	add	eax, ecx
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "n nn 10 / = "
; Expanded expression: "(@-36) (@-56) *(4) 10 /u =(4) "
; Fused expression:    "/u *(@-56) 10 =(204) *(@-36) ax "
	mov	eax, [ebp-56]
	mov	edx, 0
	mov	ecx, 10
	div	ecx
	mov	[ebp-36], eax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-52) ++p(4) "
; Fused expression:    "++p(4) *(@-52) "
	mov	eax, [ebp-52]
	inc	dword [ebp-52]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-36) *(4) "
L293:
; Fused expression:    "*(4) (@-36) "
	mov	eax, [ebp-36]
; JumpIfNotZero
	test	eax, eax
	jne	L292
L294:
; if
; RPN'ized expression: "msign 0 > "
; Expanded expression: "(@-44) *(4) 0 > "
; Fused expression:    "> *(@-44) 0 IF! "
	mov	eax, [ebp-44]
	cmp	eax, 0
	jle	L295
; {
; RPN'ized expression: "pc -- *u 43 = "
; Expanded expression: "(@-32) --(4) 43 =(-1) "
; Fused expression:    "--(4) *(@-32) =(124) *ax 43 "
	dec	dword [ebp-32]
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	eax, 43
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-52) ++p(4) "
; Fused expression:    "++p(4) *(@-52) "
	mov	eax, [ebp-52]
	inc	dword [ebp-52]
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-44) 0 =(4) "
; Fused expression:    "=(204) *(@-44) 0 "
	mov	eax, 0
	mov	[ebp-44], eax
; }
L295:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-48) *(4) (@-52) *(4) > "
L297:
; Fused expression:    "> *(@-48) *(@-52) IF! "
	mov	eax, [ebp-48]
	cmp	eax, [ebp-52]
	jle	L298
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-48) --p(4) "
; Fused expression:    "--p(4) *(@-48) "
	mov	eax, [ebp-48]
	dec	dword [ebp-48]
; }
	jmp	L297
L298:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-32) *(4) *(-1) 0 != "
L299:
; Fused expression:    "*(4) (@-32) != *ax 0 IF! "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	je	L300
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-32) ++p(4) *(-1)  putchar ()4 "
; Fused expression:    "( ++p(4) *(@-32) *(-1) ax , putchar )4 "
	mov	eax, [ebp-32]
	inc	dword [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; }
	jmp	L299
L300:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-48) *(4) -u (@-52) *(4) > "
L301:
; Fused expression:    "*(4) (@-48) -u > ax *(@-52) IF! "
	mov	eax, [ebp-48]
	neg	eax
	cmp	eax, [ebp-52]
	jle	L302
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-48) ++p(4) "
; Fused expression:    "++p(4) *(@-48) "
	mov	eax, [ebp-48]
	inc	dword [ebp-48]
; }
	jmp	L301
L302:
; break
	jmp	L251
; case
; RPN'ized expression: "88 "
; Expanded expression: "88 "
; Expression value: 88
	jmp	L291
L290:
	cmp	eax, 88
	jne	L303
L291:
; RPN'ized expression: "phex L305 = "
; Expanded expression: "(@-16) L305 =(4) "

section .data
L305:
	db	"0123456789ABCDEF",0

section .text
; Fused expression:    "=(204) *(@-16) L305 "
	mov	eax, L305
	mov	[ebp-16], eax
; case
; RPN'ized expression: "112 "
; Expanded expression: "112 "
; Expression value: 112
	jmp	L304
L303:
	cmp	eax, 112
	jne	L307
L304:
; case
; RPN'ized expression: "120 "
; Expanded expression: "120 "
; Expression value: 120
	jmp	L308
L307:
	cmp	eax, 120
	jne	L309
L308:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-32) (@-17) =(4) "
; Fused expression:    "=(204) *(@-32) (@-17) "
	lea	eax, [ebp-17]
	mov	[ebp-32], eax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-32) *(4) 0 =(-1) "
; Fused expression:    "*(4) (@-32) =(124) *ax 0 "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	eax, 0
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-52) 0 =(4) "
; Fused expression:    "=(204) *(@-52) 0 "
	mov	eax, 0
	mov	[ebp-52], eax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-36) (@-4) 4 +=p(4) *(4) =(4) "
; Fused expression:    "+=p(4) *(@-4) 4 =(204) *(@-36) *ax "
	mov	eax, [ebp-4]
	add	dword [ebp-4], 4
	mov	ebx, eax
	mov	eax, [ebx]
	mov	[ebp-36], eax
; do
L311:
; {
; loc                 nn : (@-56): unsigned
; =
; RPN'ized expression: "n "
; Expanded expression: "(@-36) *(4) "
; Fused expression:    "=(204) *(@-56) *(@-36) "
	mov	eax, [ebp-36]
	mov	[ebp-56], eax
; RPN'ized expression: "pc -- *u phex nn 15 & + *u = "
; Expanded expression: "(@-32) --(4) (@-16) *(4) (@-56) *(4) 15 & + *(-1) =(-1) "
; Fused expression:    "--(4) *(@-32) push-ax & *(@-56) 15 + *(@-16) ax =(119) **sp *ax "
	dec	dword [ebp-32]
	mov	eax, [ebp-32]
	push	eax
	mov	eax, [ebp-56]
	and	eax, 15
	mov	ecx, eax
	mov	eax, [ebp-16]
	add	eax, ecx
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "n nn 4 >> = "
; Expanded expression: "(@-36) (@-56) *(4) 4 >>u =(4) "
; Fused expression:    ">>u *(@-56) 4 =(204) *(@-36) ax "
	mov	eax, [ebp-56]
	shr	eax, 4
	mov	[ebp-36], eax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-52) ++p(4) "
; Fused expression:    "++p(4) *(@-52) "
	mov	eax, [ebp-52]
	inc	dword [ebp-52]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-36) *(4) "
L312:
; Fused expression:    "*(4) (@-36) "
	mov	eax, [ebp-36]
; JumpIfNotZero
	test	eax, eax
	jne	L311
L313:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-48) *(4) (@-52) *(4) > "
L314:
; Fused expression:    "> *(@-48) *(@-52) IF! "
	mov	eax, [ebp-48]
	cmp	eax, [ebp-52]
	jle	L315
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-48) --p(4) "
; Fused expression:    "--p(4) *(@-48) "
	mov	eax, [ebp-48]
	dec	dword [ebp-48]
; }
	jmp	L314
L315:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-32) *(4) *(-1) 0 != "
L316:
; Fused expression:    "*(4) (@-32) != *ax 0 IF! "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	je	L317
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-32) ++p(4) *(-1)  putchar ()4 "
; Fused expression:    "( ++p(4) *(@-32) *(-1) ax , putchar )4 "
	mov	eax, [ebp-32]
	inc	dword [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; }
	jmp	L316
L317:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-48) *(4) -u (@-52) *(4) > "
L318:
; Fused expression:    "*(4) (@-48) -u > ax *(@-52) IF! "
	mov	eax, [ebp-48]
	neg	eax
	cmp	eax, [ebp-52]
	jle	L319
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-48) ++p(4) "
; Fused expression:    "++p(4) *(@-48) "
	mov	eax, [ebp-48]
	inc	dword [ebp-48]
; }
	jmp	L318
L319:
; break
	jmp	L251
; case
; RPN'ized expression: "111 "
; Expanded expression: "111 "
; Expression value: 111
	jmp	L310
L309:
	cmp	eax, 111
	jne	L320
L310:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-32) (@-17) =(4) "
; Fused expression:    "=(204) *(@-32) (@-17) "
	lea	eax, [ebp-17]
	mov	[ebp-32], eax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-32) *(4) 0 =(-1) "
; Fused expression:    "*(4) (@-32) =(124) *ax 0 "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	eax, 0
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-52) 0 =(4) "
; Fused expression:    "=(204) *(@-52) 0 "
	mov	eax, 0
	mov	[ebp-52], eax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-36) (@-4) 4 +=p(4) *(4) =(4) "
; Fused expression:    "+=p(4) *(@-4) 4 =(204) *(@-36) *ax "
	mov	eax, [ebp-4]
	add	dword [ebp-4], 4
	mov	ebx, eax
	mov	eax, [ebx]
	mov	[ebp-36], eax
; do
L322:
; {
; loc                 nn : (@-56): unsigned
; =
; RPN'ized expression: "n "
; Expanded expression: "(@-36) *(4) "
; Fused expression:    "=(204) *(@-56) *(@-36) "
	mov	eax, [ebp-36]
	mov	[ebp-56], eax
; RPN'ized expression: "pc -- *u 48 nn 7 & + = "
; Expanded expression: "(@-32) --(4) 48 (@-56) *(4) 7 & + =(-1) "
; Fused expression:    "--(4) *(@-32) push-ax & *(@-56) 7 + 48 ax =(124) **sp ax "
	dec	dword [ebp-32]
	mov	eax, [ebp-32]
	push	eax
	mov	eax, [ebp-56]
	and	eax, 7
	mov	ecx, eax
	mov	eax, 48
	add	eax, ecx
	pop	ebx
	mov	[ebx], al
	movsx	eax, al
; RPN'ized expression: "n nn 3 >> = "
; Expanded expression: "(@-36) (@-56) *(4) 3 >>u =(4) "
; Fused expression:    ">>u *(@-56) 3 =(204) *(@-36) ax "
	mov	eax, [ebp-56]
	shr	eax, 3
	mov	[ebp-36], eax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-52) ++p(4) "
; Fused expression:    "++p(4) *(@-52) "
	mov	eax, [ebp-52]
	inc	dword [ebp-52]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-36) *(4) "
L323:
; Fused expression:    "*(4) (@-36) "
	mov	eax, [ebp-36]
; JumpIfNotZero
	test	eax, eax
	jne	L322
L324:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-48) *(4) (@-52) *(4) > "
L325:
; Fused expression:    "> *(@-48) *(@-52) IF! "
	mov	eax, [ebp-48]
	cmp	eax, [ebp-52]
	jle	L326
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-48) --p(4) "
; Fused expression:    "--p(4) *(@-48) "
	mov	eax, [ebp-48]
	dec	dword [ebp-48]
; }
	jmp	L325
L326:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-32) *(4) *(-1) 0 != "
L327:
; Fused expression:    "*(4) (@-32) != *ax 0 IF! "
	mov	eax, [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	cmp	eax, 0
	je	L328
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-32) ++p(4) *(-1)  putchar ()4 "
; Fused expression:    "( ++p(4) *(@-32) *(-1) ax , putchar )4 "
	mov	eax, [ebp-32]
	inc	dword [ebp-32]
	mov	ebx, eax
	mov	al, [ebx]
	movsx	eax, al
	push	eax
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; }
	jmp	L327
L328:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-48) *(4) -u (@-52) *(4) > "
L329:
; Fused expression:    "*(4) (@-48) -u > ax *(@-52) IF! "
	mov	eax, [ebp-48]
	neg	eax
	cmp	eax, [ebp-52]
	jle	L330
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()4 "
; Fused expression:    "( 32 , putchar )4 "
	push	32
	call	_putchar
	sub	esp, -4
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-8) ++p(4) "
; Fused expression:    "++p(4) *(@-8) "
	mov	eax, [ebp-8]
	inc	dword [ebp-8]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-48) ++p(4) "
; Fused expression:    "++p(4) *(@-48) "
	mov	eax, [ebp-48]
	inc	dword [ebp-48]
; }
	jmp	L329
L330:
; break
	jmp	L251
; default
L252:
; return
; RPN'ized expression: "1 -u "
; Expanded expression: "-1 "
; Expression value: -1
; Fused expression:    "-1 "
	mov	eax, -1
	jmp	L224
; }
	jmp	L251
L320:
	jmp	L252
L251:
; }
	jmp	L227
L229:
; return
; RPN'ized expression: "cnt "
; Expanded expression: "(@-8) *(4) "
; Fused expression:    "*(4) (@-8) "
	mov	eax, [ebp-8]
	jmp	L224
L224:
	leave
	ret
L223:
	sub	esp, 56
	jmp	L222

; glb putchar : (
; prm     c : int
;     ) int
section .text
_putchar:
	push	ebp
	mov	ebp, esp
	jmp	L332
L331:
; loc     c : (@8): int
; if
; RPN'ized expression: "c 10 == "
; Expanded expression: "(@8) *(4) 10 == "
; Fused expression:    "== *(@8) 10 IF! "
	mov	eax, [ebp+8]
	cmp	eax, 10
	jne	L335
; {
; RPN'ized expression: "( newline ) "
; Expanded expression: " newline ()0 "
; Fused expression:    "( newline )0 "
	call	_newline
; }
L335:
; RPN'ized expression: "( c printc ) "
; Expanded expression: " (@8) *(4)  printc ()4 "
; Fused expression:    "( *(4) (@8) , printc )4 "
	push	dword [ebp+8]
	call	_printc
	sub	esp, -4
L333:
	leave
	ret
L332:
	jmp	L331

; glb printf : (
; prm     fmt : * char
; prm     ...
;     ) int
section .text
_printf:
	push	ebp
	mov	ebp, esp
	jmp	L338
L337:
; loc     fmt : (@8): * char
; loc     pp : (@-4): * * void
; =
; RPN'ized expression: "fmt &u "
; Expanded expression: "(@8) "
; Fused expression:    "=(204) *(@-4) (@8) "
	lea	eax, [ebp+8]
	mov	[ebp-4], eax
; return
; RPN'ized expression: "( pp 1 + , fmt vprintf ) "
; Expanded expression: " (@-4) *(4) 4 +  (@8) *(4)  vprintf ()8 "
; Fused expression:    "( + *(@-4) 4 , *(4) (@8) , vprintf )8 "
	mov	eax, [ebp-4]
	add	eax, 4
	push	eax
	push	dword [ebp+8]
	call	_vprintf
	sub	esp, -8
	jmp	L339
L339:
	leave
	ret
L338:
	sub	esp, 4
	jmp	L337

; glb gettimeofday : (
; prm     buffer : * unsigned char
;     ) void
section .text
_gettimeofday:
	push	ebp
	mov	ebp, esp
	jmp	L342
L341:
; loc     buffer : (@8): * unsigned char
mov edi, [ebp + 8]
mov ah, 0x20
int 0x50
L343:
	leave
	ret
L342:
	jmp	L341

; glb getdate : (
; prm     buffer : * unsigned char
;     ) void
section .text
_getdate:
	push	ebp
	mov	ebp, esp
	jmp	L346
L345:
; loc     buffer : (@8): * unsigned char
mov edi, [ebp + 8]
mov ah, 0x21
int 0x50
L347:
	leave
	ret
L346:
	jmp	L345

__stack_ptr dd 0x00000000
; glb z_main : () int
section .text
_z_main:
	push	ebp
	mov	ebp, esp
	jmp	L350
L349:
; loc     n1 : (@-4): int
; loc     n2 : (@-8): int
; loc     i : (@-12): int
; loc     j : (@-16): int
; loc     flag : (@-20): int
; loc     count : (@-24): int
; RPN'ized expression: "n1 0 = "
; Expanded expression: "(@-4) 0 =(4) "
; Fused expression:    "=(204) *(@-4) 0 "
	mov	eax, 0
	mov	[ebp-4], eax
; RPN'ized expression: "n2 0 = "
; Expanded expression: "(@-8) 0 =(4) "
; Fused expression:    "=(204) *(@-8) 0 "
	mov	eax, 0
	mov	[ebp-8], eax
; RPN'ized expression: "n2 ( _args atoi ) = "
; Expanded expression: "(@-8)  _args *(4)  atoi ()4 =(4) "
; Fused expression:    "( *(4) _args , atoi )4 =(204) *(@-8) ax "
	push	dword [__args]
	call	_atoi
	sub	esp, -4
	mov	[ebp-8], eax
; RPN'ized expression: "( start_timer ) "
; Expanded expression: " start_timer ()0 "
; Fused expression:    "( start_timer )0 "
	call	_start_timer
; RPN'ized expression: "( n2 , L353 printf ) "
; Expanded expression: " (@-8) *(4)  L353  printf ()8 "

section .data
L353:
	db	10,"Prime Number from 0 to %d",0

section .text
; Fused expression:    "( *(4) (@-8) , L353 , printf )8 "
	push	dword [ebp-8]
	push	L353
	call	_printf
	sub	esp, -8
; RPN'ized expression: "( newline ) "
; Expanded expression: " newline ()0 "
; Fused expression:    "( newline )0 "
	call	_newline
; for
; RPN'ized expression: "i n1 1 + = "
; Expanded expression: "(@-12) (@-4) *(4) 1 + =(4) "
; Fused expression:    "+ *(@-4) 1 =(204) *(@-12) ax "
	mov	eax, [ebp-4]
	inc	eax
	mov	[ebp-12], eax
L355:
; RPN'ized expression: "i n2 < "
; Expanded expression: "(@-12) *(4) (@-8) *(4) < "
; Fused expression:    "< *(@-12) *(@-8) IF! "
	mov	eax, [ebp-12]
	cmp	eax, [ebp-8]
	jge	L358
	jmp	L357
L356:
; RPN'ized expression: "i ++ "
; Expanded expression: "(@-12) ++(4) "
; Fused expression:    "++(4) *(@-12) "
	inc	dword [ebp-12]
	mov	eax, [ebp-12]
	jmp	L355
L357:
; {
; RPN'ized expression: "flag 0 = "
; Expanded expression: "(@-20) 0 =(4) "
; Fused expression:    "=(204) *(@-20) 0 "
	mov	eax, 0
	mov	[ebp-20], eax
; for
; RPN'ized expression: "j 2 = "
; Expanded expression: "(@-16) 2 =(4) "
; Fused expression:    "=(204) *(@-16) 2 "
	mov	eax, 2
	mov	[ebp-16], eax
L359:
; RPN'ized expression: "j i 2 / <= "
; Expanded expression: "(@-16) *(4) (@-12) *(4) 2 / <= "
; Fused expression:    "/ *(@-12) 2 <= *(@-16) ax IF! "
	mov	eax, [ebp-12]
	cdq
	mov	ecx, 2
	idiv	ecx
	mov	ecx, eax
	mov	eax, [ebp-16]
	cmp	eax, ecx
	jg	L362
	jmp	L361
L360:
; RPN'ized expression: "j ++ "
; Expanded expression: "(@-16) ++(4) "
; Fused expression:    "++(4) *(@-16) "
	inc	dword [ebp-16]
	mov	eax, [ebp-16]
	jmp	L359
L361:
; {
; if
; RPN'ized expression: "i j % 0 == "
; Expanded expression: "(@-12) *(4) (@-16) *(4) % 0 == "
; Fused expression:    "% *(@-12) *(@-16) == ax 0 IF! "
	mov	eax, [ebp-12]
	cdq
	idiv	dword [ebp-16]
	mov	eax, edx
	cmp	eax, 0
	jne	L363
; {
; RPN'ized expression: "flag 1 = "
; Expanded expression: "(@-20) 1 =(4) "
; Fused expression:    "=(204) *(@-20) 1 "
	mov	eax, 1
	mov	[ebp-20], eax
; break
	jmp	L362
; }
L363:
; }
	jmp	L360
L362:
; if
; RPN'ized expression: "flag 0 == "
; Expanded expression: "(@-20) *(4) 0 == "
; Fused expression:    "== *(@-20) 0 IF! "
	mov	eax, [ebp-20]
	cmp	eax, 0
	jne	L365
; {
; RPN'ized expression: "( i , L367 printf ) "
; Expanded expression: " (@-12) *(4)  L367  printf ()8 "

section .data
L367:
	db	"%d ",0

section .text
; Fused expression:    "( *(4) (@-12) , L367 , printf )8 "
	push	dword [ebp-12]
	push	L367
	call	_printf
	sub	esp, -8
; RPN'ized expression: "count ++p "
; Expanded expression: "(@-24) ++p(4) "
; Fused expression:    "++p(4) *(@-24) "
	mov	eax, [ebp-24]
	inc	dword [ebp-24]
; }
L365:
; }
	jmp	L356
L358:
; loc     time : (@-28): int
; =
; RPN'ized expression: "( get_timer ) "
; Expanded expression: " get_timer ()0 "
; Fused expression:    "( get_timer )0 =(204) *(@-28) ax "
	call	_get_timer
	mov	[ebp-28], eax
; RPN'ized expression: "( time , L369 printf ) "
; Expanded expression: " (@-28) *(4)  L369  printf ()8 "

section .data
L369:
	db	10,"Time Taken = %d",0

section .text
; Fused expression:    "( *(4) (@-28) , L369 , printf )8 "
	push	dword [ebp-28]
	push	L369
	call	_printf
	sub	esp, -8
; RPN'ized expression: "( count , L371 printf ) "
; Expanded expression: " (@-24) *(4)  L371  printf ()8 "

section .data
L371:
	db	10,"Number of Primes %d",0

section .text
; Fused expression:    "( *(4) (@-24) , L371 , printf )8 "
	push	dword [ebp-24]
	push	L371
	call	_printf
	sub	esp, -8
; RPN'ized expression: "( stop_timer ) "
; Expanded expression: " stop_timer ()0 "
; Fused expression:    "( stop_timer )0 "
	call	_stop_timer
; RPN'ized expression: "( exit ) "
; Expanded expression: " exit ()0 "
; Fused expression:    "( exit )0 "
	call	_exit
L351:
	leave
	ret
L350:
	sub	esp, 28
	jmp	L349


; Syntax/declaration table/stack:
; Bytes used: 3360/20224


; Macro table:
; Macro __SMALLER_C__ = `0x0100`
; Macro __SMALLER_C_32__ = ``
; Macro __SMALLER_C_SCHAR__ = ``
; Macro true = `1`
; Macro false = `0`
; Macro BASE_10 = `10`
; Macro BASE_16 = `16`
; Macro APPLICATION_HEAP_START = `0x1A0000`
; Macro MAX_ALLOC_SIZE = `0xFFFFFFFF`
; Macro KEY_BACKSPACE = `8`
; Macro KEY_ESCAPE = `0x011B`
; Macro KEY_ENTER = `0x1C0D`
; Macro KEY_UP = `0x4800`
; Macro KEY_LEFT = `0x4B00`
; Macro KEY_RIGHT = `0x4D00`
; Macro KEY_DOWN = `0x5000`
; Bytes used: 285/4096


; Identifier table:
; Ident size_t
; Ident uint32_t
; Ident sint32_t
; Ident uint16_t
; Ident sint16_t
; Ident uint8_t
; Ident sint8_t
; Ident caddr_t
; Ident bool
; Ident string
; Ident <something>
; Ident hour
; Ident minute
; Ident second
; Ident time_t
; Ident _end
; Ident _start
; Ident _stack_ptr
; Ident ___APPLICATION_SIZE
; Ident ___AUTHOR_NAME
; Ident ___KERNEL_VER
; Ident _args
; Ident video_mode
; Ident mode
; Ident prints
; Ident printc
; Ident c
; Ident newline
; Ident set_text_color
; Ident color
; Ident getcursor
; Ident setcursor
; Ident x
; Ident y
; Ident drawblock
; Ident start_x
; Ident start_y
; Ident end_x
; Ident end_y
; Ident read
; Ident file_name
; Ident file_location
; Ident write
; Ident bytes
; Ident file_query
; Ident result
; Ident pci_write_8
; Ident pci_reg
; Ident pci_device
; Ident pci_write_16
; Ident pci_write_32
; Ident exit
; Ident abort
; Ident strlen
; Ident str
; Ident outportb
; Ident port
; Ident value
; Ident inportb
; Ident reverse
; Ident s
; Ident itoa
; Ident n
; Ident buffer
; Ident base
; Ident strcpy
; Ident dest
; Ident source
; Ident memcpy
; Ident src
; Ident count
; Ident memset
; Ident val
; Ident memsetw
; Ident isdigit
; Ident atoi
; Ident p
; Ident mem_32_start
; Ident mem_32_end
; Ident mem_32_count
; Ident malloc
; Ident length
; Ident get_total_used_memory
; Ident get_memory_end
; Ident get_mem_start
; Ident sbrk
; Ident incr
; Ident idt_set_gate
; Ident isr_ptr
; Ident isr_number
; Ident x86_disable_exception_gates
; Ident x86_enable_exception_gates
; Ident start_timer
; Ident stop_timer
; Ident get_timer
; Ident sleep
; Ident time
; Ident ascii_value
; Ident waitkey
; Ident getch
; Ident run_kbd_interrupt
; Ident get_scan_code
; Ident getstr
; Ident vprintf
; Ident fmt
; Ident vl
; Ident putchar
; Ident printf
; Ident gettimeofday
; Ident getdate
; Ident z_main
; Bytes used: 1060/4752

; Next label number: 373
; 

__end: