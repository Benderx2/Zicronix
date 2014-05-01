// ZNU Lib
// SmallerC library for ZNU Application and programs
// (C) Bender, 2014-2015 under 2-clause BSD license
// This file mostly contains VGA and Video related stuff
// like printf, newline, set video modes, printchar etc.
//! Video Mode
extern void video_mode(int mode);
void prints(unsigned char* string)
{
	int count;
	for (count = 0; count < strlen(string); count++)
    {
        printc(string[count]);
    }
}
void printc(unsigned char c)
{
	// Check for Newline
	if (c == '\n')
	{
		newline();
	}
	// Else print it.
	else {
		asm("push eax");
		asm("mov ah, 0x06");
		asm("mov byte al, [ebp + 8]");
		asm("int 0x50");
		asm("pop eax");
	}
}
// Newline Function
void newline()
{
	asm("push eax");
	asm("mov ah, 0x06");
	asm("mov al, 0x0A");
	asm("int 0x50");
	asm("pop eax");
}
// Set text color
void set_text_color(unsigned int color)
{
	asm("push eax");
	asm("mov ah, 0x03");
	asm("mov al, byte [ebp + 8]");
	asm("int 0x30");
	asm("pop eax");
}
void getcursor()
{
	// Get the cursor position
	asm("call getcur_c");
}
void setcursor(unsigned int x, unsigned int y)
{
	asm("mov al, [ebp + 8]");
	asm("mov ah, [ebp + 16]");
	asm("mov byte [screen_x], al");
	asm("mov byte [screen_y], ah");
	asm("call movecursor32");
}
/*
	Draw Block
*/
void drawblock(uint8_t start_x, uint8_t start_y, uint8_t end_x, uint8_t end_y, uint8_t color)
{
	asm("mov ch, [ebp + 8]");
	asm("mov al, [ebp + 16]");
	asm("mov dh, [ebp + 24]");
	asm("mov dl, [ebp + 32]");
	asm("mov cl, [ebp + 40]");
	asm("mov ah, 0x22");
	asm("int 0x50");
}
asm("%include \"..\\znu\\libc\\video.s\"");
