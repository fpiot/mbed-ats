%{^
#include "gpio_api.h"
%}

abst@ype PinName = $extype"PinName"
macdef   LED1    = $extval(PinName, "LED1")
macdef   LED2    = $extval(PinName, "LED2")
macdef   LED3    = $extval(PinName, "LED3")
macdef   LED4    = $extval(PinName, "LED4")

abst@ype PinMode     = $extype"PinMode"
macdef   PullUp      = $extval(PinMode, "PullUp")
macdef   PullDown    = $extval(PinMode, "PullDown")
macdef   PullNone    = $extval(PinMode, "PullNone")
macdef   OpenDrain   = $extval(PinMode, "OpenDrain")
macdef   PullDefault = $extval(PinMode, "PullDefault")

abst@ype PinDirection = $extype"PinDirection"
macdef   PIN_INPUT    = $extval(PinDirection, "PIN_INPUT")
macdef   PIN_OUTPUT   = $extval(PinDirection, "PIN_OUTPUT")

abst@ype gpio_t = $extype"gpio_t"
typedef gpio_t_p = cPtr0(gpio_t)

fun gpio_set: PinName -> uint32

fun gpio_init: (gpio_t_p, PinName) -> void 

fun gpio_mode: (gpio_t_p, PinMode) -> void
fun gpio_dir:  (gpio_t_p, PinDirection) -> void

fun gpio_write: (gpio_t_p, int) -> void
fun gpio_read:  (gpio_t_p) -> int

fun gpio_init_in:     (gpio_t_p, PinName) -> void
fun gpio_init_in_ex:  (gpio_t_p, PinName, PinMode) -> void
fun gpio_init_out:    (gpio_t_p, PinName) -> void
fun gpio_init_out_ex: (gpio_t_p, PinName, int) -> void
fun gpio_init_inout:  (gpio_t_p, PinName, PinDirection, PinMode, int) -> void
