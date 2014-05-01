// ZNU Lib
// SmallerC library for ZNU Application and programs
// (C) Bender, 2014-2015 under 2-clause BSD license
// Contains Keyboard Stuff
// Include Keyboard Assembly Abstraction
extern uint8_t ascii_value;
asm("%include \"..\\znu\\libc\\keyboard.s\"");
//! Some Keyboard defines
#define KEY_BACKSPACE 8
#define KEY_ESCAPE 0x011B
#define KEY_ENTER  0x1C0D
#define KEY_UP     0x4800
#define KEY_LEFT   0x4B00
#define KEY_RIGHT  0x4D00
#define KEY_DOWN   0x5000
uint8_t waitkey()
{
	// Call the Function
	asm("call wait_key");
	//! Return the values
	return ascii_value;
}
unsigned getch(void)
{
	// Call the get char function
	asm("call get_char");
}
// Run the Kernel's Keyboard Interrupt to grab values
uint16_t run_kbd_interrupt()
{
	asm("xor eax, eax");
	asm("call get_kbd_status");
}
// Grab the scan code
uint8_t get_scan_code()
{
	run_kbd_interrupt();
	asm("mov byte al, [scan_code]");
}
// Grab a string from user - UNDER CONSTRUCTION!!!
unsigned char getstr(unsigned char* buffer)
{
	// Declare a buffer
	unsigned char internal_buffer[256];
	uint8_t scan_code = 0x00;
	while(scan_code != KEY_ENTER)
	{
		scan_code = getch();
		// Ignore non-printing characters
		if (scan_code > '~')
		{
			continue;
		}
		// Lesser than space?
		// Non-printing 
		if (scan_code < ' ')
		{
			continue;
		}
		else {
			printf(scan_code);
			//scan_code = *internal_buffer++;
			continue;
		}
	}
}
