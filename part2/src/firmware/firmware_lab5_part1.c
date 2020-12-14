/*
    Created by Jorge Munoz Taylor
    A53863
    Project 5
    Digital circuit laboratory I
    II-2020
*/

#include <stdint.h>

#define SHOW_IN_DISPLAYS 0x10000000 // Position used to show a number in the display.
#define LOOP_WAIT_LIMIT  3000000 // Delay


/* Its a simple delay timer */
void delay ()
{
	uint32_t counter = 0;

	while (counter < LOOP_WAIT_LIMIT) 
		counter++;	
}


/* Store a data in the position ADDR */
static void putuint ( uint32_t ADDR, uint32_t DATA ) 
{
	*((volatile uint32_t *)ADDR) = DATA;
}


/* Return the last 5 odd numbers */
uint32_t * Last_5_odd_numbers ()
{
	uint32_t DATA;
	uint32_t next_ram_addr = 0x10001000;
	uint32_t temp;
	uint32_t mask     	   = 1;
	static uint32_t ODDS [5];

	
	/* To read the memory is necesary wait 2 cycles, for that reason there is 2 memory calls  */
	while ( next_ram_addr != 0x10004000 )
	{
		DATA = *((volatile uint32_t *) (next_ram_addr+4) );
		DATA = *((volatile uint32_t *) (next_ram_addr+4) );
		
		temp = *((volatile uint32_t *) next_ram_addr );
		next_ram_addr = *((volatile uint32_t *) next_ram_addr );

		
		/**/
		if ( DATA & mask == 1 )
		{
			for ( uint32_t i=0; i<4; i++)
			{
				ODDS [4-i] = ODDS[3-i];
			}// For end

			ODDS[0] = DATA;
		}

	}// While end


	return ODDS;
};




/**/
void main() {

	uint32_t data; // Data that will be stored in the cache.
	uint32_t *ODDS; // Array of odd numbers.
		
	data = 0;

	/* Create the linked list */
	/* One less memory space, because the positionn 16384 is invalid */
	for ( uint32_t i=4096; i<16384; i=i+8 )
	{
		putuint ( 0x10000000+i, 0x10000000+i +8 );
		putuint ( 0x10000000+i +4, data );
		data++;
	} 


	/* Create the array with the last 5 odd numbers */
	ODDS = Last_5_odd_numbers();

	/* Infite loop that show the odd numbers in the displays */
	while (1) 
	{
		for ( uint32_t i=0; i<5; i++ )
		{
			putuint ( SHOW_IN_DISPLAYS, ODDS[4-i] ); 

			delay();
		}// For end

	} //While end

} //Main end