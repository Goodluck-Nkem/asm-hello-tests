; linux i386 calls
SYS_read equ 0x3     ; SYS_write(fd, msg, len)
SYS_write equ 0x4    ; SYS_read(fd, msg, len)
SYS_exit equ 0x1     ; SYS_exit(code)

; standard file descriptors
STDIN_fd equ 0
STDOUT_fd equ 1
STDERR_fd equ 2
BUFLEN equ 256

section .rodata
    str1 db "Enter value: "
    len1 equ $-str1
    str2 db "Enter message: "
    len2 equ $-str2
    str3 db "Current message: "
    len3 equ $-str3

section .bss
    input_buf resb 256
    shift resb 1
    single_char resb 1

section .text
    global _start

; volatile:	 eax, ecx, edx
; saved:	 esp, ebp, ebx, esi, edi

; syscall: ret & NR=eax, args=[ebx,ecx,edx,esi,edi,ebp]

; PROC _start
_start:
	sub esp, 16
enter_value:
    mov eax, SYS_write		;NR
    mov ebx, STDOUT_fd		;a1
    mov ecx, str1			;a2
    mov edx, len1			;a3
    int 0x80 				;write()

    call read_value
    mov [shift], al

enter_message:
    mov eax, SYS_write		;NR
    mov ebx, STDOUT_fd		;a1
    mov ecx, str2			;a2
    mov edx, len2			;a3
    int 0x80 				;write()

    call read_message
    mov [esp], eax

    mov eax, SYS_write		;NR
    mov ebx, STDOUT_fd		;a1
    mov ecx, str3			;a2
    mov edx, len3			;a3
    int 0x80 				;write()
	
    mov eax, SYS_write		;NR
    mov ebx, STDOUT_fd		;a1
    mov ecx, input_buf		;a2
    mov edx, [esp]			;a3
    int 0x80 				;write()

exit_program:
	add esp, 16
    mov eax, SYS_exit	;NR
    xor ebx, ebx		;a1
    int 0x80			;exit()
; END PROC

; PROC read_value
read_value:
	push ebx
	push esi
	call read_message

read_value_proceed:
    xor esi, esi
    xor ebx, ebx
    xor ecx, ecx
read_value_process:  
    mov cl, [input_buf + ebx] ;
    cmp cl, 10 ; newline? we are done
    je read_value_finish
    cmp cl, '0' ; 
    jb read_value_finish ; NaN
    cmp cl, '9' ; 
    ja read_value_finish ; NaN
    sub ecx, '0' ; convert ASCII to integer
    mov eax, 10
    mul esi
    mov esi, eax ; store product
    add esi, ecx ; add unit
    inc ebx
    jmp read_value_process

read_value_finish:
    mov eax, esi
	pop esi
    pop ebx
    ret
; END PROC


; PROC read_message
read_message:
	push ebx

    mov eax, SYS_read		;NR
    mov ebx, STDIN_fd		;a0
    lea ecx, [input_buf]	;a1
    mov edx, BUFLEN			;a2
    int 0x80				;read()

	pop ebx
    ret
; END PROC
