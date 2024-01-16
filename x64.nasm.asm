section .rodata
	welcome_message db "Welcome to x86_64 program assembled with NASM ...", 0xa
	newline db 0xa 
	sizeof_welcome_message equ $-welcome_message

section .bss
    block_buffer resb 512

section .text
    global _start

; Linux x64 calling convention
; system call:  rdi, rsi, rdx, r10, r8, r9
; user call: rdi, rsi, rdx, rcx, r8, r9
; return: rdx:rax
; syscall number: rax
; Saved: rbx, rbp, rsp, r12, r13, r14, r15
; Scratch: r10, r11

; Program entry
_start:
	; Print Welcome message
    mov rax, 1 						; sys number for write
    mov rdi, 1 						; stdout fd number
    mov rsi, welcome_message 		; data address
    mov rdx, sizeof_welcome_message	; size of data
    syscall 						; invoke syscall

_exit:
	mov rax, 60                     ; sys number for exit
    mov rdi, 0					    ; exit code
    syscall                         ; invoke syscall

