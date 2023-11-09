global _start
section .text
; External libraries
extern printf, malloc

_start:
    mov rdi, 25*8        
    call malloc       		; allocate memory 
    mov rbx, rax 
    mov r9, 1 				;sets r9 to 1
    mov qword[listcount], 0   
    
    mov rcx, qword[len] 

; generates a lits of numbers to check prime numbers
numArray:
    push r9
    add r9, 2
    cmp r9, rcx
    jl numArray

; goves over the generated number one by one to see if they are prime

loopArray:
    xor rdx, rdx
    pop rax

    mov qword[temp], rax
    
    mov r15, 0x2
    div r15
    mov qword[halfnum], rax    
    call endPrime
    
    cmp r9, rcx
    jl numArray
    
    dec rcx
    jnz loopArray

exit: ;exits program
    mov rsi, 0
    mov rax, 60
    syscall

endPrime:
    cmp rax, 2
    je exit
    
    cmp rax, 3
    je isPrime
    
    cmp rax, 5
    je isPrime
    
    mov rax, qword[temp]
    div r15
    cmp rdx, 0x0
    je notPrime
    
    cmp r15, qword[halfnum]
    je isPrime
    
    inc r15
    xor rax, rax
    xor rdx, rdx
    jmp endPrime

; no prime found
notPrime:
    ret   

; the number is a prime and will be printed to the terminal
isPrime:
    mov rax, 1
    mov rdi, 1
    cmp qword[found], 0
    jne printnum
    mov rsi, isprimemsg
    mov rdx, primemsglen
    syscall
    mov qword[found], 1
    jmp printnum

printnum:
    xor rax, rax
    mov rsi, qword[temp]
    mov rdi, printformat
    call printf
    
    xor r13, r13
    mov r13, qword[listcount]
    inc qword[listcount]
    mov rax, qword[temp]
    mov qword[rbx + r13 * 8], rax
    
    inc r9
    cmp r9, rcx
    jle loopArray
    
    ret

section .data
    len: dq 100000
    isprimemsg: db "Prime Number(s) Found: ", 0x00
    primemsglen: equ $-isprimemsg
    printformat: db " %d", 0xa, 0x00
    listcount: dq 0
    found: dq 0

section .bss
    temp resb 8
    halfnum resb 2;

