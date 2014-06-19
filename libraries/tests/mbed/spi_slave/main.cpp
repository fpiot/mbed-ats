#include "mbed.h"

#if defined(TARGET_KL25Z)
SPISlave device(PTD2, PTD3, PTD1, PTD0);    // mosi, miso, sclk, ssel
#elif defined(TARGET_nRF51822)
SPISlave device(p12, p13, p15, p14);  // mosi, miso, sclk, ssel
#elif defined(TARGET_LPC812)
SPISlave device(P0_14, P0_15, P0_12, P0_13);    // mosi, miso, sclk, ssel
#else
SPISlave device(p5, p6, p7, p8);            // mosi, miso, sclk, ssel
#endif


int main() {
    uint8_t resp = 0;

    device.reply(resp);                    // Prime SPI with first reply

    while(1) {
        if(device.receive()) {
            resp = device.read();           // Read byte from master and add 1
            device.reply(resp);             // Make this the next reply
        }
    }
}
