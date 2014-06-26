staload "libmbedats/SATS/rtos_rtx_cmsis_os.sats"
staload "libmbedats/SATS/net_lwip_lwip.sats"

fun EthernetInterface_init: () -> bool
fun EthernetInterface_connect: (uint) -> bool
fun EthernetInterface_disconnect: () -> bool
fun EthernetInterface_getIPAddress: () -> string
