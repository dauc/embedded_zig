# Disable built-in rules and variables
MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --no-builtin-variables

BUILD_FLAGS = -O ReleaseSmall -target thumb-freestanding -mcpu cortex_m3
LINKER_SCRIPT = arm_cm3.ld
LD_FLAGS = --gc-sections -nostdlib
OBJS = startup.o main.o STM32F103xx.o stm32f10.o
PROG = firmware

# Need STM32F103xx.zig as a dep here so we gen the file before we try and compile anything depends
# on it existing.
%.o: %.zig STM32F103xx.zig
	zig build-obj ${BUILD_FLAGS} $<

${PROG}.hex: ${PROG}.elf
	arm-none-eabi-objcopy -O ihex $< $@

${PROG}.elf: ${OBJS}
	zig build-exe ${BUILD_FLAGS} $(OBJS:%=%) --name $@ --script ${LINKER_SCRIPT}
#	arm-none-eabi-ld ${OBJS} -o $@ -T ${LINKER_SCRIPT} -Map $@.map ${LD_FLAGS}

STM32F103xx.svd: svd2zig/zig-cache/bin/svd2zig
	curl https://raw.githubusercontent.com/posborne/cmsis-svd/master/data/STMicro/STM32F103xx.svd > STM32F103xx.svd

STM32F103xx.zig: STM32F103xx.svd
	svd2zig/zig-cache/bin/svd2zig $< > $@
	zig fmt $@

# https://github.com/justinbalexander/svd2zig
svd2zig/src/svd.zig svd2zig/src/main.zig:
	# This patch fixes up peripheral base addresses.
	git clone --single-branch --branch fix-derived-from git@github.com:rbino/svd2zig.git
	# git clone git@github.com:justinbalexander/svd2zig.git

svd2zig/zig-cache/bin/svd2zig: svd2zig/src/svd.zig svd2zig/src/main.zig
	cd svd2zig && zig build -Drelease-safe

# Regular-clean.  For clean-rebuilding the embedded application.
clean:
	rm -rf ${PROG}.* ${OBJS} $(OBJS:%.o=%.h) zig-cache STM32F103xx.*

# Really clean.  For testing make rules to build svd2zig.  Probably just `git clean -dxff` or
# whatever.
realclean: clean
	rm -rf svd2zig

.PHONY: clean
