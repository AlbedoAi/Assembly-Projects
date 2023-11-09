section .text
    			; declare _start as the entry point
    global _start

_start:
                        ; initialize the values to subtract
    mov eax, 12345678   ; set EAX register to 12345678
    mov ebx, 87654321   ; set EBX register to 87654321

                        ; subtract the values and store the result in EDX
    sub edx, eax        ; subtract EAX from EDX
    sbb edx, ebx        ; subtract EBX from EDX with borrow

                        ; call exit function
    call exit

exit:
                        ; setup a system call to terminate the application
    mov eax, 1          ; specifying a system exit call ()
    xor ebx, ebx        ; make exit status 0
    int 0x80            ; cause the system call to terminate ()

