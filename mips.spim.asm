.data
    MESSAGE: .asciiz "Running MIPS code, built by SPIM ...\n"
    
.text
main:
    li $v0, 4					# sys number for write on SPIM and MARS
    la $a0, MESSAGE				# load a C string
    syscall 					# invoke the syscall (prints message)

exit:
    li $v0, 10					# sys number for exit on SPIM and MARS
	li $a0, 0 					# exit code
    syscall 					# invoke the syscall (exits program)

