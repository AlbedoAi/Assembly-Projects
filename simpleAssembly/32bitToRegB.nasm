; Feburary 10th, 2023
; x86-64, NASM

; *******************************
; Functionality of the program:
; Loading a 32 bit value to register B
; *******************************

section .data
value dd 1234567890 ; 32-bit decimal value to load

global _start               ; exposes entry point to other programs
section .text               ; defines that the text below if the program itself

_start:
  mov eax, value ; load the value into the eax register
  mov ebx, eax ; move the value from eax to ebx
  ; now the 32-bit decimal value is loaded into the ebx register
