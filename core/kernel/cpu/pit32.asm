;; Contains the PIT stuff (Programmable Interrupt Timer)
use32
define PIT_CONST 1193180
define PIT_PORT_2 0x43
define PIT_PORT 0x40
define NORMAL_FREQ 11931
;; PIT Timer IRQ0
pit_timer:
	pushad
	push ds
	push es
	cld
	;; check if we have a timer pending
	cmp dword [timer_flag], 0x00000000
	je .next
	;; yes we do
	inc dword [timer_count]
.next:
	inc dword [system_timer_mS]
	;; How many delay flags we've?
.delay:
	cmp dword [delay_flag], 0
	je .print_time
	;; Else Decrement the Delay Flag
	dec dword [delay_flag]
.print_time:
	;; Print the time :)
	mov edi, _pit_time_buf
	call rtc_get_time_string
	mov esi, _time_string
	mov edi, video_memory + 86
.ploop:
    lodsb
	cmp al, 0x00
	je .print_date
	mov ah, 0x8F
	mov [fs:edi], ax
	inc edi
	inc edi
	jmp .ploop
.print_date:
	;; EDI is set to the screen last known location
	;; shit, shouldn't miss from radar so save it :)
	push edi
	mov edi, _pit_date_buf
	call rtc_get_date_string
	pop edi
	;; Add a space!
	add edi, 2
	mov esi, _date_string
.dloop:
	lodsb
	cmp al, 0x00
	je .done
	mov ah, 0xE0
	mov [fs:edi], ax
	inc edi
	inc edi
	jmp .dloop
.done:
	;; Tell PIC We're done.
	call send_eoi
	pop es
	pop ds
	popad
	iret
DATA_SECTION:
	delay_flag dd 0
	PIT_COUNTER dd 0, 0
	system_timer_fractions:  rd 1          ; Fractions of 1 mS since timer initialized
	system_timer_mS:         rd 1          ; Number of whole mS since timer initialized
	IRQ0_fractions:          rd 1          ; Fractions of 1 mS between IRQs
	IRQ0_mS:                 rd 1          ; Number of whole mS between IRQs
	IRQ0_frequency:          rd 1          ; Actual frequency of PIT
	PIT_reload_value:        rw 1          ; Current PIT reload value
	PIT_SIG db 0
	CURRENT_EIP: dd 0x0
	CountDown dd 0x00
	_time_string: db 'RTC Time: '
	_pit_time_buf: times 12 db 0x00
	_date_string: db 'RTC Date: '
	_pit_date_buf: times 12 db 0x00
	timer_count: dd 0x00000000
	timer_flag dd 0x00000000
;; INIT_TIMER ECX = Number of seconds
init_timer:
	cli
	mov	dword [delay_flag], ecx		      ; mov value to "timer"
    .loop:
	cmp	  [delay_flag], 0
	jz	  .done
	NOP
    NOP
    NOP
    NOP
    NOP
    NOP
	sti
	jmp .loop
.done:
	sti
	ret
	
	ret
;; PIT Intialize : Intialize the PIT with a defined frequency
;; Hz, borrowed from wiki.osdev.org under the CC0 license.
pit_init:
;Input
; ebx   Desired PIT frequency in Hz
    pushad
    ; Do some checking
 
    mov eax,0x10000                   ;eax = reload value for slowest possible frequency (65536)
    cmp ebx,18                        ;Is the requested frequency too low?
    jbe .gotReloadValue               ; yes, use slowest possible frequency
 
    mov eax,1                         ;ax = reload value for fastest possible frequency (1)
    cmp ebx,1193181                   ;Is the requested frequency too high?
    jae .gotReloadValue               ; yes, use fastest possible frequency
 
    ; Calculate the reload value
 
    mov eax,3579545
    mov edx,0                         ;edx:eax = 3579545
    div ebx                           ;eax = 3579545 / frequency, edx = remainder
    cmp edx,3579545 / 2               ;Is the remainder more than half?
    jb .l1                            ; no, round down
    inc eax                           ; yes, round up
 .l1:
    mov ebx,3
    mov edx,0                         ;edx:eax = 3579545 * 256 / frequency
    div ebx                           ;eax = (3579545 * 256 / 3 * 256) / frequency
    cmp edx,3 / 2                     ;Is the remainder more than half?
    jb .l2                            ; no, round down
    inc eax                           ; yes, round up
 .l2:
 
 
 ; Store the reload value and calculate the actual frequency
 
 .gotReloadValue:
    push eax                          ;Store reload_value for later
    mov [PIT_reload_value],ax         ;Store the reload value for later
    mov ebx,eax                       ;ebx = reload value
 
    mov eax,3579545
    mov edx,0                         ;edx:eax = 3579545
    div ebx                           ;eax = 3579545 / reload_value, edx = remainder
    cmp edx,3579545 / 2               ;Is the remainder more than half?
    jb .l3                            ; no, round down
    inc eax                           ; yes, round up
 .l3:
    mov ebx,3
    mov edx,0                         ;edx:eax = 3579545 / reload_value
    div ebx                           ;eax = (3579545 / 3) / frequency
    cmp edx,3 / 2                     ;Is the remainder more than half?
    jb .l4                            ; no, round down
    inc eax                           ; yes, round up
 .l4:
    mov [IRQ0_frequency],eax          ;Store the actual frequency for displaying later
 
 
 ; Calculate the amount of time between IRQs in 32.32 fixed point
 ;
 ; Note: The basic formula is:
 ;           time in ms = reload_value / (3579545 / 3) * 1000
 ;       This can be rearranged in the follow way:
 ;           time in ms = reload_value * 3000 / 3579545
 ;           time in ms = reload_value * 3000 / 3579545 * (2^42)/(2^42)
 ;           time in ms = reload_value * 3000 * (2^42) / 3579545 / (2^42)
 ;           time in ms * 2^32 = reload_value * 3000 * (2^42) / 3579545 / (2^42) * (2^32)
 ;           time in ms * 2^32 = reload_value * 3000 * (2^42) / 3579545 / (2^10)
 
    pop ebx                           ;ebx = reload_value
    mov eax,0xDBB3A062                ;eax = 3000 * (2^42) / 3579545
    mul ebx                           ;edx:eax = reload_value * 3000 * (2^42) / 3579545
    shrd eax,edx,10
    shr edx,10                        ;edx:eax = reload_value * 3000 * (2^42) / 3579545 / (2^10)
 
    mov [IRQ0_mS],edx                 ;Set whole mS between IRQs
    mov [IRQ0_fractions],eax          ;Set fractions of 1 mS between IRQs
 
 
 ; Program the PIT channel
 
    pushfd
    cli                               ;Disabled interrupts (just in case)
 
    mov al,00110100b                  ;channel 0, lobyte/hibyte, rate generator
    out 0x43, al
 
    mov ax,[PIT_reload_value]         ;ax = 16 bit reload value
    out 0x40,al                       ;Set low byte of PIT reload value
    mov al,ah                         ;ax = high 8 bits of reload value
    out 0x40,al                       ;Set high byte of PIT reload value
 
    popfd
 
    popad
	sti
    ret
pit32_init:
	push eax
	mov al, 0x36
	out 0x43, al    ;tell the PIT which channel we're setting
 
	mov ax, 1193
	out32 0x40, al    ;send low byte
	out32 0x40, ah    ;send high byte
	pop eax
	ret
;; pit_start_timer
;; starts the timer from 0x000
pit_start_timer:
	;; tell the pit to start the timer
	mov dword [timer_flag], 0x00000001
	;; start the timer
	mov dword [timer_count], 0x0000000
	ret
;; pit_stop_timer
;; stop the timer
pit_stop_timer:
	;; tell the pit to stop the timer
	mov dword [timer_flag], 0x00000000
	;; start the timer
	mov dword [timer_count], 0x0000000
	ret
;; pit get timer 
;; out: ecx - timer count
pit_get_timer:
	mov ecx, [timer_count]
	ret
;; Unmask the timer IRQ
UNMASK_PIT:
	;; Unmasks the Timer IRQ
	define MASTER   0x20
	define SLAVE   0xA0
    in al, MASTER+1
    and al, 11111110b
    out MASTER+1, al
	;; Remember to Unmask the IRQ1 too.
	out32 MASTER+1, 0xFC
	;; Enables interrupts 
	sti
	ret
pit_printf:
	;; edi - video memory buf
	;; esi - string
	push eax
	push edi
.loop:
	lodsb
	cmp al, 0x00
	je .done
	mov ah, 0x7F
	mov [fs:edi], ax
	add edi, 2
	jmp .loop
.done:
	pop edi
	pop eax
	ret
	
	
;