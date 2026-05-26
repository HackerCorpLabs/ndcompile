# ND-100 Compile and Test Tool
# Uses nd100x emulator and ndtool for disk image management

# Emulator settings
EMU        = nd100x
BOOT_TYPE  = smd
HDLC_PORT  = 1:5000

# Disk image
SMD_IMAGE  = SMD0.IMG

# Tools
NDTOOL     = ndtool

# Program name (override with make PROG=NAME or use convenience targets)
PROG       = HELLO

# Directories
PROG_DIR   = programs/$(PROG)
SCRIPT_DIR = scripts

# Local files
LOAD_MODE  = $(SCRIPT_DIR)/LOAD-MODE.MODE
DO_BUILD   = $(SCRIPT_DIR)/DO-BUILD.MODE
SOURCE     = $(PROG_DIR)/$(PROG).PLNC

.PHONY: run build clean hello

# Convenience targets
hello:
	$(MAKE) build PROG=HELLO

run:
	$(NDTOOL) -f --rm SYSTEM/LOAD-MODE:MODE $(SMD_IMAGE) || true
	$(EMU) --boot=$(BOOT_TYPE) --hdlc=$(HDLC_PORT)

build:
	@echo "=== Building $(PROG) ==="
	@printf '@DELETE-FILE $(PROG):PROG\r\n@DELETE-FILE $(PROG):LIST\r\n@DELETE-FILE $(PROG):BRF\r\n@PLANC\r\nPROG-FILE "$(PROG)"\r\nCOMPILE $(PROG):PLNC,"$(PROG):LIST","$(PROG)"\r\nEXIT\r\n@$(PROG)\r\n' > $(DO_BUILD)
	$(NDTOOL) -p --overwrite --put $(SOURCE) --dest BUILD $(PROG):PLNC $(SMD_IMAGE)
	$(NDTOOL) -p --overwrite --put $(DO_BUILD) --dest BUILD DO-BUILD:MODE $(SMD_IMAGE)
	$(NDTOOL) -p --overwrite --put $(LOAD_MODE) --dest SYSTEM LOAD-MODE:MODE $(SMD_IMAGE)
	$(EMU) --boot=$(BOOT_TYPE) --hdlc=$(HDLC_PORT)
	@echo "=== Extracting logs and binary ==="
	$(NDTOOL) -p -x -F BUILD-LOG:TXT -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || true
	$(NDTOOL) -p -x -F RUN-LOG:TXT -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || true
	$(NDTOOL) -x -F $(PROG):PROG -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || \
	$(NDTOOL) -x -F $(PROG):BPUN -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || \
	echo "No binary found for $(PROG)"

clean:
	cp $(SMD_IMAGE).bak $(SMD_IMAGE)
	$(NDTOOL) --useradd BUILD 500 $(SMD_IMAGE)
