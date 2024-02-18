.global	main

.equ STDOUT, 1

.bss
.p2align	3
year: .zero 8               	 // 0x0

.data
	
.text

// x9-x15 as scratch

.section .rodata.message
message: .asciz "Hello on AArch64!\n"
.equ SZ_message, .-message

.section .text.main                  
.p2align	2
main:                         
	sub	sp, sp, #16             // reserve aligned bytes on sp
	stp	fp, lr, [sp, #0]     	// save fp and lr to the stack
	add	fp, sp, #0				// fp = sp

	/* syscall write(fd, buf, sz) */
	movz x8, 0x40				// sys number for write
	movz x0, STDOUT				// (fd)
	adr x1, message				// (buf) load address (+/- 4GB)
	movz x2, SZ_message			// (sz)
	svc #0						// invoke the syscall

	/* full range address load */
	adrp x11, year				// load high 48 bits
	add	x11, x11, :lo12:year	// complete with lower 12 bits

	ldr x10, =0x30				// load reg with stored literal
	ldr x13, =0x05				// 
	mul x13, x13, x10			// multiply
	ldr x10, =0x08				//
	sdiv x13, x13, x10			// signed divide

	movz x13, #2024, lsl #0		// move imm16 with zero
	str x13, [x11]				// store in year

	ldp	fp, lr, [sp, #0]     	// restore fp and lr from stack
	add	sp, sp, #16             // reserve aligned bytes on sp

	mov x0, xzr					// set return code to 0
	ret 						// return from main

.section .note.GNU-stack
