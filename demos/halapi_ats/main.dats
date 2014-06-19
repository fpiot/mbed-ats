#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload "libmbedats/SATS/mbed_api_wait_api.sats"
staload "libmbedats/SATS/mbed_hal_gpio_api.sats"

#define BLINK_DELAY_US 500000

fun loop (): void = {
  val () = wait_us (BLINK_DELAY_US);
  val () = wait_us (BLINK_DELAY_US);
  val () = loop ();
}

implement main0 () = {
(*
  val () = gpio_init_out (LED1)
  val () = gpio_init_out (LED2)
  val () = gpio_init_out (LED3)
  val () = gpio_init_out (LED4)
*)
  val () = loop ();
}
