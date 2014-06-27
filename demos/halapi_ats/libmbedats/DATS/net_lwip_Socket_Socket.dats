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
  val (pfat, pfgc | p) = ptr_alloc<Socket_struct> ()
  val () = p->sock_fd := ~1
  val () = p->blocking := true
  val () = p->timeout := 1500U
  // xxx Call lwip_socket()
in
  $UN.castvwtp0{Socket}((pfat, pfgc | p))
end

implement socket_close (sock) = {
  val (pfat | p) = Socket_takeout_struct (sock)
  prval () = Socket_addback_struct (pfat | sock)
  val () = __free (sock) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
}
