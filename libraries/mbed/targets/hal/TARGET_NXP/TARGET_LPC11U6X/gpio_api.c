/* mbed Microcontroller Library
 * Copyright (c) 2006-2014 ARM Limited
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
#include "gpio_api.h"
#include "pinmap.h"

static int  gpio_enabled = 0;

static void gpio_enable(void) {
    gpio_enabled = 1;
    
    /* Enable AHB clock to the GPIO and IOCON domain. */
    LPC_SYSCON->SYSAHBCLKCTRL |= ((1 << 16) | (1 << 6));
}

uint32_t gpio_set(PinName pin) {
    if (!gpio_enabled)
         gpio_enable();
    
    int f = ((pin == P0_0)  ||
             (pin == P0_10) ||
             (pin == P0_15)) ? (1) : (0);
    
    pin_function(pin, f);
    
    return (1UL << ((int)pin >> PIN_SHIFT & 0x1F));
}

void gpio_init(gpio_t *obj, PinName pin) {
    if(pin == NC) return;
    
    obj->pin = pin;
    obj->mask = gpio_set(pin);
    
    unsigned int port = (unsigned int)(pin >> PORT_SHIFT);
    
    obj->reg_set = &LPC_GPIO_PORT->SET[port];
    obj->reg_clr = &LPC_GPIO_PORT->CLR[port];
    obj->reg_in  = &LPC_GPIO_PORT->PIN[port];
    obj->reg_dir = &LPC_GPIO_PORT->DIR[port];
}

void gpio_mode(gpio_t *obj, PinMode mode) {
    pin_mode(obj->pin, mode);
}

void gpio_dir(gpio_t *obj, PinDirection direction) {
    switch (direction) {
        case PIN_INPUT : *obj->reg_dir &= ~obj->mask; break;
        case PIN_OUTPUT: *obj->reg_dir |=  obj->mask; break;
    }
}
