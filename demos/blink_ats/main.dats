%{^
#include "LPC17xx.h"
#include "wait_api.h"
%}

%{
void c_set_gpio1_fiodir(uint32_t val)
{
	LPC_GPIO1->FIODIR = val;
}

void c_set_gpio1_fiopin(uint32_t val)
{
	LPC_GPIO1->FIOPIN = val;
}
%}

#define BLINK_DELAY_US 500000

extern fun c_set_gpio1_fiodir(v: int): void = "mac#"
extern fun c_set_gpio1_fiopin (v: int): void = "mac#"
extern fun c_wait_us (us: int): void = "mac#wait_us"

fun loop (): void = begin
  c_set_gpio1_fiopin (0x40000); // 1 << 18
  c_wait_us (BLINK_DELAY_US);
  c_set_gpio1_fiopin (0x0);
  c_wait_us (BLINK_DELAY_US);
  loop ();
end

implement main0 () = begin
  c_set_gpio1_fiodir (0xb40000); // 1<<18 | 1<<20 | 1<<21 | 1<<23
  loop ();
end
