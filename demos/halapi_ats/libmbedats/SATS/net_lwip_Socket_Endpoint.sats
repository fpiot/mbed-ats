absvtype Endpoint = ptr

fun endpoint_open: () -> Endpoint
fun endpoint_set_address: (!Endpoint, String, int) -> bool
fun endpoint_close: (Endpoint) -> void
