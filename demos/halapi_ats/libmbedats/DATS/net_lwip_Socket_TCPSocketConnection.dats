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
  tcp: !TCPSocketConnection >> TCPSocketConnection_minus_struct l
) : #[l:addr] (TCPSocketConnection_struct @ l | ptr l)

extern praxi
TCPSocketConnection_addback_struct
  {l:addr}
(
  pfat: TCPSocketConnection_struct @ l
| tcp: !TCPSocketConnection_minus_struct l >> TCPSocketConnection
) : void

implement
tcp_socket_connection_open () = let
  fun createtcp (sock: Socket): Option_vt TCPSocketConnection = let
    val (pfgc, pfat | p) = ptr_alloc<TCPSocketConnection_struct> ()
    val () = p->is_connected := false
    val () = p->sock := sock
    val () = p->endpoint := endpoint_open ()
    val tcp = $UN.castvwtp0{TCPSocketConnection}((pfat, pfgc | p))
  in
    Some_vt tcp
  end
  val osock = socket_open (SOCK_STREAM)
in
  case+ osock of
  | ~Some_vt sock => createtcp sock
  | ~None_vt () => None_vt ()
end

implement
tcp_socket_connection_connect (tcp, host, port) = let
  val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
  // xxx
  prval () = TCPSocketConnection_addback_struct(pfat | tcp)
in
  true // xxx
end

implement
tcp_socket_connection_close (tcp) = {
  val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
  val () = endpoint_close (p->endpoint)
  val () = socket_close (p->sock, true)
  val () = $UN.castvwtp0((pfat | p))
  val () = __free (tcp) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
}
