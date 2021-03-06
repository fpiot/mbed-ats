%{^
#include "lwip/inet.h"
#include "lwip/netif.h"
#include "lwip/dhcp.h"
#include "lwip/tcpip.h"
%}

(* lwip/err *)
abst@ype err_t = $extype"err_t"

(* lwip/ip_addr *)
abst@ype ip_addr_t = $extype"ip_addr_t"
typedef ip_addr_t_p = cPtr0(ip_addr_t)

(* lwip/pbuf *)
abst@ype struct_pbuf = $extype"struct pbuf"
typedef struct_pbuf_p = cPtr0(struct_pbuf)

(* lwip/netif *)
%{
#define c_netif_is_up(I)       netif_is_up((struct netif *)(I))
#define c_netif_is_link_up(I)  netif_is_link_up((struct netif *)(I))
#define c_get_netif_ip_addr(I)     (((struct netif *)(I))->ip_addr)
%}

abst@ype struct_netif = $extype"struct netif"
typedef struct_netif_p = cPtr0(struct_netif)

typedef netif_init_fn = (struct_netif_p) -> err_t
typedef netif_input_fn = (struct_pbuf_p, struct_netif_p) -> err_t
typedef netif_status_callback_fn = (struct_netif_p) -> void

fun get_netif_ip_addr: (struct_netif_p) -> ip_addr_t = "mac#c_get_netif_ip_addr"

fun netif_is_up: (struct_netif_p) -> bool = "mac#c_netif_is_up"
fun netif_is_link_up: (struct_netif_p) -> bool = "mac#c_netif_is_link_up"

fun netif_add: (struct_netif_p, ip_addr_t_p, ip_addr_t_p, ip_addr_t_p, ptr, netif_init_fn, netif_input_fn) -> struct_netif_p = "mac#"
fun netif_set_default: (struct_netif_p) -> void = "mac#"
fun netif_set_link_callback: (struct_netif_p, netif_status_callback_fn) -> void = "mac#"
fun netif_set_status_callback: (struct_netif_p, netif_status_callback_fn) -> void = "mac#"
fun netif_set_up: (struct_netif_p) -> void = "mac#"
fun netif_set_down: (struct_netif_p) -> void = "mac#"

(* lwip/inet *)

fun inet_ntoa_r: (ip_addr_t, string, int) -> string = "mac#"

// xxx #define inet_aton(cp, addr)   ipaddr_aton(cp, (ip_addr_t*)addr)
// xxx #define inet_ntoa(addr)       ipaddr_ntoa((ip_addr_t*)&(addr))

(* lwip/tcpip *)
typedef tcpip_init_done_fn = (ptr) -> void

fun tcpip_init: (tcpip_init_done_fn, ptr) -> void = "mac#"
fun tcpip_input: netif_input_fn = "mac#"

(* lwip/dhcp *)
fun dhcp_start: (struct_netif_p) -> err_t = "mac#"
fun dhcp_release: (struct_netif_p) -> err_t = "mac#"
fun dhcp_stop: (struct_netif_p) -> void = "mac#"
