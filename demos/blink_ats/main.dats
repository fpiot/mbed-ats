%{^
#include "LPC17xx.h"
%}

%{
volatile int g_LoopDummy;

void c_blink(void)
{
	LPC_GPIO1->FIODIR |= 1 << 18; // P1.18 connected to LED1
	while(1)
	{
		int i;

		LPC_GPIO1->FIOPIN ^= 1 << 18; // Toggle P1.18
		for (i = 0 ; i < 5000000 && !g_LoopDummy ; i++)
		{
		}
	}
}
%}

extern fun c_blink (): void = "mac#"

implement main0 () = c_blink ()
