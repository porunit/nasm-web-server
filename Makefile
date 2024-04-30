# Объявляем переменные
ASM = nasm
ASM_FLAGS = -f elf64
LD = ld
LD_FLAGS = -m elf_x86_64

BUILD_PATH = build/debug/

all: main

main.o: main.asm inc/server.inc
	$(ASM) $(ASM_FLAGS) -o $(BUILD_PATH)main.o main.asm

server.o: src/server.asm inc/parser.inc
	$(ASM) $(ASM_FLAGS) -o $(BUILD_PATH)server.o src/server.asm

parser.o: src/parser.asm inc/controllers.inc
	$(ASM) $(ASM_FLAGS) -o $(BUILD_PATH)parser.o src/parser.asm

controllers.o: src/controllers.asm inc/sender.inc
	$(ASM) $(ASM_FLAGS) -o $(BUILD_PATH)controllers.o src/controllers.asm

sender.o: src/sender.asm 
	$(ASM) $(ASM_FLAGS) -o $(BUILD_PATH)sender.o src/sender.asm
	
main: main.o server.o parser.o sender.o controllers.o
	$(LD) $(LD_FLAGS) -o build/main $(BUILD_PATH)main.o $(BUILD_PATH)server.o $(BUILD_PATH)parser.o $(BUILD_PATH)sender.o $(BUILD_PATH)controllers.o

clean:
	rm -f build/main $(BUILD_PATH)*.o

build:
	make clean; make

dev:
	make clean; make; build/main