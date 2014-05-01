#include "..\\znu\\libc\\znulib.h"
void z_main()
{
	/* Testing Write */
	printf("Writing 'Cool' to FILE.TXT'\n");
	char* buffer = "Cool";
	/* Showing how write functions work :D */
	write("FILE.TXT", buffer, 5 );
	printf("Number of bytes written: %d", 5);
	printf("\n");
	printf("Good Day Sir!");
	exit();
}