#pragma once
#include <cstdint>

typedef uint8_t U8;
typedef uint16_t U16;
typedef uint32_t U32;
typedef uint64_t U64;

typedef int8_t S8;
typedef int16_t S16;
typedef int32_t S32;
typedef int64_t S64;

typedef uint8_t P8;
typedef uint16_t P16;
typedef uint32_t P32;
typedef uint64_t P64;

void *P8_To_Pointer(P8);
void *P16_To_Pointer(P16);
void *P32_To_Pointer(P32);
void *P64_To_Pointer(P64);