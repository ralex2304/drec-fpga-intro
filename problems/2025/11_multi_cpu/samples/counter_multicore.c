typedef unsigned int uint32_t;
typedef unsigned short uint16_t;
typedef unsigned char uint8_t;

#define FIFO_DATA_ADDR  ((volatile uint32_t *)0x10)
#define FIFO_FULL_ADDR  ((volatile uint8_t *) 0x14)
#define FIFO_EMPTY_ADDR ((volatile uint8_t *) 0x18)
#define CORE_ID_ADDR    ((volatile uint32_t *)0x1C)
#define HEX_DISP_ADDR   ((volatile uint16_t *)0x20)

#define FREQ_MZ 55
#define CYCLE_PERIOD_NS (1000 / FREQ_MZ)

#define COUNT_TICKS_FROM_NS(ns) (ns / CYCLE_PERIOD_NS)

void wait_ticks(int ticks) {
    ticks /= 8; // loop takes 6 instructions + 1 nop + taken jump takes 1 tick
    for (volatile int i = 0; i < ticks; i++) {
        __asm__ volatile (
            "nop\n"
        );
    }
}

#define WAIT_NS(ns) wait_ticks(COUNT_TICKS_FROM_NS(ns))

int core_id() {
    return *CORE_ID_ADDR;
}

void fifo_put(uint32_t data) {
    while (*FIFO_FULL_ADDR) {}

    *FIFO_DATA_ADDR = data;
}

uint32_t fifo_get() {
    while (*FIFO_EMPTY_ADDR) {}

    return *FIFO_DATA_ADDR;
}

void main() {
    int id = core_id();
    if (id == 0) {
        while (1) {
            for (int i = 0; i < 100; i++) {
                fifo_put(i);
                WAIT_NS(500000000);
            }
        }
    } else if (id == 1) {
        while (1) {
            *HEX_DISP_ADDR = fifo_get();
        }
    }
}

