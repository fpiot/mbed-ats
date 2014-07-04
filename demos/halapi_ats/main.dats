#include "share/atspre_define.hats"
#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libmbedats/SATS/mbed_api_wait_api.sats"
staload "libmbedats/SATS/mbed_hal_gpio_api.sats"
staload "libmbedats/SATS/net_eth_EthernetInterface.sats"
staload "libmbedats/SATS/net_lwip_Socket_TCPSocketConnection.sats"

#define BLINK_DELAY_US 500000

%{
static gpio_t c_led1;
static gpio_t c_led2;
static gpio_t c_led3;
static gpio_t c_led4;
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
  val () = wait_us (BLINK_DELAY_US)
  val () = gpio_write (led1, 0)
  val () = gpio_write (led2, 1)
  val () = gpio_write (led3, 0)
  val () = gpio_write (led4, 1)
  val () = wait_us (BLINK_DELAY_US)
  val () = loop ()
}

fun init_tcp (): void = {
  val tcp = tcp_socket_connection_open ()
  val r = tcp_socket_connection_connect (tcp, "www.reddit.com", 80)
  val () = println! ("connect_ret: ", r, "\r")
  val () = println! ("is_connected?: ", tcp_socket_connection_is_connected (tcp), "\r")
//  val _ = tcp_socket_connection_send_all (tcp, "GET http://www.reddit.com/r/NetBSD/.rss HTTP/1.0\n\n")
  val () = tcp_socket_connection_close (tcp)
  val () = print ("Called tcp_socket_connection_close\r\n")
}

fun init_ethernet (): void = {
  val _ = EthernetInterface_init ()
  val b = EthernetInterface_connect (15000U)
  val () = println! ("EthernetInterface: ", b, "\r")
  val ip = EthernetInterface_getIPAddress ()
  val () = println! ("IP address: ", ip, "\r")
  val () = init_tcp ()
  val _ = EthernetInterface_disconnect ()
  val () = print ("Called EthernetInterface_disconnect\r\n")
}

implement main0 () = {
  val () = gpio_init_out (led1, LED1)
  val () = gpio_init_out (led2, LED2)
  val () = gpio_init_out (led3, LED3)
  val () = gpio_init_out (led4, LED4)
  val () = print ("Hello world!\r\n")
  val () = init_ethernet ()
  val () = loop ()
}
