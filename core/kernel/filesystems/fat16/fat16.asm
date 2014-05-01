;; Taken and based from ReturnInfinity's BareMetalOS
;; Copyright (C) 2008-2014 Return Infinity -- http://www.returninfinity.com
;; All rights reserved. 
;; Please see credits/baremetal.txt
;; I only modded it a little bit to support directories original credits
;; to the BareMetal guys.
;; FAT16 - Contains FAT16 Stuff.
ATA_BUFFER_2 equ 0x7E000
;; entry_exists - Check whether a FAT entry Exists.
;; AX = 0x0 if doesn't exist
;; ESI - should be the file name
;; Starting Cluster in AX, File Size in ECX
use32
entry_exists:    
	;; Push used GPRs
	push es
	push ds
	push esi
	push edi
	push edx
	push ebx
	;; Set proper selectors
	mov ax, 0x18
	mov ds, ax
	mov es, ax
	;; Clear DF
	cld
	;; Clear Carry 
	clc
	;; First sector of Current Directory, Calculated at HDD
	;; initialization..
	mov eax, [current_directory.offset]
	;; Add the Partition Offset, (REMEMBER! We're using an HDD 
	;; there are partitions on an HDD unlike an FDD, so 
	;; We need to add this value to EAX, ensuring that
	;; we're browsing the correct sector on the correct partition
	add eax, [BPB.fat_16_partition]
	;; Save Sector number
	mov edx, eax
.read_sector:
	;; Read the Sector in Memory
	mov edi, ATA_BUFFER_2
	;; Save EDI
	push edi
	;; Read one sector
	mov ecx, 1
	;; Call the routine
	call readsector32
	;; Carry Not Set = Read Fail
	jnc .fatal_read
	;; Restore EDI
	pop edi
	;; Each entry in FAT is 32 bytes, We have 512 bytes per sector.
	;; If we divide the bytes per sector by entry size, we will
	;; get the number of FAT entries in one sector, 
	;; which is 512/32 = 16
	mov ebx, 16
.next_fat_entry:
	;; This is a loop, we search through 16 entries 
	;; to find a match.
	;; End of entries?
	cmp byte [edi], 0x00
	je .fat16_NF
	;; FAT Name is limited to 11 bytes
	mov ecx, 11
	push esi
	repe cmpsb
	pop esi
	;; AX holds the starting cluster
	mov ax, [edi + 15]
	mov ecx, [edi + 17]
	;; If REPE CMPSB set the Equal Flag to 1
	;; then we've found it.
	je .fat16_F
	;; If not...
	add edi, 0x20
	and edi, -0x20
	dec ebx
	cmp ebx, 0
	jne .next_fat_entry
	;; If we reach here, that means we have browsed all the 16 entries
	;; in the sector loaded, time to load another one.
	add edx, 1
	mov eax, edx
	jmp .read_sector
.fat16_NF:
	;; Clear Carry
	clc
	;; Null out EAX
	xor eax, eax
.fat16_F:
	;; Set Carry
	cmp ax, 0x0000
	je .done
	stc
.done:
	pop ebx
	pop edx
	pop edi
	pop esi
	pop ds
	pop es
	ret
.fatal_read:
	mov esi, findfile_err_msg
	call printf32
	hlt
	jmp $
	findfile_err_msg db 0x0A, 'Error Reading Sector.', 0
;; Read Cluster - Reads a Cluster, edi - Buffer (Min : 32KB)
;; OUT : EAX Next Cluster, edi - Last Cluster Byte + 1
readcluster32:	
	push esi
	push edx
	push ecx
	push ebx
	;; Clear out the top 48-bits
	and eax, 0x0000FFFF
	;; Save Cluster
	mov ebx, eax
	cmp ax, 2
	;; Less than 2 Clusters? WTF?
	jl near .read_cluster_error
	;; Calculate LBA (Linear Block Addressing) address, 
	;; LBAAdd = cluster - 2 x size of cluster + start of fat16 data section
	;; Null out ECX
	xor ecx, ecx
	;; Set CL to number of sectors per cluster
	mov cl, byte [BPB.fat_16_sectors_per_cluster]
	;; Save it.
	push ecx
	;; Subtract 2 from AX
	sub ax, 2
	;; AX - 2 x (CL + CH)	
	imul cx
	;; Add FAT16 Data Start section
	add eax, dword [BPB.data_start]
	;; Add the partition offset to get the correct values
	add eax, [BPB.fat_16_partition]
	;; POP out ECX
	pop ecx
	;; Read Sectors
	call readsector32
	;; Calculate Next Cluster
	push edi
	mov edi, 0x7E000
	mov esi, edi
	push ebx
	shr ebx, 8
	movzx ax, byte [BPB.fat_16_reserved_sectors]
	add eax, [BPB.fat_16_partition]
	add eax, ebx
	mov ecx, 1
	call readsector32
	pop eax
	shl ebx, 8
	sub eax, ebx
	shl eax, 1
	add esi, eax
	lodsw
	pop edi
.done:
	pop ebx
	pop ecx
	pop edx
	pop esi
	ret
.read_cluster_error:
	pop ebx
	pop ecx
	pop edx
	pop esi
	ret
;; Load File 32 - Loads a file
;; EDI - Buffer
;; ESI - File Name (padded!)
loadfile32:
	pushad
	call file_exists32
	cmp ax, 0x0000
	je .error
.ok:	
	call readcluster32
	cmp ax, 0xFFFF
	jne .ok
	clc
	popad
	ret
.error:
	stc
	popad
	ret
	.c_dir_clust dw 0
;; Get Dir List - Gets the List of Files on Disk
;; EDI - Pointer to Buffer
get_dir_list_32:
	pushad
	mov ebx, [current_directory.offset]
	add ebx, [BPB.fat_16_partition]
	jmp .read_sector
.next_sector:
	add ebx, 1
.read_sector:
	push edi
	mov edi, 0x7E000
	mov esi, edi
	mov ecx, 1
	mov eax, ebx
	call readsector32
	pop edi
.parse_info:
	;; End of sector
	cmp esi, [ATA_BUFFER + 512]
	je .next_sector
	;; End of everything?
	cmp byte [esi], 0x00000000
	je .done
	;; Deleted?
	cmp byte [esi], 0x000000E5
	je .skip
	;; Directory?
	mov al, [esi + 0xB]
	bt ax, 4
	jc .directory
	;; Volume Label?
	mov al, [esi + 8]
	bt ax, 5
	jc .skip
	;; Long File Name?
	mov al, [esi + 11]
	cmp al, 0x0F
	je .skip
	;; If not then let's parse it.
	mov ecx, 0x00000000
	mov eax, 0x00000000
.copy_file_name:
	mov al, [esi + ecx]
	cmp al, 0
	je .extension
	;; Else Copy it
	inc ecx
	cmp ecx, 9
	je .extension
	cmp al, ' '
	je .copy_file_name
	stosb
	jmp .copy_file_name
.extension:
	;; Store the '.' as a separator
	mov al, '.'
	stosb
	mov al, [esi+8]
	stosb
	mov al, [esi+9]
	stosb
	mov al, [esi+10]
	stosb
	;mov al, [esi + 11]
	;stosb
	mov al, ' '
	stosb
	mov al, ' '
	stosb
	jmp .skip
.directory:
	xor ecx, ecx
	mov ah, 0x00
.loop:
	mov al, [esi + ecx]
	cmp al, ' '
	je .add_slash
	cmp al, 0 
	je .add_slash
	;; Else Copy it
	inc ecx
	stosb
	cmp ecx, 11
	jl .loop
	jmp .add_slash
.add_slash:
	mov al, '/'
	stosb
	;; Add a <DIR>
	;mov al, ' '
	;stosb
	;mov al, '<'
	;stosb
	;mov al, 'D'
	;stosb
	;mov al, 'I'
	;stosb
	;mov al, 'R'
	;stosb
;	mov al, '>'
	;stosb
	;mov al, 0x0A
	;stosb
	mov al, ' '
	stosb
	mov al, ' '
	stosb
	jmp .skip
.skip:
	add esi, 32
	jmp .parse_info
.done:
	mov al, 0x00
	stosb
	popad
	ret
;; EAX - File Name
;; Converts the 'TEST.TXT' to FAT formatted 'TEST    TXT'
;; Based upon MikeOS's FAT Convert.
;; Re-Commented and converted to FASM 32-bit syntax by Bender (me!)
file_convert:
	pushad
	;; Grab the length of the String
	mov esi, eax
	call strlen
	;; If it's greater than 14, 
	cmp eax, 14			
	jg .fat_convert_fail			
	;; NULL? WTF?
	cmp eax, 0
	;; Fail.
	je .fat_convert_fail	
	;; Save a copy of string length
	;; for later uses
	mov edx, eax	
	;; We will use STOSB,
	;; therefore DS:EDI should point to Destination
	;; string
	mov edi, FAT.converted_file_name
	;; Null out ECX, this will be used for checking
	mov ecx, 0
.get_dot_extension:
	;; Get one byte of source string (ESI) into al
	lodsb
	;; Cool. We found a dot, this means that 
	;; the extension, is the next three bytes
	cmp al, '.'
	je .dot_found
	;; Else copy AL into EDI
	stosb
	;; Increment the character counter
	inc ecx
	;; EDX was the length, did we reach the end
	;; and found no dot?
	cmp ecx, edx
	;; Fail.
	jg .fat_convert_fail			; No extension found = wrong
	jmp .get_dot_extension
.dot_found:
	;; Dot at the start of the string?
	cmp ecx, 0
	;; Impossible file name, fail.
	je .fat_convert_fail	
	;; Dot after 8 charcters?
	;; Well it's something like : FILENAME.TXT which
	;; converted equals FILENAMETXT
	;; We just need to remove the dot, and everything's
	;; done, no need for spaces.
	cmp ecx, 8
	je .add_extension
	;; Maybe not, well add spaces
.add_spaces:
	;; Keep adding spaces, 
	;; into edi.
	mov byte [edi], ' '
	;; Increment the Destination String
	inc edi
	;; Increment the counter
	inc ecx
	;; Remember! A FAT file name is 8 bytes + extension 3 bytes
	;; So we need to keep adding spaces in the file name until
	;; we reach the 8th byte, after which the extension is put.
	cmp ecx, 8
	;; If lower than 8 keep adding
	jl .add_spaces
.add_extension:
	;; Grab a character from ESI into AL
	lodsb				
	cmp al, 0
	;; if AL = 0, then it means that the file has no extension.
	je .no_ext
	stosb
	;; Get the second character into AL
	lodsb
	cmp al, 0
	;; only one extension BAD.
	je .only_1_ext
	;; Copy the second character
	stosb
	;; The last character
	lodsb
	cmp al, 0
	je .only_2_ext
	;; Copy it.
	stosb
	;; Zero Terminate it.
	mov byte [edi], 0
	;; Restore registers
	popad
.ok:	
	;; Set EAX to our converted string
	mov eax, FAT.converted_file_name
	;; Clear Carry (Indicating success)
	clc				
	;; Return
	ret
.fat_convert_fail:
	;; Restore Registers
	popad
	;; Set Carry (Indicating Failure)
	stc				
	;; Return
	ret
.no_ext:
	mov al, ' '
	stosb
	stosb
	stosb
	popad
	jmp .ok
.only_1_ext:
	mov al, ' '
	stosb
	stosb
	popad
	jmp .ok
.only_2_ext:
	mov al, ' '
	stosb
	popad
	jmp .ok
	FAT.converted_file_name:	times 20 db 0
;; Convert a directory name into FAT formatted.
;; Directory should be zero terminated.
;; in EAX
dir_convert:
	pushad
	mov esi, eax
	call strlen
	;; 11 already?
	cmp eax, 11
	;; No need for conveesion
	je .bailout
	;; Save a copy of length
	mov edx, eax
	;; If it's less than 11, well we need to
	;; add some spaces
	;; Subtract EAX from 11
	mov ecx, 11
	sub ecx, eax
	;; EDI should point to our string
	mov edi, FAT.Directory_String
.get_end_of_name:
	;; Okay we will use EDX as a counter
	;; ESI pointed to the original string,
	;; Grab a byte into AL
	mov byte al, [esi]
	;; Copy it into EDI
	mov byte [edi], al
	;; Next Destination
	inc edi
	;; Next.
	inc esi
	;; Decrement EDX
	dec edx
	;; All the characters in place? :D
	cmp edx, 0x00000000
	jne .get_end_of_name
.loop:
	;; ECX contains the number of spaces to add
	;; Add a space
	mov byte [edi], ' '
	inc edi
	;; Decrement counter
	dec ecx
	;; ECX == 0? Enough spaces.
	cmp ecx, 0
	jne .loop
	;; If ECX is 0, null terminate string
	mov byte [edi], 0
	;; Pop Registers
	popad 
	;; Set EAX to converted string
	mov eax, FAT.Directory_String
	;; Done
	jmp .done
.bailout:
	popad
.done:
	ret

	FAT.Directory_String: times 13 db 0
;; Change to a Directory.
;; IN : EAX - Name of Directory
;; OUT: CF on Ok, or current_directory.offset set to the new
;; directory
chdir:
	pushad	
	clc
	call dir_convert
	mov esi, eax
	xor eax, eax
	;; Query for existence of directory
	;; and it's starting cluster
	call entry_exists
	;; Good it exists
	cmp ax, 0x0000
	jne .ok
	;; Maybe not, clear carry and bailout
	clc
	jmp .done
.ok:
	;; Save the cluster, we may use it later
	mov word [current_directory.cluster], ax
	;; AX contains starting cluster, now we need to calculate
	;; the first sector of the cluster
	;; Subtract 2 from
	;; ax
	sub ax, 2
	xor ecx, ecx
	mov cl, byte [BPB.fat_16_sectors_per_cluster]
	;; EAX now holds starting sector of cluster
	imul cx
	;; Add Data Start region to the 
	;; Formula:
	;; DataRegion + ((N - 2) * SectorsPerCluster)
	add eax, [BPB.data_start]
	;; Cool now, EAX contains the starting sector
	;; of the sub-directory :D
	;; Update Values.
	mov dword [current_directory.offset], eax
	;; Set Carry Sucessful
	stc
.done:
	popad
	ret
;; Current Directory Variable
current_directory:
	.offset dd 0x00000000
	.cluster dw 0x00000
	.save_0 dd 0x00000000
	.save_1 dd 0x00000000
	.save_2 dd 0x00000000
	.save_3 dd 0x00000000

;; FAT16 Write Routines.
;; Write Cluster 
;; IN: AX - Cluster to Write, ESI - Memory Location
;; OUT: AX = Next Cluster, ESI = Last byte written + 1
writecluster32:
	push edi
	push edx
	push ecx
	push ebx
	and eax, 0x0000FFFF		
	mov ebx, eax				
	cmp ax, 2				
	jl near .bailout	
	xor ecx, ecx	
	mov cl, byte [BPB.fat_16_sectors_per_cluster]
	push ecx			
	sub ax, 2
	imul cx				
	add eax, dword [BPB.data_start]	
	add eax, [BPB.fat_16_partition]
	pop ecx					
	call writesector32
; Calculate the next cluster
	push esi
	mov edi, 0x700000			
	mov esi, edi			
	push ebx			
	shr ebx, 8				
	mov ax,  [BPB.fat_16_reserved_sectors]
	add eax, [BPB.fat_16_partition]	
	add eax, ebx			
	mov ecx, 1
	call readsector32
	pop eax					
	shl ebx, 8			
	sub eax, ebx			
	shl eax, 1			
	add esi, eax
	lodsw					
	pop esi
	jmp .done
.bailout:
	xor ax, ax
.done:
	pop ebx
	pop ecx
	pop edx
	pop edi
	ret
	

createfile32:	
	push esi
	push edi
	push edx
	push ecx
	push ebx
	push eax
	clc	
	;; Does the file exist?
	push ecx
	call entry_exists
	pop ecx
	;; no!
	cmp ax, 0x0000
	je .ok
	;; If it exists bailout
	jmp .fail
.ok:
	mov [filesize], ecx	
	mov [filename], esi
	mov eax, ecx
	xor edx, edx
	xor ebx, ebx
	mov bl, byte [BPB.fat_16_sectors_per_cluster]
	shl ebx, 9		
	div ebx
	cmp edx, 0
	jg .add_cluster			
	jmp .continue
.add_cluster:
	add eax, 1
.continue:
	mov ecx, eax		
	xor eax, eax
	mov ax, [BPB.fat_16_reserved_sectors]	
	add eax, [BPB.fat_16_partition]	
	mov edi, ATA_BUFFER
	mov esi, edi
	push ecx
	mov ecx, 64
	call readsector32
	pop ecx
	xor edx, edx			
	xor ebx, ebx			
.find_free_cluster:
	mov edi, esi
	lodsw
	inc dx				
	cmp ax, 0x0000
	jne .find_free_cluster		
	dec dx
	mov [startcluster], dx		
	inc dx
	mov bx, dx
	cmp ecx, 0
	je .find_cluster_done
	cmp ecx, 1
	je .find_cluster_done
.find_next_free_cluster:
	lodsw
	inc dx
	cmp ax, 0x0000
	jne .find_next_free_cluster
	mov ax, bx
	mov bx, dx
	stosw
	mov edi, esi
	sub edi, 2
	dec ecx
	cmp ecx, 1
	jne .find_next_free_cluster
.find_cluster_done:
	mov ax, 0xFFFF
	stosw
	xor eax, eax
	mov eax, [current_directory.offset]	
	add eax, [BPB.fat_16_partition]	
	mov edi, 0x7E000
	push edi
	mov ecx, 1
	call readsector32
	pop edi
	mov ecx, 16		
	mov esi, edi
.next:
	sub ecx, 1
	cmp byte [esi], 0x00	
	je .found_free_entry
	cmp byte [esi], 0xE5	
	je .found_free_entry
	add esi, 32		
	cmp ecx, 0
	je .fail
	jmp .next
.found_free_entry:
	mov edi, esi
	mov esi, [filename]
	mov ecx, 11
.set_atrrib:
	lodsb
	stosb
	sub ecx, 1
	cmp ecx, 0
	jne .set_atrrib
	xor eax, eax
	stosb	; LFN Attrib
	stosb	; NT Reserved
	stosw	; Create time
	stosb	; Create time
	stosw	; Create date
	stosw	; Access date
	stosw	; Access time
	stosw	; Modified time
	stosw	; Modified date
	mov ax, [startcluster]
	stosw
	mov eax, [filesize]
	stosd	; File size
	xor eax, eax
	movzx ax, byte [BPB.fat_16_reserved_sectors]	
	add eax, [BPB.fat_16_partition]	
	mov esi, ATA_BUFFER
	mov ecx, 64
	call writesector32
	mov eax, [current_directory.offset]	
	add eax, [BPB.fat_16_partition]	
	mov esi, 0x7E000
	mov ecx, 1
	call writesector32
	jmp .done
.fail:
	stc
.done:
	pop eax
	pop ebx
	pop ecx
	pop edx
	pop edi
	pop esi
	ret
	startcluster	dw 0x0000
	filesize	dd 0x00000000
	filename	dd 0x0000000000000000
;; Remove an entry
;; ESI - Entry
rm_entry:
	push esi
	push edi
	push edx
	push ecx
	push ebx
	clc				
	xor eax, eax
	mov eax, [current_directory.offset]
	add eax, [BPB.fat_16_partition]
	mov edx, eax			
.read_sector:
	mov edi, ATA_BUFFER
	push edi
	mov ecx, 1
	call readsector32
	pop edi
	mov ebx, 16			
.next_entry:
	cmp byte [edi], 0x00		
	je .error
	mov ecx, 11
	push esi
	repe cmpsb
	pop esi
	mov ax, [edi+15]		
	jz .entry_found
	add edi, 0x20	
	and edi, -0x20	
	dec ebx
	cmp ebx, 0
	jne .next_entry
	add edx, 1	
	mov eax, edx
	jmp .read_sector
.entry_found:
	xor ebx, ebx
	mov bx, ax		
	stosb
	mov esi, ATA_BUFFER
	mov eax, edx		
	and edi, -0x20		
	mov al, 0xE5		
	mov ecx, 1
	call writesector32
	xor eax, eax
	mov ax, [BPB.fat_16_reserved_sectors]	
	add eax, [BPB.fat_16_partition]
	mov edx, eax			
	mov edi, 0x7E000
	mov esi, edi
	mov ecx, 1
	call readsector32
	xor eax, eax
.next_cluster:
	shl ebx, 1
	mov ax, word [esi+ebx]
	mov [esi+ebx], word 0x0000
	mov bx, ax
	cmp ax, 0xFFFF - 1
	jne .next_cluster
	cmp ax, 0xFFFF
	jne .next_cluster
	mov eax, edx	
	mov ecx, 1
	call writesector32
	jmp .done
.error:
	stc				; Set carry
	xor eax, eax
.done:
	pop ebx
	pop ecx
	pop edx
	pop edi
	pop esi
	ret
;; Write file 
;; Write to a file
;; IN : ESI - Buffer to write from
;;		EDI - File Name
;; 	    ECX - Number of bytes to write
;; 	
writefile32:
	;; Push GPRs
	push esi
	push edi
	push ecx
	push eax
	;; Save memory address
	mov dword [mem_addr], esi
	;; And file name
	mov dword [file_name], edi
	;; Set ESI to file name
	mov esi, edi
	;; Does it exist?
	push ecx
	call entry_exists
	pop ecx
	cmp ax, 0x0000
	;; It doesn't no need to delete it.
	je .createfile
	;; Or delete it.
	call rm_file
.createfile:
	mov esi, [file_name]
	call createfile32
	;; Grab starting cluster
	call entry_exists
	mov esi, [mem_addr]
;; Now write to file
.write_to_file:
	call writecluster32
	cmp ax, 0xFFFF
	jne .write_to_file
.done:
	clc
	pop eax
	pop ecx
	pop edi
	pop esi
	ret
	mem_addr dd 0x00000000
	file_name dd 0x00000000
;; Remove a file :)
rm_file:
	push esi
	push edi
	push edx
	push ecx
	push ebx
	clc				
	xor eax, eax
	;; Cool, now better shut up and set EAX to
	;; our 
	mov eax, [current_directory.offset]
	add eax, [BPB.fat_16_partition]
	mov edx, eax			
.read_sector:
	mov edi, ATA_BUFFER
	push edi
	mov ecx, 1
	call readsector32
	pop edi
	mov ebx, 16			
.next_entry:
	cmp byte [edi], 0x00		
	je .error
	mov ecx, 11
	push esi
	repe cmpsb
	pop esi
	mov ax, [edi+15]		
	jz .entry_found
	add edi, 0x20	
	and edi, -0x20	
	dec ebx
	cmp ebx, 0
	jne .next_entry
	add edx, 1	
	mov eax, edx
	jmp .read_sector
.entry_found:
	xor ebx, ebx
	mov bx, ax		
	and edi, -0x20		
	mov al, 0xE5		
	stosb
	mov esi, ATA_BUFFER
	mov eax, edx		
	mov ecx, 1
	call writesector32
	xor eax, eax
	mov ax, [BPB.fat_16_reserved_sectors]	
	add eax, [BPB.fat_16_partition]
	mov edx, eax			
	mov edi, 0x7E000
	mov esi, edi
	mov ecx, 1
	call readsector32
	xor eax, eax
.next_cluster:
	mov ax, bx
	mov esi, crap_loc
.clust_loop:
	call writecluster32
	cmp ax, 0xFFFF
	jne .clust_loop
	jmp .done
.error:
	stc				; Set carry
	xor eax, eax
.done:
	pop ebx
	pop ecx
	pop edx
	pop edi
	pop esi
	ret
mkdir32:	
	push esi
	push edi
	push edx
	push ecx
	push ebx
	push eax
	xor ecx, ecx
	;; Reserve 4096 (256 entries)
	mov ecx, 4096
	clc				
	mov [.dirname], esi
	mov eax, ecx
	xor edx, edx
	xor ebx, ebx
	mov bl, byte [BPB.fat_16_sectors_per_cluster]
	shl ebx, 9			
	div ebx
	cmp edx, 0
	jg .add_cluster			
	jmp .continue
.add_cluster:
	add eax, 1
.continue:
	mov ecx, eax		
	xor eax, eax
	mov ax, [BPB.fat_16_reserved_sectors]		
	add eax, [BPB.fat_16_partition]
	;mov eax, [current_directory.offset]
	mov edi, ATA_BUFFER
	mov esi, edi
	push ecx
	mov ecx, 64
	call readsector32
	pop ecx
	xor edx, edx			
	xor ebx, ebx			
.find_free_cluster:
	mov edi, esi
	lodsw
	inc dx				
	cmp ax, 0x0000
	jne .find_free_cluster		
	dec dx
	mov [.startcluster], dx		
	inc dx
	mov bx, dx
	cmp ecx, 0
	je .find_cluster_done
	cmp ecx, 1
	je .find_cluster_done
.find_next_free_cluster:
	lodsw
	inc dx
	cmp ax, 0x0000
	jne .find_next_free_cluster
	mov ax, bx
	mov bx, dx
	stosw
	mov edi, esi
	sub edi, 2
	dec ecx
	cmp ecx, 1
	jne .find_next_free_cluster
.find_cluster_done:
	mov ax, 0xFFFF
	stosw
	xor eax, eax
	mov eax, [current_directory.offset]	
	add eax, [BPB.fat_16_partition]
	mov edi, 0x7E000
	push edi
	mov ecx, 1
	call readsector32
	pop edi
	mov ecx, 16			
	mov esi, edi
.next:
	sub ecx, 1
	cmp byte [esi], 0x00	
	je .found_free_entry
	cmp byte [esi], 0xE5	
	je .found_free_entry
	add esi, 32		
	cmp ecx, 0
	je .fail
	jmp .next
.found_free_entry:
	mov edi, esi
	mov esi, [.dirname]
	mov ecx, 11
.set_atrrib:
	lodsb
	stosb
	sub ecx, 1
	cmp ecx, 0
	jne .set_atrrib
	xor eax, eax
	;; Set the attribute as a directory
	;; 
	push eax
	mov al, 0x00
	;; Set the 4th bit
	or al, 00010000b
	stosb	
	pop eax
	stosb	; NT Reserved
	stosw	; Create time
	stosb	; Create time
	stosw	; Create date
	stosw	; Access date
	stosw	; Access time
	stosw	; Modified time
	stosw	; Modified date
	mov ax, [.startcluster]
	stosw
	xor eax, eax
	movzx ax, byte [BPB.fat_16_reserved_sectors]
	add eax, [BPB.fat_16_partition]	
	mov esi, ATA_BUFFER
	mov ecx, 64
	call writesector32
	mov eax, [current_directory.offset]
	add eax, [BPB.fat_16_partition]	
	mov esi, 0x7E000
	mov ecx, 1
	call writesector32
	;; clear(or fck) crap clusters
.fck_clusters:
	mov esi, crap_loc
	mov ax, [.startcluster]
.fck_clusters_loop:
	call writecluster32
	cmp ax, 0xFFFF
	jne .fck_clusters_loop
	;; Okay now create a '..' and '.' entry
	jmp .create_dot_dot_entry
.fail:
	stc
	jmp .done_2
.create_dot_dot_entry:
	;; Save clusters, and offsets.
	mov eax, [current_directory.offset]
	mov [.cdir_offset], eax
	xor eax, eax
	mov ax, [current_directory.cluster]
	mov [.cdir_cluster], ax
	;; Now switch to the new directory
	mov eax, [.dirname]
	call chdir
	;; Create a '.' entry
	mov eax, _dot_only
	call dir_convert
	mov esi, eax
	mov ax, [current_directory.cluster]
	call mkdirpre
	;; Create a '..' entry
	mov eax, _dot_dot
	call dir_convert
	mov [.dot_dot_name], eax
	mov esi, eax
	mov ax, [.cdir_cluster]
	call mkdirpre
	xor eax, eax
	mov ax, [.cdir_cluster]
	mov [current_directory.cluster], ax
	xor eax, eax
	mov eax, [.cdir_offset]
	mov [current_directory.offset], eax
.done_2:
	pop eax
	pop ebx
	pop ecx
	pop edx
	pop edi
	pop esi
	ret
	.startcluster	dw 0x0000
	.dirnull	dd 0x00000000
	.dirname	dd 0x0000000000000000
	.cdir_offset dd 0x00000000
	.cdir_cluster dw 0x0000
	.dot_dot_name dd 0x000000000
	_dot_dot db '..', 0
	_dot_only db '.', 0
	.cluster_value dd 0x00000000
;; Create Entry with predefined cluster
;; IN : 
;; AX - Cluster
;; ESI - Name
mkdirpre:	
	push esi
	push edi
	push edx
	push ecx
	push ebx
	push eax
	clc				
	mov [.startcluster], ax		
	mov [.filename], esi
	mov eax, ecx
	xor edx, edx
	xor ebx, ebx
	mov bl, byte [BPB.fat_16_sectors_per_cluster]
	shl ebx, 9		
	div ebx
	cmp edx, 0
	jg .add_cluster		
	jmp .continue
.add_cluster:
	add eax, 1
.continue:
	mov ecx, eax		
	xor eax, eax
	mov ax, [BPB.fat_16_reserved_sectors]	
	add eax, [BPB.fat_16_partition]
	mov edi, ATA_BUFFER
	mov esi, edi
	push ecx
	mov ecx, 64
	call readsector32																																	
	pop ecx
	xor edx, edx			
	xor ebx, ebx				
.find_free_cluster:
	mov edi, esi
	lodsw
	inc dx				
	cmp ax, 0x0000
	jne .find_free_cluster		
	dec dx
	mov [.startcluster_2], dx		
	inc dx
	mov bx, dx
	cmp ecx, 0
	je .find_cluster_done
	cmp ecx, 1
	je .find_cluster_done
.find_next_free_cluster:
	lodsw
	inc dx
	cmp ax, 0x0000
	jne .find_next_free_cluster
	mov ax, bx
	mov bx, dx
	stosw
	mov edi, esi
	sub edi, 2
	dec ecx
	cmp ecx, 1
	jne .find_next_free_cluster
.find_cluster_done:
	mov ax, 0xFFFF
	stosw
	xor eax, eax
	mov eax, [current_directory.offset]	
	add eax, [BPB.fat_16_partition]	
	mov edi, 0x7E000
	push edi
	mov ecx, 1
	call readsector32
	pop edi
	mov ecx, 16			
	mov esi, edi
.next:
	sub ecx, 1
	cmp byte [esi], 0x00	
	je .found_free_entry
	cmp byte [esi], 0xE5		
	je .found_free_entry
	add esi, 32			
	cmp ecx, 0
	je .fail
	jmp .next
.found_free_entry:
	mov edi, esi
	mov esi, [.filename]
	mov ecx, 11
.set_atrrib:
	lodsb
	stosb
	sub ecx, 1
	cmp ecx, 0
	jne .set_atrrib
	xor eax, eax
	;; 
	push eax
	mov al, 0x00
	or al, 00010000b
	stosb
	pop eax
	stosb	; NT Reserved
	stosw	; Create time
	stosb	; Create time
	stosw	; Create date
	stosw	; Access date
	stosw	; Access time
	stosw	; Modified time
	stosw	; Modified date
	mov ax, [.startcluster]
	stosw
	xor eax, eax
	movzx ax, byte [BPB.fat_16_reserved_sectors]	
	add eax, [BPB.fat_16_partition]	
	mov esi, ATA_BUFFER
	mov ecx, 64
	call writesector32
	mov eax, [current_directory.offset]
	add eax, [BPB.fat_16_partition]
	mov esi, 0x7E000
	mov ecx, 1
	call writesector32
	jmp .done
.fail:
	stc
.done:
	pop eax
	pop ebx
	pop ecx
	pop edx
	pop edi
	pop esi
	xor eax, eax
	mov ax, [.startcluster]
	call itoa32
	mov esi, eax
	call printf32
	ret
	.startcluster_2 dw 0x00000
	.startcluster	dw 0x0000
	.filename	dd 0x000
	crap_loc:
	times 512 dd 0
	
	