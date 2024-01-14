.data
    LC0: .ascii "MIPS 32-bit program assembled with GCC...\n"
.equ msgsz, .-LC0

MESSAGE: .word LC0

.global main
.text
main:
	addi $sp, -16				# allocate 16 bytes on stack
	
	li $t0, 0x48692c20			# load a 4 byte message
	sw $t0, 0($sp)				# place them in the sp buffer

    li $v0, 4004				# syscall number for write
	li $a0, 1					# stdout FD number
	move $a1, $sp  				# data address for the write
	li $a2, 4					# length of the data
    syscall 					# invoke the syscall
	
	# The next 2 lines loads effective address of LC0_MESSAGE
	lui $t0, %hi(MESSAGE)		# load hiword, zero loword
   	lw  $t0, %lo(MESSAGE)($t0)	# offset with the loword

    li $v0, 4004				# syscall number for write
	li $a0, 1					# stdout FD number
	move $a1, $t0				# data a7ddress for the write
	li $a2, msgsz				# length of the data
    syscall 					# invoke the syscall
	
	addi $sp, 16				# free the stack

exit:
	li $v0, 4001				# syscall number for exit
	li $a0, 0					# exit code
	syscall						# invoke the syscall

