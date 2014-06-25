%{^
#include "mbed_interface.h"
%}

typedef struct_macaddr = @[char][6]
fun mbed_mac_address: {l: agz} (ptr l) -> void = "mac#"
