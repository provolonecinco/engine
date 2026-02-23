.PHONY: all clean dir run gfx

OUTPUT := output

MESEN := "C:\Programs\Mesen\Mesen.exe"
SUPERFAMICONV := C:\Programs\superfamiconv_win64_v0.10.0\superfamiconv.exe

SRCDIR	:= src
ROM_NAME := $(OUTPUT)/engine.sfc
DBG_NAME := $(OUTPUT)/engine.dbg
OBJ_DIR := $(OUTPUT)/obj

# Specify files to build the ROM
SRC_FILES := $(wildcard $(SRCDIR)/*.s)
OBJ_FILES := $(patsubst $(SRCDIR)/%.s, $(OBJ_DIR)/%.o, $(SRC_FILES))

all: $(ROM_NAME)

clean:
	@rmdir /s /q output

dir:
	@mkdir output
	@mkdir output\obj

run: $(ROM_NAME)
	 @start $(MESEN) $(ROM_NAME)

# Link output files into ROM
$(ROM_NAME): $(OBJ_FILES)
	@ld65 -m output/map.txt --dbgfile $(DBG_NAME) -o $@ -C lorom256k.cfg $^

# Assemble 65816 code
$(OBJ_DIR)/%.o: $(SRCDIR)/%.s
	@ca65 -s -g $< -o $@