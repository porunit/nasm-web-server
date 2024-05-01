%include "inc/parser.inc"

%define SOCK_STREAM        1
%define AF_INET            2
%define CLOSE_SUCCESS      0

%define READ_BUFFER_LENGTH 20000

%define SYS_BIND           49
%define SYS_WRITE          1
%define SYS_OPEN           2
%define SYS_READ           0
%define SYS_DUP2           33
%define SYS_FORK           57
%define SYS_SOCKET         41
%define SYS_EXECVE         59
%define SYS_CONNECT        42
%define SYS_LISTEN         50
%define SYS_ACCEPT         43
%define SYS_CLOSE          3

global _server


; r12 - socket | r13 - client socket
_server:
        call socket
        call bind
        call listen
    loop:

        call accept

        call sock_read
        lea  rsi, [buffer]

        mov rax, SYS_FORK
        syscall

        cmp rax, 0
        je child

        mov rdi, r13 
        call close 
        jmp loop

    child:
        call _process_request
        mov rdi, r12
        call close
        ret


close:
    mov rax, SYS_CLOSE
    syscall 
    ret



_print_buffer:
    mov rdi, 1
    mov rsi, buffer
    mov rdx, READ_BUFFER_LENGTH
    mov rax, SYS_WRITE
    syscall
    ret

socket:
    mov rdi, AF_INET
    mov rsi, SOCK_STREAM
    mov rdx, 0
    mov rax, SYS_SOCKET
    syscall
    ret

listen:
    mov rdi, r12
    mov rsi, 10
    mov rax, SYS_LISTEN
    syscall
    ret

accept:
    mov rdi, r12
    mov rsi, 0
    mov rdx, 0
    mov rax, SYS_ACCEPT
    syscall
    ret

bind:
    mov r12, rax      ; socket fd
    mov rdi, r12
    mov rsi, address
    mov rdx, 16
    mov rax, SYS_BIND
    syscall
    ret

sock_read:
    mov r13, rax                ; client socket fd
    mov rdi, r13
    mov rsi, buffer
    mov rdx, READ_BUFFER_LENGTH
    mov rax, SYS_READ
    syscall
    ret


section .data

address:
    dw AF_INET
    dw 0x901f
    dd 0
    dq 0

hui:
    db 'hui', 10

section .bss

buffer:
    resb READ_BUFFER_LENGTH

