;; Taken and based from ReturnInfinity's BareMetalOS
;; Copyright (C) 2008-2014 Return Infinity -- http://www.returninfinity.com
;; All rights reserved. 
;; Please see credits/baremetal.txt
ATA_BASE equ 0x01F0
;; Probes for an IDE Drive
ide32_detect:
	pushad
	mov dx, ATA_BASE
	add dx, 7
	in al, dx
	;; Do we have an IDE controller :)
	cmp al, 0xFF
	;; No? Error out.
	je .error_hdd_detect
	;; Yes. Are any error bits set
	test al, 0xA9
	jne .error_hdd_detect
	clc
	popad
	ret
.error_hdd_detect:
	stc
	popad
	ret
;; Read Sectors - Reads Sectors into memory
;; IN : EAX - Starting Sector to Read
;;      ECX - Number of Sectors to Read
;;		EDI - Buffer to read into
;; OUT: Sector read in memory
;; 	    If Yes, Carry set
;;		If no, then no carry
readsector32:
	PUSH_GPR
	push ecx
	mov ebx, ecx
	cmp ecx, 0
	je .fail
	cmp ecx, 256
	jg .fail
	jne .continue
	xor ecx, ecx
.continue:
	push eax
	mov dx, ATA_BASE
	add dx, 2
	mov al, cl
	out dx, al
	pop eax
	inc dx
	out dx, al
	inc dx
	shr eax, 8
	out dx, al
	inc dx
	shr eax, 8
	out dx, al
	inc dx
	shr eax, 8
	and al, 00001111b
	or al, 01000000b
	out dx, al
	inc dx
	mov al, 0x20
	out dx, al
	mov ecx, 4
.ata_wait:
	in al, dx
	test al, 0x80
	jne .ata_retry
	test al, 0x08
	jne .ata_data_ready
.ata_retry:
	dec ecx
	jg .ata_wait
.next_sector:
	in al, dx
	test al, 0x80
	jne .next_sector
	test al, 0x21
	jne .fail
.ata_data_ready:
	sub dx, 7
	mov ecx, 256
	rep insw
	add dx, 7
	IN32_4
	dec ebx
	cmp ebx, 0
	jne .next_sector
	test al, 0x21
	jne .fail
	POP_GPR_EAX_ECX
	SET_CARRY_RETURN
.fail:
	pop ecx
	pop eax
	pop ebx
	pop ecx
	pop edx
	mov ecx, 0
	CLEAR_CARRY_RETURN
;; write sectors
writesector32:
	push edx
	push ecx
	push ebx
	push eax
	push ecx		
	mov ebx, ecx	
	cmp ecx, 256
	jg .fail	
	jne .continue	
	xor ecx, ecx	
.continue:
	push eax		
	mov dx, 0x01F2		
	mov al, cl		
	out dx, al
	pop eax		
	inc dx			
	out dx, al
	inc dx			
	shr eax, 8
	out dx, al
	inc dx		
	shr eax, 8
	out dx, al
	inc dx		
	shr eax, 8	
	and al, 00001111b 
	or al, 01000000b	
	out dx, al
	inc dx		
	mov al, 0x30	
	out dx, al
	mov ecx, 4
.ATA_WAIT:
	in al, dx		
	test al, 0x80		
	jne .ATA_RETRY
	test al, 0x08		
	jne .ATA_DATA_READY
.ATA_RETRY:
	dec ecx
	jg .ATA_WAIT
.ATA_NEXT_SECTOR:
	in al, dx		
	test al, 0x80	
	jne .ATA_NEXT_SECTOR
	test al, 0x21		
	jne .fail
.ATA_DATA_READY:
	sub dx, 7	
	mov ecx, 256		
.ATA_NEXT_WORD:
	outsw		
	sub ecx, 1
	cmp ecx, 0
	jne .ATA_NEXT_WORD
	add dx, 7		
	mov al, 0xE7	
	out dx, al
	in al, dx		
	in al, dx
	in al, dx
	in al, dx
	dec ebx			
	cmp ebx, 0
	jne .ATA_NEXT_SECTOR
	pop ecx
	pop eax
	pop ebx
	add eax, ecx
	pop ecx
	pop edx
	ret
.fail:
	pop ecx
	pop eax
	pop ebx
	pop ecx
	pop edx
	xor ecx, ecx	
	ret
	