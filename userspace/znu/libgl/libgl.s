;; LIBGL - Graphics Library for Zicronix
;; Values for 320x200x256
DEFINE FRAME_BUFFER_ADDR 0xA0000
;; Clears the entire screen
;; IN: Nothing
libgl.clearscreen:
	pushad
	mov ebx, FRAME_BUFFER_ADDR
	mov ecx, 0xFFFF
.clear_loop:
	mov byte [fs:ebx], dl
	inc ebx
	loop .clear_loop
.done:
	popad
	ret
;; puts a pixel on screen
;; IN: EBX/ECX - Co-ordinate, AL - Color 
libgl.put_pixel:
	push ax
  push bx
  push cx
  push edi
  mov edi, FRAME_BUFFER_ADDR                ; directly to mem
  add di, bx
  mov bx, cx
  shl cx, 8
  shl bx, 6
  add cx, bx
  add di, cx
  stosb
  pop edi
  pop cx
  pop bx
  pop ax
  ret
;; puts a sprite on screen
;; AL - Color
;; AX/BX - X/Y Location
;; SI/DI - Height/Width 
;; ESI - Pointer to sprite
libgl.put_sprite:
  pushad                                      
  .row_loop:                                      
  dec dx                                  
  push cx                                  
  push ax                                 
  .col_loop:                                    
   dec cx                                
   push ax                                  
   push bx
   push cx      
   mov cx, bx      
   mov bx, ax      
   lodsb     
   call libgl.put_pixel
   pop cx
   pop bx
   pop ax
   inc ax
   cmp cx, 0
   jne .col_loop
   pop ax
   pop cx
   inc bx
   cmp ax, 0
   jne .row_loop
   popad
   ret
;; Draw Rectangle 
;; IN : AL - Color, BX/CX - X/Y Co-ordinate (Start), SI/DI - End X/Y Co-ordinate
libgl.draw_rectangle:
   ;; Save Cursor Positions
   mov [.cur_X], bx
   mov [.cur_Y], cx
   mov [.cur_Y_end], di
   mov [.cur_X_end], si
   ;; push all regs
   pushad
.put_loop:
   ;; okay put the pixel
   call libgl.put_pixel
   ;; increment X
   inc bx
   ;; is bx over than the last x Co-ordinate
   cmp bx, [.cur_X_end]
   jle .put_loop
   ;; else increment CX (Y Co-ordinate)
   inc cx
   ;; is cx EOY?
   cmp cx, [.cur_Y_end]
   jle .put_loop
   ;; else exit
   popad
   ret
.cur_X dw 0
.cur_Y dw 0
.cur_X_end dw 0
.cur_Y_end dw 0
;; Switches to ModeX
libgl.ModeX:
    pushad
    mov    dx, 03c4h    ;{ Set up DX to one of the VGA registers }
    mov    al, 04h      ;{ Register = Sequencer : Memory Modes }
    out    dx, al
    inc    dx           ;{ Now get the status of the register }
    in     al, dx       ;{ from the next port }
    and    al, 0c7h     ;{ AND it with 11000111b ie, bits 3,4,5 wiped }
    or     al, 04h      ;{ Turn on bit 2 (00000100b) }
    out    dx, al       ;{ and send it out to the register }
    mov    dx, 03c4h    ;{ Again, get ready to activate a register }
    mov    al, 02h      ;{ Register = Map Mask }
    out    dx, al
    inc    dx
    mov    al, 0fh      ;{ Send 00001111b to Map Mask register }
    out    dx, al       ;{ Setting all planes active }
    mov edi, FRAME_BUFFER_ADDR      ;{ clear DI }
    mov eax, 0x3F
    mov    ecx, 8000h   ;{ set entire 64k memory area (all 4 pages) }
    repnz  stosd        ;{ to colour BLACK (ie, Clear screens) }
    mov    dx, 03d4h    ;{ User another VGA register }
    mov    al, 14h      ;{ Register = Underline Location }
    out    dx, al
    inc    dx           ;{ Read status of register }
    in     al, dx       ;{ into AL }
    and    al, 0bFh     ;{ AND AL with 10111111b }
    out    dx, al       ;{ and send it to the register }
                        ;{ to deactivate Double Word mode addressing }
    dec    dx           ;{ Okay, this time we want another register,}
    mov    al, 17h      ;{ Register = CRTC : Mode Control }
    out    dx, al
    inc    dx
    in     al, dx       ;{ Get status of this register }
    or     al, 40h      ;{ and Turn the 6th bit ON }
    out    dx, al
    popad
    mov dword [MODE_X], 1
    ret

SCREEN_WIDTH dw 320
SCREEN_HEIGHT dw 200
SCREEN_COLOR dw 256
SCREEN_SIZE dd 320*200*256
MODE_X dd 0x0