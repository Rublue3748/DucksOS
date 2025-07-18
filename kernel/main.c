void print_debug(const char *str);
void infinite_halt(void);

void kmain() {
  print_debug("Hello world!");
  infinite_halt();
}

void print_debug(const char *str) {
  int i = 0;
  while (str[i] != '\0') {
    asm volatile("out %0,%1" : : "N"(0xE9), "a"(str[i]) : "memory");
    i++;
  }
}

void infinite_halt(void) {
  asm volatile("cli" : : : "memory");
  while (1) {
    asm volatile("hlt" : : : "memory");
  }
}