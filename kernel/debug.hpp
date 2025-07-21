#pragma once
#include "ports.hpp"
#include <cstddef>

void debug_printf(const char *format, ...);
void debug_putc(char c);

// template <typename T> void print_debug(T value);
// template <> void print_debug(const char *str);

// template <typename T> void print_debug(T value) {
//   print_debug("0x");
//   for (size_t i = 0; i < sizeof(T) * 8; i += 4) {
//     size_t shift_amount = sizeof(T) - (i + 8);
//     port_out(DEBUG_PORT,
//              static_cast<U8>(((value >> shift_amount) & 0xF) + '0'));
//   }
// }
