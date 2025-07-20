.PHONY: clean
CPPSTD = -std=c++11
WARNINGS = -Wall -Wextra -pedantic
OPTIMIZATIONS = -g -O0
COMPILE_FLAGS = -masm=intel -ffreestanding -fno-exceptions -fno-rtti $(CPPSTD) $(WARNINGS) $(OPTIMIZATIONS)


kernel.a: main.o debug.o ports.o
	ar rcs $@ $^

%.o: %.cpp
	i686-elf-g++ $(COMPILE_FLAGS) -c $< -o $@

clean:
	rm *.o *.a