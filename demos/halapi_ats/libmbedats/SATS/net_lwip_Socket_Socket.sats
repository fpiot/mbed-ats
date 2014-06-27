%{^
#include "lwip/sockets.h"
#include "lwip/netdb.h"
%}

// Socket protocol types (TCP/UDP/RAW)
abst@ype SOCKTYPE = $extype"int"
macdef   SOCK_STREAM   = $extval(SOCKTYPE, "SOCK_STREAM")
macdef   SOCK_DGRAM    = $extval(SOCKTYPE, "SOCK_DGRAM")
macdef   SOCK_RAW      = $extval(SOCKTYPE, "SOCK_RAW")

abst@ype struct_hostent = $extype"struct hostent"
typedef struct_hostent_p = cPtr0(struct_hostent)

fun gethostbyname: string -> struct_hostent_p = "mac#lwip_gethostbyname"
// Also need gethostbyname_r() ?

abst@ype struct_timeval = $extype"struct timeval"
typedef struct_timeval_p = cPtr0(struct_timeval)

absvtype Socket = ptr

fun socket_open: (SOCKTYPE) -> Socket
fun socket_wait_readable: {l:agz} (Socket, struct_timeval_p) -> bool
fun socket_wait_writable: {l:agz} (Socket, struct_timeval_p) -> bool
// xxx void set_blocking(bool blocking, unsigned int timeout=1500)
// xxx int set_option(int level, int optname, const void *optval, socklen_t optlen)
// xxx int get_option(int level, int optname, void *optval, socklen_t *optlen)
fun socket_close: (Socket) -> void
