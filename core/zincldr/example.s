bits 16

org 0x100
cli
push cs
pop ds
push ds
pop es
push ds
pop ss
push es
pop fs
jmp _main
; glb bool : unsigned
; glb serial_output : unsigned
section .data
	align 2
_serial_output:
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	dw	0

; glb uint8_t : unsigned char
; glb int8_t : char
; glb uint16_t : unsigned
; glb int16_t : int
; glb uint32_t : unsigned
; glb int32_t : int
; glb PhysicalAddr_t : * unsigned
; glb vga_mode_t : unsigned char
; glb screen_color : unsigned char
section .data
_screen_color:
; =
; RPN'ized expression: "7 "
; Expanded expression: "7 "
; Expression value: 7
	db	7

; glb gfx_mode : unsigned
section .data
	align 2
_gfx_mode:
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	dw	0

; glb cursor_t : struct <something>
; glb scr_putchar : (
; prm     c : unsigned char
;     ) void
section .text
_scr_putchar:
	push	bp
	mov	bp, sp
	jmp	L2
L1:
; loc     c : (@4): unsigned char
; if
; RPN'ized expression: "c 10 == "
; Expanded expression: "(@4) *(1) 10 == "
; Fused expression:    "== *(@4) 10 IF! "
	mov	al, [bp+4]
	mov	ah, 0
	cmp	ax, 10
	jne	L5
; {
pusha
mov bh, 0x00
mov al, 13
mov ah, 0x0E
int 0x10
mov al, 10
int 0x10
popa
leave
ret
; }
	jmp	L6
L5:
; else
; {
; if
; RPN'ized expression: "gfx_mode 1 == "
; Expanded expression: "gfx_mode *(2) 1 == "
; Fused expression:    "== *gfx_mode 1 IF! "
	mov	ax, [_gfx_mode]
	cmp	ax, 1
	jne	L7
; {
; RPN'ized expression: "( screen_color , c c_printc ) "
; Expanded expression: " screen_color *(1)  (@4) *(1)  c_printc ()4 "
; Fused expression:    "( *(1) screen_color , *(1) (@4) , c_printc )4 "
	mov	al, [_screen_color]
	mov	ah, 0
	push	ax
	mov	al, [bp+4]
	mov	ah, 0
	push	ax
	call	_c_printc
	sub	sp, -4
leave
ret
; }
L7:
pusha
mov al, [bp + 4]
mov bh, 0x00
mov ah, 0x0E
int 0x10
popa
; }
L6:
L3:
	leave
	ret
L2:
	jmp	L1

; glb c_printc : (
; prm     c : unsigned char
; prm     color : unsigned
;     ) void
section .text
_c_printc:
	push	bp
	mov	bp, sp
	jmp	L10
L9:
; loc     c : (@4): unsigned char
; loc     color : (@6): unsigned
pusha
mov al, [bp + 4]
mov bh, 0x00
mov bl, [bp + 6]
mov ah, 0x0E
int 0x10
popa
L11:
	leave
	ret
L10:
	jmp	L9

; glb vga_gfxmode : (
; prm     mode_number : unsigned char
;     ) int
section .text
_vga_gfxmode:
	push	bp
	mov	bp, sp
	jmp	L14
L13:
; loc     mode_number : (@4): unsigned char
; if
; RPN'ized expression: "mode_number 3 == mode_number 3 == || "
; Expanded expression: "(@4) *(1) 3 == [sh||->19] (@4) *(1) 3 == ||[19] "
; Fused expression:    "== *(@4) 3 [sh||->19] == *(@4) 3 ||[19] "
	mov	al, [bp+4]
	mov	ah, 0
	cmp	ax, 3
	sete	al
	cbw
; JumpIfNotZero
	test	ax, ax
	jne	L19
	mov	al, [bp+4]
	mov	ah, 0
	cmp	ax, 3
	sete	al
	cbw
L19:
; JumpIfZero
	test	ax, ax
	je	L17
; {
pusha
mov al, [bp + 4]
mov ah, 0x00
int 0x10
popa
; RPN'ized expression: "gfx_mode 0 = "
; Expanded expression: "gfx_mode 0 =(2) "
; Fused expression:    "=(170) *gfx_mode 0 "
	mov	ax, 0
	mov	[_gfx_mode], ax
leave
ret
; }
L17:
pusha
mov al, [bp + 4]
mov ah, 0x00
int 0x10
popa
; RPN'ized expression: "gfx_mode 1 = "
; Expanded expression: "gfx_mode 1 =(2) "
; Fused expression:    "=(170) *gfx_mode 1 "
	mov	ax, 1
	mov	[_gfx_mode], ax
L15:
	leave
	ret
L14:
	jmp	L13

; glb errno : unsigned
section .data
	align 2
_errno:
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	dw	0

; glb settextcolor : (
; prm     color : unsigned char
;     ) int
section .text
_settextcolor:
	push	bp
	mov	bp, sp
	jmp	L21
L20:
; loc     color : (@4): unsigned char
; if
; RPN'ized expression: "gfx_mode 0 == "
; Expanded expression: "gfx_mode *(2) 0 == "
; Fused expression:    "== *gfx_mode 0 IF! "
	mov	ax, [_gfx_mode]
	cmp	ax, 0
	jne	L24
; {
; RPN'ized expression: "errno 1 -u = "
; Expanded expression: "errno -1 =(2) "
; Fused expression:    "=(170) *errno -1 "
	mov	ax, -1
	mov	[_errno], ax
; return
; RPN'ized expression: "1 -u "
; Expanded expression: "-1 "
; Expression value: -1
; Fused expression:    "-1 "
	mov	ax, -1
	jmp	L22
; }
	jmp	L25
L24:
; else
; {
; RPN'ized expression: "screen_color color = "
; Expanded expression: "screen_color (@4) *(1) =(1) "
; Fused expression:    "=(153) *screen_color *(@4) "
	mov	al, [bp+4]
	mov	ah, 0
	mov	[_screen_color], al
	mov	ah, 0
; RPN'ized expression: "errno 0 = "
; Expanded expression: "errno 0 =(2) "
; Fused expression:    "=(170) *errno 0 "
	mov	ax, 0
	mov	[_errno], ax
; return
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "0 "
	mov	ax, 0
	jmp	L22
; }
L25:
L22:
	leave
	ret
L21:
	jmp	L20

; glb bios_move_cursor : (
; prm     x : unsigned char
; prm     Y : unsigned char
;     ) void
section .text
_bios_move_cursor:
	push	bp
	mov	bp, sp
	jmp	L27
L26:
; loc     x : (@4): unsigned char
; loc     Y : (@6): unsigned char
pusha
mov bh, 0x00
mov ah, 0x00
mov dl, [bp + 4]
mov dh, [bp + 8]
int 0x10
popa
ret
L28:
	leave
	ret
L27:
	jmp	L26

; glb string : * char
; glb size_t : unsigned
; glb strlen : (
; prm     str : * char
;     ) unsigned
section .text
_strlen:
	push	bp
	mov	bp, sp
	jmp	L31
L30:
; loc     str : (@4): * char
; loc     retval : (@-2): unsigned
; for
; RPN'ized expression: "retval 0 = "
; Expanded expression: "(@-2) 0 =(2) "
; Fused expression:    "=(170) *(@-2) 0 "
	mov	ax, 0
	mov	[bp-2], ax
L34:
; RPN'ized expression: "str *u 0 != "
; Expanded expression: "(@4) *(2) *(-1) 0 != "
; Fused expression:    "*(2) (@4) != *ax 0 IF! "
	mov	ax, [bp+4]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	je	L37
	jmp	L36
L35:
; RPN'ized expression: "str ++p "
; Expanded expression: "(@4) ++p(2) "
; Fused expression:    "++p(2) *(@4) "
	mov	ax, [bp+4]
	inc	word [bp+4]
	jmp	L34
L36:
; RPN'ized expression: "retval ++p "
; Expanded expression: "(@-2) ++p(2) "
; Fused expression:    "++p(2) *(@-2) "
	mov	ax, [bp-2]
	inc	word [bp-2]
	jmp	L35
L37:
; return
; RPN'ized expression: "retval "
; Expanded expression: "(@-2) *(2) "
; Fused expression:    "*(2) (@-2) "
	mov	ax, [bp-2]
	jmp	L32
L32:
	leave
	ret
L31:
	sub	sp, 2
	jmp	L30

; glb reverse : (
; prm     s : * char
;     ) void
section .text
_reverse:
	push	bp
	mov	bp, sp
	jmp	L39
L38:
; loc     s : (@4): * char
; loc     j : (@-2): * char
; loc     i : (@-4): int
; =
; RPN'ized expression: "( s strlen ) "
; Expanded expression: " (@4) *(2)  strlen ()2 "
; Fused expression:    "( *(2) (@4) , strlen )2 =(170) *(@-4) ax "
	push	word [bp+4]
	call	_strlen
	sub	sp, -2
	mov	[bp-4], ax
; RPN'ized expression: "( s , j strcpy ) "
; Expanded expression: " (@4) *(2)  (@-2) *(2)  strcpy ()4 "
; Fused expression:    "( *(2) (@4) , *(2) (@-2) , strcpy )4 "
	push	word [bp+4]
	push	word [bp-2]
	call	_strcpy
	sub	sp, -4
; while
; RPN'ized expression: "i --p 0 >= "
; Expanded expression: "(@-4) --p(2) 0 >= "
L42:
; Fused expression:    "--p(2) *(@-4) >= ax 0 IF! "
	mov	ax, [bp-4]
	dec	word [bp-4]
	cmp	ax, 0
	jl	L43
; RPN'ized expression: "s ++p *u j i + *u = "
; Expanded expression: "(@4) ++p(2) (@-2) *(2) (@-4) *(2) + *(-1) =(-1) "
; Fused expression:    "++p(2) *(@4) push-ax + *(@-2) *(@-4) =(119) **sp *ax "
	mov	ax, [bp+4]
	inc	word [bp+4]
	push	ax
	mov	ax, [bp-2]
	add	ax, [bp-4]
	mov	bx, ax
	mov	al, [bx]
	cbw
	pop	bx
	mov	[bx], al
	cbw
	jmp	L42
L43:
; RPN'ized expression: "s *u 0 = "
; Expanded expression: "(@4) *(2) 0 =(-1) "
; Fused expression:    "*(2) (@4) =(122) *ax 0 "
	mov	ax, [bp+4]
	mov	bx, ax
	mov	ax, 0
	mov	[bx], al
	cbw
L40:
	leave
	ret
L39:
	sub	sp, 4
	jmp	L38

; glb strcpy : (
; prm     dest : * char
; prm     source : * char
;     ) void
section .text
_strcpy:
	push	bp
	mov	bp, sp
	jmp	L45
L44:
; loc     dest : (@4): * char
; loc     source : (@6): * char
; loc     i : (@-2): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(170) *(@-2) 0 "
	mov	ax, 0
	mov	[bp-2], ax
; while
; RPN'ized expression: "1 "
; Expanded expression: "1 "
; Expression value: 1
L48:
; Fused expression:    "1 "
	mov	ax, 1
; JumpIfZero
	test	ax, ax
	je	L49
; {
; RPN'ized expression: "dest i + *u source i + *u = "
; Expanded expression: "(@4) *(2) (@-2) *(2) + (@6) *(2) (@-2) *(2) + *(-1) =(-1) "
; Fused expression:    "+ *(@4) *(@-2) push-ax + *(@6) *(@-2) =(119) **sp *ax "
	mov	ax, [bp+4]
	add	ax, [bp-2]
	push	ax
	mov	ax, [bp+6]
	add	ax, [bp-2]
	mov	bx, ax
	mov	al, [bx]
	cbw
	pop	bx
	mov	[bx], al
	cbw
; if
; RPN'ized expression: "dest i + *u 0 == "
; Expanded expression: "(@4) *(2) (@-2) *(2) + *(-1) 0 == "
; Fused expression:    "+ *(@4) *(@-2) == *ax 0 IF! "
	mov	ax, [bp+4]
	add	ax, [bp-2]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	jne	L50
; break
	jmp	L49
L50:
; RPN'ized expression: "i ++p "
; Expanded expression: "(@-2) ++p(2) "
; Fused expression:    "++p(2) *(@-2) "
	mov	ax, [bp-2]
	inc	word [bp-2]
; }
	jmp	L48
L49:
L46:
	leave
	ret
L45:
	sub	sp, 2
	jmp	L44

; glb memset : (
; prm     dest : * void
; prm     val : char
; prm     count : unsigned
;     ) void
section .text
_memset:
	push	bp
	mov	bp, sp
	jmp	L53
L52:
; loc     dest : (@4): * void
; loc     val : (@6): char
; loc     count : (@8): unsigned
; loc     temp : (@-2): * char
; =
; loc     <something> : * char
; RPN'ized expression: "dest (something56) "
; Expanded expression: "(@4) *(2) "
; Fused expression:    "=(170) *(@-2) *(@4) "
	mov	ax, [bp+4]
	mov	[bp-2], ax
; while
; RPN'ized expression: "count 0 != "
; Expanded expression: "(@8) *(2) 0 != "
L57:
; Fused expression:    "!= *(@8) 0 IF! "
	mov	ax, [bp+8]
	cmp	ax, 0
	je	L58
; {
; RPN'ized expression: "temp ++p *u val = "
; Expanded expression: "(@-2) ++p(2) (@6) *(-1) =(-1) "
; Fused expression:    "++p(2) *(@-2) =(119) *ax *(@6) "
	mov	ax, [bp-2]
	inc	word [bp-2]
	mov	bx, ax
	mov	al, [bp+6]
	cbw
	mov	[bx], al
	cbw
; RPN'ized expression: "count --p "
; Expanded expression: "(@8) --p(2) "
; Fused expression:    "--p(2) *(@8) "
	mov	ax, [bp+8]
	dec	word [bp+8]
; }
	jmp	L57
L58:
L54:
	leave
	ret
L53:
	sub	sp, 2
	jmp	L52

; glb memcpy : (
; prm     dest : * void
; prm     src : * void
; prm     count : unsigned
;     ) void
section .text
_memcpy:
	push	bp
	mov	bp, sp
	jmp	L60
L59:
; loc     dest : (@4): * void
; loc     src : (@6): * void
; loc     count : (@8): unsigned
; loc     sp : (@-2): * char
; =
; loc     <something> : * char
; RPN'ized expression: "src (something63) "
; Expanded expression: "(@6) *(2) "
; Fused expression:    "=(170) *(@-2) *(@6) "
	mov	ax, [bp+6]
	mov	[bp-2], ax
; loc     dp : (@-4): * char
; =
; loc     <something> : * char
; RPN'ized expression: "dest (something64) "
; Expanded expression: "(@4) *(2) "
; Fused expression:    "=(170) *(@-4) *(@4) "
	mov	ax, [bp+4]
	mov	[bp-4], ax
; while
; RPN'ized expression: "count 0 != "
; Expanded expression: "(@8) *(2) 0 != "
L65:
; Fused expression:    "!= *(@8) 0 IF! "
	mov	ax, [bp+8]
	cmp	ax, 0
	je	L66
; {
; RPN'ized expression: "dp ++p *u sp ++p *u = "
; Expanded expression: "(@-4) ++p(2) (@-2) ++p(2) *(-1) =(-1) "
; Fused expression:    "++p(2) *(@-4) push-ax ++p(2) *(@-2) =(119) **sp *ax "
	mov	ax, [bp-4]
	inc	word [bp-4]
	push	ax
	mov	ax, [bp-2]
	inc	word [bp-2]
	mov	bx, ax
	mov	al, [bx]
	cbw
	pop	bx
	mov	[bx], al
	cbw
; RPN'ized expression: "count --p "
; Expanded expression: "(@8) --p(2) "
; Fused expression:    "--p(2) *(@8) "
	mov	ax, [bp+8]
	dec	word [bp+8]
; }
	jmp	L65
L66:
L61:
	leave
	ret
L60:
	sub	sp, 4
	jmp	L59

; glb memsetw : (
; prm     dest : * unsigned
; prm     val : unsigned
; prm     count : unsigned
;     ) unsigned
section .text
_memsetw:
	push	bp
	mov	bp, sp
	jmp	L68
L67:
; loc     dest : (@4): * unsigned
; loc     val : (@6): unsigned
; loc     count : (@8): unsigned
; loc     temp : (@-2): * unsigned
; =
; loc     <something> : * unsigned
; RPN'ized expression: "dest (something71) "
; Expanded expression: "(@4) *(2) "
; Fused expression:    "=(170) *(@-2) *(@4) "
	mov	ax, [bp+4]
	mov	[bp-2], ax
; while
; RPN'ized expression: "count 0 != "
; Expanded expression: "(@8) *(2) 0 != "
L72:
; Fused expression:    "!= *(@8) 0 IF! "
	mov	ax, [bp+8]
	cmp	ax, 0
	je	L73
; {
; RPN'ized expression: "temp ++p *u val = "
; Expanded expression: "(@-2) 2 +=p(2) (@6) *(2) =(2) "
; Fused expression:    "+=p(2) *(@-2) 2 =(170) *ax *(@6) "
	mov	ax, [bp-2]
	add	word [bp-2], 2
	mov	bx, ax
	mov	ax, [bp+6]
	mov	[bx], ax
; RPN'ized expression: "count --p "
; Expanded expression: "(@8) --p(2) "
; Fused expression:    "--p(2) *(@8) "
	mov	ax, [bp+8]
	dec	word [bp+8]
; }
	jmp	L72
L73:
L69:
	leave
	ret
L68:
	sub	sp, 2
	jmp	L67

; glb itoa : (
; prm     n : int
; prm     buffer : * char
; prm     base : int
;     ) void
section .text
_itoa:
	push	bp
	mov	bp, sp
	jmp	L75
L74:
; loc     n : (@4): int
; loc     buffer : (@6): * char
; loc     base : (@8): int
; loc     ptr : (@-2): * char
; =
; RPN'ized expression: "buffer "
; Expanded expression: "(@6) *(2) "
; Fused expression:    "=(170) *(@-2) *(@6) "
	mov	ax, [bp+6]
	mov	[bp-2], ax
; loc     lowbit : (@-4): int
; RPN'ized expression: "base 1 >>= "
; Expanded expression: "(@8) 1 >>=(2) "
; Fused expression:    ">>=(170) *(@8) 1 "
	mov	ax, [bp+8]
	sar	ax, 1
	mov	[bp+8], ax
; do
L78:
; {
; RPN'ized expression: "lowbit n 1 & = "
; Expanded expression: "(@-4) (@4) *(2) 1 & =(2) "
; Fused expression:    "& *(@4) 1 =(170) *(@-4) ax "
	mov	ax, [bp+4]
	and	ax, 1
	mov	[bp-4], ax
; RPN'ized expression: "n n 1 >> 32767 & = "
; Expanded expression: "(@4) (@4) *(2) 1 >> 32767 & =(2) "
; Fused expression:    ">> *(@4) 1 & ax 32767 =(170) *(@4) ax "
	mov	ax, [bp+4]
	sar	ax, 1
	and	ax, 32767
	mov	[bp+4], ax
; RPN'ized expression: "ptr *u n base % 1 << lowbit + = "
; Expanded expression: "(@-2) *(2) (@4) *(2) (@8) *(2) % 1 << (@-4) *(2) + =(-1) "
; Fused expression:    "*(2) (@-2) push-ax % *(@4) *(@8) << ax 1 + ax *(@-4) =(122) **sp ax "
	mov	ax, [bp-2]
	push	ax
	mov	ax, [bp+4]
	cwd
	idiv	word [bp+8]
	mov	ax, dx
	shl	ax, 1
	add	ax, [bp-4]
	pop	bx
	mov	[bx], al
	cbw
; if
; RPN'ized expression: "ptr *u 10 < "
; Expanded expression: "(@-2) *(2) *(-1) 10 < "
; Fused expression:    "*(2) (@-2) < *ax 10 IF! "
	mov	ax, [bp-2]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 10
	jge	L81
; RPN'ized expression: "ptr *u 48 += "
; Expanded expression: "(@-2) *(2) 48 +=(-1) "
; Fused expression:    "*(2) (@-2) +=(122) *ax 48 "
	mov	ax, [bp-2]
	mov	bx, ax
	mov	al, [bx]
	cbw
	add	ax, 48
	mov	[bx], al
	cbw
	jmp	L82
L81:
; else
; RPN'ized expression: "ptr *u 55 += "
; Expanded expression: "(@-2) *(2) 55 +=(-1) "
; Fused expression:    "*(2) (@-2) +=(122) *ax 55 "
	mov	ax, [bp-2]
	mov	bx, ax
	mov	al, [bx]
	cbw
	add	ax, 55
	mov	[bx], al
	cbw
L82:
; RPN'ized expression: "ptr ++ "
; Expanded expression: "(@-2) ++(2) "
; Fused expression:    "++(2) *(@-2) "
	inc	word [bp-2]
	mov	ax, [bp-2]
; }
; while
; RPN'ized expression: "n base /= "
; Expanded expression: "(@4) (@8) *(2) /=(2) "
L79:
; Fused expression:    "/=(170) *(@4) *(@8) "
	mov	ax, [bp+4]
	cwd
	idiv	word [bp+8]
	mov	[bp+4], ax
; JumpIfNotZero
	test	ax, ax
	jne	L78
L80:
; RPN'ized expression: "ptr *u 0 = "
; Expanded expression: "(@-2) *(2) 0 =(-1) "
; Fused expression:    "*(2) (@-2) =(122) *ax 0 "
	mov	ax, [bp-2]
	mov	bx, ax
	mov	ax, 0
	mov	[bx], al
	cbw
; RPN'ized expression: "( buffer reverse ) "
; Expanded expression: " (@6) *(2)  reverse ()2 "
; Fused expression:    "( *(2) (@6) , reverse )2 "
	push	word [bp+6]
	call	_reverse
	sub	sp, -2
L76:
	leave
	ret
L75:
	sub	sp, 4
	jmp	L74

; glb atoi : (
; prm     p : * char
;     ) int
section .text
_atoi:
	push	bp
	mov	bp, sp
	jmp	L84
L83:
; loc     p : (@4): * char
; loc     k : (@-2): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(170) *(@-2) 0 "
	mov	ax, 0
	mov	[bp-2], ax
; while
; RPN'ized expression: "p *u "
; Expanded expression: "(@4) *(2) *(-1) "
L87:
; Fused expression:    "*(2) (@4) *(-1) ax "
	mov	ax, [bp+4]
	mov	bx, ax
	mov	al, [bx]
	cbw
; JumpIfZero
	test	ax, ax
	je	L88
; {
; RPN'ized expression: "k k 3 << k 1 << + p *u + 48 - = "
; Expanded expression: "(@-2) (@-2) *(2) 3 << (@-2) *(2) 1 << + (@4) *(2) *(-1) + 48 - =(2) "
; Fused expression:    "<< *(@-2) 3 push-ax << *(@-2) 1 + *sp ax push-ax *(2) (@4) + *sp *ax - ax 48 =(170) *(@-2) ax "
	mov	ax, [bp-2]
	shl	ax, 3
	push	ax
	mov	ax, [bp-2]
	shl	ax, 1
	mov	cx, ax
	pop	ax
	add	ax, cx
	push	ax
	mov	ax, [bp+4]
	mov	bx, ax
	movsx	cx, byte [bx]
	pop	ax
	add	ax, cx
	sub	ax, 48
	mov	[bp-2], ax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@4) ++p(2) "
; Fused expression:    "++p(2) *(@4) "
	mov	ax, [bp+4]
	inc	word [bp+4]
; }
	jmp	L87
L88:
; return
; RPN'ized expression: "k "
; Expanded expression: "(@-2) *(2) "
; Fused expression:    "*(2) (@-2) "
	mov	ax, [bp-2]
	jmp	L85
L85:
	leave
	ret
L84:
	sub	sp, 2
	jmp	L83

; glb isdigit : (
; prm     c : int
;     ) int
section .text
_isdigit:
	push	bp
	mov	bp, sp
	jmp	L90
L89:
; loc     c : (@4): int
; return
; RPN'ized expression: "c 48 >= c 57 <= && "
; Expanded expression: "(@4) *(2) 48 >= [sh&&->93] (@4) *(2) 57 <= &&[93] "
; Fused expression:    ">= *(@4) 48 [sh&&->93] <= *(@4) 57 &&[93] "
	mov	ax, [bp+4]
	cmp	ax, 48
	setge	al
	cbw
; JumpIfZero
	test	ax, ax
	je	L93
	mov	ax, [bp+4]
	cmp	ax, 57
	setle	al
	cbw
L93:
	jmp	L91
L91:
	leave
	ret
L90:
	jmp	L89

; glb vprintf : (
; prm     fmt : * char
; prm     vl : * void
;     ) int
section .text
_vprintf:
	push	bp
	mov	bp, sp
	jmp	L95
L94:
; loc     fmt : (@4): * char
; loc     vl : (@6): * void
; loc     pp : (@-2): * int
; =
; RPN'ized expression: "vl "
; Expanded expression: "(@6) *(2) "
; Fused expression:    "=(170) *(@-2) *(@6) "
	mov	ax, [bp+6]
	mov	[bp-2], ax
; loc     cnt : (@-4): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(170) *(@-4) 0 "
	mov	ax, 0
	mov	[bp-4], ax
; loc     p : (@-6): * char
; loc     phex : (@-8): * char
; RPN'ized expression: "12 "
; Expanded expression: "12 "
; Expression value: 12
; loc     s : (@-20): [12u] char
; loc     pc : (@-22): * char
; loc     n : (@-24): int
; loc     sign : (@-26): int
; loc     msign : (@-28): int
; loc     minlen : (@-30): int
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(170) *(@-30) 0 "
	mov	ax, 0
	mov	[bp-30], ax
; loc     len : (@-32): int
; for
; RPN'ized expression: "p fmt = "
; Expanded expression: "(@-6) (@4) *(2) =(2) "
; Fused expression:    "=(170) *(@-6) *(@4) "
	mov	ax, [bp+4]
	mov	[bp-6], ax
L98:
; RPN'ized expression: "p *u 0 != "
; Expanded expression: "(@-6) *(2) *(-1) 0 != "
; Fused expression:    "*(2) (@-6) != *ax 0 IF! "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	je	L101
	jmp	L100
L99:
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-6) ++p(2) "
; Fused expression:    "++p(2) *(@-6) "
	mov	ax, [bp-6]
	inc	word [bp-6]
	jmp	L98
L100:
; {
; if
; RPN'ized expression: "p *u 37 != p 1 + *u 37 == || "
; Expanded expression: "(@-6) *(2) *(-1) 37 != [sh||->104] (@-6) *(2) 1 + *(-1) 37 == ||[104] "
; Fused expression:    "*(2) (@-6) != *ax 37 [sh||->104] + *(@-6) 1 == *ax 37 ||[104] "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 37
	setne	al
	cbw
; JumpIfNotZero
	test	ax, ax
	jne	L104
	mov	ax, [bp-6]
	inc	ax
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 37
	sete	al
	cbw
L104:
; JumpIfZero
	test	ax, ax
	je	L102
; {
; RPN'ized expression: "( p *u putchar ) "
; Expanded expression: " (@-6) *(2) *(-1)  putchar ()2 "
; Fused expression:    "( *(2) (@-6) *(-1) ax , putchar )2 "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "p p p *u 37 == + = "
; Expanded expression: "(@-6) (@-6) *(2) (@-6) *(2) *(-1) 37 == + =(2) "
; Fused expression:    "*(2) (@-6) == *ax 37 + *(@-6) ax =(170) *(@-6) ax "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 37
	sete	al
	cbw
	mov	cx, ax
	mov	ax, [bp-6]
	add	ax, cx
	mov	[bp-6], ax
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; continue
	jmp	L99
; }
L102:
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-6) ++p(2) "
; Fused expression:    "++p(2) *(@-6) "
	mov	ax, [bp-6]
	inc	word [bp-6]
; RPN'ized expression: "minlen 0 = "
; Expanded expression: "(@-30) 0 =(2) "
; Fused expression:    "=(170) *(@-30) 0 "
	mov	ax, 0
	mov	[bp-30], ax
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-28) 0 =(2) "
; Fused expression:    "=(170) *(@-28) 0 "
	mov	ax, 0
	mov	[bp-28], ax
; if
; RPN'ized expression: "p *u 43 == "
; Expanded expression: "(@-6) *(2) *(-1) 43 == "
; Fused expression:    "*(2) (@-6) == *ax 43 IF! "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 43
	jne	L105
; {
; RPN'ized expression: "msign 1 = "
; Expanded expression: "(@-28) 1 =(2) "
; Fused expression:    "=(170) *(@-28) 1 "
	mov	ax, 1
	mov	[bp-28], ax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-6) ++p(2) "
; Fused expression:    "++p(2) *(@-6) "
	mov	ax, [bp-6]
	inc	word [bp-6]
; }
	jmp	L106
L105:
; else
; if
; RPN'ized expression: "p *u 45 == "
; Expanded expression: "(@-6) *(2) *(-1) 45 == "
; Fused expression:    "*(2) (@-6) == *ax 45 IF! "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 45
	jne	L107
; {
; RPN'ized expression: "msign 1 -u = "
; Expanded expression: "(@-28) -1 =(2) "
; Fused expression:    "=(170) *(@-28) -1 "
	mov	ax, -1
	mov	[bp-28], ax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-6) ++p(2) "
; Fused expression:    "++p(2) *(@-6) "
	mov	ax, [bp-6]
	inc	word [bp-6]
; }
L107:
L106:
; if
; RPN'ized expression: "( p *u isdigit ) "
; Expanded expression: " (@-6) *(2) *(-1)  isdigit ()2 "
; Fused expression:    "( *(2) (@-6) *(-1) ax , isdigit )2 "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_isdigit
	sub	sp, -2
; JumpIfZero
	test	ax, ax
	je	L109
; {
; while
; RPN'ized expression: "( p *u isdigit ) "
; Expanded expression: " (@-6) *(2) *(-1)  isdigit ()2 "
L111:
; Fused expression:    "( *(2) (@-6) *(-1) ax , isdigit )2 "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_isdigit
	sub	sp, -2
; JumpIfZero
	test	ax, ax
	je	L112
; RPN'ized expression: "minlen minlen 10 * p ++p *u + 48 - = "
; Expanded expression: "(@-30) (@-30) *(2) 10 * (@-6) ++p(2) *(-1) + 48 - =(2) "
; Fused expression:    "* *(@-30) 10 push-ax ++p(2) *(@-6) + *sp *ax - ax 48 =(170) *(@-30) ax "
	mov	ax, [bp-30]
	imul	ax, ax, 10
	push	ax
	mov	ax, [bp-6]
	inc	word [bp-6]
	mov	bx, ax
	movsx	cx, byte [bx]
	pop	ax
	add	ax, cx
	sub	ax, 48
	mov	[bp-30], ax
	jmp	L111
L112:
; if
; RPN'ized expression: "msign 0 < "
; Expanded expression: "(@-28) *(2) 0 < "
; Fused expression:    "< *(@-28) 0 IF! "
	mov	ax, [bp-28]
	cmp	ax, 0
	jge	L113
; RPN'ized expression: "minlen minlen -u = "
; Expanded expression: "(@-30) (@-30) *(2) -u =(2) "
; Fused expression:    "*(2) (@-30) -u =(170) *(@-30) ax "
	mov	ax, [bp-30]
	neg	ax
	mov	[bp-30], ax
L113:
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-28) 0 =(2) "
; Fused expression:    "=(170) *(@-28) 0 "
	mov	ax, 0
	mov	[bp-28], ax
; }
L109:
; if
; RPN'ized expression: "msign 0 == "
; Expanded expression: "(@-28) *(2) 0 == "
; Fused expression:    "== *(@-28) 0 IF! "
	mov	ax, [bp-28]
	cmp	ax, 0
	jne	L115
; {
; if
; RPN'ized expression: "p *u 43 == "
; Expanded expression: "(@-6) *(2) *(-1) 43 == "
; Fused expression:    "*(2) (@-6) == *ax 43 IF! "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 43
	jne	L117
; {
; RPN'ized expression: "msign 1 = "
; Expanded expression: "(@-28) 1 =(2) "
; Fused expression:    "=(170) *(@-28) 1 "
	mov	ax, 1
	mov	[bp-28], ax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-6) ++p(2) "
; Fused expression:    "++p(2) *(@-6) "
	mov	ax, [bp-6]
	inc	word [bp-6]
; }
	jmp	L118
L117:
; else
; if
; RPN'ized expression: "p *u 45 == "
; Expanded expression: "(@-6) *(2) *(-1) 45 == "
; Fused expression:    "*(2) (@-6) == *ax 45 IF! "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 45
	jne	L119
; {
; RPN'ized expression: "msign 1 -u = "
; Expanded expression: "(@-28) -1 =(2) "
; Fused expression:    "=(170) *(@-28) -1 "
	mov	ax, -1
	mov	[bp-28], ax
; RPN'ized expression: "p ++p "
; Expanded expression: "(@-6) ++p(2) "
; Fused expression:    "++p(2) *(@-6) "
	mov	ax, [bp-6]
	inc	word [bp-6]
; }
L119:
L118:
; }
L115:
; RPN'ized expression: "phex L121 = "
; Expanded expression: "(@-8) L121 =(2) "

section .data
L121:
	db	"0123456789abcdef",0

section .text
; Fused expression:    "=(170) *(@-8) L121 "
	mov	ax, L121
	mov	[bp-8], ax
; switch
; RPN'ized expression: "p *u "
; Expanded expression: "(@-6) *(2) *(-1) "
; Fused expression:    "*(2) (@-6) *(-1) ax "
	mov	ax, [bp-6]
	mov	bx, ax
	mov	al, [bx]
	cbw
	jmp	L125
; {
; case
; RPN'ized expression: "99 "
; Expanded expression: "99 "
; Expression value: 99
	jmp	L126
L125:
	cmp	ax, 99
	jne	L127
L126:
; while
; RPN'ized expression: "minlen 1 > "
; Expanded expression: "(@-30) *(2) 1 > "
L129:
; Fused expression:    "> *(@-30) 1 IF! "
	mov	ax, [bp-30]
	cmp	ax, 1
	jle	L130
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-30) --p(2) "
; Fused expression:    "--p(2) *(@-30) "
	mov	ax, [bp-30]
	dec	word [bp-30]
; }
	jmp	L129
L130:
; RPN'ized expression: "( pp ++p *u putchar ) "
; Expanded expression: " (@-2) 2 +=p(2) *(2)  putchar ()2 "
; Fused expression:    "( +=p(2) *(@-2) 2 *(2) ax , putchar )2 "
	mov	ax, [bp-2]
	add	word [bp-2], 2
	mov	bx, ax
	push	word [bx]
	call	_putchar
	sub	sp, -2
; while
; RPN'ized expression: "minlen -u 1 > "
; Expanded expression: "(@-30) *(2) -u 1 > "
L131:
; Fused expression:    "*(2) (@-30) -u > ax 1 IF! "
	mov	ax, [bp-30]
	neg	ax
	cmp	ax, 1
	jle	L132
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-30) ++p(2) "
; Fused expression:    "++p(2) *(@-30) "
	mov	ax, [bp-30]
	inc	word [bp-30]
; }
	jmp	L131
L132:
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; break
	jmp	L123
; case
; RPN'ized expression: "115 "
; Expanded expression: "115 "
; Expression value: 115
	jmp	L128
L127:
	cmp	ax, 115
	jne	L133
L128:
; RPN'ized expression: "pc pp ++p *u = "
; Expanded expression: "(@-22) (@-2) 2 +=p(2) *(2) =(2) "
; Fused expression:    "+=p(2) *(@-2) 2 =(170) *(@-22) *ax "
	mov	ax, [bp-2]
	add	word [bp-2], 2
	mov	bx, ax
	mov	ax, [bx]
	mov	[bp-22], ax
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-32) 0 =(2) "
; Fused expression:    "=(170) *(@-32) 0 "
	mov	ax, 0
	mov	[bp-32], ax
; if
; RPN'ized expression: "pc "
; Expanded expression: "(@-22) *(2) "
; Fused expression:    "*(2) (@-22) "
	mov	ax, [bp-22]
; JumpIfZero
	test	ax, ax
	je	L135
; RPN'ized expression: "len ( pc strlen ) = "
; Expanded expression: "(@-32)  (@-22) *(2)  strlen ()2 =(2) "
; Fused expression:    "( *(2) (@-22) , strlen )2 =(170) *(@-32) ax "
	push	word [bp-22]
	call	_strlen
	sub	sp, -2
	mov	[bp-32], ax
L135:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-30) *(2) (@-32) *(2) > "
L137:
; Fused expression:    "> *(@-30) *(@-32) IF! "
	mov	ax, [bp-30]
	cmp	ax, [bp-32]
	jle	L138
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-30) --p(2) "
; Fused expression:    "--p(2) *(@-30) "
	mov	ax, [bp-30]
	dec	word [bp-30]
; }
	jmp	L137
L138:
; if
; RPN'ized expression: "len "
; Expanded expression: "(@-32) *(2) "
; Fused expression:    "*(2) (@-32) "
	mov	ax, [bp-32]
; JumpIfZero
	test	ax, ax
	je	L139
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-22) *(2) *(-1) 0 != "
L141:
; Fused expression:    "*(2) (@-22) != *ax 0 IF! "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	je	L142
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-22) ++p(2) *(-1)  putchar ()2 "
; Fused expression:    "( ++p(2) *(@-22) *(-1) ax , putchar )2 "
	mov	ax, [bp-22]
	inc	word [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; }
	jmp	L141
L142:
L139:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-30) *(2) -u (@-32) *(2) > "
L143:
; Fused expression:    "*(2) (@-30) -u > ax *(@-32) IF! "
	mov	ax, [bp-30]
	neg	ax
	cmp	ax, [bp-32]
	jle	L144
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-30) ++p(2) "
; Fused expression:    "++p(2) *(@-30) "
	mov	ax, [bp-30]
	inc	word [bp-30]
; }
	jmp	L143
L144:
; break
	jmp	L123
; case
; RPN'ized expression: "105 "
; Expanded expression: "105 "
; Expression value: 105
	jmp	L134
L133:
	cmp	ax, 105
	jne	L145
L134:
; case
; RPN'ized expression: "100 "
; Expanded expression: "100 "
; Expression value: 100
	jmp	L146
L145:
	cmp	ax, 100
	jne	L147
L146:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-22) (@-9) =(2) "
; Fused expression:    "=(170) *(@-22) (@-9) "
	lea	ax, [bp-9]
	mov	[bp-22], ax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-22) *(2) 0 =(-1) "
; Fused expression:    "*(2) (@-22) =(122) *ax 0 "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	ax, 0
	mov	[bx], al
	cbw
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-32) 0 =(2) "
; Fused expression:    "=(170) *(@-32) 0 "
	mov	ax, 0
	mov	[bp-32], ax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-24) (@-2) 2 +=p(2) *(2) =(2) "
; Fused expression:    "+=p(2) *(@-2) 2 =(170) *(@-24) *ax "
	mov	ax, [bp-2]
	add	word [bp-2], 2
	mov	bx, ax
	mov	ax, [bx]
	mov	[bp-24], ax
; RPN'ized expression: "sign 1 2 n 0 < * - = "
; Expanded expression: "(@-26) 1 2 (@-24) *(2) 0 < * - =(2) "
; Fused expression:    "< *(@-24) 0 * 2 ax - 1 ax =(170) *(@-26) ax "
	mov	ax, [bp-24]
	cmp	ax, 0
	setl	al
	cbw
	mov	cx, ax
	mov	ax, 2
	mul	cx
	mov	cx, ax
	mov	ax, 1
	sub	ax, cx
	mov	[bp-26], ax
; do
L149:
; {
; RPN'ized expression: "pc -- *u 48 n n 10 / 10 * - sign * + = "
; Expanded expression: "(@-22) --(2) 48 (@-24) *(2) (@-24) *(2) 10 / 10 * - (@-26) *(2) * + =(-1) "
; Fused expression:    "--(2) *(@-22) push-ax / *(@-24) 10 * ax 10 - *(@-24) ax * ax *(@-26) + 48 ax =(122) **sp ax "
	dec	word [bp-22]
	mov	ax, [bp-22]
	push	ax
	mov	ax, [bp-24]
	cwd
	mov	cx, 10
	idiv	cx
	imul	ax, ax, 10
	mov	cx, ax
	mov	ax, [bp-24]
	sub	ax, cx
	mul	word [bp-26]
	mov	cx, ax
	mov	ax, 48
	add	ax, cx
	pop	bx
	mov	[bx], al
	cbw
; RPN'ized expression: "n n 10 / = "
; Expanded expression: "(@-24) (@-24) *(2) 10 / =(2) "
; Fused expression:    "/ *(@-24) 10 =(170) *(@-24) ax "
	mov	ax, [bp-24]
	cwd
	mov	cx, 10
	idiv	cx
	mov	[bp-24], ax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-32) ++p(2) "
; Fused expression:    "++p(2) *(@-32) "
	mov	ax, [bp-32]
	inc	word [bp-32]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-24) *(2) "
L150:
; Fused expression:    "*(2) (@-24) "
	mov	ax, [bp-24]
; JumpIfNotZero
	test	ax, ax
	jne	L149
L151:
; if
; RPN'ized expression: "sign 0 < "
; Expanded expression: "(@-26) *(2) 0 < "
; Fused expression:    "< *(@-26) 0 IF! "
	mov	ax, [bp-26]
	cmp	ax, 0
	jge	L152
; {
; RPN'ized expression: "pc -- *u 45 = "
; Expanded expression: "(@-22) --(2) 45 =(-1) "
; Fused expression:    "--(2) *(@-22) =(122) *ax 45 "
	dec	word [bp-22]
	mov	ax, [bp-22]
	mov	bx, ax
	mov	ax, 45
	mov	[bx], al
	cbw
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-32) ++p(2) "
; Fused expression:    "++p(2) *(@-32) "
	mov	ax, [bp-32]
	inc	word [bp-32]
; }
	jmp	L153
L152:
; else
; if
; RPN'ized expression: "msign 0 > "
; Expanded expression: "(@-28) *(2) 0 > "
; Fused expression:    "> *(@-28) 0 IF! "
	mov	ax, [bp-28]
	cmp	ax, 0
	jle	L154
; {
; RPN'ized expression: "pc -- *u 43 = "
; Expanded expression: "(@-22) --(2) 43 =(-1) "
; Fused expression:    "--(2) *(@-22) =(122) *ax 43 "
	dec	word [bp-22]
	mov	ax, [bp-22]
	mov	bx, ax
	mov	ax, 43
	mov	[bx], al
	cbw
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-32) ++p(2) "
; Fused expression:    "++p(2) *(@-32) "
	mov	ax, [bp-32]
	inc	word [bp-32]
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-28) 0 =(2) "
; Fused expression:    "=(170) *(@-28) 0 "
	mov	ax, 0
	mov	[bp-28], ax
; }
L154:
L153:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-30) *(2) (@-32) *(2) > "
L156:
; Fused expression:    "> *(@-30) *(@-32) IF! "
	mov	ax, [bp-30]
	cmp	ax, [bp-32]
	jle	L157
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-30) --p(2) "
; Fused expression:    "--p(2) *(@-30) "
	mov	ax, [bp-30]
	dec	word [bp-30]
; }
	jmp	L156
L157:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-22) *(2) *(-1) 0 != "
L158:
; Fused expression:    "*(2) (@-22) != *ax 0 IF! "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	je	L159
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-22) ++p(2) *(-1)  putchar ()2 "
; Fused expression:    "( ++p(2) *(@-22) *(-1) ax , putchar )2 "
	mov	ax, [bp-22]
	inc	word [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; }
	jmp	L158
L159:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-30) *(2) -u (@-32) *(2) > "
L160:
; Fused expression:    "*(2) (@-30) -u > ax *(@-32) IF! "
	mov	ax, [bp-30]
	neg	ax
	cmp	ax, [bp-32]
	jle	L161
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-30) ++p(2) "
; Fused expression:    "++p(2) *(@-30) "
	mov	ax, [bp-30]
	inc	word [bp-30]
; }
	jmp	L160
L161:
; break
	jmp	L123
; case
; RPN'ized expression: "117 "
; Expanded expression: "117 "
; Expression value: 117
	jmp	L148
L147:
	cmp	ax, 117
	jne	L162
L148:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-22) (@-9) =(2) "
; Fused expression:    "=(170) *(@-22) (@-9) "
	lea	ax, [bp-9]
	mov	[bp-22], ax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-22) *(2) 0 =(-1) "
; Fused expression:    "*(2) (@-22) =(122) *ax 0 "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	ax, 0
	mov	[bx], al
	cbw
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-32) 0 =(2) "
; Fused expression:    "=(170) *(@-32) 0 "
	mov	ax, 0
	mov	[bp-32], ax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-24) (@-2) 2 +=p(2) *(2) =(2) "
; Fused expression:    "+=p(2) *(@-2) 2 =(170) *(@-24) *ax "
	mov	ax, [bp-2]
	add	word [bp-2], 2
	mov	bx, ax
	mov	ax, [bx]
	mov	[bp-24], ax
; do
L164:
; {
; loc                 nn : (@-34): unsigned
; =
; RPN'ized expression: "n "
; Expanded expression: "(@-24) *(2) "
; Fused expression:    "=(170) *(@-34) *(@-24) "
	mov	ax, [bp-24]
	mov	[bp-34], ax
; RPN'ized expression: "pc -- *u 48 nn 10 % + = "
; Expanded expression: "(@-22) --(2) 48 (@-34) *(2) 10 %u + =(-1) "
; Fused expression:    "--(2) *(@-22) push-ax %u *(@-34) 10 + 48 ax =(122) **sp ax "
	dec	word [bp-22]
	mov	ax, [bp-22]
	push	ax
	mov	ax, [bp-34]
	mov	dx, 0
	mov	cx, 10
	div	cx
	mov	ax, dx
	mov	cx, ax
	mov	ax, 48
	add	ax, cx
	pop	bx
	mov	[bx], al
	cbw
; RPN'ized expression: "n nn 10 / = "
; Expanded expression: "(@-24) (@-34) *(2) 10 /u =(2) "
; Fused expression:    "/u *(@-34) 10 =(170) *(@-24) ax "
	mov	ax, [bp-34]
	mov	dx, 0
	mov	cx, 10
	div	cx
	mov	[bp-24], ax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-32) ++p(2) "
; Fused expression:    "++p(2) *(@-32) "
	mov	ax, [bp-32]
	inc	word [bp-32]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-24) *(2) "
L165:
; Fused expression:    "*(2) (@-24) "
	mov	ax, [bp-24]
; JumpIfNotZero
	test	ax, ax
	jne	L164
L166:
; if
; RPN'ized expression: "msign 0 > "
; Expanded expression: "(@-28) *(2) 0 > "
; Fused expression:    "> *(@-28) 0 IF! "
	mov	ax, [bp-28]
	cmp	ax, 0
	jle	L167
; {
; RPN'ized expression: "pc -- *u 43 = "
; Expanded expression: "(@-22) --(2) 43 =(-1) "
; Fused expression:    "--(2) *(@-22) =(122) *ax 43 "
	dec	word [bp-22]
	mov	ax, [bp-22]
	mov	bx, ax
	mov	ax, 43
	mov	[bx], al
	cbw
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-32) ++p(2) "
; Fused expression:    "++p(2) *(@-32) "
	mov	ax, [bp-32]
	inc	word [bp-32]
; RPN'ized expression: "msign 0 = "
; Expanded expression: "(@-28) 0 =(2) "
; Fused expression:    "=(170) *(@-28) 0 "
	mov	ax, 0
	mov	[bp-28], ax
; }
L167:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-30) *(2) (@-32) *(2) > "
L169:
; Fused expression:    "> *(@-30) *(@-32) IF! "
	mov	ax, [bp-30]
	cmp	ax, [bp-32]
	jle	L170
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-30) --p(2) "
; Fused expression:    "--p(2) *(@-30) "
	mov	ax, [bp-30]
	dec	word [bp-30]
; }
	jmp	L169
L170:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-22) *(2) *(-1) 0 != "
L171:
; Fused expression:    "*(2) (@-22) != *ax 0 IF! "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	je	L172
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-22) ++p(2) *(-1)  putchar ()2 "
; Fused expression:    "( ++p(2) *(@-22) *(-1) ax , putchar )2 "
	mov	ax, [bp-22]
	inc	word [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; }
	jmp	L171
L172:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-30) *(2) -u (@-32) *(2) > "
L173:
; Fused expression:    "*(2) (@-30) -u > ax *(@-32) IF! "
	mov	ax, [bp-30]
	neg	ax
	cmp	ax, [bp-32]
	jle	L174
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-30) ++p(2) "
; Fused expression:    "++p(2) *(@-30) "
	mov	ax, [bp-30]
	inc	word [bp-30]
; }
	jmp	L173
L174:
; break
	jmp	L123
; case
; RPN'ized expression: "88 "
; Expanded expression: "88 "
; Expression value: 88
	jmp	L163
L162:
	cmp	ax, 88
	jne	L175
L163:
; RPN'ized expression: "phex L177 = "
; Expanded expression: "(@-8) L177 =(2) "

section .data
L177:
	db	"0123456789ABCDEF",0

section .text
; Fused expression:    "=(170) *(@-8) L177 "
	mov	ax, L177
	mov	[bp-8], ax
; case
; RPN'ized expression: "112 "
; Expanded expression: "112 "
; Expression value: 112
	jmp	L176
L175:
	cmp	ax, 112
	jne	L179
L176:
; case
; RPN'ized expression: "120 "
; Expanded expression: "120 "
; Expression value: 120
	jmp	L180
L179:
	cmp	ax, 120
	jne	L181
L180:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-22) (@-9) =(2) "
; Fused expression:    "=(170) *(@-22) (@-9) "
	lea	ax, [bp-9]
	mov	[bp-22], ax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-22) *(2) 0 =(-1) "
; Fused expression:    "*(2) (@-22) =(122) *ax 0 "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	ax, 0
	mov	[bx], al
	cbw
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-32) 0 =(2) "
; Fused expression:    "=(170) *(@-32) 0 "
	mov	ax, 0
	mov	[bp-32], ax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-24) (@-2) 2 +=p(2) *(2) =(2) "
; Fused expression:    "+=p(2) *(@-2) 2 =(170) *(@-24) *ax "
	mov	ax, [bp-2]
	add	word [bp-2], 2
	mov	bx, ax
	mov	ax, [bx]
	mov	[bp-24], ax
; do
L183:
; {
; loc                 nn : (@-34): unsigned
; =
; RPN'ized expression: "n "
; Expanded expression: "(@-24) *(2) "
; Fused expression:    "=(170) *(@-34) *(@-24) "
	mov	ax, [bp-24]
	mov	[bp-34], ax
; RPN'ized expression: "pc -- *u phex nn 15 & + *u = "
; Expanded expression: "(@-22) --(2) (@-8) *(2) (@-34) *(2) 15 & + *(-1) =(-1) "
; Fused expression:    "--(2) *(@-22) push-ax & *(@-34) 15 + *(@-8) ax =(119) **sp *ax "
	dec	word [bp-22]
	mov	ax, [bp-22]
	push	ax
	mov	ax, [bp-34]
	and	ax, 15
	mov	cx, ax
	mov	ax, [bp-8]
	add	ax, cx
	mov	bx, ax
	mov	al, [bx]
	cbw
	pop	bx
	mov	[bx], al
	cbw
; RPN'ized expression: "n nn 4 >> = "
; Expanded expression: "(@-24) (@-34) *(2) 4 >>u =(2) "
; Fused expression:    ">>u *(@-34) 4 =(170) *(@-24) ax "
	mov	ax, [bp-34]
	shr	ax, 4
	mov	[bp-24], ax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-32) ++p(2) "
; Fused expression:    "++p(2) *(@-32) "
	mov	ax, [bp-32]
	inc	word [bp-32]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-24) *(2) "
L184:
; Fused expression:    "*(2) (@-24) "
	mov	ax, [bp-24]
; JumpIfNotZero
	test	ax, ax
	jne	L183
L185:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-30) *(2) (@-32) *(2) > "
L186:
; Fused expression:    "> *(@-30) *(@-32) IF! "
	mov	ax, [bp-30]
	cmp	ax, [bp-32]
	jle	L187
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-30) --p(2) "
; Fused expression:    "--p(2) *(@-30) "
	mov	ax, [bp-30]
	dec	word [bp-30]
; }
	jmp	L186
L187:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-22) *(2) *(-1) 0 != "
L188:
; Fused expression:    "*(2) (@-22) != *ax 0 IF! "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	je	L189
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-22) ++p(2) *(-1)  putchar ()2 "
; Fused expression:    "( ++p(2) *(@-22) *(-1) ax , putchar )2 "
	mov	ax, [bp-22]
	inc	word [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; }
	jmp	L188
L189:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-30) *(2) -u (@-32) *(2) > "
L190:
; Fused expression:    "*(2) (@-30) -u > ax *(@-32) IF! "
	mov	ax, [bp-30]
	neg	ax
	cmp	ax, [bp-32]
	jle	L191
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-30) ++p(2) "
; Fused expression:    "++p(2) *(@-30) "
	mov	ax, [bp-30]
	inc	word [bp-30]
; }
	jmp	L190
L191:
; break
	jmp	L123
; case
; RPN'ized expression: "111 "
; Expanded expression: "111 "
; Expression value: 111
	jmp	L182
L181:
	cmp	ax, 111
	jne	L192
L182:
; RPN'ized expression: "pc s s sizeof 1 - + *u &u = "
; Expanded expression: "(@-22) (@-9) =(2) "
; Fused expression:    "=(170) *(@-22) (@-9) "
	lea	ax, [bp-9]
	mov	[bp-22], ax
; RPN'ized expression: "pc *u 0 = "
; Expanded expression: "(@-22) *(2) 0 =(-1) "
; Fused expression:    "*(2) (@-22) =(122) *ax 0 "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	ax, 0
	mov	[bx], al
	cbw
; RPN'ized expression: "len 0 = "
; Expanded expression: "(@-32) 0 =(2) "
; Fused expression:    "=(170) *(@-32) 0 "
	mov	ax, 0
	mov	[bp-32], ax
; RPN'ized expression: "n pp ++p *u = "
; Expanded expression: "(@-24) (@-2) 2 +=p(2) *(2) =(2) "
; Fused expression:    "+=p(2) *(@-2) 2 =(170) *(@-24) *ax "
	mov	ax, [bp-2]
	add	word [bp-2], 2
	mov	bx, ax
	mov	ax, [bx]
	mov	[bp-24], ax
; do
L194:
; {
; loc                 nn : (@-34): unsigned
; =
; RPN'ized expression: "n "
; Expanded expression: "(@-24) *(2) "
; Fused expression:    "=(170) *(@-34) *(@-24) "
	mov	ax, [bp-24]
	mov	[bp-34], ax
; RPN'ized expression: "pc -- *u 48 nn 7 & + = "
; Expanded expression: "(@-22) --(2) 48 (@-34) *(2) 7 & + =(-1) "
; Fused expression:    "--(2) *(@-22) push-ax & *(@-34) 7 + 48 ax =(122) **sp ax "
	dec	word [bp-22]
	mov	ax, [bp-22]
	push	ax
	mov	ax, [bp-34]
	and	ax, 7
	mov	cx, ax
	mov	ax, 48
	add	ax, cx
	pop	bx
	mov	[bx], al
	cbw
; RPN'ized expression: "n nn 3 >> = "
; Expanded expression: "(@-24) (@-34) *(2) 3 >>u =(2) "
; Fused expression:    ">>u *(@-34) 3 =(170) *(@-24) ax "
	mov	ax, [bp-34]
	shr	ax, 3
	mov	[bp-24], ax
; RPN'ized expression: "len ++p "
; Expanded expression: "(@-32) ++p(2) "
; Fused expression:    "++p(2) *(@-32) "
	mov	ax, [bp-32]
	inc	word [bp-32]
; }
; while
; RPN'ized expression: "n "
; Expanded expression: "(@-24) *(2) "
L195:
; Fused expression:    "*(2) (@-24) "
	mov	ax, [bp-24]
; JumpIfNotZero
	test	ax, ax
	jne	L194
L196:
; while
; RPN'ized expression: "minlen len > "
; Expanded expression: "(@-30) *(2) (@-32) *(2) > "
L197:
; Fused expression:    "> *(@-30) *(@-32) IF! "
	mov	ax, [bp-30]
	cmp	ax, [bp-32]
	jle	L198
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen --p "
; Expanded expression: "(@-30) --p(2) "
; Fused expression:    "--p(2) *(@-30) "
	mov	ax, [bp-30]
	dec	word [bp-30]
; }
	jmp	L197
L198:
; while
; RPN'ized expression: "pc *u 0 != "
; Expanded expression: "(@-22) *(2) *(-1) 0 != "
L199:
; Fused expression:    "*(2) (@-22) != *ax 0 IF! "
	mov	ax, [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	cmp	ax, 0
	je	L200
; {
; RPN'ized expression: "( pc ++p *u putchar ) "
; Expanded expression: " (@-22) ++p(2) *(-1)  putchar ()2 "
; Fused expression:    "( ++p(2) *(@-22) *(-1) ax , putchar )2 "
	mov	ax, [bp-22]
	inc	word [bp-22]
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; }
	jmp	L199
L200:
; while
; RPN'ized expression: "minlen -u len > "
; Expanded expression: "(@-30) *(2) -u (@-32) *(2) > "
L201:
; Fused expression:    "*(2) (@-30) -u > ax *(@-32) IF! "
	mov	ax, [bp-30]
	neg	ax
	cmp	ax, [bp-32]
	jle	L202
; {
; RPN'ized expression: "( 32 putchar ) "
; Expanded expression: " 32  putchar ()2 "
; Fused expression:    "( 32 , putchar )2 "
	push	32
	call	_putchar
	sub	sp, -2
; RPN'ized expression: "cnt ++p "
; Expanded expression: "(@-4) ++p(2) "
; Fused expression:    "++p(2) *(@-4) "
	mov	ax, [bp-4]
	inc	word [bp-4]
; RPN'ized expression: "minlen ++p "
; Expanded expression: "(@-30) ++p(2) "
; Fused expression:    "++p(2) *(@-30) "
	mov	ax, [bp-30]
	inc	word [bp-30]
; }
	jmp	L201
L202:
; break
	jmp	L123
; default
L124:
; return
; RPN'ized expression: "1 -u "
; Expanded expression: "-1 "
; Expression value: -1
; Fused expression:    "-1 "
	mov	ax, -1
	jmp	L96
; }
	jmp	L123
L192:
	jmp	L124
L123:
; }
	jmp	L99
L101:
; return
; RPN'ized expression: "cnt "
; Expanded expression: "(@-4) *(2) "
; Fused expression:    "*(2) (@-4) "
	mov	ax, [bp-4]
	jmp	L96
L96:
	leave
	ret
L95:
	sub	sp, 34
	jmp	L94

; glb printf : (
; prm     fmt : * char
; prm     ...
;     ) int
section .text
_printf:
	push	bp
	mov	bp, sp
	jmp	L204
L203:
; loc     fmt : (@4): * char
; loc     pp : (@-2): * * void
; =
; RPN'ized expression: "fmt &u "
; Expanded expression: "(@4) "
; Fused expression:    "=(170) *(@-2) (@4) "
	lea	ax, [bp+4]
	mov	[bp-2], ax
; return
; RPN'ized expression: "( pp 1 + , fmt vprintf ) "
; Expanded expression: " (@-2) *(2) 2 +  (@4) *(2)  vprintf ()4 "
; Fused expression:    "( + *(@-2) 2 , *(2) (@4) , vprintf )4 "
	mov	ax, [bp-2]
	add	ax, 2
	push	ax
	push	word [bp+4]
	call	_vprintf
	sub	sp, -4
	jmp	L205
L205:
	leave
	ret
L204:
	sub	sp, 2
	jmp	L203

; glb getch : () unsigned char
section .text
_getch:
	push	bp
	mov	bp, sp
	jmp	L208
L207:
mov ah, 0x00
int 0x16
mov al, ah
L209:
	leave
	ret
L208:
	jmp	L207

; RPN'ized expression: "128 "
; Expanded expression: "128 "
; Expression value: 128
; glb en_US_Keyboard : [128u] unsigned char
section .data
_en_US_Keyboard:
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "27 "
; Expanded expression: "27 "
; Expression value: 27
	db	27
; RPN'ized expression: "49 "
; Expanded expression: "49 "
; Expression value: 49
	db	49
; RPN'ized expression: "50 "
; Expanded expression: "50 "
; Expression value: 50
	db	50
; RPN'ized expression: "51 "
; Expanded expression: "51 "
; Expression value: 51
	db	51
; RPN'ized expression: "52 "
; Expanded expression: "52 "
; Expression value: 52
	db	52
; RPN'ized expression: "53 "
; Expanded expression: "53 "
; Expression value: 53
	db	53
; RPN'ized expression: "54 "
; Expanded expression: "54 "
; Expression value: 54
	db	54
; RPN'ized expression: "55 "
; Expanded expression: "55 "
; Expression value: 55
	db	55
; RPN'ized expression: "56 "
; Expanded expression: "56 "
; Expression value: 56
	db	56
; RPN'ized expression: "57 "
; Expanded expression: "57 "
; Expression value: 57
	db	57
; RPN'ized expression: "48 "
; Expanded expression: "48 "
; Expression value: 48
	db	48
; RPN'ized expression: "45 "
; Expanded expression: "45 "
; Expression value: 45
	db	45
; RPN'ized expression: "61 "
; Expanded expression: "61 "
; Expression value: 61
	db	61
; RPN'ized expression: "8 "
; Expanded expression: "8 "
; Expression value: 8
	db	8
; RPN'ized expression: "9 "
; Expanded expression: "9 "
; Expression value: 9
	db	9
; RPN'ized expression: "113 "
; Expanded expression: "113 "
; Expression value: 113
	db	113
; RPN'ized expression: "119 "
; Expanded expression: "119 "
; Expression value: 119
	db	119
; RPN'ized expression: "101 "
; Expanded expression: "101 "
; Expression value: 101
	db	101
; RPN'ized expression: "114 "
; Expanded expression: "114 "
; Expression value: 114
	db	114
; RPN'ized expression: "116 "
; Expanded expression: "116 "
; Expression value: 116
	db	116
; RPN'ized expression: "121 "
; Expanded expression: "121 "
; Expression value: 121
	db	121
; RPN'ized expression: "117 "
; Expanded expression: "117 "
; Expression value: 117
	db	117
; RPN'ized expression: "105 "
; Expanded expression: "105 "
; Expression value: 105
	db	105
; RPN'ized expression: "111 "
; Expanded expression: "111 "
; Expression value: 111
	db	111
; RPN'ized expression: "112 "
; Expanded expression: "112 "
; Expression value: 112
	db	112
; RPN'ized expression: "91 "
; Expanded expression: "91 "
; Expression value: 91
	db	91
; RPN'ized expression: "93 "
; Expanded expression: "93 "
; Expression value: 93
	db	93
; RPN'ized expression: "10 "
; Expanded expression: "10 "
; Expression value: 10
	db	10
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "97 "
; Expanded expression: "97 "
; Expression value: 97
	db	97
; RPN'ized expression: "115 "
; Expanded expression: "115 "
; Expression value: 115
	db	115
; RPN'ized expression: "100 "
; Expanded expression: "100 "
; Expression value: 100
	db	100
; RPN'ized expression: "102 "
; Expanded expression: "102 "
; Expression value: 102
	db	102
; RPN'ized expression: "103 "
; Expanded expression: "103 "
; Expression value: 103
	db	103
; RPN'ized expression: "104 "
; Expanded expression: "104 "
; Expression value: 104
	db	104
; RPN'ized expression: "106 "
; Expanded expression: "106 "
; Expression value: 106
	db	106
; RPN'ized expression: "107 "
; Expanded expression: "107 "
; Expression value: 107
	db	107
; RPN'ized expression: "108 "
; Expanded expression: "108 "
; Expression value: 108
	db	108
; RPN'ized expression: "59 "
; Expanded expression: "59 "
; Expression value: 59
	db	59
; RPN'ized expression: "39 "
; Expanded expression: "39 "
; Expression value: 39
	db	39
; RPN'ized expression: "96 "
; Expanded expression: "96 "
; Expression value: 96
	db	96
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "92 "
; Expanded expression: "92 "
; Expression value: 92
	db	92
; RPN'ized expression: "122 "
; Expanded expression: "122 "
; Expression value: 122
	db	122
; RPN'ized expression: "120 "
; Expanded expression: "120 "
; Expression value: 120
	db	120
; RPN'ized expression: "99 "
; Expanded expression: "99 "
; Expression value: 99
	db	99
; RPN'ized expression: "118 "
; Expanded expression: "118 "
; Expression value: 118
	db	118
; RPN'ized expression: "98 "
; Expanded expression: "98 "
; Expression value: 98
	db	98
; RPN'ized expression: "110 "
; Expanded expression: "110 "
; Expression value: 110
	db	110
; RPN'ized expression: "109 "
; Expanded expression: "109 "
; Expression value: 109
	db	109
; RPN'ized expression: "44 "
; Expanded expression: "44 "
; Expression value: 44
	db	44
; RPN'ized expression: "46 "
; Expanded expression: "46 "
; Expression value: 46
	db	46
; RPN'ized expression: "47 "
; Expanded expression: "47 "
; Expression value: 47
	db	47
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "42 "
; Expanded expression: "42 "
; Expression value: 42
	db	42
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "32 "
; Expanded expression: "32 "
; Expression value: 32
	db	32
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "45 "
; Expanded expression: "45 "
; Expression value: 45
	db	45
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "43 "
; Expanded expression: "43 "
; Expression value: 43
	db	43
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
	db	0
	times	38 db 0

; glb BYTE : char
; glb WORD : int
; glb DWORD : int
; glb halt : (void) int
section .text
_halt:
	push	bp
	mov	bp, sp
	jmp	L212
L211:
; RPN'ized expression: "( L215 printf ) "
; Expanded expression: " L215  printf ()2 "

section .data
L215:
	db	"Halt Called. Now Halting.....",10,0

section .text
; Fused expression:    "( L215 , printf )2 "
	push	L215
	call	_printf
	sub	sp, -2
cli
hlt
jmp $
L213:
	leave
	ret
L212:
	jmp	L211

; glb outportb : (
; prm     port : unsigned
; prm     byte : unsigned char
;     ) void
section .text
_outportb:
	push	bp
	mov	bp, sp
	jmp	L218
L217:
; loc     port : (@4): unsigned
; loc     byte : (@6): unsigned char
pusha
mov al, [bp + 4]
mov dx, [bp + 6]
out dx, al
popa
L219:
	leave
	ret
L218:
	jmp	L217

; glb inportb : (
; prm     port : unsigned
;     ) unsigned char
section .text
_inportb:
	push	bp
	mov	bp, sp
	jmp	L222
L221:
; loc     port : (@4): unsigned
push dx
mov dx, [bp + 4]
in al, dx
pop dx
L223:
	leave
	ret
L222:
	jmp	L221

; glb init_serial : () void
section .text
_init_serial:
	push	bp
	mov	bp, sp
	jmp	L226
L225:
; RPN'ized expression: "( 0 , 1016 1 + outportb ) "
; Expanded expression: " 0  1017  outportb ()4 "
; Fused expression:    "( 0 , 1017 , outportb )4 "
	push	0
	push	1017
	call	_outportb
	sub	sp, -4
; RPN'ized expression: "( 128 , 1016 3 + outportb ) "
; Expanded expression: " 128  1019  outportb ()4 "
; Fused expression:    "( 128 , 1019 , outportb )4 "
	push	128
	push	1019
	call	_outportb
	sub	sp, -4
; RPN'ized expression: "( 3 , 1016 0 + outportb ) "
; Expanded expression: " 3  1016  outportb ()4 "
; Fused expression:    "( 3 , 1016 , outportb )4 "
	push	3
	push	1016
	call	_outportb
	sub	sp, -4
; RPN'ized expression: "( 0 , 1016 1 + outportb ) "
; Expanded expression: " 0  1017  outportb ()4 "
; Fused expression:    "( 0 , 1017 , outportb )4 "
	push	0
	push	1017
	call	_outportb
	sub	sp, -4
; RPN'ized expression: "( 3 , 1016 3 + outportb ) "
; Expanded expression: " 3  1019  outportb ()4 "
; Fused expression:    "( 3 , 1019 , outportb )4 "
	push	3
	push	1019
	call	_outportb
	sub	sp, -4
; RPN'ized expression: "( 199 , 1016 2 + outportb ) "
; Expanded expression: " 199  1018  outportb ()4 "
; Fused expression:    "( 199 , 1018 , outportb )4 "
	push	199
	push	1018
	call	_outportb
	sub	sp, -4
; RPN'ized expression: "( 11 , 1016 4 + outportb ) "
; Expanded expression: " 11  1020  outportb ()4 "
; Fused expression:    "( 11 , 1020 , outportb )4 "
	push	11
	push	1020
	call	_outportb
	sub	sp, -4
L227:
	leave
	ret
L226:
	jmp	L225

; glb s_putchar : (
; prm     c : unsigned char
;     ) unsigned char
section .text
_s_putchar:
	push	bp
	mov	bp, sp
	jmp	L230
L229:
; loc     c : (@4): unsigned char
mov al, [bp +4]
push edx
push eax
mov dx, 0x3F8+5
.wait:
in al, dx
bt ax, 5
jnc .wait
pop eax
mov dx, 0x3F8
out dx, al
pop edx
leave
ret
L231:
	leave
	ret
L230:
	jmp	L229

; glb putchar : (
; prm     c : unsigned char
;     ) void
section .text
_putchar:
	push	bp
	mov	bp, sp
	jmp	L234
L233:
; loc     c : (@4): unsigned char
; if
; RPN'ized expression: "serial_output 0 == "
; Expanded expression: "serial_output *(2) 0 == "
; Fused expression:    "== *serial_output 0 IF! "
	mov	ax, [_serial_output]
	cmp	ax, 0
	jne	L237
; {
; RPN'ized expression: "( c scr_putchar ) "
; Expanded expression: " (@4) *(1)  scr_putchar ()2 "
; Fused expression:    "( *(1) (@4) , scr_putchar )2 "
	mov	al, [bp+4]
	mov	ah, 0
	push	ax
	call	_scr_putchar
	sub	sp, -2
; }
	jmp	L238
L237:
; else
; {
; RPN'ized expression: "( c s_putchar ) "
; Expanded expression: " (@4) *(1)  s_putchar ()2 "
; Fused expression:    "( *(1) (@4) , s_putchar )2 "
	mov	al, [bp+4]
	mov	ah, 0
	push	ax
	call	_s_putchar
	sub	sp, -2
; }
L238:
L235:
	leave
	ret
L234:
	jmp	L233

; RPN'ized expression: "4 "
; Expanded expression: "4 "
; Expression value: 4
; RPN'ized expression: "2 "
; Expanded expression: "2 "
; Expression value: 2
; RPN'ized expression: "4 "
; Expanded expression: "4 "
; Expression value: 4
; RPN'ized expression: "2 "
; Expanded expression: "2 "
; Expression value: 2
; RPN'ized expression: "189 "
; Expanded expression: "189 "
; Expression value: 189
; glb VBEInfoBlock_t : struct VBEInfoBlock
; glb VBEModeInfoBlock_t : struct VBEModeInfoBlock
; glb VBEGetModeInformation : (
; prm     mode_number : unsigned
; prm     InfoBlock : unsigned
;     ) unsigned
section .text
_VBEGetModeInformation:
	push	bp
	mov	bp, sp
	jmp	L240
L239:
; loc     mode_number : (@4): unsigned
; loc     InfoBlock : (@6): unsigned
pusha
mov ax, 0x4F01
mov cx, [bp + 4]
and cx, 0xFFF
mov di, [bp + 6]
int 0x10
popa
; return
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "0 "
	mov	ax, 0
	jmp	L241
L241:
	leave
	ret
L240:
	jmp	L239

; glb main : (void) int
section .text
_main:
	push	bp
	mov	bp, sp
	jmp	L244
L243:
; loc     VbeModeInfo : (@-2): * struct VBEModeInfoBlock
; =
; RPN'ized expression: "36864u "
; Expanded expression: "36864u "
; Expression value: 36864u
; Fused expression:    "=(170) *(@-2) 36864u "
	mov	ax, -28672
	mov	[bp-2], ax
; RPN'ized expression: "( 18 vga_gfxmode ) "
; Expanded expression: " 18  vga_gfxmode ()2 "
; Fused expression:    "( 18 , vga_gfxmode )2 "
	push	18
	call	_vga_gfxmode
	sub	sp, -2
; RPN'ized expression: "( L247 printf ) "
; Expanded expression: " L247  printf ()2 "

section .data
L247:
	db	10,"VGA 0x12 Mode Set, Reading VBE Information now......",0

section .text
; Fused expression:    "( L247 , printf )2 "
	push	L247
	call	_printf
	sub	sp, -2
; RPN'ized expression: "( VbeModeInfo , 16658 VBEGetModeInformation ) "
; Expanded expression: " (@-2) *(2)  16658  VBEGetModeInformation ()4 "
; Fused expression:    "( *(2) (@-2) , 16658 , VBEGetModeInformation )4 "
	push	word [bp-2]
	push	16658
	call	_VBEGetModeInformation
	sub	sp, -4
; RPN'ized expression: "( 2 settextcolor ) "
; Expanded expression: " 2  settextcolor ()2 "
; Fused expression:    "( 2 , settextcolor )2 "
	push	2
	call	_settextcolor
	sub	sp, -2
; RPN'ized expression: "( 16641 , L249 printf ) "
; Expanded expression: " 16641  L249  printf ()4 "

section .data
L249:
	db	10,"VBE Mode Infomation Block for: %d",0

section .text
; Fused expression:    "( 16641 , L249 , printf )4 "
	push	16641
	push	L249
	call	_printf
	sub	sp, -4
; RPN'ized expression: "( 4 settextcolor ) "
; Expanded expression: " 4  settextcolor ()2 "
; Fused expression:    "( 4 , settextcolor )2 "
	push	4
	call	_settextcolor
	sub	sp, -2
; RPN'ized expression: "( VbeModeInfo XResolution -> *u , L251 printf ) "
; Expanded expression: " (@-2) *(2) 16 + *(2)  L251  printf ()4 "

section .data
L251:
	db	10,"VBE Mode X resolution: %d",0

section .text
; Fused expression:    "( + *(@-2) 16 *(2) ax , L251 , printf )4 "
	mov	ax, [bp-2]
	add	ax, 16
	mov	bx, ax
	push	word [bx]
	push	L251
	call	_printf
	sub	sp, -4
; RPN'ized expression: "( VbeModeInfo YResolution -> *u , L253 printf ) "
; Expanded expression: " (@-2) *(2) 18 + *(2)  L253  printf ()4 "

section .data
L253:
	db	10,"VBE Mode Y resolution: %d",0

section .text
; Fused expression:    "( + *(@-2) 18 *(2) ax , L253 , printf )4 "
	mov	ax, [bp-2]
	add	ax, 18
	mov	bx, ax
	push	word [bx]
	push	L253
	call	_printf
	sub	sp, -4
; RPN'ized expression: "( 8 settextcolor ) "
; Expanded expression: " 8  settextcolor ()2 "
; Fused expression:    "( 8 , settextcolor )2 "
	push	8
	call	_settextcolor
	sub	sp, -2
; RPN'ized expression: "( VbeModeInfo PhysBasePtr -> *u , L255 printf ) "
; Expanded expression: " (@-2) *(2) 38 + *(2)  L255  printf ()4 "

section .data
L255:
	db	10,"VBE Mode FrameBuffer Address: %d",0

section .text
; Fused expression:    "( + *(@-2) 38 *(2) ax , L255 , printf )4 "
	mov	ax, [bp-2]
	add	ax, 38
	mov	bx, ax
	push	word [bx]
	push	L255
	call	_printf
	sub	sp, -4
; RPN'ized expression: "( 11 settextcolor ) "
; Expanded expression: " 11  settextcolor ()2 "
; Fused expression:    "( 11 , settextcolor )2 "
	push	11
	call	_settextcolor
	sub	sp, -2
; RPN'ized expression: "( VbeModeInfo BitsPerPixel -> *u , L257 printf ) "
; Expanded expression: " (@-2) *(2) 23 + *(-1)  L257  printf ()4 "

section .data
L257:
	db	10,"VBE Mode Color Depth: %d",0

section .text
; Fused expression:    "( + *(@-2) 23 *(-1) ax , L257 , printf )4 "
	mov	ax, [bp-2]
	add	ax, 23
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	push	L257
	call	_printf
	sub	sp, -4
; RPN'ized expression: "( 15 settextcolor ) "
; Expanded expression: " 15  settextcolor ()2 "
; Fused expression:    "( 15 , settextcolor )2 "
	push	15
	call	_settextcolor
	sub	sp, -2
; RPN'ized expression: "( VbeModeInfo WinAAttributes -> *u , L259 printf ) "
; Expanded expression: " (@-2) *(2) 2 + *(-1)  L259  printf ()4 "

section .data
L259:
	db	10,"VBE Window Attributes: %d",0

section .text
; Fused expression:    "( + *(@-2) 2 *(-1) ax , L259 , printf )4 "
	mov	ax, [bp-2]
	add	ax, 2
	mov	bx, ax
	mov	al, [bx]
	cbw
	push	ax
	push	L259
	call	_printf
	sub	sp, -4
; RPN'ized expression: "serial_output 1 = "
; Expanded expression: "serial_output 1 =(2) "
; Fused expression:    "=(170) *serial_output 1 "
	mov	ax, 1
	mov	[_serial_output], ax
; loc     n1 : (@-4): int
; loc     n2 : (@-6): int
; loc     i : (@-8): int
; loc     j : (@-10): int
; loc     count : (@-12): int
; RPN'ized expression: "n1 0 = "
; Expanded expression: "(@-4) 0 =(2) "
; Fused expression:    "=(170) *(@-4) 0 "
	mov	ax, 0
	mov	[bp-4], ax
; RPN'ized expression: "n2 100 = "
; Expanded expression: "(@-6) 100 =(2) "
; Fused expression:    "=(170) *(@-6) 100 "
	mov	ax, 100
	mov	[bp-6], ax
; loc     flag : (@-14): unsigned
; =
; RPN'ized expression: "0 "
; Expanded expression: "0 "
; Expression value: 0
; Fused expression:    "=(170) *(@-14) 0 "
	mov	ax, 0
	mov	[bp-14], ax
; RPN'ized expression: "( 10 , n2 , L261 printf ) "
; Expanded expression: " 10  (@-6) *(2)  L261  printf ()6 "

section .data
L261:
	db	10,"Prime Number from 0 to %d",0

section .text
; Fused expression:    "( 10 , *(2) (@-6) , L261 , printf )6 "
	push	10
	push	word [bp-6]
	push	L261
	call	_printf
	sub	sp, -6
; for
; RPN'ized expression: "i n1 1 + = "
; Expanded expression: "(@-8) (@-4) *(2) 1 + =(2) "
; Fused expression:    "+ *(@-4) 1 =(170) *(@-8) ax "
	mov	ax, [bp-4]
	inc	ax
	mov	[bp-8], ax
L263:
; RPN'ized expression: "i n2 < "
; Expanded expression: "(@-8) *(2) (@-6) *(2) < "
; Fused expression:    "< *(@-8) *(@-6) IF! "
	mov	ax, [bp-8]
	cmp	ax, [bp-6]
	jge	L266
	jmp	L265
L264:
; RPN'ized expression: "i ++ "
; Expanded expression: "(@-8) ++(2) "
; Fused expression:    "++(2) *(@-8) "
	inc	word [bp-8]
	mov	ax, [bp-8]
	jmp	L263
L265:
; {
; RPN'ized expression: "flag 0 = "
; Expanded expression: "(@-14) 0 =(2) "
; Fused expression:    "=(170) *(@-14) 0 "
	mov	ax, 0
	mov	[bp-14], ax
; for
; RPN'ized expression: "j 2 = "
; Expanded expression: "(@-10) 2 =(2) "
; Fused expression:    "=(170) *(@-10) 2 "
	mov	ax, 2
	mov	[bp-10], ax
L267:
; RPN'ized expression: "j i 2 / <= "
; Expanded expression: "(@-10) *(2) (@-8) *(2) 2 / <= "
; Fused expression:    "/ *(@-8) 2 <= *(@-10) ax IF! "
	mov	ax, [bp-8]
	cwd
	mov	cx, 2
	idiv	cx
	mov	cx, ax
	mov	ax, [bp-10]
	cmp	ax, cx
	jg	L270
	jmp	L269
L268:
; RPN'ized expression: "j ++ "
; Expanded expression: "(@-10) ++(2) "
; Fused expression:    "++(2) *(@-10) "
	inc	word [bp-10]
	mov	ax, [bp-10]
	jmp	L267
L269:
; {
; if
; RPN'ized expression: "i j % 0 == "
; Expanded expression: "(@-8) *(2) (@-10) *(2) % 0 == "
; Fused expression:    "% *(@-8) *(@-10) == ax 0 IF! "
	mov	ax, [bp-8]
	cwd
	idiv	word [bp-10]
	mov	ax, dx
	cmp	ax, 0
	jne	L271
; {
; RPN'ized expression: "flag 1 = "
; Expanded expression: "(@-14) 1 =(2) "
; Fused expression:    "=(170) *(@-14) 1 "
	mov	ax, 1
	mov	[bp-14], ax
; break
	jmp	L270
; }
L271:
; }
	jmp	L268
L270:
; if
; RPN'ized expression: "flag 0 == "
; Expanded expression: "(@-14) *(2) 0 == "
; Fused expression:    "== *(@-14) 0 IF! "
	mov	ax, [bp-14]
	cmp	ax, 0
	jne	L273
; {
; RPN'ized expression: "( i , L275 printf ) "
; Expanded expression: " (@-8) *(2)  L275  printf ()4 "

section .data
L275:
	db	"%d ",0

section .text
; Fused expression:    "( *(2) (@-8) , L275 , printf )4 "
	push	word [bp-8]
	push	L275
	call	_printf
	sub	sp, -4
; RPN'ized expression: "count ++p "
; Expanded expression: "(@-12) ++p(2) "
; Fused expression:    "++p(2) *(@-12) "
	mov	ax, [bp-12]
	inc	word [bp-12]
; }
L273:
; }
	jmp	L264
L266:
; while
; RPN'ized expression: "1 "
; Expanded expression: "1 "
; Expression value: 1
L277:
; Fused expression:    "1 "
	mov	ax, 1
; JumpIfZero
	test	ax, ax
	je	L278
; {
; loc         c : (@-16): unsigned char
; RPN'ized expression: "c ( getch ) = "
; Expanded expression: "(@-16)  getch ()0 =(1) "
; Fused expression:    "( getch )0 =(154) *(@-16) ax "
	call	_getch
	mov	[bp-16], al
	mov	ah, 0
; RPN'ized expression: "( en_US_Keyboard c + *u putchar ) "
; Expanded expression: " en_US_Keyboard (@-16) *(1) + *(1)  putchar ()2 "
; Fused expression:    "( + en_US_Keyboard *(@-16) *(1) ax , putchar )2 "
	mov	ax, _en_US_Keyboard
	movzx	cx, byte [bp-16]
	add	ax, cx
	mov	bx, ax
	mov	al, [bx]
	mov	ah, 0
	push	ax
	call	_putchar
	sub	sp, -2
; }
	jmp	L277
L278:
; RPN'ized expression: "( L279 printf ) "
; Expanded expression: " L279  printf ()2 "

section .data
L279:
	db	"[ENTER] Pressed.",0

section .text
; Fused expression:    "( L279 , printf )2 "
	push	L279
	call	_printf
	sub	sp, -2
; RPN'ized expression: "( halt ) "
; Expanded expression: " halt ()0 "
; Fused expression:    "( halt )0 "
	call	_halt
; Fused expression:    "0 "
	mov	ax, 0
L245:
	leave
	ret
L244:
	sub	sp, 16
	jmp	L243


; Syntax/declaration table/stack:
; Bytes used: 3544/20224


; Macro table:
; Macro __SMALLER_C__ = `0x0100`
; Macro __SMALLER_C_16__ = ``
; Macro __SMALLER_C_SCHAR__ = ``
; Macro __LOADER_H = ``
; Macro __IO_H = ``
; Macro __STDBOOL_H = ``
; Macro TRUE = `1`
; Macro FALSE = `0`
; Macro true = `1`
; Macro false = `0`
; Macro __PRINTF_H = ``
; Macro __SCREEN_H = ``
; Macro __STDINT_H = ``
; Macro VGA_40x25 = `0x01`
; Macro VGA_80x25 = `0x03`
; Macro VGA_320x200x256 = `0x0D`
; Macro VGA_640x480x256 = `0x12`
; Macro __ERRNO_H = ``
; Macro ERRNO_ERROR = `-1`
; Macro ERRNO_OK = `0`
; Macro __STRING_H = ``
; Macro __STRING_C = ``
; Macro __KEYBOARD_H = ``
; Macro __SERIAL_H = ``
; Macro COM1_PORT = `0x3F8`
; Macro __X86_H = ``
; Macro __VBE_H = ``
; Bytes used: 379/4096


; Identifier table:
; Ident bool
; Ident serial_output
; Ident uint8_t
; Ident int8_t
; Ident uint16_t
; Ident int16_t
; Ident uint32_t
; Ident int32_t
; Ident PhysicalAddr_t
; Ident vga_mode_t
; Ident screen_color
; Ident gfx_mode
; Ident <something>
; Ident X
; Ident Y
; Ident cursor_t
; Ident scr_putchar
; Ident c
; Ident c_printc
; Ident color
; Ident vga_gfxmode
; Ident mode_number
; Ident errno
; Ident settextcolor
; Ident bios_move_cursor
; Ident x
; Ident string
; Ident size_t
; Ident strlen
; Ident str
; Ident reverse
; Ident s
; Ident strcpy
; Ident dest
; Ident source
; Ident memset
; Ident val
; Ident count
; Ident memcpy
; Ident src
; Ident memsetw
; Ident itoa
; Ident n
; Ident buffer
; Ident base
; Ident atoi
; Ident p
; Ident isdigit
; Ident vprintf
; Ident fmt
; Ident vl
; Ident printf
; Ident getch
; Ident en_US_Keyboard
; Ident BYTE
; Ident WORD
; Ident DWORD
; Ident halt
; Ident outportb
; Ident port
; Ident byte
; Ident inportb
; Ident init_serial
; Ident s_putchar
; Ident putchar
; Ident VBEInfoBlock
; Ident VbeSignature
; Ident VbeVersion
; Ident OemStringPtr
; Ident Capabilities
; Ident VideoModePtr
; Ident TotalMemory
; Ident VBEModeInfoBlock
; Ident ModeAttributes
; Ident WinAAttributes
; Ident WinBAttributes
; Ident WinGranularity
; Ident WinSize
; Ident WinASegment
; Ident WinBSegment
; Ident WinFuncPtr
; Ident BytesPerScanLine
; Ident XResolution
; Ident YResolution
; Ident XCharSize
; Ident YCharSize
; Ident NumberOfPlanes
; Ident BitsPerPixel
; Ident NumberOfBanks
; Ident MemoryModel
; Ident BankSize
; Ident NumberOfImagePages
; Ident Reserved_page
; Ident RedMaskSize
; Ident RedFieldPosition
; Ident GreenMaskSize
; Ident GreenFieldPosition
; Ident BlueMaskSize
; Ident BlueFieldPosition
; Ident RsvdMaskSize
; Ident RsvdFieldPosition
; Ident DirectColorModeInfo
; Ident PhysBasePtr
; Ident OffScreenMemOffset
; Ident OffScreenMemSize
; Ident LinBytesPerScanLine
; Ident BnkNumberOfPages
; Ident LinNumberOfPages
; Ident LinRedMaskSize
; Ident LinRedFieldPosition
; Ident LinGreenMaskSize
; Ident LinGreenFieldPosition
; Ident LinBlueMaskSize
; Ident LinBlueFieldPosition
; Ident LinRsvdMaskSize
; Ident LinRsvdFieldPosition
; Ident MaxPixelClock
; Ident Reserved
; Ident VBEInfoBlock_t
; Ident VBEModeInfoBlock_t
; Ident VBEGetModeInformation
; Ident InfoBlock
; Ident main
; Bytes used: 1453/4752

; Next label number: 281
; Compilation succeeded.
