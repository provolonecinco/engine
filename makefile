.PHONY: all clean dir run

OUTPUT := output

MESEN := "Mesen.exe"

SRCDIR	:= src
ROM_NAME := $(OUTPUT)/engine.sfc
DBG_NAME := $(OUTPUT)/engine.dbg
OBJ_DIR := $(OUTPUT)/obj

# Specify files to build the ROM
SRC_FILES := $(wildcard $(SRCDIR)/*.s)
OBJ_FILES := $(patsubst $(SRCDIR)/%.s, $(OBJ_DIR)/%.o, $(SRC_FILES))

all: dir $(ROM_NAME)

clean:
	@rmdir /s /q output

dir:
	@if not exist "$(OUTPUT)" mkdir $(OUTPUT)
	@if not exist "$(OBJ_DIR)" mkdir "$(OBJ_DIR)"

run: dir $(ROM_NAME)
	 @start $(MESEN) $(ROM_NAME)

# Link output files into ROM
$(ROM_NAME): $(OBJ_FILES)
	@ld65 -m output/map.txt --dbgfile $(DBG_NAME) -o $@ -C lorom256k.cfg $^

# Assemble 65816 code
$(OBJ_DIR)/%.o: $(SRCDIR)/%.s
	@ca65 -s -g $< -o $@