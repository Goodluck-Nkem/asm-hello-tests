none:
	@echo "Must choose an option!"

mips.gcc:
	mips-linux-gnu-gcc-12 -g mips.gcc.s -o mips.gcc.prog
	qemu-mips mips.gcc.prog

mips.spim:
	spim -f mips.spim.asm

mips64:

riscv:

nasm:
	nasm -gdwarf -f elf64 x64.nasm.asm -o x64.nasm.asm.o
	x86_64-linux-gnu-ld x64.nasm.asm.o -o x64.nasm
	qemu-x86_64 x64.nasm

yasm:

x64:

x86:

arm:

aarch64:

jwasm64:
	qemu-i386 ~/JWasm/jwasm -win64 Win64_hello.asm
	qemu-i386 ~/JWasm/jwasm -win64 Win64_console_msgbox.asm
	qemu-i386 ~/JWlink/jwlink format win pe ru win file Win64_hello op start=CustomEntry
	qemu-i386 ~/JWlink/jwlink format win pe ru win file Win64_console_msgbox op start=CustomEntry

jwasm32:

clean:
	rm  $(wildcard *.exe) $(wildcard *.prog)

