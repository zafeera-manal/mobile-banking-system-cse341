.MODEL SMALL
.STACK 100H
.DATA
    
    msg0 db "Welcome to better bKash service!",10,13,"$    "
    msg1 db "Enter your UserID: $" 
    msg2 db "Invalid account. Re-$"
    msg3 db "Enter your password: $"    
    msg4 db "Login successful!$" 
    msg5 db "Wrong password. Re-$"
    msg9 db "Enter your pin: $"
    msg10 db 10,13,"Wrong Pin. Try again!",10,13,"$"
    msg11 db "Enter receiver's account number: $"
    msg12 db "Insufficient Balance! Try Again!$"
    msg13 db "Invalid Selection! Please enter a valid option.$"
    msg15 db 10,13,"Exceeded Digit Limit",10,13,"$"

    msg6 db "Select Options:", 10, 13, "1: Check Balance", 10, 13, "2: Cash In", 10, 13, "3: Send Money", 10, 13, "4: Cash Out", 10, 13, "5: Log Out", 10, 13, "6: Exit", 10, 13, "Selected: $" 
    
    msg7 db "Transaction Successful! $" 
    
    msg8 db "Your current Balance is : $"
     
    factor1 db 100  
    factor2 dw 1000
    account dw 0
    store   dw 0
    
    arr dw  0001, 1234, 500, 111, 0002, 5678, 1000, 222, 0003, 1212, 1000, 333, 0004, 3687, 2000, 444, 0005, 2343, 5000, 555  
    
    arrLen dw 5 ;number of users predefined
    
    input_msg DB 'Enter the amount (up to 3 digits): $'
    buffer    DB 4 DUP('$') ; buffer to store input string (3 digits + carriage return)
    buffer2   DB 16 DUP('$')
    amount    DW 0            ; variable to store the converted amount
    balance   DW 69
    pin       DW 0
    rec_acc   DW 0
    rec_bal   DW 0
    
    
    
.CODE  
    MAIN PROC
        
        MOV AX, @DATA
        MOV DS, AX
        MOV ES, AX
        
        MOV AH,9
        LEA DX,msg0
        INT 21H
        
        
start:  
        ;Reset everything
        XOR AX, AX ;compare bits and sets 0 for same value
        MOV BX,0
        MOV CX,0
        MOV DX,0
        MOV SI,0
        MOV DI,0
        MOV rec_acc,0
        MOV rec_bal,0
        MOV account,0
        MOV amount,0
        MOV balance,0         
        MOV pin,0
        
        
    enterAcc:
        mov account, 0   
        mov factor2, 1000
        
        lea dx, msg1
        mov ah, 9
        int 21h     
            
        ;take input for userID 
        mov cx, 4      
        inputAcc:
            mov ah, 1
            int 21h       
            sub al, 48     ;Convert to use as value
            mov ah, 0
            mul factor2  
            
            add account, ax
                
            mov ax, factor2 
            mov bl, 10      ;Each time the factor is decreasing by 1 decimal value (1000 -> 100, 100-> 10)
            div bl  
            mov factor2, ax
                
            loop inputAcc 
            
            
        ;new line
            mov ah, 2
            mov dl, 10
            int 21h
            mov dl, 13
            int 21h
     
            
        ;check if account exists 
        mov cx, arrLen
        mov si, 0   
        mov bx, account
        
    findAcc:  
            cmp arr[si], bx
            je foundAcc
            
            add si, 8
            loop findAcc   
            
            
    printWrongAcc:
            lea dx, msg2
            mov ah, 9
            int 21h
            jmp enterAcc
            
            
    foundAcc:
     
        lea dx, msg3   ;password prompt
        mov ah, 9
        int 21h   
        
        ;take input for password   
        mov account, 0   
        mov factor2, 1000
        mov cx, 4 
            
    inputPass:
            mov ah, 1
            int 21h      
            sub al, 48
            mov ah, 0    
            mul factor2 
            
            add account, ax
            
            MOV AH,2    ;Password Hashing. Will not show input numbers instead show asterisk
            MOV DL,8
            INT 21h
            MOV DL,"*"
            INT 21h
                
            mov ax, factor2 
            mov bl, 10
            div bl  
            mov factor2, ax
                
            loop inputPass 
            
        ;new line
        mov ah, 2
        mov dl, 10
        int 21h
        mov dl, 13
        int 21h
            
                
        ;check if password matches 
        mov bx, account
        cmp arr[si+2], bx
        je printSuccess
        
        lea dx, msg5
        mov ah, 9
        int 21h 
        jmp foundAcc 
          
        
        
    printSuccess: 
        lea dx, msg4
        mov ah, 9
        int 21h
        
        MOV [account], SI  ;storing the logged in account value as SI will be used later.  
        
        mov BX, arr[si+4]     ; taking account balance to a variable
        mov [balance], BX
        
        mov BX, arr[si+6]     ; taking account pin to a variable
        mov [pin], BX
        
        
    options:                 
        ; New line
        mov ah, 2
        mov dl, 10
        int 21h
        mov dl, 13
        int 21h
        
         
               
        ; Reset all       
        XOR AX, AX ;compare bits and sets 0 for same value
        MOV BX,0
        MOV CX,0
        MOV DX,0
        MOV SI,0
        MOV DI,0

        MOV rec_acc,0
        MOV rec_bal,0 
        
        ; Above all login process is complete.
            
        ; Options
        
        MOV AH,9
        LEA DX,msg6
        INT 21h 
        
        ; Take Input for selecting option
        
        MOV AH,1 
        INT 21H   ;input goes to AL
        
        MOV BL,AL
        

        
        ;new line
        mov ah, 2
        mov dl, 10
        int 21h
        mov dl, 13
        int 21h 
        
        CMP BL,'1'
        JE printAmount
        
        CMP BL,'2'
        JE cashin_amount
        
        CMP BL,'3'
        JE send_amount
        
        CMP BL,'4'
        JE cashout_amount
        
        CMP BL,'5'
        JE logout
        
        CMP BL,'6'
        JE exit
        
        
        lea dx, msg13
        mov ah, 9
        int 21h 
        
        JMP options
            
    cashin_amount:
        ; Display input message
        MOV AH, 09H           ; DOS function to print string
        LEA DX, input_msg     ; load offset of input_msg to DX
        INT 21H               ; call DOS

        ; Read input from keyboard
        MOV AH, 0AH           ; DOS function to read string
        LEA DX, buffer        ; load buffer address to DX   PRESS "ENTER" to exit
        INT 21H               ; call DOS

        ; Convert ASCII to binary
        LEA SI, [buffer+2] ; offset to the start of input buffer (skip first byte which contains the length)
        XOR AX, AX             ; clear AX register (will hold the converted number)
        convert_loop1:
            MOV BL, [SI]           ; load next character from buffer
            CMP BL, 0Dh            ; check if it's end of string
            JE convert_done1        ; if it is, conversion is done
            SUB BL, 30H            ; convert ASCII to binary
            MOV CX, 10             ; multiply AX by 10
            MUL CX
            ADD AX, BX             ; add the converted digit to AX
            INC SI                 ; move to next character
            JMP convert_loop1       ; repeat for next character
        convert_done1:
            ; At this point, AX holds the converted number
            MOV [amount], AX      ; Store the converted number in the amount variable
            
            MOV CX,999
            CMP AX,999 
            JLE okay1
            
            LEA DX,msg15
            MOV AH,9
            INT 21H
            
            JMP cashin_amount
        
            okay1:
            ;new line
            mov ah, 2
            mov dl, 10
            int 21h
            mov dl, 13
            int 21h
            
            MOV AH,9
            LEA DX,msg9
            INT 21h
            
            MOV store, 0   
            MOV factor2, 100
            MOV CX, 3
            
            pin_loop1:
                MOV AH, 1
                INT 21h      
                SUB AL, 48
                MOV AH, 0    
                MUL factor2 
                
                ADD store, AX
                    
                mov AX, factor2 
                mov BL, 10
                div BL  
                mov factor2, AX
                    
                loop pin_loop1 
                    
                    
                        
                ;check if password matches 
                mov bx, store
                cmp [pin], bx
                je pin_success1
                
                lea dx, msg10
                mov ah, 9
                int 21h
                
                ; Reset all       
                XOR AX, AX ;compare bits and sets 0 for same value
                MOV BX,0
                MOV CX,0
                MOV DX,0 
                
                JMP options  ;Back to options as logged in 
            
            pin_success1:
            
            MOV SI, [account] ; Load account number to SI
            
            MOV BX, [balance] ; Load prev balance to BX
            MOV CX, [amount]  ; Load input ammount to CX
            ADD BX, CX
            
            MOV arr[SI+4],BX  ; Update balance in array
            MOV [balance],BX  ; As well as current logged in balance
            
            ;New line
            mov ah, 2
            mov dl, 10
            int 21h
            mov dl, 13
            int 21h 
            
            JMP transaction_success
        

    send_amount:    
          
        enterRecAcc:
            mov rec_acc, 0   
            mov factor2, 1000
            
            lea dx, msg11
            mov ah, 9
            int 21h     
                
            ;take input for userID 
            mov cx, 4      
            inputRecAcc:
                mov ah, 1
                int 21h       
                sub al, 48
                mov ah, 0
                mul factor2  
                
                add rec_acc, ax
                    
                mov ax, factor2 
                mov bl, 10
                div bl  
                mov factor2, ax
                    
                loop inputRecAcc 
            
            
            ;new line
                mov ah, 2
                mov dl, 10
                int 21h
                mov dl, 13
                int 21h
     
            
            ;check if account exists 
            mov cx, arrLen
            mov si, 0   
            mov bx, rec_acc 
            
            mov di, [account]
        
        findRecAcc:    
            cmp bx, arr[di]
            je printWrongRecAcc 
            
            cmp arr[si], bx
            je foundRecAcc
               
            add si, 8
            loop findRecAcc   
                
                
        printWrongRecAcc:        
        
            lea dx, msg2
            mov ah, 9
            int 21h
            jmp enterRecAcc
            
            
    foundRecAcc:
    
                
        mov BX, SI       ; taking rec account index number to a variable
        mov [rec_acc], BX
        
        mov BX, arr[si+4]     ; taking rec account balance to a variable
        mov [rec_bal], BX  
        
        
        back1:
        
        ; Reset all       
        XOR AX, AX ;compare bits and sets 0 for same value
        MOV BX,0
        MOV CX,0
        MOV DX,0
        MOV SI,0 
        
        
        ; Display input message
        MOV AH, 09H           ; DOS function to print string
        LEA DX, input_msg     ; load offset of input_msg to DX
        INT 21H               ; call DOS

        ; Read input from keyboard
        MOV AH, 0AH           ; DOS function to read string
        LEA DX, buffer        ; load buffer address to DX   PRESS "ENTER" to exit
        INT 21H               ; call DOS

        ; Convert ASCII to binary
        LEA SI, [buffer+2] ; offset to the start of input buffer (skip first byte which contains the length)
        XOR AX, AX             ; clear AX register (will hold the converted number)
        convert_loop2:
            MOV BL, [SI]           ; load next character from buffer
            CMP BL, 0Dh            ; check if it's end of string
            JE convert_done2        ; if it is, conversion is done
            SUB BL, 30H            ; convert ASCII to binary
            MOV CX, 10             ; multiply AX by 10
            MUL CX
            ADD AX, BX             ; add the converted digit to AX
            INC SI                 ; move to next character
            JMP convert_loop2       ; repeat for next character
        convert_done2:
            ; At this point, AX holds the converted number
            MOV [amount], AX      ; Store the converted number in the amount variable
            
            MOV CX,999
            CMP AX,999 
            JLE okay2
            
            LEA DX,msg15
            MOV AH,9
            INT 21H
            
            JMP back1
            
        
            okay2:            
            
            MOV BX, [balance]
            CMP BX,AX
            JGE okay
                        
               ;new line
                mov ah, 2
                mov dl, 10
                int 21h
                mov dl, 13
                int 21h            
            
            MOV AH,9
            LEA DX, msg12
            INT 21H
            
            JMP options
            
            
            Okay:
            
            ;new line
            mov ah, 2
            mov dl, 10
            int 21h
            mov dl, 13
            int 21h
            
            MOV AH,9
            LEA DX,msg9
            INT 21h                        
            
            MOV store, 0   
            MOV factor2, 100
            MOV CX, 3
            
            pin_loop2:
                    MOV AH, 1
                    INT 21h      
                    SUB AL, 48
                    MOV AH, 0    
                    MUL factor2 
                    
                    ADD store, AX
                        
                    mov AX, factor2 
                    mov BL, 10
                    div BL  
                    mov factor2, AX
                        
                    loop pin_loop2 
                    
                        
                ;check if password matches 
                mov bx, store
                cmp [pin], bx
                je pin_success2
                
                lea dx, msg10
                mov ah, 9
                int 21h
                
                ; Reset all       
                XOR AX, AX ;compare bits and sets 0 for same value
                MOV BX,0
                MOV CX,0
                MOV DX,0 
                
                JMP options  ;Back to options as logged in 
            
            pin_success2:
            
            ;Logged In Acc Changes
            MOV SI, [account] ; Load account number to SI
            
            MOV BX, [balance] ; Load prev balance to BX
            MOV CX, [amount]  ; Load input ammount to CX
            SUB BX, CX
            
            MOV arr[SI+4],BX  ; Update balance in array
            MOV [balance],BX  ; As well as current logged in balance  
            
            ;Rec Acc Changes
            MOV SI,0
            MOV SI,[rec_acc]
            
            MOV BX, [rec_bal]
            MOV CX, [amount]
            ADD BX, CX
            
            MOV arr[SI+4],BX
            MOV [rec_bal],BX
            
            ;New line
            mov ah, 2
            mov dl, 10
            int 21h
            mov dl, 13
            int 21h 
            
            JMP transaction_success
            
            
    cashout_amount:
    
        
        ; Reset all       
        XOR AX, AX ;compare bits and sets 0 for same value
        MOV BX,0
        MOV CX,0
        MOV DX,0
        MOV SI,0     
    
        ; Display input message
        MOV AH, 09H           ; DOS function to print string
        LEA DX, input_msg     ; load offset of input_msg to DX
        INT 21H               ; call DOS

        ; Read input from keyboard
        MOV AH, 0AH           ; DOS function to read string
        LEA DX, buffer        ; load buffer address to DX   PRESS "ENTER" to exit
        INT 21H               ; call DOS

        ; Convert ASCII to binary
        LEA SI, [buffer+2] ; offset to the start of input buffer (skip first byte which contains the length)
        XOR AX, AX             ; clear AX register (will hold the converted number)
        convert_loop3:
            MOV BL, [SI]           ; load next character from buffer
            CMP BL, 0Dh            ; check if it's end of string
            JE convert_done3        ; if it is, conversion is done
            SUB BL, 30H            ; convert ASCII to binary
            MOV CX, 10             ; multiply AX by 10
            MUL CX
            ADD AX, BX             ; add the converted digit to AX
            INC SI                 ; move to next character
            JMP convert_loop3       ; repeat for next character
        convert_done3:
            ; At this point, AX holds the converted number
            MOV [amount], AX      ; Store the converted number in the amount variable
            
            MOV CX,999
            CMP AX,999 
            JLE okay3
            
            LEA DX,msg15
            MOV AH,9
            INT 21H
            
            JMP cashout_amount
        
            okay3:
            
                MOV BX, [balance]
                CMP BX,AX
                JGE okay4
                
                ;new line
                mov ah, 2
                mov dl, 10
                int 21h
                mov dl, 13
                int 21h
                
                MOV AH,9
                LEA DX,msg12
                INT 21H            
                
                JMP options
            
            okay4:
                ;new line
                mov ah, 2
                mov dl, 10
                int 21h
                mov dl, 13
                int 21h
                
                
                MOV AH,9
                LEA DX,msg9
                INT 21h 

            
            MOV store, 0   
            MOV factor2, 100
            MOV CX, 3
            
            pin_loop3:
            
                MOV AH, 1
                INT 21h      
                SUB AL, 48
                MOV AH, 0    
                MUL factor2 
                
                ADD store, AX
                    
                mov AX, factor2 
                mov BL, 10
                div BL  
                mov factor2, AX
                    
                loop pin_loop3 
                    
                    
                        
                ;check if password matches 
                mov bx, store
                cmp [pin], bx
                je pin_success3
                
                lea dx, msg10
                mov ah, 9
                int 21h
                
                ; Reset all       
                XOR AX, AX ;compare bits and sets 0 for same value
                MOV BX,0
                MOV CX,0
                MOV DX,0 
                
                JMP options  ;Back to options as logged in 
            
            pin_success3:
            
                MOV SI, [account] ; Load account number to SI
                
                MOV BX, [balance] ; Load prev balance to BX
                MOV CX, [amount]  ; Load input ammount to CX
                SUB BX, CX
                
                MOV arr[SI+4],BX  ; Update balance in array
                MOV [balance],BX  ; As well as current logged in balance
                
                ;New line
                mov ah, 2
                mov dl, 10
                int 21h
                mov dl, 13
                int 21h 
                
                JMP transaction_success            
                  
                    
           
    transaction_success:
        MOV AH, 09H    ; print string for success
        LEA DX, msg7    
        INT 21H 
        
        ; New line
        mov ah, 2
        mov dl, 10
        int 21h
        mov dl, 13
        int 21h           

    printAmount:
        MOV AH, 09H    ; print string for success
        LEA DX, msg8    
        INT 21H 
    
        ; Convert the number in AX into ASCII characters and print them
        MOV CX, 0    ; Counter for the number of digits printed
        MOV AX, [balance] ;Load our balance to AX 
        print_amount_loop:
           
            MOV DX, 0    ; Clear DX register
            MOV BX, 10   ; Divisor for extracting digits
            DIV BX       ; Divide AX by BX, quotient in AX, remainder in DX
            ADD DL, '0'  ; Convert remainder to ASCII
            PUSH DX      ; Save ASCII character to stack for later printing
            INC CX       ; Increment counter
            TEST AX, AX  ; Check if quotient is zero
            JNZ print_amount_loop ; If not zero, continue printing digits
        
            ; Pop and print each digit from the stack
        print_stack:
            POP DX       ; Retrieve ASCII character from stack
            MOV AH, 02h  ; DOS function to print character
            INT 21h      ; Call DOS
            DEC CX       ; Decrement counter
            JNZ print_stack ; If counter is not zero, continue printing digits
        
        ; Code snippet to print the amount stored in the 'amount' variable
            ; Now you can use the amount in AX for further processing
            ; For example, you can subtract it from another value representing your balance
    
            ; New line
            mov ah, 2
            mov dl, 10
            int 21h
            mov dl, 13
            int 21h
            
        JMP options    
        ; Exit the program
        ; Jump to the exit point to terminate the program
    logout:
       JMP start
             
    exit:
        MOV AH, 4CH            ; DOS function to terminate program
        INT 21H                ; call DOS
        
    MAIN ENDP
    END MAIN
