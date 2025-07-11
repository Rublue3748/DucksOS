BOOTLOADER_ASMS = a20.asm bootloader.asm main.asm memory_map.asm video.asm protected_mode.asm kernel_setup.asm

bootloader: $(BOOTLOADER_ASMS)
	nasm -O0 bootloader.asm

clean:
	rm bootloader
