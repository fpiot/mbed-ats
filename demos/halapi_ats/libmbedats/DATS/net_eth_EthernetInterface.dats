#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libmbedats/SATS/rtos_rtx_cmsis_os.sats"
staload "libmbedats/SATS/net_eth_EthernetInterface.sats"
staload "libmbedats/SATS/net_lwip_lwip.sats"
staload "libmbedats/SATS/mbed_api_mbed_interface.sats"

%{^
#include <stdbool.h>
%}

%{
static struct netif netif;
#define LEN_IP_ADDR 17
static char ip_addr[LEN_IP_ADDR] = "\0";
static char gateway[LEN_IP_ADDR] = "\0";
static char networkmask[LEN_IP_ADDR] = "\0";
static bool use_dhcp = false;
%}

fun null_ip_addr_t_p () = $UN.castvwtp0{ip_addr_t_p}(the_null_ptr)


// Global State on C
macdef use_dhcp_p = $extval(ptr, "(&use_dhcp)")

// Global State on ATS
var tcpip_inited_id: osSemaphoreId
var tcpip_inited_def: osSemaphoreDef_t
fun tcpip_inited_def_p () = $UN.castvwtp0{osSemaphoreDef_t_p}(addr@tcpip_inited_def)
var netif_linked_id: osSemaphoreId
var netif_linked_def: osSemaphoreDef_t
fun netif_linked_def_p () = $UN.castvwtp0{osSemaphoreDef_t_p}(addr@netif_linked_def)
var netif_up_id: osSemaphoreId
var netif_up_def: osSemaphoreDef_t
fun netif_up_def_p () = $UN.castvwtp0{osSemaphoreDef_t_p}(addr@netif_up_def)
extern praxi addback_macaddr {l:agz} (pf: struct_macaddr @ l): void
local
  var _dat_macaddr: struct_macaddr // hide
in
  fun takeout_macaddr (): [l:agz] (struct_macaddr @ l | ptr l) = $UN.castvwtp0 (addr@_dat_macaddr)
end


fun tcpip_init_done (p: ptr): void = {
  // xxx NOT YET
}

fun init_netif(ipaddr: ip_addr_t_p, netmask: ip_addr_t_p, gw: ip_addr_t_p): void = {
  val v = osSemaphoreCreate (tcpip_inited_def_p (), $UN.cast (0))
  val () = $UN.ptr0_set (addr@tcpip_inited_id, v)
  val v = osSemaphoreCreate (netif_linked_def_p (), $UN.cast (0))
  val () = $UN.ptr0_set (addr@netif_linked_id, v)
  val v = osSemaphoreCreate (netif_up_def_p (), $UN.cast (0))
  val () = $UN.ptr0_set (addr@netif_up_id, v)
  // xxx Init Semaphores
  // xxx NOT YET
}

fun set_mac_address (): void = {
  // xxx Need to support case of MBED_MAC_ADDRESS_SUM != MBED_MAC_ADDR_INTERFACE ?
  val (pf | p) = takeout_macaddr ()
  val () = mbed_mac_address (p)
  prval () = addback_macaddr (pf)
}

implement EthernetInterface_init () = let
  val () = $UN.ptr0_set<bool> (use_dhcp_p, true)
  val () = set_mac_address ()
  val () = init_netif(null_ip_addr_t_p (), null_ip_addr_t_p (), null_ip_addr_t_p ())
in
  0
end
