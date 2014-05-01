// ZNU Lib
// SmallerC library for ZNU Application and programs
// (C) Bender, 2014-2015 under 2-clause BSD license
//! TODO: Support Write File Functions!
/*
	Zicronix Load File
*/
void read(unsigned char* file_name, unsigned int* file_location)
{
	asm("push eax");
	asm("mov ah, 0x03");
	asm("mov esi, [ebp + 8]");
	asm("mov edi, [ebp + 12]");
	asm("int 0x50");
	asm("pop eax");
}
void write(unsigned int* file_name, unsigned int* file_location, unsigned int bytes)
{
	asm("mov dh, 0x08");
	asm("mov edi, [ebp + 8]");
	asm("mov esi, [ebp + 12]");
	asm("mov ecx, [ebp + 16]");
	asm("int 0x31");
}
/*
	Zicronix File Query
*/
unsigned file_query(unsigned char* file_name, unsigned char* result)
{
	asm("push esi");
	asm("mov ah, 0x04");
	asm("mov esi, [ebp + 8]");
	asm("int 0x50");
	asm("jnc .ok");
	asm("jmp .error");
	asm(".error: ");
	asm("mov edi, [ebp + 16]");
	asm("mov al, 1");
	asm("stosb");
	asm("pop esi");
	asm("leave");
	asm("ret");
	asm(".ok: ");
	asm("mov edi, [ebp + 16]");
	asm("mov al, 0");
	asm("stosb");
	asm("pop esi");
}