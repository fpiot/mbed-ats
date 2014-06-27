#include "share/atspre_staload.hats"

staload UN = "prelude/SATS/unsafe.sats"
staload "libmbedats/SATS/net_lwip_Socket_Socket.sats"
staload "libmbedats/SATS/net_lwip_Socket_Endpoint.sats"

abst@ype struct_sockaddr_in = $extype"struct sockaddr_in"
typedef struct_sockaddr_in_p = cPtr0(struct_sockaddr_in)

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

%{
#define set_sockaddr_addr(sp,addr) memcpy(((struct sockaddr_in *)(sp))->sin_addr.s_addr, addr, 4)
#define set_sockaddr_family(sp)    ((struct sockaddr_in *)(sp))->sin_family = AF_INET
#define set_sockaddr_port(sp,port) ((struct sockaddr_in *)(sp))->sin_port = htons(port)
#define get_hostent_addr(he)       (char*)((struct hostent *)(he))->h_addr_list[0]
%}

implement endpoint_set_address (ep, host, port) = let
  extern fun set_sockaddr_addr: (ptr, ptr) -> void = "mac#"
  extern fun set_sockaddr_family: (ptr) -> void = "mac#"
  extern fun set_sockaddr_port: (ptr, int) -> void = "mac#"
  extern fun get_hostent_addr: (struct_hostent_p) -> ptr = "mac#"
  extern fun lwip_gethostbyname: (string) -> struct_hostent_p = "mac#"

  // xxx Need Dot-decimal notation ?
  val hostaddr = lwip_gethostbyname (host)
in
  if $UN.cast2ptr(hostaddr) = the_null_ptr then false else true where {
    val (pfat | p) = Endpoint_takeout_struct (ep)
    val addr = get_hostent_addr (hostaddr)
    val () = set_sockaddr_addr (addr@(p->remoteHost), addr)
    val () = set_sockaddr_family (addr@(p->remoteHost))
    val () = set_sockaddr_port (addr@(p->remoteHost), port)
    prval () = Endpoint_addback_struct (pfat | ep)
  }
end

implement endpoint_close (ep) =
  __free (ep) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
