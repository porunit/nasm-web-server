%include "inc/controllers.inc"

%define TRUE                1
%define FALSE               0
%define WRITE_BUFFER_LENGTH 4096

%define SYS_WRITE           1
%define SYS_OPEN            2
%define SYS_READ            0

section .text

global  _process_request
global  extracted_url

_process_request:
    call _parse_request
    
    mov rdi, request_body
    call find_and_copy
    push rsi
    mov rsi, request_body
    call _print_buffer
    pop rsi
    mov  rsi, extracted_url
    call _determine_route

    ret

; rsi - search buffer rdi - copy buffer
find_and_copy:
   
    .find_char:
        mov al, [rsi]       
        cmp al, 0x7f          
        je .copy              
        cmp al, 0             
        je not_found          
        inc rsi               
        jmp .find_char         

    .copy:
        mov al, [rsi]         
        mov [rdi], al        
        inc rsi               
        inc rdi               
        cmp al, 0             
        jne .copy             
        ret                   

    not_found:
        ret                  


_determine_route:
        mov  rdi, auth_uri
        call _compare_route
        cmp  rax, TRUE
        je   .auth

        mov rdi, reg_uri
        call _compare_route
        cmp rax, TRUE
        je .reg
        
        call _main_controller
        jmp  .end


    .reg:
        mov rsi, request_body
        call _register_controller
        jmp .end
    .auth:
        mov rsi, request_body
        call _auth_controller
        jmp  .end
    .end:
        ret


; rsi - request str path address
_parse_request:
        push rdi
        push rsi
        push rcx
        lea  rsi, [rsi + 5]

        xor rcx, rcx

    .find_space:
        cmp byte [rsi + rcx], 0
        je  .error_handle
        cmp byte [rsi + rcx], ' '
        je  .found_space
        inc rcx
        jmp .find_space

    .found_space:
        lea rdi,        [extracted_url]
        mov rdx,        rcx
        rep movsb                  
        mov byte [rdi], 0

        pop rcx
        pop rsi
        pop rdi
        ret                        

    .error_handle:
        pop rcx
        pop rsi
        pop rdi
        ret


; rsi - pointer route ; rdi - compare with
_compare_route:
        push rsi
        push rdi
        push rcx
        
        push r12

        push rsi
        call _len
        mov  r12, rcx
        mov  rsi, rdi
        call _len
        pop  rsi

        cmp r12, rcx
        jne .not_equal

        mov rcx, 0 ; index and loop counter
    .loop:  
        mov al,  [rsi+rcx] ; load a character from passwd
        cmp al,  [rdi+rcx] ; is it equal to the same character in the input?
        jne .not_equal     ; if not, the password is incorrect
        inc rcx            ; advance index
        cmp rcx, r12       ; reached the end of the string?
        jle .loop          ; loop until we do

        pop r12
        pop rcx
        pop rdi
        pop rsi

        mov rax, TRUE
        ret                    
    .not_equal:
        pop r12
        pop rcx
        pop rdi
        pop rsi

        mov rax, FALSE
        ret

_print_buffer:
    mov rdi, 1
    mov rdx, 2048
    mov rax, SYS_WRITE
    syscall
    ret


_len:
        mov rcx, 0 ; counter
    .repeat:
        lodsb         ; byte in AL
        test  al, al  ; check if zero
        jz    .done   ; if zero then we're done
        inc   rcx     ; increment counter
        jmp   .repeat ; repeat until zero
    .done:
        ret


_find_body:



section .data


main_uri:
    db '/main', 0

auth_uri:
    db '/auth', 0

reg_uri:
    db '/reg', 0

section .bss

extracted_url:
    resb 512

write_buffer:
    resb WRITE_BUFFER_LENGTH

request_body:
    resb 2048