;--- Win64 simple hello world application.
;--- assemble: jwasm -win64 Win64_hello.asm
;--- MS link: link /subsystem:windows /entry:CustomEntry Win64_hello
;--- JWlink:  jwlink format win pe ru win file Win64_hello op start=CustomEntry

; include libraries used
includelib kernel32.Lib
includelib User32.Lib

; External Symbols
externdef WriteConsoleA     : near
externdef ReadConsoleA      : near
externdef ExitProcess       : near
externdef GetStdHandle      : near
externdef AllocConsole      : near
externdef FreeConsole       : near

; Definitions
STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11
NULL equ 0
SHADOW equ 32

.data
    brw         dd ?
    message     db "Win64 simple hello world with MASM!", 0Ah, "Press any key...", 0

; Normal Arguments:     rcx, rdx, r8, r9, stack (after SHADOW)
; Float Arguments:      xmm0, xmm1, xmm2, xmm3, stack (after SHADOW)
; return normal:        rax
; return float:         xmm0
; Saved (non-volatile): rbx, rbp, rdi, rsi, rsp, r12, r13, r14, r15, xmm6-xmm15
; Scratch (volatile):   arguments, return, r10, r11, xmm4, xmm5, upper ymm/zmm 

; Mixed Arguments will skip the alternate registers
; Stack arguments in the left to right order are place at increasing addresses
; Win32 requires callee to have access to SHADOW space (4 args worth, i.e 32 bytes)  

; Win32 mandates 16 bytes aligned stack before any call
; Note misalignment occurs on entry into a call due to a 8-byte return address push


.code
CustomEntry proc
	; push non-volatile, odd number of pushes means misalignment due to call is fixed
	push rdi							; save rdi
    sub rsp, 32                         ; <misalignment fix> + <local_aligned> + SHADOW 

	call AllocConsole                   ; Allocate console window for display
    
    ; GetStdHandle(IN_number)
    mov ecx, STD_INPUT_HANDLE          	; arg1
    call GetStdHandle                   ; Get stdin handle
	mov rdi, rax						; save stdin handle

    ; GetStdHandle(OUT_number)
    mov ecx, STD_OUTPUT_HANDLE          ; arg1
    call GetStdHandle                   ; Get stdout handle in rax
    
	; WriteConsoleA([1]stdout_H, [2]message, [3]sizeof(message) - 1, [4]&bw, [5]NULL);	
    sub rsp, 16                         ; aligned stack allocation for 5th argument
    mov rcx, rax						; arg1 = stdout handle
    lea rdx, [message]                  ; arg2
    mov r8, LENGTHOF message - 1        ; arg3
    lea r9, [brw]                       ; arg4
    mov QWORD PTR [rsp + SHADOW], NULL  ; arg5
    call WriteConsoleA                  ; call function
    add rsp, 16                         ; free stack allocated for arguments
   
   	; ReadConsoleA(stdin_H, message, 1, &br, NULL);	/* Hold console with read */
    sub rsp, 16                         ; aligned stack allocation
    mov rcx, rdi		          		; arg1 = stdin handle
    lea rdx, [message]                  ; arg2
    mov r8, 1                           ; arg3
    lea r9, [brw]                       ; arg4
    mov QWORD PTR [rsp + SHADOW], NULL  ; arg5
    call ReadConsoleA                   ; call function
    add rsp, 16                         ; free stack allocated for arguments

    call FreeConsole                    ; Free console window
    
    add rsp, 32                         ; Free alloc stack
	pop rdi								; restore rdi

    xor rax, rax                        ; set return code = 0
    ret                                 ; return
CustomEntry endp

    end
