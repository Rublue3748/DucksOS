#include "bootloader_vars.hpp"
#include "debug.hpp"

void infinite_halt(void);

extern "C" void kmain() {
    debug_printf("Hello world!\n\r");
    debug_printf("Testing string printing: %s\n\r", "This is a test string!");
    debug_printf("Testing printing a decimal number: %d\n\r", 25328);
    debug_printf("The video info is stored at %p\n\r", BOOTLOADER_Video_Mode_Ptr);
    infinite_halt();
}

void infinite_halt(void) {
    asm volatile("cli" : : : "memory");
    while (1) {
        asm volatile("hlt" : : : "memory");
    }
}