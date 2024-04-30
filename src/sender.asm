
%define TRUE                1
%define FALSE               0
%define WRITE_BUFFER_LENGTH 4096

%define SYS_WRITE           1
%define SYS_OPEN            2
%define SYS_READ            0

section .text

global _send_responce

_clear_write_buffer:
    mov rcx, WRITE_BUFFER_LENGTH
    lea rdi, [write_buffer]
    xor rax, rax
    rep stosb
    ret

; rdi - file path
_send_responce:
    mov rsi, 0        ; Read only
    mov rax, SYS_OPEN
    syscall

    mov rdi, rax
    mov rsi, write_buffer
    mov rdx, WRITE_BUFFER_LENGTH
    mov rax, SYS_READ
    syscall

    mov rdi, r13
    mov rsi, write_buffer
    mov rdx, rax
    mov rax, SYS_WRITE
    syscall
    call _clear_write_buffer
    ret


section .bss

write_buffer:  
    resb WRITE_BUFFER_LENGTH