// ZNU Lib
// SmallerC library for ZNU Application and programs
// (C) Bender, 2014-2015 under 2-clause BSD license
// GLOBAL.C - Contains functions that can be directly copy-pasted
// into your OS :)
/*
	strlen (String Length) implementation
*/
size_t strlen(const char *str)
{
    size_t retval;
    for(retval = 0; *str != '\0'; str++) retval++;
    return retval;
}
/*
	outportb (Out Byte) implmentation
*/
unsigned outportb(uint16_t port, uint8_t value)
{
	// Save DX
	asm("push EDX");
	// Save Accumulator
	asm("push EAX");
	// Set DX to to the port
	asm("mov dx, [ebp + 8]");
	// Set the first 8-bits (AL) to the value
	asm("mov al, [ebp + 16]");
	// Run the instruction
	asm("out dx, al");
	// POP out EAX/EDX
	asm("pop EAX");
	asm("pop EDX");
}
/*
	inportb - (In Byte) Implementation
*/
unsigned inportb(uint16_t port)
{
	// Save EDX
	asm("push EDX");
	// Clear EAX
	asm("xor eax, eax");
	// Set DX to port
	asm("mov dx, [ebp + 8]");
	// According to the C calling convention, 
	// if it's a byte it must be in AL, if it's
	// a word, it should be returned in AX
	// if it's a dword it should be in EAX,
	// if it's longer than that, EAX should contain
	// a pointer which points to the return value
	// Here AL will return the Value :)
	asm("in al, dx");
	// POP out EDX
	asm("pop edx");
}
void reverse(char *s)
{
   char *j;
   int i = strlen(s);

   strcpy(j,s);
   while (i-- >= 0)
      *(s++) = j[i];
   *s = '\0';
}

/* itoa()
* converts an integer into a string */
void itoa(int n, char *buffer, int base)
{
   char *ptr = buffer;
   int lowbit;

   base >>= 1;
   do
   {
      lowbit = n & 1;
      n = (n >> 1) & 32767;
      *ptr = ((n % base) << 1) + lowbit;
      if (*ptr < 10)
         *ptr +='0';
      else
         *ptr +=55;
      ++ptr;
   }
   while (n /= base);
   *ptr = '\0';
   reverse (buffer);   /* reverse string */
}
/*
	Strcpy Implementation
*/
void strcpy(char dest[], const char source[]) 
 {
	int i = 0;
    while (1) 
	{
      dest[i] = source[i];
      if (dest[i] == '\0') break;
      i++;
	}
 }
/*
	memcpy implementation
*/
void memcpy(void *dest, const void *src, size_t count)
{
    const char *sp = (const char *)src;
    char *dp = (char *)dest;
    while(count != 0) 
		{
			*dp++ = *sp++;
			count--;
		}
}
/*
	memset Implementation
*/
void memset(void *dest, char val, size_t count)
{
    char *temp = (char *)dest;
    while(count != 0)
	{
		*temp++ = val;
		count--;
	}
}
/*
	memset (Wide) implementation
*/
unsigned short memsetw(unsigned short *dest, unsigned short val, size_t count)
{
    unsigned short *temp = (unsigned short *)dest;
    while(count != 0)
	{
		*temp++ = val;
		 count--;
	}
}
/*
	isdigit
*/
int isdigit(int c)
{
	 return c >= '0' && c <= '9';
}
/*
	ATOI - Implmentation
*/
int atoi(char *p) 
{
		int k = 0;
		while (*p) {
        k = (k<<3)+(k<<1)+(*p)-'0';
        p++;
     }
     return k;
}