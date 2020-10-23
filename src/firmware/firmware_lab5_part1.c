/*
    Created by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/

#include <stdint.h>

#define SHOW_IN_DISPLAYS 0x10000000
#define CACHE_ADDR       0x10000008
#define CACHE_DATA       0x1000000C
#define GET_MEMORY_ADDR  0x10000004

#define LOOP_WAIT_LIMIT 2000000 // Delay



/**/
static void putuint ( uint32_t ADDR, uint32_t DATA ) 
{
	*((volatile uint32_t *)ADDR) = DATA;
}



/**/
void Last_5_odd_numbers ()
{
	uint32_t DATA;
	uint32_t next_cache_addr = 4096;
	uint32_t ODDS [5] 		 = {0};
	uint32_t counter  		 = 0;
	uint32_t mask     		 = 1;

	
	/**/
	while ( next_cache_addr < 16384 )
	{
		/* Get the memory position values */
		*((volatile uint32_t *) GET_MEMORY_ADDR) = next_cache_addr;

		// Obtain the next memory address.
		next_cache_addr = *((volatile uint32_t *) CACHE_ADDR);//cache_addr);
		
		// Obtain the data.
		DATA = *((volatile uint32_t *) CACHE_DATA); //(cache_addr+4) );
		
		/**/
		if ( DATA & mask == 1 )
		{
			for ( uint32_t i=0; i<4; i++)
			{
				ODDS [4-i] = ODDS[4-i-1];
			}// For end

			ODDS[0] = DATA;
		}

	}// While end


	/**/
	for ( uint32_t i=0; i<5; i++ )
	{
		putuint ( SHOW_IN_DISPLAYS, ODDS[4-i] ); 
		counter = 0;

		while (counter < LOOP_WAIT_LIMIT) {
			counter++;
		}

	}// For end

};




/**/
void main() {

	uint32_t cache_addr;	
	uint32_t data;
	uint32_t counter;

	cache_addr = 4096;
	data       = 0;

	/* Create the linked list */
	/* One less memory space, because the positionn 16384 is invalid */
	for ( uint32_t i=0; i<1536; i=i+1 )
	{
		putuint ( CACHE_ADDR, cache_addr );
		putuint ( CACHE_DATA, data );
					
		cache_addr = cache_addr + 8;
		data++;

	} 

	

	/**/
	while (1) 
	{
		Last_5_odd_numbers ();

		counter = 0;
		while (counter < LOOP_WAIT_LIMIT) {
			counter++;

		} //While end
	} //While end

} //Main end