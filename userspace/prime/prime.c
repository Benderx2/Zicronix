#include "..\\znu\\libc\\znulib.h"
//! Prime application, shows an example of how to grab arguments, timer etc.
int z_main()
{
	int n1, n2, i, j, flag;
	int count;
	n1 = 0;
	n2 = 0;
	// convert it
	n2 = atoi(_args);
	// start the timer
	start_timer();
	printf("\nPrime Number from 0 to %d", n2);
	//! newline
	newline();
	for(i = n1 + 1; i < n2; ++i)
		{
			flag = 0;
				for(j=2; j<=i/2; ++j)
					{
						if(i%j==0)
							{
								flag=1;
								break;
							}
					}
						if(flag==0)
							{
								printf("%d ",i);
								count++;
							}
		}		
	//! Number of seconds*10
	int time = get_timer();
	printf("\nTime Taken = %d", time);
	printf("\nNumber of Primes %d", count);
	// Stop the timer
	stop_timer();
	exit();
}