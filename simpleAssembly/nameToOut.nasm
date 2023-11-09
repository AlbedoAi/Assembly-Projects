; Feburary 10th, 2023
; x86-64, NASM

; *******************************
; Functionality of the program:
; This program writes my name on the screen
; *******************************

global _start               ; exposes entry point to other programs
section .data               ; defines that the text below is data

firstname db 'Shubham', 0     ; null-terminated string for first name
surname db 'Raturi', 0        ; null-terminated string for surname
newline db 10, 0           ; null-terminated string for newline

section .text               ; defines that the text below if the program itself

_start:                     ; Entry point
    ; write the first name to stdout
    mov rax, 4
    mov rbx, 1
    mov rcx, firstname
    mov rdx, 7
    int 0x80

    ; write a newline to stdout
    mov rax, 4
    mov rbx, 1
    mov rcx, newline
    mov rdx, 1
    int 0x80

    ; write the surname to stdout
    mov rax, 4
    mov rbx, 1
    mov rcx, surname
    mov rdx, 6
    int 0x80

_exit:
    mov rax, 60             ; x86-64 syscall for sys_exit
    mov rdi, 0              ; system return code of 0 (normal exit)
    syscall                 ; execute syscall
