all: payload.bin

crt.o: crt.asm
	yasm -f elf64 -o $@ $<

payload.elf: crt.o source/main.c source/decrypt.c source/decryptio.c source/encryptsrv.c source/checkheaders.c
	gcc -Wl,-z,max-page-size=16384,-z,common-page-size=16384 -Os -nostdlib -nostdinc -Iinclude crt.o source/main.c source/decrypt.c source/decryptio.c source/encryptsrv.c source/checkheaders.c -fPIE -fno-stack-protector -o payload.elf

payload.bin: payload.elf
	objcopy --only-section .text --only-section .rodata --only-section .data --only-section .bss -O binary payload.elf payload.bin
	file 'payload.bin' | fgrep -q 'payload.bin: DOS executable (COM)'

clean:
	rm -f payload.elf payload.bin crt.o

install: payload.bin
	cp payload.bin ../root/
