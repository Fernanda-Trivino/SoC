#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <irq.h>
#include <uart.h>
#include <console.h>
#include <generated/csr.h>

#include "i2c.h"

static void wait(unsigned int s)
{
	timer0_en_write(0);
	timer0_reload_write(0);
	timer0_load_write(SYSTEM_CLOCK_FREQUENCY*s);
	timer0_en_write(1);
	timer0_update_value_write(1);
	while(timer0_value_read()) timer0_update_value_write(1);
}

uint8_t dato1 = 0xFF;
uint8_t dato2 = 0xAA;

int main(void)
{
	irq_setmask(0);
	irq_setie(1);
	uart_init();

	puts("\niniciando ejemplo i2c con lm32 "__DATE__" "__TIME__"\n");
   	i2c_init();
	
		//bLINKER
//while(1){	
		i2c_command_write(0x0);	
		i2c_write(0x53,0x2D);
		i2c_command_write(CSTO);
		wait(1);
		i2c_command_write(0x0);
		leds_out_write(i2c_status_read());
		printf("salio\n");
		wait(3);		
		leds_out_write(0xff);
	//}
	return 0;
}
