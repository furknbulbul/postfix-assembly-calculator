;read input until see enter
;until see a blank store characters to calculate hexadecimal number
;when blank is seen push the number to the stack
;when an operator is seen pop the top two numbers from the stack and perform the operation
;when the end of the input is seen pop the top number from the stack and print it


jmp start
     

start:
    mov cx,0  ;cx will be holding the current number
    mov ax,0  ;dx will be holding the temp result
    mov dl,0  ;dl will be holding the current character


;read characters until a blank is seen

morechar:
    mov ah,01h      ;read character to al
    int 21h

    mov dx,0        ;dx is 0
    mov dl,al       ;move current character to dl


    cmp dl,32       ;compare current character to a blank
    je endchar      ;if it is a blank, jump to endchar (end of token)

    cmp dl,0Dh      ;compare current character to enter
    je fininput     ;if it is enter, jump to fininput (end of input)

    cmp dl,43       ;compare current character to +
    je plus         ;if it is +, jump to plus

    cmp dl,42       ;compare current character to *
    je times        ;if it is *, jump to times

    cmp dl,47       ;compare current character to /
    je divide       ;if it is /, jump to divide

    cmp dl,94       ;compare current character to ^
    je xor          ;if it is ^, jump to xor

    cmp dl,38       ;compare current character to &
    je and          ;if it is &, jump to and

    cmp dl,124      ;compare current character to |
    je or           ;if it is |, jump to or




endchar:
    push cx         ;push current number to stack
    mov cx,0        ;reset current number

plus:
    pop ax          ;pop number from stack
    pop bx          ;pop number from stack
    add ax,bx       ;add the two numbers
    push ax         ;push the result to stack
    mov bx,0        ;reset bx
    mov ax,0        ;reset ax
    jmp morechar    ;go back to morechar

times:
    pop ax          ;pop number from stack
    pop bx          ;pop number from stack
    mul bx          ;multiply ax by bx->    dx:ax=ax*bx 
    push ax         ;push the result to stack
    mov bx,0        ;reset bx
    mov ax,0        ;reset ax
    jmp morechar    ;go back to morechar

divide:
    pop ax          ;pop number from stack
    pop bx          ;pop number from stack
    div bx          ;divide ax by bx->    dx:ax=ax/bx
    push ax         ;push the result to stack
    mov bx,0        ;reset bx
    mov ax,0        ;reset ax
    jmp morechar    ;go back to morechar


xor:
    

