; Read two positive integers: a, b. Display the result of the expression: (a ^ b) - 3
.model small ; size of model
.stack 200h ; size of stack

.data ; data segment
msga db 13,10,'Read a: $' ; db=define byte ; $ ends the string
msgb db 13,10,'Read b: $'
msgf db 13,10,'Result of (a^b)-3 is: $'

; messages for special cases
a0 db 13,10,'For any value of b the result of (a^b)-3 will be: -3 $' ; if a=0 
a1 db 13,10, 'For any value of b the result of (a^b)-3 will be: -2 $' ; if a=1
b0 db 13,10, 'Result of (a^b)-3 is: -2 $' ; if b=0
a2 db 13,10, 'Result of (a^b)-3 is: -1 $' ; if a=2 and b=1 (2^1-3=-1)

; result
res db 30 dup(0) ; we will store the result in res ; size 30 ; dup(0) = fill with (30) 0's 

.code
start:
 mov ax,@data
 mov ds,ax

; number a
 mov ah,09
 mov dx,offset msga
 int 21h
 call readproc ; read a in ax
 push ax ; store ax in the stack

; checking a
 cmp ax,1 ; we check if a=1 
    jne ais0
        mov ah,09
        mov dx, offset a1
        int 21h
        jmp stopprog ; we end the program
 ais0:
 pop ax ; take a from the stack
 push ax ; save a in the stack for later
  cmp ax,0 ; check if a=0
    jne readb
        mov ah,09
        mov dx, offset a0
        int 21h
        jmp stopprog ; we end the program
 
readb:
; number b
 mov ah,09
 mov dx,offset msgb
 int 21h
 call readproc ; read b in ax

; checking b
verif1:
    mov cx,ax ; b -> cx (for multiplication)
    cmp cx,0 ; check if b=0
    jne verif2 
        mov ah,09
        mov dx, offset b0
        int 21h
        jmp stopprog ; we end the program

verif2:
    pop ax ; take a from stack
    push ax ; save a for multiplication
    cmp ax,2 ; check if a=2 
    jne power
    cmp cx,1 ; check if b=1
    jne power
        mov ah,09
        mov dx, offset a2
        int 21h
        jmp stopprog ; we end the program

; raising a to the power of b
power:
    pop bx ; take a from stack
    mov ax,0001 ; the result from the loop will be in ax
multiplication: 
    mul bx ; (a) bx * cx (b)
 loop multiplication ; repeats mul bx and substracts 1 from cx until cx = 0
    dec ax
    dec ax
    dec ax ; we substract 1 from the result 3 times

; adding the result from ax to res
 xor si,si ; reset si which will be our counter
           ; it will help us display res
 mov bx,10 ; bx=10
storing:
    div bx ; divide ax by bx(=10) to extract the last digit which will be stored in dx
    add dl,30h ; add 0 to transform number into char
    mov res[si],dl ; res[si] = dl ; add the digit from dx in res
    inc si ; si++
    xor dx,dx ; reset dx
    cmp ax,0 ; if ax is not 0 yet, repeat  storing:
    jne storing

; displaying res
 mov ah,09
 mov dx, offset msgf
 int 21h

writeres:
    dec si ; si--
    mov ah,02 ;
    mov dl,res[si] ; dl = res[si] -> display dl
    int 21h ; int
    cmp si,0 ; repeat if si != 0
    jne writeres


; procedures
jmp skipProc

readproc proc
    mov ah,01h ; read number 
    int 21h ; int
    and ax,00FFh ; reset ah / transforms al->ax (00FFh = 00000000 11111111)
    sub ax, 30h ; substract 0 to transform from char into number
ret
endp

skipProc:

; stopprog
stopprog:
 mov ah,4ch ; ends program execution
 int 21h
end start
