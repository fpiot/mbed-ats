#include "test_env.h"

#if defined(TARGET_LPC4088)
InterruptIn wkp(P2_10);
#else
InterruptIn wkp(p14);
#endif

void flip() {
    printf("button pressed\n");
}

int main() {
    wkp.rise(&flip);

    while (true) {
        // sleep();
        deepsleep();
    }
}
