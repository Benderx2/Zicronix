void exit()
{
	// Leave the stack frame
	asm("leave");
	asm("xor eax, eax");
	asm("xor ebx, ebx");
	asm("int 0x50");
}
//! Abort the program
void abort()
{
	asm("leave");
	asm("xor eax, eax");
	asm("mov ebx, 'ERR '");
	asm("int 0x50");
}