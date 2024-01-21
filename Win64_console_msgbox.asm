;--- Win64 Console and Message Window application.
;--- assemble: jwasm -win64 Win64_console_msgbox.asm
;--- MS link: link /subsystem:windows /entry:CustomEntry Win64_console_msgbox.obj
;--- JWlink: jwlink format win pe ru win file Win64_console_msgbox op start=CustomEntry

; include libraries used
includelib kernel32.Lib
includelib User32.Lib

; External Symbols
externdef MessageBoxA       : near
externdef WriteConsoleA     : near
externdef ReadConsoleA      : near
externdef ExitProcess       : near
externdef GetParent         : near
externdef GetStdHandle      : near
externdef AllocConsole      : near
externdef FreeConsole       : near
externdef SetConsoleMode    : near

; Definitions
STD_INPUT_HANDLE equ -10
STD_OUTPUT_HANDLE equ -11
MB_OK equ 0
NULL equ 0
SHADOW equ 32

.data
    brw         dd ?
    message     db "Hello with MASM 64-bit!", 0Ah, 0
    caption     db "MSGBOX", 0

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
; Note misalignment occurs on call entry due to 8-byte return address push

.code
CustomEntry proc
	; push non-volatile, odd number of pushes means misalignment due to call is fixed
	push rdi							; save rdi
	push rsi							; save rsi
	push rbx							; save rbx
    sub rsp, 32                         ; <misalignment fix> + <local_aligned> + SHADOW
    
	call AllocConsole                   ; Allocate console window for display
    
    ; GetStdHandle(IN_number)
    mov ecx, STD_INPUT_HANDLE           ; arg1 
    call GetStdHandle                   ; Get stdin handle
    mov rdi, rax                 		; store stdin handle in rdi
    
    ; GetStdHandle(OUT_number)
    mov ecx, STD_OUTPUT_HANDLE          ; arg1
    call GetStdHandle                   ; Get stdout handle
    mov rsi, rax                 		; store stdout handle in rsi

	lea rbx, [message]					; load message address into rbx
    
	; WriteConsoleA(h_stdout, message, sizeof(message) - 1, &bw, NULL);	
    sub rsp, 16                         ; aligned stack allocation for 1 argument
    mov rcx, rsi                		; arg1 = stdout handle
    mov rdx, rbx                  		; arg2 = message
    mov r8, LENGTHOF message - 1        ; arg3
    lea r9, [brw]                       ; arg4
    mov QWORD PTR [rsp + SHADOW], NULL  ; arg5
    call WriteConsoleA                  ; call function
    add rsp, 16                         ; free stack allocated for arguments
    
	; ReadConsoleA(h_stdin, message, 16, &br, NULL);  /* Read maximum of16 bytes */
    sub rsp, 16                         ; aligned stack allocation
    mov rcx, rdi                  		; arg1 = stdin handle
    mov rdx, rbx                  		; arg2 = message
    mov r8, 16                          ; arg3
    lea r9, [brw]                       ; arg4
    mov QWORD PTR [rsp + SHADOW], NULL  ; arg5
    call ReadConsoleA                   ; call function
    add rsp, 16                         ; free stack allocated for arguments
    
	; if (br < 16)	message[br - 1] = ' ';   /* replace CR+LF with spaces */
    mov r10d, [brw]                     ; move number of bytes read
    cmp r10, 14                         ; compare with limit - (CR+LF)
    jg _continue_display                ; no CR+LF
    sub r10, 2                          ; else get the index of CR
    mov BYTE PTR [rbx + r10*1 + 0], 20h ; replace CR with space
    mov BYTE PTR [rbx + r10*1 + 1], 20h ; replace LF with space

_continue_display:
	; MessageBoxA(GetParent(NULL), message, caption, MB_OK);
    mov rcx, NULL                       ; arg1 of GetParent(HWND)
    call GetParent                      ; call function
    mov rcx, rax                        ; arg1 of MessageBoxA()
    mov rdx, rbx                  		; arg2 = message
    lea r8, [caption]                   ; arg3
    mov r9, MB_OK                       ; arg4
    call MessageBoxA                    ; call function

	; WriteConsoleA(h_stdout, message, sizeof(message) - 1, &bw, NULL);	
    sub rsp, 16                         ; aligned stack allocation for 1 argumentt
    mov rcx, rsi                		; arg1 = stdout handle
    mov rdx, rbx                  		; arg2 = message
    mov r8, LENGTHOF message - 1        ; arg3
    lea r9, [brw]                       ; arg4
    mov QWORD PTR [rsp + SHADOW], NULL  ; arg5
    call WriteConsoleA                  ; call function
    add rsp, 16                         ; free stack allocated for arguments

	; ReadConsoleA(h_stdin, message, 1, &br, NULL);	/* Hold console with read */
    sub rsp, 16                         ; aligned stack allocation
    mov rcx, rdi                  		; arg1 = stdin handle
    mov rdx, rbx                  		; arg2 = message
    mov r8, 1                           ; arg3
    lea r9, [brw]                       ; arg4
    mov QWORD PTR [rsp + SHADOW], NULL  ; arg5
    call ReadConsoleA                   ; call function
    add rsp, 16                         ; free stack allocated for arguments

    call FreeConsole                    ; Free console window
    
    add rsp, 32                         ; Free alloc stack
	pop rbx								; restore rbx
	pop rsi								; restore rsi
	pop rdi								; restore rdi
    
    xor rax, rax                        ; set return code = 0
    ret                                 ; return
CustomEntry endp

    end
