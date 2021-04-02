usingnamespace @import("STM32F103xx.zig");
const stm32 = @import("stm32f10.zig");

export fn main() void {
    stm32.SystemInit();

    // enable GPIOC clk
    RCC_APB2ENR_Ptr.* |= RCC_APB2ENR_IOPCEN(1);

    // PC13, Out PP 2MHz
    GPIOC_CRH_Ptr.* &= ~@as(u32, GPIOC_CRH_MODE13_Mask | GPIOC_CRH_CNF13_Mask);
    GPIOC_CRH_Ptr.* |= GPIOC_CRH_MODE13(2) | GPIOC_CRH_CNF13(0);

    while (true) {
        GPIOC_ODR_Ptr.* ^= GPIOC_ODR_ODR13_Mask;
        var i: u32 = 0;
        while (i < 1000000) {
            asm volatile ("nop");
            i += 1;
        }
    }
}
