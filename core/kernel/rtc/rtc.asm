;; rtc initialization
use32
define RTC_COMMAND 0x70
define RTC_DATA 0x71
;; Intializes the rtc a 32.768 hz, to show the current time
rtc_init:
.poll:
	push eax
	mov al, 0x0A
	out RTC_COMMAND, al
	in al, RTC_DATA
	test al, 0x80
	jne .poll
	mov al, 0x0A		
	out RTC_COMMAND, al
	mov al, 00101101b	
	out RTC_DATA, al
	mov al, 0x0B		
	out RTC_COMMAND, al		
	in al, RTC_DATA		
	push eax
	mov al, 0x0B		
	out RTC_COMMAND, al			
	pop eax
	bts ax, 6			
	out RTC_DATA, al		
	mov al, 0x0C		
	out RTC_COMMAND, al
	in al, RTC_DATA
	pop eax
	;; Return
	ret

;; RTC Get Date, gets day/month/year
rtc_get_date:
	;; push required registers
	pushad
	;; clear interrupts, don't wanna be interrupted
	cli
	;; Request for century
	mov al, 0x32
	out RTC_COMMAND, al
	in al, RTC_DATA
	;; Store it. (Remember it's a BCD!)
	mov [rtc_data.century], al
	;; Request for year
	mov al, 0x09
	out RTC_COMMAND, al
	in al, RTC_DATA
	mov [rtc_data.year], al
	;; Request for month
	mov al, 0x8
	out RTC_COMMAND, al
	in al, RTC_DATA
	mov [rtc_data.month], al
	;; Request for day
	mov al, 0x7
	out RTC_COMMAND, al
	in al, RTC_DATA
	mov [rtc_data.day], al
	;; Restore interrupts
	sti
	popad
	ret
;; rtc_get_time
;; gets the time in BCD
rtc_get_time:
	pushad
	mov al, 0x4
	out RTC_COMMAND, al
	in al, RTC_DATA
	mov [rtc_data.hour], al
	mov al, 0x2
	out RTC_COMMAND, al
	in al, RTC_DATA
	mov [rtc_data.minute], al
	mov al, 0x00
	out RTC_COMMAND, al
	in al, RTC_DATA
	mov [rtc_data.second], al
	popad
	ret
;; Gets the time string in EDI.
;; EDI - Pointer to buffer of string
rtc_get_time_string:
	;; Save registers
	push eax
	;; Get the time.
	call rtc_get_time
	;; Convert each value to ASCII
	mov al, [rtc_data.hour]
	call btoc32
	;; Copy it into EDI
	stosw
	;; Insert a colon after hours
	mov al, ':'
	stosb
	mov al, [rtc_data.minute]
	call btoc32
	stosw
	mov al, ':'
	stosb
	mov al, [rtc_data.second]
	call btoc32
	stosw
	;; Null terminate
	mov al, 0
	stosb
	pop eax
	ret
;; rtc get date string - gets the date string
;; EDI - pointer to buffer
rtc_get_date_string:
	;; Save registers
	push eax
	;; Get the time.
	call rtc_get_date
	;; Convert each value to ASCII
	mov al, [rtc_data.day]
	call btoc32
	;; Copy it into EDI
	stosw
	;; Insert a / after day
	mov al, '/'
	stosb
	mov al, [rtc_data.month]
	call btoc32
	stosw
	mov al, '/'
	stosb
	mov al, [rtc_data.year]
	call btoc32
	stosw
	;; Null terminate
	mov al, 0
	stosb
	pop eax
	ret
;; rtc_data section
rtc_data:
	.century db 0x00
	.year db 0x00
	.month db 0x00
	.day db 0x00
	.second db 0x00
	.minute db 0x00
	.hour db 0x00