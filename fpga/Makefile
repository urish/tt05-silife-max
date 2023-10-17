SOURCE_FILES = fpga_top.v uart_rx.v uart_tx.v rpll.v $(wildcard ../src/*.v)
TARGET = impl/pnr/project.fs
GW_SH = $(GOWIN_HOME)/IDE/bin/gw_sh

$(TARGET): $(SOURCE_FILES)
	$(GW_SH) project.tcl

.PHONY: all
all: $(TARGET)

.PHONY: sram
sram: $(TARGET)
	openFPGALoader $(TARGET)

.PHONY: flash
flash: $(TARGET)
	openFPGALoader -f $(TARGET)

.PHONY: clean
clean:
	rm -rf impl
