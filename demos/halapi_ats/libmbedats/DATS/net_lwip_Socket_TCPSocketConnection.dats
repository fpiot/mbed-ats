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
tcp_socket_connection_send_all (tcp, str) = let
  fun loop (tcp: !TCPSocketConnection, str: string, fd: int, written: int): Option_vt int = let
      val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
      val blocking = socket_blocking (p->sock)
      prval () = TCPSocketConnection_addback_struct(pfat | tcp)
      val b = if blocking then true else let
                val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
                val tout = socket_timeout (p->sock)
                val r = socket_wait_writable (p->sock, tout)
                prval () = TCPSocketConnection_addback_struct(pfat | tcp)
              in
                r
              end
    in
      if b then let
          extern fun lwip_send: (int, ptr, int, int) -> int = "mac#"
          val p = string2ptr (str)
          val len = $UN.cast{int}(length (str))
          val r = lwip_send (fd, ptr_add<char>(p, written), len - written, 0)
        in
          if r < 0 then None_vt () else if r = 0 then let
              val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
              val () = p->is_connected := false
              prval () = TCPSocketConnection_addback_struct(pfat | tcp)
            in
              Some_vt (written)
            end
          else let
              val written2 = written + r
            in
              if written2 >= len then Some_vt (written2) else loop (tcp, str, fd, written2)
            end
        end
      else Some_vt (written)
    end
  val is_connected = tcp_socket_connection_is_connected (tcp)
  val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
  val fd = socket_sock_fd (p->sock)
  val blocking = socket_blocking (p->sock)
  prval () = TCPSocketConnection_addback_struct(pfat | tcp)
in
  if (fd < 0) orelse (not is_connected) then None_vt () else loop (tcp, str, fd, 0)
end

implement
tcp_socket_connection_receive (tcp) = let
  val is_connected = tcp_socket_connection_is_connected (tcp)
  val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
  val fd = socket_sock_fd (p->sock)
  val blocking = socket_blocking (p->sock)
  prval () = TCPSocketConnection_addback_struct(pfat | tcp)
in
  if (fd < 0) orelse (not is_connected) then None_vt () else let
      val b = if blocking then true else let
                val (pfat | p) = TCPSocketConnection_takeout_struct (tcp)
                val tout = socket_timeout (p->sock)
                val r = socket_wait_readable (p->sock, tout)
                prval () = TCPSocketConnection_addback_struct(pfat | tcp)
              in
                r
              end
    in
      if b then let
          extern fun lwip_recv: (int, ptr, size_t, int) -> int = "mac#"
          #define N 127
          #define CNUL '\000'
          val N1 = succ(N)
          val (pf, pfgc | p) = malloc_gc (i2sz N1)
          val n = lwip_recv (fd, p, i2sz N, 0)
          val () = $UN.ptr0_set<char>(ptr_add<char>(p, n), CNUL)
          val s = $UN.castvwtp0{strptr}((pf, pfgc | p))
        in
          Some_vt (s)
        end else None_vt ()
    end
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
