#pragma once
#include "data_types.hpp"

void __attribute__((noinline)) port_out(U16 port, U8 data);
U8 __attribute__((noinline)) port_in(U16 port);