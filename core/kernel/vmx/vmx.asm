use32
DEFINE IA32_VMX_BASIC          0x480
DEFINE IA32_VMX_CR0_FIXED0     0x486
DEFINE IA32_VMX_CR0_FIXED1     0x487
DEFINE IA32_VMX_CR4_FIXED0     0x488
DEFINE IA32_VMX_CR4_FIXED1     0x489
VMX_BUF equ 0x6FD4A7
init_vmx:
	mov esi, VMX_INIT
	call printf32
	mov eax, 0x1
	cpuid
	bt ecx, 5
	jnc .vmx_error
	call print_ok
	mov byte [VMX_ON], 1
	mov eax, cr4
	;; enable CR4.VMXE
	bts eax, 13
	mov cr4, eax
	mov eax, cr0
	;; enable CR0.NE
	bts eax, 5
	;; enable CR0.PG
	bts eax, 31
	;; PE is already enable as we're in Protected Mode :)
	mov cr0, eax
	;; empty 4096 bytes for VMX_BUF
	mov edi, VMX_BUF
	mov al, 0
	mov ecx, 4096
	rep stosb
	;; VMXON! To make sure everthing is working
	vmxon [VMX_BUF]
	;; exit now
	vmxoff
	ret
.vmx_error:
	mov byte [VMX_ON], 0
	ret
VMX_INIT: db '[CPU0:]VMX Extensions              ', 0
VMX_ON db 0
;; VMX_READ_MSR
;; MSR Into EDX:EAX
macro VMX_READ_MSR MSR_CODE
{
	push ecx
	mov ecx, MSR_CODE
	rdmsr
	pop ecx
}
;; VMX_WRITE_MSR
macro VMX_WRITE_MSR LOW_BIT, HIGH_BIT, MSR_CODE
{
	push edx
	push ecx
	push eax
	mov edx, LOW_BIT
	mov eax, HIGH_BIT
	mov ecx, MSR_CODE
	wrmsr
	pop eax
	pop ecx
	pop edx
}
	
