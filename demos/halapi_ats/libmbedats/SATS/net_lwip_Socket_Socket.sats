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

absvtype Socket = ptr

fun socket_open: () -> Socket
fun socket_sock_fd: (!Socket) -> int
fun socket_initsock: (!Socket, SOCKTYPE) -> bool
fun socket_wait_readable: (!Socket, lint, lint) -> bool
fun socket_wait_writable: (!Socket, lint, lint) -> bool
// xxx void set_blocking(bool blocking, unsigned int timeout=1500)
// xxx int set_option(int level, int optname, const void *optval, socklen_t optlen)
// xxx int get_option(int level, int optname, void *optval, socklen_t *optlen)
fun socket_finisock: (!Socket, bool) -> bool
fun socket_close: (Socket) -> void
