// ZNU Lib
// SmallerC library for ZNU Application and programs
// (C) Bender, 2014-2015 under 2-clause BSD license
void idt_set_gate(unsigned int* isr_ptr, uint8_t isr_number)
{
	// Save Used Registers
	asm("push eax\n push edx");
	// Set EDX to pointer to interrupt Service
	asm("mov edx, [ebp + 8]");
	// Set AH = 0x02, function number
	asm("mov ah, 0x02");
	// Set AL to interrupt number
	asm("mov byte al, [ebp + 16]");
	// Call Kernel
	asm("int 0x30");
	// Return Used Registers
	asm("pop edx\npop eax");
}
// Disables All Exception Gates
void x86_disable_exception_gates()
{
	asm("cli");
}
// Enables all of them
void x86_enable_exception_gates()
{
	asm("sti");
}
/*!
	pit timer stuff
!*/
//! start timer
void start_timer()
{
	asm("mov ah, 0x23");
	asm("int 0x50");
}
//! end timer
void stop_timer()
{
	asm("mov ah, 0x24");
	asm("int 0x50");
}
//! get timer
int get_timer()
{
	asm("push ecx");
	asm("mov ah, 0x25");
	asm("int 0x50");
	asm("mov eax, ecx");
	asm("pop ecx");
}
//! sleep bs.
void sleep(uint32_t time)
{
	// Sleeps For Seconds*10 units
	asm("push ecx");
	asm("push eax");
	asm("mov ah, 0x17");
	asm("mov ecx, [ebp + 8]");
	asm("int 0x50");
	asm("pop eax");
	asm("pop ecx");
}
