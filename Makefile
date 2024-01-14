# All binaries will be runnable on Linux

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

yasm:

x64:

x86:

arm:

aarch64:

uasm64:

uasm32:

clean:
	rm $(wildcard *.prog)

