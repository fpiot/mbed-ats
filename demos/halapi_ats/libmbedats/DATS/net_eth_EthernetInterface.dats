#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
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

static osSemaphoreId    tcpip_inited_id;
static osSemaphoreDef_t tcpip_inited_def;
static osSemaphoreId    netif_linked_id;
static osSemaphoreDef_t netif_linked_def;
static osSemaphoreId    netif_up_id;
static osSemaphoreDef_t netif_up_def;
%}

fun null_ip_addr_t_p (): ip_addr_t_p =  $UN.castvwtp0{ip_addr_t_p}(the_null_ptr)


macdef use_dhcp_p = $extval(ptr, "(&use_dhcp)")

// Global State
extern praxi addback_macaddr {l:agz} (pf: struct_macaddr @ l): void
local
  var _dat_macaddr: struct_macaddr // hide
in
  fun takeout_macaddr (): [l:agz] (struct_macaddr @ l | ptr l) = $UN.castvwtp0 (addr@_dat_macaddr)
end

fun init_netif(ipaddr: ip_addr_t_p, netmask: ip_addr_t_p, gw: ip_addr_t_p): void = {
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
