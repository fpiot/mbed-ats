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

implement socket_open () = let
  val (pfat, pfgc | p) = ptr_alloc<Socket_struct> ()
  val () = p->sock_fd := ~1
  val () = p->blocking := true
  val () = p->timeout := 1500U
in
  $UN.castvwtp0{Socket}((pfat, pfgc | p))
end

implement socket_sock_fd (sock) = let
  val (pfat | p) = Socket_takeout_struct (sock)
  val sock_fd = p->sock_fd
  prval () = Socket_addback_struct (pfat | sock)
in
  sock_fd
end

implement socket_blocking (sock) = let
  val (pfat | p) = Socket_takeout_struct (sock)
  val blocking = p->blocking
  prval () = Socket_addback_struct (pfat | sock)
in
  blocking
end

implement socket_timeout (sock) = let
  val (pfat | p) = Socket_takeout_struct (sock)
  val timeout = p->timeout
  prval () = Socket_addback_struct (pfat | sock)
in
  timeout
end

implement socket_initsock (sock, socktype) = let
  fun createsock (sock: !Socket): bool = let
    fun setfd (sock: !Socket, fd: int): bool = let
        val (pfat | p) = Socket_takeout_struct (sock)
        val () = p->sock_fd := fd
        prval () = Socket_addback_struct (pfat | sock)
      in
        true
      end
    val fd = lwip_socket (AF_INET, socktype, 0) where {
      macdef AF_INET = $extval(int, "AF_INET")
      extern fun lwip_socket: (int, SOCKTYPE, int) -> int = "mac#"
    }
    in
      if fd < 0 then false else setfd (sock, fd)
    end
in
  if socket_sock_fd (sock) = ~1 then false else createsock (sock)
end

%{
#define c_FD_SET(n, p)  FD_SET(n, ((fd_set *)(p)))
#define c_FD_ISSET(n, p)  FD_ISSET(n, ((fd_set *)(p)))
#define set_timeval_sec(tvp, sec)  ((struct timeval *)(tvp))->tv_sec = sec
#define set_timeval_usec(tvp, usec)  ((struct timeval *)(tvp))->tv_usec = usec
%}

extern fun socket_select: (!Socket, uint, bool, bool) -> bool
implement socket_select (sock, ms, read, write) = let
  abst@ype struct_timeval = $extype"struct timeval"
  typedef struct_timeval_p = cPtr0(struct_timeval)
  abst@ype fd_set = $extype"fd_set"
  typedef fd_set_p = cPtr0(fd_set)
  macdef FD_SETSIZE = $extval(int, "FD_SETSIZE")
  extern fun set_timeval_sec: (struct_timeval_p, lint) -> void = "mac#"
  extern fun set_timeval_usec: (struct_timeval_p, lint) -> void = "mac#"
  extern fun FD_ZERO: (fd_set_p) -> void = "mac#"
  extern fun FD_SET: (int, fd_set_p) -> void = "mac#c_FD_SET"
  extern fun FD_ISSET: (int, fd_set_p) -> uchar = "mac#c_FD_ISSET"
  extern fun lwip_select: (int, ptr, ptr, ptr, struct_timeval_p) -> int = "mac#"

  var fdSet: fd_set
  var timeout: struct_timeval
  val sock_fd = socket_sock_fd (sock)
  val tv_sec = ms / 1000U
  val tv_usec = (ms - (tv_sec * 1000U)) * 1000U
  val () = set_timeval_sec ($UN.castvwtp0(addr@timeout), $UN.cast(tv_sec))
  val () = set_timeval_usec ($UN.castvwtp0(addr@timeout), $UN.cast(tv_usec))
  val () = FD_ZERO ($UN.castvwtp0(addr@fdSet))
  val () = FD_SET (sock_fd, $UN.castvwtp0(addr@fdSet))
  val readset = if read then $UN.castvwtp0{ptr}(addr@fdSet) else the_null_ptr
  val writeset = if write then $UN.castvwtp0{ptr}(addr@fdSet) else the_null_ptr
  val ret = lwip_select (FD_SETSIZE, readset, writeset, the_null_ptr, $UN.castvwtp0(addr@timeout))
in
  if ret <= 0 orelse ($UN.cast(0) = FD_ISSET(sock_fd, $UN.castvwtp0(addr@fdSet)))
  then false else true
end

implement socket_wait_readable (sock, ms) =
  socket_select (sock, ms, true, false)

implement socket_wait_writable (sock, ms) =
  socket_select (sock, ms, false, true)

implement socket_finisock (sock, shutdown) = let
  macdef SHUT_RDWR = $extval(int, "SHUT_RDWR")
  extern fun lwip_shutdown: (int, int) -> int = "mac#"
  extern fun lwip_close: (int) -> int = "mac#"
  fun close (sock: !Socket): bool = let
      val (pfat | p) = Socket_takeout_struct (sock)
      val _ = if shutdown then lwip_shutdown (p->sock_fd, SHUT_RDWR) else 0/*DUMMY*/
      val _ = lwip_close (p->sock_fd)
      val () = p->sock_fd := ~1
      prval () = Socket_addback_struct (pfat | sock)
    in
      true
    end
in
  if socket_sock_fd (sock) < 0 then false else close (sock)
end

implement socket_close (sock) = {
  val _ = socket_finisock (sock, true)
  val () = __free (sock) where {
    extern fun __free {vt:vtype} (x: vt): void = "atspre_mfree_gc"
  }
}
