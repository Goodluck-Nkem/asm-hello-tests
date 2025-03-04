none:
	@echo "Must choose an option!"

mips.gcc:
	mips-linux-gnu-gcc-12 -g mips.gcc.s -o mips.gcc.prog
	qemu-mips mips.gcc.prog

mips.spim:
	spim -f mips.spim.asm

mips64.gcc:

riscv.gcc:

x64.nasm:
	nasm -gdwarf -f elf64 x64.nasm.asm -o x64.nasm.asm.o
	x86_64-linux-gnu-ld x64.nasm.asm.o -o x64.nasm.prog
	qemu-x86_64 x64.nasm.prog

x64.yasm:

x64.gcc:

x86.nasm:
	nasm -gdwarf -f elf32 x86-nasm.asm -o x86-nasm.asm.o
	i686-linux-gnu-ld x86-nasm.asm.o -o x86-nasm.prog
	qemu-i386 x86-nasm.prog
x86.gcc:

arm.gcc:

aarch64.gcc:
	aarch64-linux-gnu-gcc-13 -g -fpic aarch64.s -o aarch64.prog
	qemu-aarch64 aarch64.prog

x64.jwasm:
	qemu-i386 ~/JWasm/jwasm -win64 Win64_hello.asm
	qemu-i386 ~/JWasm/jwasm -win64 Win64_console_msgbox.asm
	qemu-i386 ~/JWlink/jwlink format win pe ru win file Win64_hello op start=CustomEntry
	qemu-i386 ~/JWlink/jwlink format win pe ru win file Win64_console_msgbox op start=CustomEntry

x86.jwasm:

clean:
	rm -f $(wildcard *.exe) $(wildcard *.prog) $(wildcard *.o)

