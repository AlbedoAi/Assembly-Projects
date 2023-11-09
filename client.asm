; Program that recieves a random amount of requested bytes from the server then sorts the bytes using a selection sort algorithm. Also converts it from hex to ascii and saves it to a file
; Assembly - Nasm x86-64


struc sockaddr_in_type
; defined in man ip(7) because it's dependent on the type of address
    .sin_family:        resw 1
    .sin_port:          resw 1
    .sin_addr:          resd 1
    .sin_zero:          resd 2          ; padding
endstruc

section .data

    userInputMsg:    db "Enter hex value between 0x100 and 0x4FF without the 0x:", 0xa, 0x0
    userInputMsg_l: equ $ - userInputMsg

    errorReceivingMsg: db "Error recieving from the server.", 0xa, 0x0
    errorReceivingMsg_l: equ $ - errorReceivingMsg

    inputError: db "The value entered were not in range", 0xa, 0x0
    inputError_l: equ $ - inputError

    socket_f_msg:   db "Socket failed to be created.", 0xA, 0x0
    socket_f_msg_l: equ $ - socket_f_msg

    socket_t_msg:   db "Socket created.", 0xA, 0x0
    socket_t_msg_l: equ $ - socket_t_msg

    bind_f_msg:   db "Socket failed to bind.", 0xA, 0x0
    bind_f_msg_l: equ $ - bind_f_msg

    bind_t_msg:   db "Socket bound.", 0xA, 0x0
    bind_t_msg_l: equ $ - bind_t_msg

    shutdown_t_msg:   db "Socket shutdown.", 0xA, 0x0
    shutdown_t_msg_l: equ $ - shutdown_t_msg

    socket_closed_msg:   db "Socket closed.", 0xA, 0x0
    socket_closed_msg_l: equ $ - socket_closed_msg

    delay dq 1, 000000000  ; dealaying file creation

    filename: db 'output.txt', 0x0    ; the name of file to create

    errorCreatingFile:  db "File error. Please try again", 0xA, 0x0
    errorCreatingFile_L: equ $ - errorCreatingFile

    randomDataMsg: db 0xa, 0xa, "----- START OF RANDOM DATA -----", 0xa, 0x0
    randomDataMsg_L: equ $ - randomDataMsg

    sortedDataMsg: db 0xa, 0xa, "----- START OF SORTED DATA -----", 0xA, 0x0
    sortedDataMsg_L: equ $ - sortedDataMsg

    sockaddr_in:
        istruc sockaddr_in_type

            at sockaddr_in_type.sin_family,  dw 0x02
            at sockaddr_in_type.sin_port,    dw 0x1f90         ; port 8080
            at sockaddr_in_type.sin_addr,    dd 0x0100007F     ; random ip because localhost wasnt working.

        iend
    sockaddr_in_l:  equ $ - sockaddr_in

section .bss

    arrayLength:            resq 0x1       ; length of both random and output arrays
    randomInputArray:       resq 0x1       ; pointer to received array
    sortedOutputArray:      resq 0x1       ; pointer to output
    socketFD:               resq 0x1       ; socket file descriptor
    msgBuf:                 resb 0x4       ; user input buffer
    fileFD:                 resq 0x1       ; file descriptor for output
    maxValue: 		    	resq 0x1

section .text

global _start

_start:
    call _network                       ; creates socket and connect to server

	; prompts user for input
    push rbp
    mov rbp, rsp				    	; asks for input
    push userInputMsg_l
    push userInputMsg
    call _print

    ; reads the input
    mov rax, 0x00                       ; read syscall
    mov rdi, 0x00                       ; reads user input
    mov rsi, msgBuf
    mov rdx, 0x04
    syscall

    cmp rax, 0x4                        ; checks how many characters user entered
    jne _inputError

	; writes input to buffer
    mov rax, 0x01                       ; write syscall
    mov rdi, qword[socketFD]
    mov rsi, msgBuf                     ; sends the user input
    mov rdx, 0x04
    syscall

    mov rax, 35                         ; syscall to delay
    mov rdi, delay                      ; delay to let server write
    mov rsi, 0
    syscall

    mov rsp, rbp
    pop rbp

    call _ascii_to_hex                      ; Convert the bytes from the server from ascii to hex
    mov [arrayLength], rax                  ; Save return value from the subroutine asciiToHex

    push rax                                ; Pass return value from the subroutine asciiToHex to both memory allocation function calls
    call _memoryAllocation
    mov [randomInputArray], rax             ; Saves the return value from memory allocation function for the arrays

    call _memoryAllocation
    mov [sortedOutputArray], rax

 	; reads from socket
    push rbp
    mov rbp, rsp

    mov r13, [randomInputArray]

    mov rax, 0x00                       ; read syscall
    mov rdi, qword[socketFD]
    mov rsi, r13
    mov rdx, [arrayLength]
    syscall

    cmp rax, [arrayLength]              ; checks if requested bytes are same
    jne _receive_error
	call _fileOutput
    mov rsp, rbp                        ; dealocating the stack
    pop rbp


    call _selectionSort                     ; Call the sorting algorithim

    call _fileOutput.sortedWrite            ; Print output to the file

    add rsp, 0x8                            ; Clean the stack
    call _exit                              ; Exits by closing all the things such as fd, socket, etc.

_network:
        push rbp
        mov rbp, rsp

    .init:
        mov rax, 0x29                       ; socket syscall
        mov rdi, 0x02                       ; int domain - AF_INET = 2 for IPV4
        mov rsi, 0x01                       ; int type - SOCK_STREAM = 1
        mov rdx, 0x00                       ; int protocol is 0
        syscall
        cmp rax, 0x00
        jl _socket_failed                   ; jump if negative
        mov [socketFD], rax                 ; save the socket fd to basepointer
        call _socket_created

        mov rax, 0x2A                       ; syscall to connect
        mov rdi, qword[socketFD]
        mov rsi, sockaddr_in                ; sockaddr struct points to the server IP address and port
        mov rdx, sockaddr_in_l
        syscall

        cmp rax, 0x00
        jl _bind_failed                     ; jump when connection fails
        call _bind_created

        mov rsp, rbp                        ; deallocating the stack
        pop rbp
        ret				    ; returns control back to the calling function

    .shutdown:
        push rbp
        mov rbp, rsp

        mov rax, 0x30                       ; close syscall
        mov rdi, qword [socketFD]           ; sfd
        mov rsi, 0x2                        ; shuwdown RW
        syscall

        cmp rax, 0x0
        jne _network.shutdown
        call _shutdown_msg

    .close:
        mov rax, 0x03                       ; close syscall
        mov rdi, qword [socketFD]           ; sfd
        syscall

        cmp rax, 0x0
        jne _network.close
        call _socket_closed

        mov rsp, rbp                        ; deallocating the stack
        pop rbp
        ret				    ; returns control back to the calling function

_selectionSort:
    push rbp
    mov rbp, rsp

    mov r13, [randomInputArray]             ; Load the input array into r13
    mov r14, [sortedOutputArray]            ; Load the output array into r14
    mov r15, [arrayLength]                  ; Load the array length into r15

    ; Outer loop
    xor r8, r8                              ; Initialize outer loop counter (r8) to 0
    .OuterLoop:
        ; Find the minimum value in the remaining unsorted part of the array
        mov r9, r8                          ; Initialize the minimum index (r9) with the outer loop counter (r8)
        mov r10, r8                         ; Initialize inner loop counter (r10) with the outer loop counter (r8)
        .InnerLoop:
            movzx rax, byte [r13 + r10]     ; Load array element at inner loop counter (r10) into rax
            movzx rbx, byte [r13 + r9]      ; Load array element at minimum index (r9) into rbx
            cmp rax, rbx                    ; Compare array elements
            jge .InnerLoopSkip              ; If the element at r10 is greater than or equal to the element at r9, skip updating the minimum index
            mov r9, r10                     ; Update the minimum index (r9) with the inner loop counter (r10)
            .InnerLoopSkip:
            inc r10                         ; Increment the inner loop counter (r10)
            cmp r10, r15                    ; Compare the inner loop counter with the array length
            jl .InnerLoop                   ; If the inner loop counter is less than the array length, continue the inner loop

        ; Swap the minimum value with the value at the outer loop counter index
        mov al, byte [r13 + r8]             ; Load the element at outer loop counter (r8) into al
        mov bl, byte [r13 + r9]             ; Load the element at minimum index (r9) into bl
        mov byte [r13 + r8], bl             ; Swap the element at outer loop counter (r8) with the element at minimum index (r9)
        mov byte [r13 + r9], al             ; Swap the element at minimum index (r9) with the element at outer loop counter (r8)

        inc r8                              ; Increment the outer loop counter (r8)
        cmp r8, r15                         ; Compare the outer loop counter with the array length
        jl .OuterLoop                       ; If the outer loop counter is less than the array length, continue the outer loop

    ; Copy sorted array to output array
    xor r11, r11                            ; Initialize copy loop counter (r11) to 0
    .CopyLoop:
        mov al, byte [r13 + r11]            ; Load the element at copy loop counter (r11) into al
        mov byte [r14 + r11], al            ; Copy the element to the output array
        inc r11                             ; Increment the copy loop counter (r11)
        cmp r11, r15                        ; Compare the copy loop counter with the array length
        jl .CopyLoop                        ; If the copy loop counter is less than the array length, continue the copy loop

    mov rsp, rbp
    pop rbp
    ret					    ; return control back to the calling function

_memoryAllocation:
    push rbp
    mov rbp, rsp

    mov rax, 0x9            ; Mmap syscall
    mov rdi, 0x00	    	; NULL
    mov rsi, [rbp + 0x10]   ; array with size
    mov rdx, 0x04	    	; PROT_EXEC
    or rdx, 0x01	    	; PROT_READ
    or rdx, 0x02	    	; PROT_WRITE
    mov r10, 0x20 	    	; MAP ANONO
    or r10, 0x02	    	; Map private
    mov r8, 0x00
    mov r9, 0x00
    syscall

    mov rsp, rbp            ; deallocates the stack
    pop rbp
    ret			    		; returns to function

_fileOutput:
    push rbp
    mov rbp, rsp

    .openFile:
        mov rax, 0x2                    ; open syscall
        mov rdi, filename               ; if file exists it opens it other wise it creates the file and gives it the appropriate permissions for read and write.
        mov rsi, 0x442
        mov rdx, 0q666                  ; permissions given
        syscall

        cmp rax, -1                     ; if value is -1 then there was error creating the file
        jle .errorCreatingF         	; jumps to error message
        mov [fileFD], rax
        jmp .randomWrite   		; otherwise jump to writing

	.randomWrite:
		mov r13, [randomInputArray]

		mov rdx, randomDataMsg_L
        mov rsi, randomDataMsg
        call .writeToFile             ; writes the first part for random data

        mov rdx, [arrayLength]          ; length of array
        mov rsi, r13                   	; random array to write
        call .writeToFile

        mov rsp, rbp                     	; deallocating the stack
   		pop rbp
        ret

	.sortedWrite:

	 	mov rax, 0x2                    ; open syscall
        mov rdi, filename               ; if file exists it opens it other wise it creates the file and gives it the appropriate permissions for read and write.
        mov rsi, 0x442
        mov rdx, 0q666                  ; permissions given
        syscall

        cmp rax, -1                     ; if value is -1 then there was error creating the file
        jle .errorCreatingF         	; jump to error message
        mov [fileFD], rax

	    mov r14, [sortedOutputArray]

        mov rdx, sortedDataMsg_L
        mov rsi, sortedDataMsg
        call .writeToFile             ; writes the second part for sorted data

        mov rdx, [arrayLength]          ; length of array
        mov rsi, r14                   	; sorted arrray to write
        call .writeToFile
		ret

    mov rsp, rbp                     	; deallocating the stack
    pop rbp
    ret


    .writeToFile:
        push rbp
        mov rbp, rsp

        mov rax, 0x1
        mov rdi, [fileFD]
        syscall

        mov rsp, rbp                    ; deallocating the stack
        pop rbp
        ret

    .closeFile:
        push rbp
        mov rbp, rsp

        mov rax, 0x3                    ; close file
        mov rdi, [fileFD]               ; clean the FD
        syscall

        mov rsp, rbp                    ; deallocating the stack
        pop rbp
        ret

    .errorCreatingF:                 ;	prints error msg if error occurs
        mov rax, 0x1
        mov rdi, 1
        mov rsi, errorCreatingFile
        mov rdx, errorCreatingFile_L
        syscall
        jmp     _exit


_print:

    push rbp
    mov rbp, rsp
    push rdi
    push rsi

    mov rax, 0x1                     ; write syscall
    mov rdi, 0x1
    mov rsi, [rbp + 0x10]            ; [rbp + 0x10] -> buffer pointer
    mov rdx, [rbp + 0x18]            ; [rbp + 0x18] -> buffer length
    syscall

    ; epilogue
    pop rsi
    pop rdi
    mov rsp, rbp                     ; deallocating the stack
    pop rbp

    ret 0x10

_ascii_to_hex:
    push rbp
    mov rbp, rsp

    .converter:
        mov rsi, 0x0                    ; Set counter to 0
        xor r8, r8                      ; Clear result register
        .loop:
        mov bl, byte [msgBuf + rsi]    	; Load one letter from array into bl
        sub bl, 0x30                    ; Subtract ascii offset
        cmp bl, 0x9                     ; Compare with 9
        jle .skip                       ; If less than or equal to 9 then skip
        sub bl, 0x7                     ; If greater than 9 then subtract ascii offset for character (A-F)
        .skip:
        add r8, rbx                     ; Add converted hex value to register r8
        cmp rsi, 0x2                    ; Check to see if we are at the end of the input
        jz .tail                        ; If so, jump to .tail to avoid shifting register
        inc rsi                         ; Incremenst rsi to move to next character
        shl r8, 0x4                     ; Shift r8 register 4 bits to the left to shift the power of 16
        jmp .loop                       ; Jump back to .loop
        .tail:
        mov rax, r8                     ; Save the converted number to rax for return

    .checker:                           ; Check that converted value was between 0x100 and 0x4FF
        cmp rax, 0x100
        jl _inputError
        cmp rax, 0x4FF
        jg _inputError

    mov rsp, rbp                        ; deallocating the stack
    pop rbp

    ret


; prints socket failed
_socket_failed:
    push socket_f_msg_l
    push socket_f_msg
    call _print
    jmp _exit

; prints socket created
_socket_created:
    push socket_t_msg_l
    push socket_t_msg
    call _print
    ret

; prints connect failed
_bind_failed:
    push bind_f_msg_l
    push bind_f_msg
    call _print
    jmp _exit

; prints bind created
_bind_created:
    push bind_t_msg_l
    push bind_t_msg
    call _print
    ret

; prints socket shutdown
_shutdown_msg:
    push shutdown_t_msg_l
    push shutdown_t_msg
    call _print
    ret

; prints socket closed
_socket_closed:
    push socket_closed_msg_l
    push socket_closed_msg
    call _print
    ret

; prints error message for incorrect bytes received from server
_receive_error:
    push errorReceivingMsg_l
    push errorReceivingMsg
    call _print
    jmp _exit

; prints error with input
_inputError:
    push inputError_l
    push inputError
    call _print
    jmp _exit

_exit:
    call _fileOutput.closeFile      ; Close the open file for output
    call _network.shutdown       	; Close the open socket
    add rsp, 0x20                   ; Cleanup the stack
    mov rax, 60                     ; Exit syscall
    mov rdi, 0
    syscall
