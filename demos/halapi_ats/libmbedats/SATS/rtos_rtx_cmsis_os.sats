%{^
#include "cmsis_os.h"
%}

abst@ype osSemaphoreId = $extype"osSemaphoreId"

abst@ype osSemaphoreDef_t = $extype"osSemaphoreDef_t"
typedef osSemaphoreDef_t_p = cPtr0(osSemaphoreDef_t)

abst@ype osStatus             = $extype"osStatus"
macdef osOK                   = $extval(osStatus, "osOK")
macdef osEventSignal          = $extval(osStatus, "osEventSignal")
macdef osEventMessage         = $extval(osStatus, "osEventMessage")
macdef osEventMail            = $extval(osStatus, "osEventMail")
macdef osEventTimeout         = $extval(osStatus, "osEventTimeout")
macdef osErrorParameter       = $extval(osStatus, "osErrorParameter")
macdef osErrorResource        = $extval(osStatus, "osErrorResource")
macdef osErrorTimeoutResource = $extval(osStatus, "osErrorTimeoutResource")
macdef osErrorISR             = $extval(osStatus, "osErrorISR")
macdef osErrorISRRecursive    = $extval(osStatus, "osErrorISRRecursive")
macdef osErrorPriority        = $extval(osStatus, "osErrorPriority")
macdef osErrorNoMemory        = $extval(osStatus, "osErrorNoMemory")
macdef osErrorValue           = $extval(osStatus, "osErrorValue")
macdef osErrorOS              = $extval(osStatus, "osErrorOS")
macdef os_status_reserved     = $extval(osStatus, "os_status_reserved")

fun osSemaphoreCreate: (osSemaphoreDef_t_p, int32) -> osSemaphoreId = "mac#"
fun osSemaphoreWait: (osSemaphoreId, uint32) -> int32 = "mac#"
fun osSemaphoreRelease: (osSemaphoreId) -> osStatus = "mac#"
fun osSemaphoreDelete: (osSemaphoreId) -> osStatus = "mac#"
