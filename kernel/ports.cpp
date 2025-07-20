#include "ports.hpp"

void port_out(U16 port, U8 data) {
  asm volatile("out %0,%1" : : "d"(port), "a"(data) : "memory");
}

U8 port_in(U16 port) {
  U8 data;
  asm volatile("in %0,%1" : "=a"(data) : "d"(port) : "memory");
  return data;
}