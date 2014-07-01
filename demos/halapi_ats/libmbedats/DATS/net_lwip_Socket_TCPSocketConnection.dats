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
  val (pfgc, pfat | p) = ptr_alloc<TCPSocketConnection_struct> ()
  val () = p->is_connected := false
  val () = p->sock := socket_open ()
  val () = p->endpoint := endpoint_open ()
in
  $UN.castvwtp0{TCPSocketConnection}((pfat, pfgc | p))
end

implement
tcp_socket_connection_is_connected (tcp) = let
  val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
  val r = p->is_connected
  prval () = TCPSocketConnection_addback_struct(pfat | tcp)
in
  r
end

implement
tcp_socket_connection_connect (tcp, host, port) = let
  val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
  val rs = socket_initsock (p->sock, SOCK_STREAM)
  val ret = if rs = false then false else let
      val re = endpoint_set_address (p->endpoint, host, port)
    in
      if re = false then false else let
          abst@ype socklen_t = $extype"socklen_t"
          extern fun lwip_connect: (int, struct_sockaddr_in_p, socklen_t) -> int = "mac#"
          val fd = socket_sock_fd (p->sock)
          val rh = endpoint_remoteHost (p->endpoint)
          val rc = lwip_connect (fd, rh, $UN.cast (sizeof<struct_sockaddr_in>))
        in
          if rc < 0 then let
              val _ = socket_finisock (p->sock, true)
            in
              false
            end else let
              val () = p->is_connected := true
            in
              true
            end
        end
    end
  prval () = TCPSocketConnection_addback_struct(pfat | tcp)
in
  ret
end

implement
tcp_socket_connection_close (tcp) = {
  val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
  val () = endpoint_close (p->endpoint)
  val () = socket_close (p->sock)
  val () = $UN.castvwtp0((pfat | p))
  val () = __free (tcp) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
}
