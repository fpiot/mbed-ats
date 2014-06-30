staload "libmbedats/SATS/net_lwip_Socket_Socket.sats"
staload "libmbedats/SATS/net_lwip_Socket_Endpoint.sats"

absvtype TCPSocketConnection = ptr

fun tcp_socket_connection_open: () -> Option_vt TCPSocketConnection
fun tcp_socket_connection_connect: (!TCPSocketConnection, string, int) -> bool
//fun tcp_socket_connection_send_all: (!TCPSocketConnection, char* data, int length);
//fun tcp_socket_connection_receive: (!TCPSocketConnection, char* data, int length);
fun tcp_socket_connection_close: (TCPSocketConnection) -> void
