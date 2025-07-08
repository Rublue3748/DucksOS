.PHONY: run

run: bootloader
	bochs -f bochs_config

bootloader: bootloader.asm
	nasm -O0 bootloader.asm
	dd if=/dev/null of=bootloader bs=1 count=1 seek=161280