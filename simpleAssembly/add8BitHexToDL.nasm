; Feburary 10th, 2023
; x86-64, NASM

; *******************************
; Functionality of the program:
; adds to 8 bit hex and stores them in DL
; *******************************

global _start               ; exposes entry point to other programs
section .text               ; defines that the text below if the program itself

_start:                     ; Entry point


    MOV AL, 0x5A ; move number (0x5A) into AL register
    MOV BL, 0x3C ; move number (0x3C) into BL register
    ADD AL, BL ; add the two numbers and store the result in AL
    MOV DL, AL ; move the result from AL into DL

    jmp _exit
_exit:
    mov rax, 60             ; x86-64 syscall for sys_exit
    mov rdi, 0              ; system return code of 0 (normal exit)
    syscall                 ; execute syscall

