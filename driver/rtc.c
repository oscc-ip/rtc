#include <am.h>
#include <klib.h>
#include <klib-macros.h>

#define RTC_BASE_ADDR 0x10004000
#define RTC_REG_CTRL  *((volatile uint32_t *)(RTC_BASE_ADDR))
#define RTC_REG_PSCR  *((volatile uint32_t *)(RTC_BASE_ADDR + 4))
#define RTC_REG_CNT   *((volatile uint32_t *)(RTC_BASE_ADDR + 8))
#define RTC_REG_ALRM  *((volatile uint32_t *)(RTC_BASE_ADDR + 12))
#define RTC_REG_ISTA  *((volatile uint32_t *)(RTC_BASE_ADDR + 16))
#define RTC_REG_SSTA  *((volatile uint32_t *)(RTC_BASE_ADDR + 20))

// fpga: apb4_clk: 50MHz rtc_clk: 6MHz
int main(){
    putstr("rtc test\n");

    RTC_REG_CTRL = (uint32_t)1;                   // enter config mode
    RTC_REG_PSCR = (uint32_t)(1000000 - 1);       // div 1000000 for 6Hz

    printf("CTRL: %d PSCR: %d\n", RTC_REG_CTRL, RTC_REG_PSCR);
    for(int i = 0; i < 6; ++i) {
        RTC_REG_CNT = (uint32_t)(123 * i);
        RTC_REG_ALRM = RTC_REG_CNT + 10;
        printf("[static]CNT: %d ALRM: %d\n", RTC_REG_CNT, RTC_REG_ALRM);
        if(RTC_REG_CNT != (uint32_t)(123 * i)) putstr("error\n");
    }

    RTC_REG_CNT  = (uint32_t)0;
    RTC_REG_CTRL = (uint32_t)0b0010010;           // core and inc trg en
    printf("CTRL: %d PSCR: %d\n", RTC_REG_CTRL, RTC_REG_PSCR);
    putstr("cnt inc test\n");
    for(int i = 0; i < 6; ++i) {
        while(RTC_REG_ISTA != (uint32_t)1);       // wait inc irq flag
        printf("RTC_REG_CNT: %d\n", RTC_REG_CNT); // inc 1 in 1/6s
    }
    putstr("cnt inc test done\n");
    putstr("alrm trigger test\n");

    RTC_REG_CTRL = (uint32_t)1; // enter config mode
    RTC_REG_CNT  = (uint32_t)0;
    RTC_REG_ALRM = RTC_REG_CNT + 6;
    for(int i = 0; i < 6; ++i) {
        RTC_REG_CTRL = (uint32_t)0b0010100;       // core and alrm trg en
        while(RTC_REG_ISTA != (uint32_t)2);       // wait alrm irq flag
        RTC_REG_CTRL = (uint32_t)1;               // enter config mode
        while(RTC_REG_ISTA != (uint32_t)0);       // clear the all irq flag
        printf("RTC_REG_CNT: %d\n", RTC_REG_CNT); // alrm trg every 1s
        RTC_REG_ALRM = RTC_REG_CNT + 6;
    }
    printf("CTRL: %d PSCR: %d\n", RTC_REG_CTRL, RTC_REG_PSCR);
    putstr("alrm trigger test done\n");
    putstr("rtc test done\n");

    return 0;
}
