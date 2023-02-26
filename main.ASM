jmp start
    number db 5 dup 0		; stores output string
    cr     dw 10, 13, "$"	; carriage return, line feed
    temp   dw 0
    

start:
    mov cx,0  				;cx will be holding the current number
    mov dl,0  				;dl will be holding the current character



morechar:
	mov ah,01h      		;read character to al
   	int 21h

  	mov dx,0        		;dx is 0
  	mov dl,al      			;move current character to dl

   	cmp dl,32       		;compare current character to a blank
    je endchar      		;if it is a blank, jump to endchar (end of token)

    cmp al, 0dh 			; check if it is enter
	je dummy_label			;if it is enter, jump to fininput (end of input)

    cmp dl,43       		;compare current character to +
	je plus         		;if it is +, jump to plus

	cmp dl,42       		;compare current character to *
	je time        			;if it is *, jump to times

	cmp dl,47       		;compare current character to /
	je divide       		;if it is /, jump to divide
	
	cmp dl,94       		;compare current character to ^
    je operation_xor 

    cmp dl,38       		;compare current character to &
    je operation_and          

    cmp dl,124      		;compare current character to |
    je dummy_label_to_or           
	
	cmp dl,64       		;compare current character to A
	ja dummy_label2    
	cmp dl,58				;compare current character is digit
	jb dummy_label1

endchar:
	push cx         		;push current number to stack
	mov cx,0        		;reset current number
	jmp morechar    		;go back to morechar

plus:
	pop ax          		;pop number from stack
	pop bx          		;pop number from stack
	add ax,bx       		;add the two numbers
	push ax         		;push the result to stack
	mov bx,0        		;reset bx
	mov ax,0        		;reset ax
	mov ah,01h      		;read character to al
	int 21h
	cmp al, 0dh 			;check if it is enter
	je dummy_label			;if it is enter, jump to fininput (end of input)
	jmp morechar    		;go back to morechar

dummy_label_to_or:
	jmp operation_or
time:
	pop ax          		;pop number from stack
	pop bx          		;pop number from stack
	mul bx          		;multiply ax by bx->    dx:ax=ax*bx 
	push ax         		;push the result to stack
	mov bx,0        		;reset bx
	mov ax,0        		;reset ax
	mov ah,01h      		;read character to al
	int 21h
	cmp al, 0dh 			; check if it is enter
	je dummy_label			;if it is enter, jump to fininput (end of input)
	jmp morechar    		;go back to morechar

divide:
	mov dx,0
	pop cx          		;pop number from stack
	pop ax          		;pop number from stack
	div cx          		;divide ax by bx->  
	push ax	        		;push the result to stack

	mov cx,0        		;reset bx
	mov ax,0        		;reset ax
	mov dx,0
	mov ah,01h      		;read character to al
	int 21h
	cmp al, 0dh 			; check if it is enter
	je dummy_label			;if it is enter, jump to fininput (end of input)   
	jmp morechar    		;go back to morechar


dummy_label:
    jmp fininput

dummy_label1:
	jmp char_is_number	

dummy_label2:
	jmp char_is_letter


operation_xor:
    pop ax          		;pop number from stack
    pop bx          		;pop number from stack
    xor ax,bx      			;xor the two numbers
    push ax         		;push the result to stack
    mov bx,0        		;reset bx
    mov ax,0        		;reset ax
	mov ah,01h      		;read character to al
   	int 21h
	cmp al, 0dh 			; check if it is enter
	je dummy_label			;if it is enter, jump to fininput (end of input)
    jmp morechar    		;go back to morechar

operation_and:
    pop ax          		;pop number from stack
    pop bx          		;pop number from stack
    and ax,bx      			;and the two numbers
    push ax         		;push the result to stack
    mov bx,0        		;reset bx
    mov ax,0        		;reset ax
    mov ah,01h      		;read character to al
   	int 21h
	cmp al, 0dh 			; check if it is enter
	je dummy_label			;if it is enter, jump to fininput (end of input)
	jmp morechar    		;go back to morechar

operation_or:
    pop ax          		;pop number from stack
    pop bx          		;pop number from stack
    or ax,bx        		;or the two numbers
    push ax         		;push the result to stack
    mov bx,0        		;reset bx
    mov ax,0        		;reset ax
    mov ah,01h      		;read character to al
   	int 21h
	cmp al, 0dh 			; check if it is enter
	je dummy_label			;if it is enter, jump to fininput (end of input)
	jmp morechar    		;go back to morechar	




char_is_letter:
	sub dx,'7'       		;subtract 55 from dx
	mov temp,dx      		;move dx to temp
	mov ax,cx        
	mov cx,16d
	mul cx          		;multiply ax by 16
	add ax,temp     		;add temp to ax
	mov cx,ax       		;move ax to cx
	jmp morechar
	jmp fininput

char_is_number:

	sub dx,'0'       		;subtract 48 from dx
	mov temp,dx      		;move dx to ax
	mov ax,cx        
	mov cx,16d
	mul cx          		;multiply ax by 16
	add ax,temp     		;add temp to ax
	mov cx,ax       		;move ax to cx
	jmp morechar
	
fininput:

	cmp SP, 0FFFEh 			; check if the stack is empty or not
	je  one_number			; if equal jump to one_number
	
	pop dx          		;pop number from stack
	mov ax,dx        	
	mov bx,0
	mov cx,0
	mov dx,0 				; put a character in DL by popping value from stack in DX because top half is empty
	jmp setup_string
one_number:
	mov ax,cx

setup_string:
	;result is already in ax
	mov bx,offset number+4 	; put a $ at end of buffer
	mov b[bx],"$"			; we will fill buffer from back
	dec bx

convert_hex:

	mov dx,0
	mov cx,16d
	div cx	
	
	cmp dl,9d
	ja connum				; divide ax (i.e. current number) by 10 to get the last digit
	add dx,48d  			; convert remainder (last digit) to its ASCII representation
	mov [bx],dl				; and move to buffer for output
	dec bx
	cmp bl,number			; check if we have got all digits
	jae convert_hex
	jmp print_cr

connum:
	add dx,55d  			; convert remainder (last digit) to its ASCII representation
	mov [bx],dl				; and move to buffer for output
	dec bx
	cmp bl,number			; check if we have got all digits
	jae convert_hex			; check if we have got all digits

print_cr:
	;dummy label

printout:
		
	MOV DL, 10 				; PRINT NEW LINE FOR OUTPUT
	MOV AH, 02
	INT 21h

	mov dx,bx				; give the address of string to dx
	inc dx					; we decremented once too many, go forward one
	mov ah,09
	int 21h

exit:
	mov ah,04ch				; exit the program with 0
	mov al,00
	int 21h





