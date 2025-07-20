#include "bootloader_vars.hpp"
#include "debug.hpp"

void infinite_halt(void);

extern "C" void kmain() {
  print_debug("Hello world!\n\r");
  print_debug("Test: ");
  print_debug<U8>((U8)100);
  print_debug("\n\r");
  print_debug("The address of the memory map is: ");
  print_debug<U32>(BOOTLOADER_Memory_Map_Pointer);
  print_debug("\n\r");
  infinite_halt();
}

void infinite_halt(void) {
  asm volatile("cli" : : : "memory");
  while (1) {
    asm volatile("hlt" : : : "memory");
  }
}