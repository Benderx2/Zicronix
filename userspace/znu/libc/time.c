//! Time.c - Contains time and date BS.
void gettimeofday(unsigned char* buffer)
{
	asm("mov edi, [ebp + 8]");
	asm("mov ah, 0x20");
	asm("int 0x50");
}
void getdate(unsigned char* buffer)
{
	asm("mov edi, [ebp + 8]");
	asm("mov ah, 0x21");
	asm("int 0x50");
}