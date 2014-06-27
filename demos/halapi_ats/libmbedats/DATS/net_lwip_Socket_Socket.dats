#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libmbedats/SATS/net_lwip_Socket_Socket.sats"

typedef Socket_struct = @{
  sock_fd=  int
, blocking= bool
, timeout=  uint
}
absvtype Socket_minus_struct (l:addr)

extern castfn
Socket_takeout_struct
(
  sock: !Socket >> Socket_minus_struct l
) : #[l:addr] (Socket_struct @ l | ptr l)

extern praxi
Socket_addback_struct
  {l:addr}
(
  pfat: Socket_struct @ l
| sock: !Socket_minus_struct l >> Socket
) : void

implement socket_open (socktype) = let
  fun createsock (fd: int): Option_vt Socket = let
      val (pfat, pfgc | p) = ptr_alloc<Socket_struct> ()
      val () = p->sock_fd := fd
      val () = p->blocking := true
      val () = p->timeout := 1500U
      val s = $UN.castvwtp0{Socket}((pfat, pfgc | p))
    in
      Some_vt s
    end
  val fd = lwip_socket (AF_INET, socktype, 0) where {
    macdef AF_INET = $extval(int, "AF_INET")
    extern fun lwip_socket: (int, SOCKTYPE, int) -> int = "mac#"
  }
in
  if fd < 0 then None_vt() else createsock fd
end

extern fun socket_select: (!Socket, lint, lint, bool, bool) -> bool
implement socket_select (sock, tv_sec, tv_usec, read, write) = let
  // xxx
in
  // xxx
  true
end

implement socket_wait_readable (sock, tv_sec, tv_usec) =
  socket_select (sock, tv_sec, tv_usec, true, false)

implement socket_wait_writable (sock, tv_sec, tv_usec) =
  socket_select (sock, tv_sec, tv_usec, false, true)

implement socket_close (sock) = {
  val (pfat | p) = Socket_takeout_struct (sock)
  prval () = Socket_addback_struct (pfat | sock)
  val () = __free (sock) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
}
