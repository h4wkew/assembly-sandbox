section .data
    ; syscalls
    sys_write   equ 0x01
    sys_exit    equ 0x3c

    newline     db 10

    err_msg     db 'Error: No argument provided.', 10
    err_msg_len equ $ - err_msg

section .text
global _start

_start:
    pop r8                      ; argc
    cmp r8, 1                   ; check if argc is 1 (= no arguments)
    jle no_arguments            ; if argc <= 1, jump to no_arguments

    pop rsi                     ; discard the program name (argv[0])

.print_arguments:
    dec r8                      ; decrement argc
    jz end_program              ; if argc is zero, end program

    pop rsi                     ; get next argument (argv[i])

    ; calculate string length
    mov rdx, rsi                ; store argument pointer in rdx
    xor rcx, rcx                ; use rcx as length counter

.find_length:
    cmp byte [rdx + rcx], 0     ; find null terminator
    je .write_argument          ; when found, proceed to write
    inc rcx                     ; increment length counter
    jmp .find_length

.write_argument:
    ; write argument to stdout
    mov rax, sys_write
    mov rdi, 1                  ; stdout file descriptor
    mov rdx, rcx                ; length of the argument
    syscall

    ; write newline
    mov rax, sys_write
    mov rsi, newline            ; buffer with newline character
    mov rdx, 1                  ; length of newline
    syscall

    jmp .print_arguments        ; loop to next argument

no_arguments:
    ; write error message
    mov rax, sys_write
    mov rdi, 1                  ; stdout file descriptor    
    mov rsi, err_msg            ; buffer to write from
    mov rdx, err_msg_len        ; number of bytes to write
    syscall

    mov rax, sys_exit
    mov rdi, 1                  ; exit code 1
    syscall

end_program:
    mov rax, sys_exit
    mov rdi, 0                  ; exit code 0
    syscall
