.PHONY: run

BOOTLOADER_ASMS = a20.asm bootloader.asm main.asm memory_map.asm

run: bootloader
	bochs -f bochs_config -debugger

bootloader: $(BOOTLOADER_ASMS)
	nasm -O0 bootloader.asm
	dd if=/dev/null of=bootloader bs=1 count=1 seek=161280