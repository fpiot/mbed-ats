%{^
#include "serial_api.h"
%}

staload "libmbedats/SATS/mbed_hal_gpio_api.sats"

macdef   USBTX = $extval(PinName, "USBTX")
macdef   USBRX = $extval(PinName, "USBRX")

abst@ype SerialParity  = $extype"SerialParity"
macdef   ParityNone    = $extval(SerialParity, "ParityNone")
macdef   ParityOdd     = $extval(SerialParity, "ParityOdd")
macdef   ParityEven    = $extval(SerialParity, "ParityEven")
macdef   ParityForced1 = $extval(SerialParity, "ParityForced1")
macdef   ParityForced0 = $extval(SerialParity, "ParityForced0")

abst@ype SerialIrq = $extype"SerialIrq"
macdef   RxIrq     = $extval(SerialIrq, "RxIrq")
macdef   TxIrq     = $extval(SerialIrq, "TxIrq")

abst@ype FlowControl       = $extype"FlowControl"
macdef   FlowControlNone   = $extval(FlowControl, "FlowControlNone")
macdef   FlowControlRTS    = $extval(FlowControl, "FlowControlRTS")
macdef   FlowControlCTS    = $extval(FlowControl, "FlowControlCTS")
macdef   FlowControlRTSCTS = $extval(FlowControl, "FlowControlRTSCTS")

typedef uart_irq_handler = (uint32, SerialIrq) -> void

abst@ype serial_t = $extype"serial_t"
typedef serial_t_p = cPtr0(serial_t)

fun serial_init:       (serial_t_p, PinName, PinName) -> void = "mac#"
fun serial_free:       (serial_t_p) -> void = "mac#"
fun serial_baud:       (serial_t_p, int) -> void = "mac#"
fun serial_format:     (serial_t_p, int, SerialParity, int) -> void = "mac#"

fun serial_irq_handler: (serial_t_p, uart_irq_handler, uint32) -> void = "mac#"
fun serial_irq_set:    (serial_t_p, SerialIrq, uint32) -> void = "mac#"

fun serial_getc:       (serial_t_p) -> int = "mac#"
fun serial_putc:       (serial_t_p, int) -> void = "mac#"
fun serial_readable:   (serial_t_p) -> int = "mac#"
fun serial_writable:   (serial_t_p) -> int = "mac#"
fun serial_clear:      (serial_t_p) -> void = "mac#"

fun serial_break_set:  (serial_t_p) -> void = "mac#"
fun serial_break_clear: (serial_t_p) -> void = "mac#"

fun serial_pinout_tx:  (PinName) -> void = "mac#"

fun serial_set_flow_control: (serial_t_p, FlowControl, PinName, PinName) -> void = "mac#"
