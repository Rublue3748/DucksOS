#include "debug.hpp"
#include "ports.hpp"
#include <cstddef>

template <> void print_debug(const char *str) {
  size_t i = 0;
  while (str[i] != '\0') {
    port_out(DEBUG_PORT, str[i]);
    i++;
  }
}