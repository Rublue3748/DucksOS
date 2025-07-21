#include "debug.hpp"
#include "data_types.hpp"
#include "ports.hpp"
#include <cstdarg>
#include <cstddef>
#include <cstdint>

constexpr U16 DEBUG_PORT = 0xE9;

void debug_print_string(const char *str);
void debug_print_int(S32 val);
void debug_print_uint(U32 val);
void debug_print_pointer(P32 val);

// template <> void print_debug(const char *str) {
//   size_t i = 0;
//   while (str[i] != '\0') {
//     port_out(DEBUG_PORT, str[i]);
//     i++;
//   }
// }

void debug_printf(const char *format, ...) {
    va_list list;
    va_start(list, format);
    bool is_specifier = false;
    for (size_t i = 0; format[i] != '\0'; i++) {
        char c = format[i];
        if (is_specifier) {
            is_specifier = false;
            if (c == 's') {
                const char *str = va_arg(list, const char *);
                debug_print_string(str);
            } else if (c == 'd') {
                S32 val = va_arg(list, S32);
                debug_print_int(val);
            } else if (c == 'u') {
                U32 val = va_arg(list, U32);
                debug_print_uint(val);
            } else if (c == 'p') {
                P32 val = va_arg(list, P32);
                debug_print_pointer(val);
            } else if (c == '%') {
                debug_putc('%');
            }
        } else {
            switch (c) {
            case '%':
                is_specifier = true;
                break;
            default:
                debug_putc(c);
            }
        }
    }
    va_end(list);
}

void debug_print_string(const char *str) {
    size_t i = 0;
    while (str[i] != '\0') {
        debug_putc(str[i]);
        i++;
    }
}

void debug_print_int(S32 val) {
    if (val < 0) {
        debug_putc('-');
        val *= -1;
    }
    debug_print_uint(val);
}
void debug_print_uint(U32 val) {
    if (val == 0) {
        debug_putc('0');
        return;
    }
    while (val != 0) {
        int top_digit = val;
        size_t tens_place = 0;
        while (top_digit / 10 != 0) {
            top_digit /= 10;
            tens_place++;
        }
        debug_putc(static_cast<char>(top_digit) + '0');
        int temp = 1;
        for (size_t i = 0; i < tens_place; i++) {
            temp *= 10;
        }
        val %= temp;
    }
}
void debug_print_pointer(P32 val) {
    for (size_t shift_amount = 28; shift_amount < 32; shift_amount -= 4) {
        P32 shifted_value = (val >> shift_amount) & 0xF;
        char c = shifted_value + '0';
        debug_putc(c);
    }
}

void debug_putc(char c) { port_out(DEBUG_PORT, c); }