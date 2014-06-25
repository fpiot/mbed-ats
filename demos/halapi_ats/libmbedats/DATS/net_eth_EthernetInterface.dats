#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload STRING = "libc/SATS/string.sats"
staload "libmbedats/SATS/rtos_rtx_cmsis_os.sats"
staload "libmbedats/SATS/net_eth_EthernetInterface.sats"
staload "libmbedats/SATS/net_lwip_lwip.sats"
staload "libmbedats/SATS/mbed_api_mbed_interface.sats"

%{^
#include "eth_arch.h"
%}

%{
#define LEN_IP_ADDR 17
static char ip_addr[LEN_IP_ADDR] = "\0";
static char gateway[LEN_IP_ADDR] = "\0";
static char networkmask[LEN_IP_ADDR] = "\0";
%}

extern fun eth_arch_enetif_init: netif_init_fn = "mac#"

fun null_ip_addr_t_p () = $UN.castvwtp0{ip_addr_t_p}(the_null_ptr)


// *** Global State on ATS ***
// state = netif
var netif: struct_netif
fun netif_p (): struct_netif_p = $UN.castvwtp0 (addr@netif)
// state = use_dhctp_{id,def}
var use_dhcp = false
fun use_dhcp_p (): ptr = $UN.castvwtp0 (addr@use_dhcp)
// state = tcpip_inited_{id,def}
var tcpip_inited_id: osSemaphoreId
fun takeout_tcpip_inited_id (): [l:agz] (osSemaphoreId @ l | ptr l) = $UN.castvwtp0 (addr@tcpip_inited_id)
extern praxi addback_tcpip_inited_id {l:agz} (pf: osSemaphoreId @ l): void
var tcpip_inited_def: osSemaphoreDef_t
fun tcpip_inited_def_p (): osSemaphoreDef_t_p = $UN.castvwtp0 (addr@tcpip_inited_def)
// state = netif_linked_{id,def}
var netif_linked_id: osSemaphoreId
var netif_linked_def: osSemaphoreDef_t
fun netif_linked_def_p (): osSemaphoreDef_t_p = $UN.castvwtp0 (addr@netif_linked_def)
// state = netif_up_{id,def}
var netif_up_id: osSemaphoreId
var netif_up_def: osSemaphoreDef_t
fun netif_up_def_p (): osSemaphoreDef_t_p = $UN.castvwtp0 (addr@netif_up_def)
// state = macaddr
local
  var _dat_macaddr: struct_macaddr // hide
in
  fun takeout_macaddr (): [l:agz] (struct_macaddr @ l | ptr l) = $UN.castvwtp0 (addr@_dat_macaddr)
end
extern praxi addback_macaddr {l:agz} (pf: struct_macaddr @ l): void


fun tcpip_init_done (p: ptr): void = {
  val (pf | p) = takeout_tcpip_inited_id ()
  val _ = osSemaphoreRelease (!p)
  val () = addback_tcpip_inited_id (pf)
}

fun init_netif(ipaddr: ip_addr_t_p, netmask: ip_addr_t_p, gw: ip_addr_t_p): void = {
  // Init Semaphores
  val v = osSemaphoreCreate (tcpip_inited_def_p (), $UN.cast (0))
  val () = $UN.ptr0_set (addr@tcpip_inited_id, v)
  val v = osSemaphoreCreate (netif_linked_def_p (), $UN.cast (0))
  val () = $UN.ptr0_set (addr@netif_linked_id, v)
  val v = osSemaphoreCreate (netif_up_def_p (), $UN.cast (0))
  val () = $UN.ptr0_set (addr@netif_up_id, v)
  // Init & wait
  val () = tcpip_init (tcpip_init_done, the_null_ptr)
  val (pf | p) = takeout_tcpip_inited_id ()
  val _ = osSemaphoreWait (!p, osWaitForever)
  val () = addback_tcpip_inited_id (pf)
  // Init netif
  val _ = $STRING.memset_unsafe(addr@netif, 0, sizeof<struct_netif>)
  val _ = netif_add(netif_p (), ipaddr, netmask, gw, the_null_ptr, eth_arch_enetif_init, tcpip_input)
  val () = netif_set_default (netif_p ())
  // xxx NOT YET
}

fun set_mac_address (): void = {
  // xxx Need to support case of MBED_MAC_ADDRESS_SUM != MBED_MAC_ADDR_INTERFACE ?
  val (pf | p) = takeout_macaddr ()
  val () = mbed_mac_address (p)
  prval () = addback_macaddr (pf)
}

implement EthernetInterface_init () = let
  // Use DHCP
  val () = $UN.ptr0_set<bool> (use_dhcp_p (), true)
  val () = set_mac_address ()
  val () = init_netif(null_ip_addr_t_p (), null_ip_addr_t_p (), null_ip_addr_t_p ())
in
  0
end
