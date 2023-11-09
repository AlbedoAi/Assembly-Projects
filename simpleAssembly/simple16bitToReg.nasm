section .text
global _start        

_start:
    mov bx, 1234     ; Put a 16-bit value in register BX.

    		     ; terminate the function and give 0 back
    mov eax, 1       ; enter the exit function code
    xor ebx, ebx     ; Make exit status 0
    int 0x80         ; Use the exit function


   

