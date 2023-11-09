section .text
    global _start

_start:
    ; initialise the values before adding
    mov ax, 0x1234  ; 0x1234 in the AX register
    mov bx, 0x5678  ; 0x5678 in the BX register
    
   		    ; Add the values together and save the outcome in DX.
    add dx, ax      ; add AX to DX
    adc dx, bx      ; add BX to DX with carry
    
    		    ; call exit function
    call exit
    
exit:
  		    ; set up system call to exit the program
    mov eax, 1      ; specify system call for exit()
    xor ebx, ebx    ; set exit status to 0
    int 0x80        ; trigger the system call to exit()

