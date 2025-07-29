BUILD_DIR ?= build

KERNEL_SOURCES = $(wildcard *.c) $(wildcard *.cpp)
KERNEL_OBJS = $(patsubst %.cpp,$(BUILD_DIR)/%.o,$(patsubst %.c,$(BUILD_DIR)/%.o,$(KERNEL_SOURCES)))
KERNEL_DEPS = $(patsubst %.cpp,$(BUILD_DIR)/%.d,$(patsubst %.c,$(BUILD_DIR)/%.d,$(KERNEL_SOURCES)))

WARNINGS = -Wall -Wextra -pedantic
OPTIMIZATIONS = -g -O0
MAKEFILE_DEPS_OPTIONS = -MT $@ -MMD -MP -MF $(BUILD_DIR)/$*.d
GENERAL_OPTIONS = $(WARNINGS) $(OPTIMIZATIONS) $(MAKEFILE_DEPS_OPTIONS) -masm=intel -ffreestanding

CSTD = -std=c99
CFLAGS = $(CSTD) $(GENERAL_OPTIONS)

CPPSTD = -std=c++14
CPPFLAGS = -fno-exceptions -fno-rtti $(CPPSTD) $(GENERAL_OPTIONS)

.PHONY: clean

$(BUILD_DIR)/kernel.a: $(KERNEL_OBJS) | $(BUILD_DIR)
	ar rcs $@ $^

$(BUILD_DIR)/%.o: %.cpp $(BUILD_DIR)/%.d | $(BUILD_DIR)
	i686-elf-g++ $(CPPFLAGS) -c $< -o $@

$(BUILD_DIR)/%.o: %.c $(BUILD_DIR)/%.d | $(BUILD_DIR)
	i686-elf-gcc $(CFLAGS) -c $< -o $@

$(BUILD_DIR):
	mkdir $(BUILD_DIR)

$(KERNEL_DEPS):

test:
	echo $(KERNEL_SOURCES)
	echo $(KERNEL_OBJS)
	echo $(KERNEL_DEPS)

clean:
	rm ./$(BUILD_DIR)/*.o ./$(BUILD_DIR)/*.a ./$(BUILD_DIR)/*.d *.a *.o *.d

include $(KERNEL_DEPS)