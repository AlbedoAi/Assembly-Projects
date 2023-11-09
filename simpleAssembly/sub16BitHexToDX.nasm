; Feburary 10th, 2023
; x86-64, NASM

global _start               ; exposes entry point to other programs
section .text               ; defines that the text below if the program itself

_start:                     ; Entry point

    mov ax, 1234h ; load the first hex number into AX
    sub ax, 5678h ; subtract the second hex number from AX
    mov dx, ax ; move the result from AX to DX
    jmp _exit ; exit the program

_exit:
    ; exit syscall
    mov eax, 60             ; x86-64 syscall for sys_exit
    xor ebx, ebx            ; system return code of 0 (normal exit)
    syscall                 ; execute syscall

