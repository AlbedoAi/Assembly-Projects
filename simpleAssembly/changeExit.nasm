section .text
global _start         

_start:
    mov ax, 0x1234   ; Fill register AX with a 16-bit hexadecimal value.
    mov ah, al       ; Change the upper 8 bits to AH.
    mov al, 0x56     ; Lower 8 bit data loaded into AL

    		     ; terminate the function and give 0 back
    mov eax, 1       ; change the exit function code
    xor ebx, ebx     ; Make exit status 0
    int 0x80         ; Use the exit function.


   


