#include "mbed.h"

# if defined(TARGET_LPC1768) || defined(TARGET_LPC2368) || defined(TARGET_LPC4088)
#     define LED1   (1 << 18) // P1.18
#     define LED2   (1 << 20) // P1.20
#     define LED3   (1 << 21) // P1.21
#     define LED4   (1 << 23) // P1.23
# elif defined(TARGET_LPC11U24) || defined(TARGET_LPC1114)
#     define LED1   (1 <<  8) // P1.8
#     define LED2   (1 <<  9) // P1.9
#     define LED3   (1 << 10) // P1.10
#     define LED4   (1 << 11) // P1.11
# endif

#define LED_MASK    (LED1|LED2|LED3|LED4)

int mask[4] = {
    (LED1 | LED3),
    (LED2 | LED4),
    (LED1 | LED2),
    (LED3 | LED4)
};

PortOut ledport(Port1, LED_MASK);

int main() {
    while (1) {
        for (int i=0; i<4; i++) {
            ledport = mask[i];
            wait(1);
        }
    }
}
