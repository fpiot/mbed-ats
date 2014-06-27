#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libmbedats/SATS/net_lwip_Socket_Socket.sats"
staload "libmbedats/SATS/net_lwip_Socket_Endpoint.sats"

abst@ype struct_sockaddr_in = $extype"struct sockaddr_in"

typedef Endpoint_struct = @{
  remoteHost= struct_sockaddr_in
}

absvtype Endpoint_minus_struct (l:addr)

extern castfn
Endpoint_takeout_struct
(
  sock: !Endpoint >> Endpoint_minus_struct l
) : #[l:addr] (Endpoint_struct @ l | ptr l)

extern praxi
Endpoint_addback_struct
  {l:addr}
(
  pfat: Endpoint_struct @ l
| sock: !Endpoint_minus_struct l >> Endpoint
) : void

extern fun endpoint_reset_address: (!Endpoint) -> void
implement endpoint_reset_address (ep) = {
  extern fun memset: (ptr, int, size_t) -> ptr = "mac#"
  val (pfat | p) = Endpoint_takeout_struct (ep)
  val _ = memset (p, 0, sizeof<struct_sockaddr_in>)
  prval () = Endpoint_addback_struct (pfat | ep)
}

implement endpoint_open () = let
  val (pfat, pfgc | p) = ptr_alloc<Endpoint_struct> ()
  val ep = $UN.castvwtp0{Endpoint}((pfat, pfgc | p))
  val () = endpoint_reset_address (ep)
in
  ep
end

// xxx fun endpoint_set_address: (!Endpoint, String, int) -> bool

implement endpoint_close (ep) = {
  val () = __free (ep) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
}
