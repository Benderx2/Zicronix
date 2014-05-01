// ZNU Lib
// SmallerC library for ZNU Application and programs
// (C) Bender, 2014-2015 under 2-clause BSD license
// Contains memory stuff
#define APPLICATION_HEAP_START 0x1A0000
#define MAX_ALLOC_SIZE 0xFFFFFFFF
unsigned int mem_32_start = 0;
unsigned int mem_32_end = 0;
unsigned int mem_32_count = 0;
int malloc(size_t length)
{
	// Check if we have increased the pointer too much
	if (mem_32_end >= MAX_ALLOC_SIZE)
	{
		// Return error
		return -1;
	}
	// Increase Length Pointer
	mem_32_count += length;
	// Increase End of Memory
	mem_32_end += mem_32_count + mem_32_start;
	// Return Success
	return 0;
}
unsigned int get_total_used_memory()
{
	// Returns total heap used by application
	return mem_32_count;
}
unsigned int get_memory_end()
{
	// Gets the end of usable heap
	return mem_32_end;
}
unsigned int get_mem_start()
{
	// Returns start of heap
	return mem_32_start;
}
/*!
	sbrk - increase data space
!*/
 caddr_t sbrk(int incr)
{
      char *heap_end;
      char *prev_heap_end;
     
      if (heap_end == 0) {
        heap_end = &_end;
      }
      prev_heap_end = heap_end;
      if (heap_end + incr > _stack_ptr)
        {
          printf(1, "Heap and stack collision\n", 25);
          abort();
        }

      heap_end += incr;
      return (caddr_t) prev_heap_end;
}
