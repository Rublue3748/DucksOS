void print_debug(const char *str);

extern int *BOOTLOADER_Memory_Map_Pointer;

int x = 5;

int main() {
  print_debug("Hello world!");
  *BOOTLOADER_Memory_Map_Pointer = 5;
  return 0;
}

void print_debug(const char *str) {
  int i = 0;
  while (str[i] != '\0') {
    asm volatile("out %0,%1" : : "N"(0xE9), "a"(str[i]) : "memory");
  }
}