use32
init_sse:
	;; initialize sse.
	;; check
	mov esi, SSE_MSG
	call printf32
	mov eax, 0x1
	cpuid
    bt edx, 25
	jnc .noSSE
	call print_ok
	;; enable sse
	;; by setting CR4.OSXMMEXCPT and CR4.OSFXSR
	mov ecx, cr0
	btr ecx, 2	; clear CR0.EM bit
	bts ecx, 1	; set CR0.MP bit
	mov cr0, ecx

	mov ecx, cr4
	bts ecx, 9	; set CR4.OSFXSR bit
	bts ecx, 10	; set CR4.OSXMMEXCPT bit
	mov cr4, ecx
	mov byte [SSE_OK], 1
	ret
.noSSE:
	mov byte [SSE_OK], 0
	mov esi, NO_SSE_MSG
	call printf32
	ret
	SSE_MSG db '[CPU0:]Streaming SIMD Extensions   ', 0
	NO_SSE_MSG: db 0x0A, '[NO SSE! THE TARGET DOES NOT SUPPORT SSE!] FAIL!', 0
	SSE_OK db 0