BUILD_DIR ?= build
BOOTLOADER_ASMS = a20.asm main.asm memory_map.asm video.asm protected_mode.asm kernel_setup.asm
BOOTLOADER_OBJS = $(patsubst %.asm,$(BUILD_DIR)/%.o,$(BOOTLOADER_ASMS))
BOOTLOADER_DEPS = $(patsubst %.asm,$(BUILD_DIR)/%.d,$(BOOTLOADER_ASMS))

WARNINGS = -Wall
MAKEFILE_DEPENDENCY_VARS = -MT $@ -MD -MP -MF $(BUILD_DIR)/$*.d
GENERAL_ASM_OPTIONS = $(WARNINGS)
BOOTSECTOR_OPTIONS = $(GENERAL_ASM_OPTIONS)
BOOTLOADER_OPTIONS = $(GENERAL_ASM_OPTIONS) $(MAKEFILE_DEPENDENCY_VARS) -felf --gprefix BOOTLOADER_ --lprefix BOOTLOADER_ 

NUM_SECTORS ?= 20

$(BUILD_DIR)/bootloader.a: $(BOOTLOADER_OBJS) | $(BUILD_DIR)
	ar rcs $@ $^

$(BUILD_DIR)/bootsector: bootsector.asm $(BUILD_DIR)/bootloader.a | $(BUILD_DIR)
	nasm -O0 $< -o $@ $(BOOTSECTOR_OPTIONS) -DNUM_SECTORS=$(NUM_SECTORS)

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.asm $(BUILD_DIR)/%.d | $(BUILD_DIR)
	nasm -O0 $< -o $@ $(BOOTLOADER_OPTIONS) 
clean:
	rm ./$(BUILD_DIR)/*.a ./$(BUILD_DIR)/bootsector ./$(BUILD_DIR)/*.o ./$(BUILD_DIR)/*.d


$(BOOTLOADER_DEPS):

include $(BOOTLOADER_DEPS)