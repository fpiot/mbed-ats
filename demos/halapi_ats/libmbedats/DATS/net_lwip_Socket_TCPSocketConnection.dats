#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libmbedats/SATS/net_lwip_Socket_Socket.sats"
staload "libmbedats/SATS/net_lwip_Socket_Endpoint.sats"
staload "libmbedats/SATS/net_lwip_Socket_TCPSocketConnection.sats"

vtypedef TCPSocketConnection_struct = @{
  is_connected= bool
, sock=         Socket
, endpoint=     Endpoint
}

absvtype TCPSocketConnection_minus_struct (l:addr)

extern castfn
TCPSocketConnection_takeout_struct
(
  sock: !TCPSocketConnection >> TCPSocketConnection_minus_struct l
) : #[l:addr] (TCPSocketConnection_struct @ l | ptr l)

extern praxi
TCPSocketConnection_addback_struct
  {l:addr}
(
  pfat: TCPSocketConnection_struct @ l
| sock: !TCPSocketConnection_minus_struct l >> TCPSocketConnection
) : void
