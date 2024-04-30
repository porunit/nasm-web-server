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
    call _print_buffer

    mov rsi, extracted_url
    call _determine_route
    ret



_determine_route:
        mov  rdi, auth_uri
        call _compare_route
        cmp  rax, TRUE
        je   .auth

        call _main_controller
        jmp .end
    .auth:
        call _auth_controller
        jmp .end
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
    mov rsi, extracted_url
    mov rdx, 512
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


section .data


main_uri:
    db '/main', 0

auth_uri:
    db '/auth', 0


section .bss
extracted_url:
    resb 512

write_buffer:
    resb WRITE_BUFFER_LENGTH