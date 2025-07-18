BOOTLOADER_ASMS = a20.asm main.asm memory_map.asm video.asm protected_mode.asm kernel_setup.asm
BOOTLOADER_OBJS = $(patsubst %.asm,%.o,$(BOOTLOADER_ASMS))

bootloader.a: $(BOOTLOADER_OBJS)
	ar rcs $@ $^

bootsector: bootsector.asm bootloader.a
	nasm -O0 bootsector.asm -o bootsector -Wall -DNUM_SECTORS=$(NUM_SECTORS)

%.o: %.asm
	nasm -O0 $< -o $@ -felf -Wall --gprefix BOOTLOADER_ --lprefix BOOTLOADER_

clean:
	rm *.a bootsector *.o 
