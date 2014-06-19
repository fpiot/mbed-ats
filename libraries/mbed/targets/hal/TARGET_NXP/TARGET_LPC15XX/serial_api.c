/* mbed Microcontroller Library
 * Copyright (c) 2006-2013 ARM Limited
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
// math.h required for floating point operations for baud rate calculation
#include <math.h>
#include <string.h>

#include "serial_api.h"
#include "cmsis.h"
#include "pinmap.h"
#include "error.h"

/******************************************************************************
 * INITIALIZATION
 ******************************************************************************/
#define UART_NUM    3

static const SWM_Map SWM_UART_TX[] = {
    {0, 0},  // Pin assign register0, 7:0bit
    {1, 8},  // Pin assign register1, 15:8bit
    {2, 16}, // Pin assign register2, 23:16bit
};

static const SWM_Map SWM_UART_RX[] = {
    {0, 8},
    {1, 16},
    {2, 24},
};

static const SWM_Map SWM_UART_RTS[] = {
    {0, 16},
    {1, 24},
    {3, 0}, // not available
};
 
static const SWM_Map SWM_UART_CTS[] = {
    {0, 24},
    {2, 0},
    {3, 8} // not available
};

// bit flags for used UARTs
static unsigned char uart_used = 0;
static int get_available_uart(void) {
    int i;
    for (i=0; i<3; i++) {
        if ((uart_used & (1 << i)) == 0)
            return i;
    }
    return -1;
}

#define UART_EN       (0x01<<0)

#define CTS_DELTA     (0x01<<5)
#define RXBRK         (0x01<<10)
#define DELTA_RXBRK   (0x01<<11)

#define RXRDY         (0x01<<0)
#define TXRDY         (0x01<<2)

#define TXBRKEN       (0x01<<1)
#define CTSEN         (0x01<<9)

static uint32_t UARTSysClk;

static uint32_t serial_irq_ids[UART_NUM] = {0};
static uart_irq_handler irq_handler;

int stdio_uart_inited = 0;
serial_t stdio_uart;

static void switch_pin(const SWM_Map *swm, PinName pn)
{
    uint32_t regVal;
    if (pn != NC)
    {
        // check if we have any function mapped to this pin already and remove it
        for (int n = 0; n < sizeof(LPC_SWM->PINASSIGN)/sizeof(*LPC_SWM->PINASSIGN); n ++) {
            regVal = LPC_SWM->PINASSIGN[n];
            for (int j = 0; j <= 24; j += 8) {
                if (((regVal >> j) & 0xFF) == pn) 
                    regVal |= (0xFF << j);
            }
            LPC_SWM->PINASSIGN[n] = regVal;
        }
    }
    // now map it
    regVal = LPC_SWM->PINASSIGN[swm->n] & ~(0xFF << swm->offset);
    LPC_SWM->PINASSIGN[swm->n] = regVal |  (pn  << swm->offset);
}

void serial_init(serial_t *obj, PinName tx, PinName rx) {
    int is_stdio_uart = 0;
  
    int uart_n = get_available_uart();
    if (uart_n == -1) {
        error("No available UART");
    }
    obj->index = uart_n;
    obj->uart = (LPC_USART0_Type *)(LPC_USART0_BASE + (0x4000 * uart_n));
    uart_used |= (1 << uart_n);
    
    switch_pin(&SWM_UART_TX[uart_n], tx);
    switch_pin(&SWM_UART_RX[uart_n], rx);
    
    /* uart clock divided by 6 */
    LPC_SYSCON->UARTCLKDIV =6;
    
    /* disable uart interrupts */
    NVIC_DisableIRQ((IRQn_Type)(UART0_IRQn + uart_n));
    
    /* Enable UART clock */
    LPC_SYSCON->SYSAHBCLKCTRL1 |= (1 << (17 + uart_n));
    
    /* Peripheral reset control to UART, a "1" bring it out of reset. */
//    LPC_SYSCON->PRESETCTRL1 &= ~(0x1 << (17 + uart_n));
    LPC_SYSCON->PRESETCTRL1 |=  (0x1 << (17 + uart_n));
    LPC_SYSCON->PRESETCTRL1 ^=  (0x1 << (17 + uart_n));
    
    UARTSysClk = SystemCoreClock / LPC_SYSCON->UARTCLKDIV;
    
    // set default baud rate and format
    serial_baud  (obj, 9600);
    serial_format(obj, 8, ParityNone, 1);
    
    /* Clear all status bits. */
    obj->uart->STAT = CTS_DELTA | DELTA_RXBRK;
    
    /* enable uart interrupts */
    NVIC_EnableIRQ((IRQn_Type)(UART0_IRQn + uart_n));
    
    /* Enable UART interrupt */
    // obj->uart->INTENSET = RXRDY | TXRDY | DELTA_RXBRK;
    
    /* Enable UART */
    obj->uart->CFG |= UART_EN;
    
    is_stdio_uart = ((tx == USBTX) && (rx == USBRX));
    
    if (is_stdio_uart) {
        stdio_uart_inited = 1;
        memcpy(&stdio_uart, obj, sizeof(serial_t));
    }
}

void serial_free(serial_t *obj) {
    uart_used &= ~(1 << obj->index);
    serial_irq_ids[obj->index] = 0;
}

// serial_baud
// set the baud rate, taking in to account the current SystemFrequency
void serial_baud(serial_t *obj, int baudrate) {
    /* Integer divider:
         BRG = UARTSysClk/(Baudrate * 16) - 1
       
       Frational divider:
         FRG = ((UARTSysClk / (Baudrate * 16 * (BRG + 1))) - 1)
       
       where
         FRG = (LPC_SYSCON->UARTFRDADD + 1) / (LPC_SYSCON->UARTFRDSUB + 1)
       
       (1) The easiest way is set SUB value to 256, -1 encoded, thus SUB
           register is 0xFF.
       (2) In ADD register value, depending on the value of UartSysClk,
           baudrate, BRG register value, and SUB register value, be careful
           about the order of multiplier and divider and make sure any
           multiplier doesn't exceed 32-bit boundary and any divider doesn't get
           down below one(integer 0).
       (3) ADD should be always less than SUB.
    */
    obj->uart->BRG = UARTSysClk / 16 / baudrate - 1;
    
    // To use of the fractional baud rate generator, you must write 0xFF to the DIV
    // value to yield a denominator value of 256. All other values are not supported.
    LPC_SYSCON->FRGCTRL = 0xFF;
    
    LPC_SYSCON->FRGCTRL |= ( ( ((UARTSysClk / 16) * (0xFF + 1)) /
                                (baudrate * (obj->uart->BRG + 1))
                              ) - (0xFF + 1) ) << 8;

}

void serial_format(serial_t *obj, int data_bits, SerialParity parity, int stop_bits) {
    // 0: 1 stop bits, 1: 2 stop bits
    if (stop_bits != 1 && stop_bits != 2) {
        error("Invalid stop bits specified");
    }
    stop_bits -= 1;
    
    // 0: 7 data bits ... 2: 9 data bits
    if (data_bits < 7 || data_bits > 9) {
        error("Invalid number of bits (%d) in serial format, should be 7..9", data_bits);
    }
    data_bits -= 7;
    
    int paritysel;
    switch (parity) {
        case ParityNone: paritysel = 0; break;
        case ParityEven: paritysel = 2; break;
        case ParityOdd : paritysel = 3; break;
        default:
            error("Invalid serial parity setting");
            return;
    }
    
    obj->uart->CFG = (data_bits << 2)
                   | (paritysel << 4)
                   | (stop_bits << 6);
}

/******************************************************************************
 * INTERRUPTS HANDLING
 ******************************************************************************/
static inline void uart_irq(uint32_t iir, uint32_t index) {
    // [Chapter 14] LPC17xx UART0/2/3: UARTn Interrupt Handling
    SerialIrq irq_type;
    switch (iir) {
        case 1: irq_type = TxIrq; break;
        case 2: irq_type = RxIrq; break;
        default: return;
    }
    
    if (serial_irq_ids[index] != 0)
        irq_handler(serial_irq_ids[index], irq_type);
}

void uart0_irq() {uart_irq((LPC_USART0->STAT & (1 << 2)) ? 2 : 1, 0);}
void uart1_irq() {uart_irq((LPC_USART1->STAT & (1 << 2)) ? 2 : 1, 1);}
void uart2_irq() {uart_irq((LPC_USART2->STAT & (1 << 2)) ? 2 : 1, 2);}

void serial_irq_handler(serial_t *obj, uart_irq_handler handler, uint32_t id) {
    irq_handler = handler;
    serial_irq_ids[obj->index] = id;
}

void serial_irq_set(serial_t *obj, SerialIrq irq, uint32_t enable) {
    IRQn_Type irq_n = (IRQn_Type)0;
    uint32_t vector = 0;
    switch ((int)obj->uart) {
        case LPC_USART0_BASE: irq_n=UART0_IRQn; vector = (uint32_t)&uart0_irq; break;
        case LPC_USART1_BASE: irq_n=UART1_IRQn; vector = (uint32_t)&uart1_irq; break;
        case LPC_USART2_BASE: irq_n=UART2_IRQn; vector = (uint32_t)&uart2_irq; break;
    }
    
    if (enable) {
        obj->uart->INTENSET = (1 << ((irq == RxIrq) ? 0 : 2));
        NVIC_SetVector(irq_n, vector);
        NVIC_EnableIRQ(irq_n);
    } else { // disable
        int all_disabled = 0;
        SerialIrq other_irq = (irq == RxIrq) ? (TxIrq) : (RxIrq);
        obj->uart->INTENSET &= ~(1 << ((irq == RxIrq) ? 0 : 2));
        all_disabled = (obj->uart->INTENSET & (1 << ((other_irq == RxIrq) ? 0 : 2))) == 0;
        if (all_disabled)
            NVIC_DisableIRQ(irq_n);
    }
}

/******************************************************************************
 * READ/WRITE
 ******************************************************************************/
int serial_getc(serial_t *obj) {
    while (!serial_readable(obj));
    return obj->uart->RXDATA;
}

void serial_putc(serial_t *obj, int c) {
    while (!serial_writable(obj));
    obj->uart->TXDATA = c;
}

int serial_readable(serial_t *obj) {
    return obj->uart->STAT & RXRDY;
}

int serial_writable(serial_t *obj) {
    return obj->uart->STAT & TXRDY;
}

void serial_clear(serial_t *obj) {
    // [TODO]
}

void serial_pinout_tx(PinName tx) {
    
}

void serial_break_set(serial_t *obj) {
    obj->uart->CTRL |= TXBRKEN;
}

void serial_break_clear(serial_t *obj) {
    obj->uart->CTRL &= ~TXBRKEN;
}

void serial_set_flow_control(serial_t *obj, FlowControl type, PinName rxflow, PinName txflow) {
    if ((FlowControlNone == type || FlowControlRTS == type)) txflow = NC;
    if ((FlowControlNone == type || FlowControlCTS == type)) rxflow = NC;
    switch_pin(&SWM_UART_RTS[obj->index], rxflow);
    switch_pin(&SWM_UART_CTS[obj->index], txflow);
    if (txflow == NC) obj->uart->CFG &= ~CTSEN;
    else              obj->uart->CFG |=  CTSEN;
}

