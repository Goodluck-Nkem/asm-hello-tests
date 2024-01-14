.data
    MESSAGE: .ascii "MIPS 32-bit program assembled with GCC...\n"
.equ msgsz, .-MESSAGE

.global main
.text
main:
	addi $sp, -16				# allocate 16 bytes on stack
	
	# The next 2 lines loads a big-endian 4 byte message to sp buffer
	li $t0, 0x48692c20			# load the message "Hi, "
	sw $t0, 0($sp)				# place them in the sp buffer

    li $v0, 4004				# syscall number for write
	li $a0, 1					# stdout FD number
	move $a1, $sp  				# data address for the write
	li $a2, 4					# length of the data
    syscall 					# invoke the syscall
	
	# The next 2 lines loads effective address of MESSAGE
	lui $t0, %hi(MESSAGE)		# load hiword, zeroes loword
   	addi $t0, %lo(MESSAGE)		# place loword to get final address

    li $v0, 4004				# syscall number for write
	li $a0, 1					# stdout FD number
	move $a1, $t0				# data address for the write
	li $a2, msgsz				# length of the data
    syscall 					# invoke the syscall
	
	addi $sp, 16				# free the stack

exit:
	li $v0, 4001				# syscall number for exit
	li $a0, 0					# exit code
	syscall						# invoke the syscall

