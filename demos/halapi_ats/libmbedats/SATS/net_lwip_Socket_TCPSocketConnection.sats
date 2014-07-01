staload "libmbedats/SATS/net_lwip_Socket_Socket.sats"
staload "libmbedats/SATS/net_lwip_Socket_Endpoint.sats"

absvtype TCPSocketConnection = ptr

fun tcp_socket_connection_open: () -> TCPSocketConnection
fun tcp_socket_connection_is_connected: (!TCPSocketConnection) -> bool
fun tcp_socket_connection_connect: (!TCPSocketConnection, string, int) -> bool
fun tcp_socket_connection_send_all: (!TCPSocketConnection, strptr) -> int
fun tcp_socket_connection_receive: (!TCPSocketConnection) -> Option_vt strptr
fun tcp_socket_connection_close: (TCPSocketConnection) -> void
