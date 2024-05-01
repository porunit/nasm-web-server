%include "inc/sender.inc"

%define SYS_WRITE 1
%define SYS_OPEN  2
%define SYS_CLOSE          3


section .text

global  _auth_controller
global  _main_controller
global _register_controller

_auth_controller:
    mov  rdi, auth_http_responce
    call _send_responce
    ret

_main_controller:
    mov  rdi, index_html
    call _send_responce
    ret

; rsi - pointer to body
_register_controller:
    push rsi
        call check_body
        cmp  rax, 0
        je  .incorrect_body
    .correct_body:
        pop rsi
        mov  rdi, logins_file_path
        call _open_file
        push rax
        mov rdi, rax
        mov rdx, 2048
        mov rax, SYS_WRITE
        syscall
        
        mov rax, SYS_CLOSE
        pop rdi
        syscall

        mov  rdi, auth_http_responce
        call _send_responce
        ret
    .incorrect_body:
        pop rsi
        mov  rdi, error_http_responce
        call _send_responce
        ret


_write_to_logins:

; rdi - file path
_open_file:
    mov rsi, 2        ; rw
    mov rax, SYS_OPEN
    syscall
    ret

check_body:
    
        xor rcx, rcx         
    count_colons:
        mov al, [rsi]       
        cmp al, 0            
        je check_result      
        cmp al, ':'          
        je increment_colon  
        inc rsi              
        jmp count_colons    

    increment_colon:
        inc rcx              
        inc rsi            
        jmp count_colons     

    check_result:
        cmp rcx, 1          
        je is_valid         
        mov rax, 0           
        ret                  

    is_valid:
        mov rax, 1          
        ret                  

    ; rsi - str
    _print_error:
        mov rdi, 1
        mov rdx, 2048
        mov rax, SYS_WRITE
        syscall
        ret


section .data

index_html:
    db 'resources/templates/index.html', 0

auth_http_responce:
    db 'resources/responces/auth.http', 0

error_http_responce:
    db 'resources/responces/error.http', 0

logins_file_path:
    db 'resources/logins.shweb', 0

incorrect_body_error_msg:
    db 'ERROR: incorrect body for register', 10, 0

