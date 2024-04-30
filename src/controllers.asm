%include "inc/sender.inc"

section .text

global _auth_controller
global _main_controller

_auth_controller:
    mov rdi, auth_http_responce
    call _send_responce
    ret

_main_controller:
    mov rdi, index_html
    call _send_responce
    ret

_register_controller:
    


section .data
index_html:
    db 'resources/templates/index.html', 0

auth_http_responce:
    db 'resources/responces/auth.http', 0