BOOTLOADER_DIR = bootloader
BOOTLOADER_OUTPUT = $(BOOTLOADER_DIR)/bootloader

.PHONY: run clean $(BOOTLOADER_OUTPUT)

run: final.img
	bochs -f bochs_config -debugger

final.img: $(BOOTLOADER_OUTPUT)
	dd if=/dev/null of=$(BOOTLOADER_OUTPUT) bs=1 count=1 seek=161280
	cp $(BOOTLOADER_OUTPUT) final.img

$(BOOTLOADER_OUTPUT):
	$(MAKE) -C bootloader

clean:
	-rm final.img
	-$(MAKE) -C bootloader clean