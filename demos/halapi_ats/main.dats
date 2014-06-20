#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libmbedats/SATS/mbed_api_wait_api.sats"
staload "libmbedats/SATS/mbed_hal_gpio_api.sats"
staload "libmbedats/SATS/mbed_hal_serial_api.sats"

#define BLINK_DELAY_US 100000

%{
gpio_t c_led1;
gpio_t c_led2;
gpio_t c_led3;
gpio_t c_led4;
%}

macdef led1 = $extval(gpio_t_p, "(&c_led1)")
macdef led2 = $extval(gpio_t_p, "(&c_led2)")
macdef led3 = $extval(gpio_t_p, "(&c_led3)")
macdef led4 = $extval(gpio_t_p, "(&c_led4)")

fun loop (): void = {
  val () = gpio_write (led1, 1)
  val () = gpio_write (led2, 0)
  val () = gpio_write (led3, 1)
  val () = gpio_write (led4, 0)
  val () = wait_us (BLINK_DELAY_US);
  val () = gpio_write (led1, 0)
  val () = gpio_write (led2, 1)
  val () = gpio_write (led3, 0)
  val () = gpio_write (led4, 1)
  val () = wait_us (BLINK_DELAY_US);
  val () = loop ();
}

implement main0 () = {
  val () = gpio_init_out (led1, LED1)
  val () = gpio_init_out (led2, LED2)
  val () = gpio_init_out (led3, LED3)
  val () = gpio_init_out (led4, LED4)
  val () = loop ();
}
