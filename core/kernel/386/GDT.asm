; Contains the 386 GDT
;; Okay,
;; Before reading the code or copying it I would 
;; first like to have a talk. ;).
;; Get a cup of coffee and sit down.
;; Now you may be wondering what does GDT mean?
;; You might have seen me telling a lot of times
;; "Load the GDT", "Compute the Linear address of GDT" etc.
;; Well let's get back to 8086 and Real Mode. How was memory
;; addressed? We used segments, Those ugly faeces? 64kB?
;; Now since you know that these segments were limited
;; to 64KB, hence the 8086 could hold a maximum value
;; of 0xFFFF, and therefore the maximum memory addressable was 
;; 1MB, and the max address was 0xFFFF:0xFFFF.
;; Well there was a problem.
;; It was segment wraparounds.
;; Remember how we convert Segment:Offset addressing to Physical Memory
;; addressing?
;; segment * 0x10 (or 16d) + Offset
;; Well, if we wanna convert 0x0000:0x7C00 to linear memory it should be:
;; 0x0000 * 0x10 + 0x7C00 = 0x7C00
;; And, 
;; 0009:7B70 = 0x7C00
;; See the problem? 
;; If we are:
;; mov ax, 0x0009
;; mov es, ax
;; mov di, 0x7B70
;; mov byte [es:di], 0x0F
;; This will write 0x0F to 0x7C00
;; And,
;; mov ax, 0x0000
;; mov es, ax
;; mov di, 0x7B70
;; mov byte [es:di], 0x0F
;; THIS WILL ALSO WRITE 0x0F TO 0x7C00!
;; And now we've the risk of overwriting memory locations. Even if we think
;; 0000:7C00 is safe if we're using 0009:7B70, it's actually not as they both
;; correspond to the same physical memory location. :(
;; For these reasons Intel 80386 defined the Protected Mode, 
;; which contained the "Global Descriptor Tables" (The glorious GDT) 
;; which defines the Memory Layout :)
;; Onto the GDT now.
;; Each Entry in the GDT Looks like This:
;; LIMIT_LOW - Limit of the GDT
;; BASE_LOW - Lower Base of The GDT
;; BASE_MIDDLE 
;; ACCESS_LEVEL (0 = Kernel Mode, 3 = Userspace)
;; GRANULARITY
;; BASE_HIGH
;; Each Entry is 8 bytes wide.
;; I got this from Brokenthron.com it gives quite a good explaination
;; of the ACCESS_LEVEL byte which I wanna discuss
;; 10010010b - ACCESS_LEVEL
;=============================================================
; Bit 0:
; (Bit 40 in GDT): Access bit(Used with Virtual Memory).Because we don't 
; use virtual memory (Yet, anyway), we will ignore it. Hence, it is 0
;=============================================================
; Bit 1 :
; (Bit 41 in GDT): is the readable/writable bit. 
; Its set (for code selector), so we can read and execute 
; data in the segment (From 0x0 through 0xFFFF) as code
;=============================================================
; Bit 2:
; (Bit 42 in GDT): is the "expansion direction" bit. 
; We will look more at this later. For now, ignore it.
;=============================================================
; Bit 3:
; (Bit 43 in GDT): tells the processor this is a code or 
; data descriptor. (It is set, so we have a code descriptor)
;=============================================================
; Bit 4:
; (Bit 44 in GDT): Represents this as a "system" or "code/data" descriptor. 
; This is a code selector, so the bit is set to 1.
;=============================================================
; Bits 5-6:
; (Bits 45-46 in GDT): is the privilege level (i.e., Ring 0 or Ring 3). 
; We are in ring 0, so both bits are 0.
;=============================================================
; Bit 7 (Bit 47 in GDT): Used to indicate the segment is in memory 
; (Used with virtual memory). 
; Set to zero for now, since we are not using virtual memory yet
;=============================================================
align 4                                                  
GDT32:
;; Segment 0x00 - Null Segment					                
	.FIRST: times 2 dw ?				                  
	.SECOND: times 4 db ?                                   			   
.LINEAR_SEL:
	;; Segment 0x08 - LINEAR READ/WRITE DATA SEGMENT (FS)                                          
       dw 0xFFFF			                  
       dw 0		                                  		   
       db 0                                               
       db 10010010b	                                  		   
       db 11001111b	                                  			  
       db 0                                               
.CODE_SEL:
	;; Segment 0x10 - KERNEL CODE SEGMENT READ/EXECUTE (CS/DS/ES)
       dw 0xFFFF   			   
       dw 0                                               
       db 0                                               
       db 10011010b                                       
       db 11001111b                                       
       db 0                                                
.DATA_SEL:	
	;; Segment 0x18 - KERNEL DATA SEGMENT READ/WRITE (GS)
       dw 0xFFFF                                         
       dw 0                                               
       db 0                                               
       db 10010010b                                       
       db 11001111b                                       
       db 0                                                
.RM_CODE:	
	;; Segment 0x20 - REAL MODE CODE SEGMENT READ/EXECUTE (REAL MODE DS/ES)
       dw 0xFFFF                                          
       dw 0		                                  			 
       db 0                                               
       db 10011010b		                          			  
       db 0		                                  				  
       db 0                                                
.RM_DATA:    
	;; Segment 0x28 - REAL MODE DATA SEGMENT READ/WRITE (FS/GS)
       dw 0xFFFF                                          
       dw 0	                                          				  
       db 0                                               
       db 10010010b                                       						  
       db 0	                                          				  
       db 0          
.END_OF_GDT:                                                  				   
	;; End of GDT
GDT_DESC:        
			 ;; The LGDT instruction expects the 
			 ;; pointer to gdt to contain the length of
			 ;; gdt - 1 and the offset of GDT itself
			 dw GDT32.END_OF_GDT - GDT32 - 1			    
		     dd GDT32				
