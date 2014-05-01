//!ZNU Lib
//! SmallerC library for ZNU Application and programs
//! (C) Bender, 2014-2015 under 2-clause BSD license
/*!	
	Zicronix is Not UN*X, (or ZNU Kernel) loads file at 4MB,
	with the header 'ZNUX'
!*/
//! Some really obivious BS.
#define true 1
#define false 0
#define BASE_10 10
#define BASE_16 16
// Some Type Defs :)
typedef unsigned int size_t;
typedef unsigned int uint32_t;
typedef int sint32_t;
typedef unsigned short uint16_t;
typedef short sint16_t;
typedef unsigned char uint8_t;
typedef char sint8_t;
typedef void* caddr_t;
typedef unsigned int bool;
typedef char* string;
typedef struct 
{
	uint8_t hour;
	uint8_t minute;
	uint8_t second;
} time_t;
//! Some symbols that need to be told
extern int* _end;
extern int* _start;
extern int* _stack_ptr;
extern int* ___APPLICATION_SIZE;
extern int* ___AUTHOR_NAME;
extern uint8_t* ___KERNEL_VER;
//! Arguments!
extern uint32_t* _args;
//! Include file headers
asm("%include \"..\\znu\\libc\\zef.s\"");
#include "..\\znu\\libc\\video.c"
#include "..\\znu\\libc\\file.c"
#include "..\\znu\\libc\\pci.c"
#include "..\\znu\\libc\\znu.c"
#include "..\\znu\\libc\\global.c"
#include "..\\znu\\libc\\memory.c"
#include "..\\znu\\libc\\x86.c"
#include "..\\znu\\libc\\keyboard.c"
#include "..\\znu\\libc\\stdio.c"
#include "..\\znu\\libc\\time.c"
asm("__stack_ptr dd 0x00000000");