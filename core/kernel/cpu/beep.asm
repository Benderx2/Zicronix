;; turns on the speaker
;; ax = frequency
os_speaker_on:
	push eax
	push ecx
	mov cx, ax		
	mov al, 182
	out 0x43, al		
	mov ax, cx		
	out 0x42, al
	mov al, ah		
	out 0x42, al
	in al, 0x61		
	or al, 0x03
	out 0x61, al
	pop ecx
	pop eax
	ret
;; os_speaker_off
;; turns off the speaker
os_speaker_off:
	  push	  ax
	  in	  al, 0x61
	  and	  al, 0xFC			      
	  out	  0x61, al
	  pop	  ax
	  ret