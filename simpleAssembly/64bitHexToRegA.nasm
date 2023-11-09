; Feburary 10th, 2023
; x86-64, NASM

; *******************************
; Functionality of the program:
; Loads 64 bit hexadecimal value into register A
; *******************************

section .data
value dq 0xDEADBEEF12345678 ; 64-bit hexadecimal value to load

global _start               ; exposes entry point to other programs
section .text               ; defines that the text below if the program itself

_start:
  mov rax, value ; load the value into the rax register
  ; now the 64-bit hexadecimal value is loaded into the rax register
