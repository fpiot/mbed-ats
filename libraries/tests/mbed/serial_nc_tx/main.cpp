#include "mbed.h"
#include "test_env.h"

int main() {
    MBED_HOSTTEST_TIMEOUT(20);
    MBED_HOSTTEST_SELECT(serial_nc_tx_auto);
    MBED_HOSTTEST_DESCRIPTION(Serial NC TX);
    MBED_HOSTTEST_START("MBED_38");

    // Wait until we receive start signal from host test
    Serial *pc = new Serial(USBTX, USBRX);
    char c = pc->getc();
    delete pc;

    // If signal is correct, start the test
    if (c == 'S') {
      Serial *pc = new Serial(USBTX, NC);
      pc->printf("TX OK - Expected\r\n");
      delete pc;

      pc = new Serial(NC, USBRX);
      pc->printf("TX OK - Unexpected\r\n");
      delete pc;
    }



    while (1) {
    }
}
