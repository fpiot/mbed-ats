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
  tsc: !TCPSocketConnection >> TCPSocketConnection_minus_struct l
) : #[l:addr] (TCPSocketConnection_struct @ l | ptr l)

extern praxi
TCPSocketConnection_addback_struct
  {l:addr}
(
  pfat: TCPSocketConnection_struct @ l
| tsc: !TCPSocketConnection_minus_struct l >> TCPSocketConnection
) : void

implement
tcp_socket_connection_open () = let
  val (pfgc, pfat | p) = ptr_alloc<TCPSocketConnection_struct> ()
  val () = p->sock := socket_open (SOCK_STREAM)
  val () = p->endpoint := endpoint_open ()
  // xxx
  val tsc = $UN.castvwtp0{TCPSocketConnection}((pfat, pfgc | p))
in
  tsc
end

implement
tcp_socket_connection_close (tsc) = {
  val (pfat | p) = TCPSocketConnection_takeout_struct (tsc)
//  val () = endpoint_close (p->endpoint)
//  val () = socket_close (p->sock, true)
  prval () = TCPSocketConnection_addback_struct (pfat | tsc)
  val () = __free (tsc) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
}
