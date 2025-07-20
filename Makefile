BUILD_DIR = build
BOOTLOADER_DIR = bootloader
BOOTLOADER_OUTPUT = $(BOOTLOADER_DIR)/$(BUILD_DIR)/bootloader.a
BOOTSECTOR_OUTPUT = $(BOOTLOADER_DIR)/$(BUILD_DIR)/bootsector

KERNEL_DIR = kernel
KERNEL_OUTPUT = $(KERNEL_DIR)/$(BUILD_DIR)/kernel.a

.PHONY: debug clean $(BOOTLOADER_OUTPUT) $(KERNEL_OUTPUT) $(BOOTSECTOR_OUTPUT)

debug: final.img symbols.sym
	bochs -f bochs_config -debugger

final.img: $(BOOTSECTOR_OUTPUT) bootloader.bin kernel.elf
	./build_img.sh $(BUILD_DIR)

$(BOOTSECTOR_OUTPUT): bootloader.bin # Needs the size of the second stage bootloader passed as the number of sectors
	$(MAKE) -C $(BOOTLOADER_DIR) $(BUILD_DIR)/bootsector NUM_SECTORS=$$(($$(stat -c %s bootloader.bin)/512 + 1)) BUILD_DIR=$(BUILD_DIR)

bootloader.bin: full_image.elf
	objcopy -O binary --remove-section=* --keep-section=.boot* $^ $@

kernel.elf: full_image.elf
	objcopy --strip-all --remove-section=.boot* $^ $@

symbols.sym: full_image.elf
	objdump -t $< | \
	grep -E '^([0-9]|[a-f]|[A-F]){8}' |\
	sed --regexp-extended -f symbol.sed > $@


full_image.elf: $(BOOTLOADER_OUTPUT) $(KERNEL_OUTPUT)
	i686-elf-gcc -T linker.ld -ffreestanding -O0 -g -nostdlib -o $@ -Wl,--whole-archive -Wl,-z -Wl,separate-code $^ -Wl,--no-whole-archive -lgcc

$(BOOTLOADER_OUTPUT):
	$(MAKE) -C $(BOOTLOADER_DIR) BUILD_DIR=$(BUILD_DIR)

$(KERNEL_OUTPUT):
	$(MAKE) -C $(KERNEL_DIR) BUILD_DIR=$(BUILD_DIR)


clean:
	-rm final.img *.elf *.bin *.sym
	-$(MAKE) -C $(BOOTLOADER_DIR) clean BUILD_DIR=$(BUILD_DIR)
	-$(MAKE) -C $(KERNEL_DIR) clean BUILD_DIR=$(BUILD_DIR)