absvtype Endpoint = ptr

abst@ype struct_sockaddr_in = $extype"struct sockaddr_in"
typedef struct_sockaddr_in_p = cPtr0(struct_sockaddr_in)

fun endpoint_open: () -> Endpoint
fun endpoint_remoteHost: (!Endpoint) -> struct_sockaddr_in_p
fun endpoint_set_address: (!Endpoint, string, int) -> bool
fun endpoint_close: (Endpoint) -> void
