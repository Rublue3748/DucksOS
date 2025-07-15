.PHONY: clean

kernel.a: main.o
	ar rcs $@ $^

%.o: %.c
	i686-elf-gcc -masm=intel -ffreestanding -O0 -g -c $< -o $@

clean:
	rm *.o *.a