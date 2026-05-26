# ND-100 Compile and Test Tool
# Uses nd100x emulator and ndtool for disk image management

# Emulator settings
EMU        = nd100x
BOOT_TYPE  = smd
HDLC_PORT  = 1:5000

# Disk images
SMD_IMAGE  = SMD0.IMG
RUN_IMAGE  = BIGDISK0-L2-100.IMG

# Tools
NDTOOL     = ndtool

# Program name (override with make PROG=NAME or use convenience targets)
PROG       = planc-hello-world

# Directories
PROG_DIR   = programs/$(PROG)
SCRIPT_DIR = scripts

# Local files
LOAD_MODE  = $(SCRIPT_DIR)/LOAD-MODE.MODE
DO_BUILD   = $(PROG_DIR)/DO-BUILD.MODE

.PHONY: run build deploy clean hello ftn-xmsg-1 ftn-xmsg-1-run 1 1-run 2 2-run

# Aliases
1: hello
1-run:
	$(MAKE) deploy PROG=planc-hello-world
2: ftn-xmsg-1
2-run: ftn-xmsg-1-run

# Convenience targets
hello:
	$(MAKE) build PROG=planc-hello-world

ftn-xmsg-1:
	$(MAKE) build PROG=ftn-xmsg-1

ftn-xmsg-1-run:
	$(MAKE) deploy PROG=ftn-xmsg-1

run:
	$(NDTOOL) -f --rm SYSTEM/LOAD-MODE:MODE $(SMD_IMAGE) || true
	$(EMU) --boot=$(BOOT_TYPE) --hdlc=$(HDLC_PORT)

build:
	@echo "=== Building $(PROG) ==="
	@test -f $(DO_BUILD) || { echo "ERROR: $(DO_BUILD) not found"; exit 1; }
	@for f in $(PROG_DIR)/*; do \
		name=$$(basename "$$f"); \
		ndfs_name=$$(echo "$$name" | sed 's/\./:/'); \
		$(NDTOOL) -p --overwrite --put "$$f" --dest BUILD "$$ndfs_name" $(SMD_IMAGE); \
	done
	$(NDTOOL) -p --overwrite --put $(LOAD_MODE) --dest SYSTEM LOAD-MODE:MODE $(SMD_IMAGE)
	$(EMU) --boot=$(BOOT_TYPE) --hdlc=$(HDLC_PORT)
	@echo "=== Extracting build artifacts ==="
	$(NDTOOL) -x --overwrite -F 'BUILD/*:PROG' -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || true
	$(NDTOOL) -x --overwrite -F 'BUILD/*:BRF' -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || true
	$(NDTOOL) -x --overwrite -F 'BUILD/*:LIST' -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || true
	$(NDTOOL) -p -x --overwrite -F 'BUILD/*:TXT' -o $(PROG_DIR)/ $(SMD_IMAGE) 2>/dev/null || true

deploy:
	@echo "=== Deploying $(PROG) to run image ==="
	$(NDTOOL) --useradd RUN 500 $(RUN_IMAGE) 2>/dev/null || true
	@for f in $(PROG_DIR)/*.PROG; do \
		name=$$(basename "$$f"); \
		ndfs_name=$$(echo "$$name" | sed 's/\./:/'); \
		$(NDTOOL) --overwrite --put "$$f" --dest RUN "$$ndfs_name" $(RUN_IMAGE); \
	done
	$(EMU) --boot=$(BOOT_TYPE) --hdlc=$(HDLC_PORT) --smd0=$(RUN_IMAGE)

clean:
	cp $(SMD_IMAGE).bak $(SMD_IMAGE)
	$(NDTOOL) --useradd BUILD 500 $(SMD_IMAGE)
	cp $(RUN_IMAGE).bak $(RUN_IMAGE)
