staload "libmbedats/SATS/net_eth_EthernetInterface.sats"

%{^
#include <stdbool.h>
%}

%{
static struct netif netif;
#define LEN_MAC_ADDR 19
static char mac_addr[LEN_MAC_ADDR];
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

implement EthernetInterface_init () = let
  // xxx
in
  0
end

