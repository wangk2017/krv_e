RISCV_BIN ?= ${ZEPHYR_SDK_INSTALL_DIR}/sysroots/x86_64-pokysdk-linux/usr/bin/riscv32-zephyr-elf/riscv32-zephyr-elf-
RISCV_CC=${RISCV_BIN}gcc
RISCV_OBJCOPY=${RISCV_BIN}objcopy
RISCV_OBJDUMP=${RISCV_BIN}objdump

PROJ_NAME=coremark
DEBUG=no
MULDIV?=yes
COMPRESSED?=no



MARCH := RV32I
ifeq ($(MULDIV),yes)
	MARCH := $(MARCH)M
endif
ifeq ($(COMPRESSED),yes)
	MARCH := $(MARCH)AC
endif

ifeq ("$(ITERATIONS)","")
ITERATIONS=1
endif

FLAGS = -O2 -funroll-loops -fpeel-loops -fgcse-sm -fgcse-las
FLAGS_STR = "$(FLAGS)"

CFLAGS = -DFLAGS_STR=\"$(FLAGS_STR)\" 
CFLAGS += -march=$(MARCH)
CFLAGS += -fno-inline -fno-common
CFLAGS += -DTIME -DCORE_HZ=25000000ll
CFLAGS += -DITERATIONS=$(ITERATIONS)




SRCS = src/core_portme.c ../common/stdlib.c src/core_list_join.c src/core_matrix.c src/core_main.c src/core_util.c ./src/core_state.c  ../common/start.S
#../common/stdlib.c
LDFLAGS += -lc
LDSCRIPT = ../common/mapping.ld

CFLAGS += -I${ZEPHYR_SDK_INSTALL_DIR}/sysroots/riscv32-zephyr-elf/usr/include
LDFLAGS += -L${ZEPHYR_SDK_INSTALL_DIR}/sysroots/riscv32-zephyr-elf/usr/lib/riscv32-zephyr-elf/6.1.0
LDFLAGS += -L${ZEPHYR_SDK_INSTALL_DIR}/sysroots/riscv32-zephyr-elf/usr/lib



ifeq ($(DEBUG),yes)
	CFLAGS += -g3 -O0 
endif

ifeq ($(DEBUG),no)
	CFLAGS += -O3
endif


LDFLAGS +=  -nostdlib -lgcc -nostartfiles -ffreestanding -Wl,-Bstatic,-T,$(LDSCRIPT),-Map,$(OBJDIR)/$(PROJ_NAME).map,--print-memory-usage

OBJDIR = build
OBJS := $(SRCS)
OBJS := $(OBJS:.c=.o)
OBJS := $(OBJS:.cpp=.o)
OBJS := $(OBJS:.S=.o)
OBJS := $(OBJS:..=miaou)
OBJS := $(addprefix $(OBJDIR)/,$(OBJS))


#all: $(OBJDIR)/$(PROJ_NAME).elf $(OBJDIR)/$(PROJ_NAME).hex $(OBJDIR)/$(PROJ_NAME).asm $(OBJDIR)/$(PROJ_NAME).bin
all: $(OBJDIR)/software.elf $(OBJDIR)/software.hex $(OBJDIR)/software.asm $(OBJDIR)/software.bin

$(OBJDIR)/%.elf: $(OBJS) | $(OBJDIR)
	$(RISCV_CC) $(CFLAGS) -o $@ $^ $(LDFLAGS) $(LIBS)

%.hex: %.elf
	$(RISCV_OBJCOPY) -O ihex $^ $@

%.bin: %.elf
	$(RISCV_OBJCOPY) -O binary $^ $@
	
%.v: %.elf
	$(RISCV_OBJCOPY) -O verilog $^ $@
	
	
	
%.asm: %.elf
	$(RISCV_OBJDUMP) -S -d $^ > $@

$(OBJDIR)/%.o: %.c
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^
	
$(OBJDIR)/%.o: %.cpp
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS)  $(INC) -o $@ $^	

$(OBJDIR)/%.o: %.S
	mkdir -p $(dir $@)
	$(RISCV_CC) -c $(CFLAGS) -o $@ $^ -D__ASSEMBLY__=1

$(OBJDIR):
	mkdir -p $@

clean:
	rm -f $(OBJDIR)/software.elf
	rm -f $(OBJDIR)/software.hex
	rm -f $(OBJDIR)/software.map
	rm -f $(OBJDIR)/software.v
	rm -f $(OBJDIR)/software.bin
	rm -f $(OBJDIR)/software.asm
	rm -rf ./common
	rm -rf $(OBJDIR)

.SECONDARY: $(OBJS)
