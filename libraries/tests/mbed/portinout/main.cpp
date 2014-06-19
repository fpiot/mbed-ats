#include "test_env.h"

#if defined(TARGET_K64F)
#define P1_1    (1 << 16)
#define P1_2    (1 << 17)
#define PORT_1  PortC

#define P2_1    (1 << 2)
#define P2_2    (1 << 3)
#define PORT_2  PortC

#elif defined(TARGET_LPC11U24)
#define P1_1    (1 <<  9) // p0.9
#define P1_2    (1 <<  8) // p0.8
#define PORT_1  Port0

#define P2_1    (1 << 24) // p1.24
#define P2_2    (1 << 25) // p1.25
#define PORT_2  Port1

#elif defined(TARGET_LPC1768) || defined(TARGET_LPC2368)
#define P1_1    (1 << 9)  // p0.9  -> p5
#define P1_2    (1 << 8)  // p0.8  -> p6
#define PORT_1  Port0

#define P2_1    (1 << 1)  // p2.1 -> p25
#define P2_2    (1 << 0)  // p2.0 -> p26
#define PORT_2  Port2

#elif defined(TARGET_LPC4088)
#define P1_1    (1 << 7)  // p0.7  -> p13
#define P1_2    (1 << 6)  // p0.6  -> p14
#define PORT_1  Port0

#define P2_1    (1 << 2)  // p1.2 -> p30
#define P2_2    (1 << 3)  // p1.3 -> p29
#define PORT_2  Port1

#elif defined(TARGET_LPC1114)
#define P1_1    (1 <<  9) // p0.9
#define P1_2    (1 <<  8) // p0.8
#define PORT_1  Port0

#define P2_1    (1 << 1) // p1.1
#define P2_2    (1 << 0) // p1.0
#define PORT_2  Port1

#elif defined(TARGET_KL25Z)
#define P1_1    (1 << 4)  // PTA4
#define P1_2    (1 << 5)  // PTA5
#define PORT_1  PortA

#define P2_1    (1 << 5)  // PTC5
#define P2_2    (1 << 6)  // PTC6
#define PORT_2  PortC

#elif defined(TARGET_nRF51822)
#define P1_1    (1 << 4)  // p4
#define P1_2    (1 << 5)  // p5
#define PORT_1  Port0

#define P2_1    (1 << 24)  // p24
#define P2_2    (1 << 25)  // p25
#define PORT_2  Port0

#elif defined(TARGET_NUCLEO_F103RB)
#define P1_1    (1 << 6)  // PC_6
#define P1_2    (1 << 5)  // PC_5
#define PORT_1  PortC

#define P2_1    (1 << 8)  // PB_8
#define P2_2    (1 << 9)  // PB_9
#define PORT_2  PortB
#endif

#define MASK_1   (P1_1 | P1_2)
#define MASK_2   (P2_1 | P2_2)

PortInOut port1(PORT_1, MASK_1);
PortInOut port2(PORT_2, MASK_2);

int main() {
    bool check = true;

    port1.output();
    port2.input();

    port1 = MASK_1; wait(0.1);
    if (port2 != MASK_2) check = false;

    port1 = 0; wait(0.1);
    if (port2 != 0) check = false;

    port1.input();
    port2.output();

    port2 = MASK_2; wait(0.1);
    if (port1 != MASK_1) check = false;

    port2 = 0; wait(0.1);
    if (port1 != 0) check = false;

    notify_completion(check);
}
