staload "libmbedats/SATS/rtos_rtx_cmsis_os.sats"
staload "libmbedats/SATS/net_lwip_lwip.sats"

fun EthernetInterface_init: () -> int
fun EthernetInterface_connect: (uint32) -> bool
