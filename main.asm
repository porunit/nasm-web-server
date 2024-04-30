%include "inc/server.inc"


section .text

global _start
   
_start:
    call _server
    call exit


exit:
    xor rax, rax
    mov rax, 60
    mov rdi, 0
    syscall




