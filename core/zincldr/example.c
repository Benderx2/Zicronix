/*
	Example for Zicronix C->BIOS Interface.
	Compile with SmallerC - https://github.com/alexfru/SmallerC/
	smlrc -seg16 -no-externs -I /include/ example.c example.bin
*/
#include <loader.h>
#include <io.h>
#include <vbe.h>
#include <serial.h>
#include <screen.h>
#include <stdbool.h>
#include <x86.h>
int main(void)
{
	//! VBE Structure at 0x9000
	VBEModeInfoBlock_t *VbeModeInfo = 0x9000;
	vga_gfxmode(VGA_640x480x256);
	printf("\nVGA 0x12 Mode Set, Reading VBE Information now......");
	VBEGetModeInformation(0x4112, VbeModeInfo);
	settextcolor(0x02);
	printf("\nVBE Mode Infomation Block for: %d", 0x4101);
	settextcolor(0x04);
	printf("\nVBE Mode X resolution: %d", VbeModeInfo->XResolution);
	printf("\nVBE Mode Y resolution: %d", VbeModeInfo->YResolution);
	settextcolor(0x08);
	printf("\nVBE Mode FrameBuffer Address: %d", VbeModeInfo->PhysBasePtr);
	settextcolor(0x0B);
	printf("\nVBE Mode Color Depth: %d", VbeModeInfo->BitsPerPixel);
	settextcolor(0x0F);
	printf("\nVBE Window Attributes: %d", VbeModeInfo->WinAAttributes);
	serial_output = true;
	int n1, n2, i, j;
	int count;
	n1 = 0;
	n2 = 100;
	bool flag = false;
	printf("\nPrime Number from 0 to %d", n2, '\n');
	for(i = n1 + 1; i < n2; ++i)
		{
			flag = false;
				for(j = 2; j <= i / 2; ++j)
					{
						if(i%j == 0)
							{
								flag = true;
								break;
							}
					}
						if(flag == false)
							{
								printf("%d ",i);
								count++;
							}
		}
	while(1)
	{
		uint8_t c;
		c = getch();
		putchar(en_US_Keyboard[c]);
	}
	printf("[ENTER] Pressed.");
	
	halt();
}