; control  1 2 3 4
;          q w e r
;          a s d f
;          z x c v
[org 0x0100]
call gameLoop

board: db 0,0,0,0     ,0,0,0,0     ,0,0,0,0     ,0,0,0,0
gameEnded: db 0
MessageFirstWon: db 'First Player won the game :)',0
MessageSecondWon: db 'Second Player won the game :)',0
MessageDraw: db 'Game Drawed Sed loife',0
turn: db 1
wonFlag: db 0
delay:
    push cx
    mov cx, 0
    delayLoop:
    inc cx
    cmp cx, 0xFFFF
    jnz delayLoop
    pop cx
    ret
PlayerWon:
    push ax
    push bx
    push cx
    push dx
    push di
    mov bx, 0
    mov di, 0
    mov dx, 0
    mov ax, [turn]
    mov cx, 2
    div cx
    cmp dl, 0
    jnz player2msg
        FirstWonLoop:
        mov cx, 0
        mov ch, 0x0E
        mov cl, [MessageFirstWon+bx]
        mov word[es:di],cx
        add di, 2
        inc bx
        cmp byte [MessageFirstWon+bx],0
        jnz FirstWonLoop
    player2msg:
        SecondWonLoop:
        mov cx, 0
        mov ch, 0x0E
        mov cl, [MessageSecondWon+bx]
        mov word[es:di],cx
        add di, 2
        inc bx
        cmp byte [MessageSecondWon+bx],0
        jnz SecondWonLoop    
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
Draw:
    push ax
    push bx
    push cx
    push dx
    push di
    mov di, 0
    mov bx, 0
        DrawLoop:
        mov cx,0
        mov ch, 0x04
        mov cl, [MessageDraw+bx]
        mov word [es:di],cx
        add di, 2
        inc bx
        cmp byte [MessageDraw+bx],0
        jnz DrawLoop
    pop di
    pop dx
    pop cx
    pop bx
    pop ax
    ret
winCondition:
    push ax
    push si
    mov di, 0 ; Assume game continues.

    ; Check rows.
    mov si, 0
    rowLoop:
        mov al, [board+si]
        cmp al, [board+si+1]
        jne nextRow
        cmp al, [board+si+2]
        jne nextRow
        cmp al, [board+si+3]
        jne nextRow
        cmp al, 0
        je nextRow
        mov di, 1 ; Win condition met.
        jmp endCheck
    nextRow:
        add si, 4
        cmp si, 16
        jl rowLoop

    ; Check columns.
    mov si, 0
    columnLoop:
        mov al, [board+si]
        cmp al, [board+si+4]
        jne nextColumn
        cmp al, [board+si+8]
        jne nextColumn
        cmp al, [board+si+12]
        jne nextColumn
        cmp al, 0
        je nextColumn
        mov di, 1 ; Win condition met.
        jmp endCheck
    nextColumn:
        inc si
        cmp si, 4
        jl columnLoop

    ; Check diagonals.
    mov al, [board]
    cmp al, [board+5]
    jne checkOtherDiagonal
    cmp al, [board+10]
    jne checkOtherDiagonal
    cmp al, [board+15]
    jne checkOtherDiagonal
    cmp al, 0
    je checkOtherDiagonal
    mov di, 1 ; Win condition met.
    jmp endCheck

    checkOtherDiagonal:
   mov al, [board+3]
   cmp al, [board+6]
   jne noWinnerFound
   cmp al, [board+9]
   jne noWinnerFound
   cmp al, [board+12]
   jne noWinnerFound
   cmp al, 0
   je noWinnerFound
   mov di, 1 ; Win condition met.

    noWinnerFound:
    endCheck:
   
   pop si 
   pop ax 
   
    ret 

gameLoop:
    call clearRegister
    call clearscreen
    call box
    back:
    mov byte[gameEnded], 0
    call getInput
    call placeValue
    call winCondition
    call checkGameStatus
    cmp byte[gameEnded], 1
    jz gameLoopEnd
    jmp back
    gameLoopEnd:
    cmp byte[wonFlag],0
    jnz gamenotDrawed
    call Draw
    gamenotDrawed:
    mov ah, 0x01
    int 0x21
    call clearscreen
    mov ax, 0x4c00
    int 0x21
    checkGameStatus:
    push cx
    mov cx, 16 
    xor si, si
    checkLoop:
        mov al, [board+si]
        cmp al, 0
        jz emptyCellFound 
        inc si 
        loop checkLoop 
    emptyCellFound:
        cmp si, 16 
        jnz notAllFilled
        mov byte[gameEnded], 1 ; Set gameEnded to 1 if all cells are filled.
    notAllFilled:
        cmp di, 1 ; Check if winCondition was met.
        je gameWon ; If winCondition was met, set gameEnded to 1.
        pop cx
        ret
    gameWon:
        call PlayerWon
        mov byte[wonFlag],1
        mov byte[gameEnded], 1 ; Set gameEnded to 1 if winCondition was met.
        pop cx
        ret

getInput:
    push bx
    push ax
    push si
    push cx
    mov cx, 2
    mov bx, 0
    mov ah, 0x00
    int 0x16
    cmp al, '1'
   jnz notInputOne
   mov bx, 0
   jmp exitGetInput
   notInputOne :
   cmp al, '2'
   jnz notInputTwo
   mov bx, 1
   jmp exitGetInput
   notInputTwo :
   cmp al, '3'
   jnz notInputThree
   mov bx, 2
   jmp exitGetInput
   notInputThree :
   cmp al, '4'
   jnz notInputFour
   mov bx, 3
   jmp exitGetInput
   notInputFour :
   cmp al, 'q'
   jnz notInputQ
   mov bx, 4
   jmp exitGetInput
   notInputQ :
   cmp al, 'w'
   jnz notInputW
   mov bx, 5
   jmp exitGetInput
   notInputW :
   cmp al, 'e'
   jnz notInputE
   mov bx, 6
   jmp exitGetInput
   notInputE :
   cmp al, 'r'
   jnz notInputR
   mov bx, 7
   jmp exitGetInput
   notInputR :
   cmp al, 'a'
   jnz notInputA
   mov bx, 8
   jmp exitGetInput
   notInputA :
   cmp al, 's'
   jnz notInputS
   mov bx, 9
   jmp exitGetInput
   notInputS :
   cmp al, 'd'
   jnz notInputD
   mov bx, 10
   jmp exitGetInput
   notInputD :
   cmp al, 'f'
   jnz notInputF
   mov bx, 11
   jmp exitGetInput
   notInputF :
   cmp al, 'z'
   jnz notInputZ
   mov bx, 12
   jmp exitGetInput
   notInputZ :
   cmp al, 'x'
   jnz notInputX
   mov bx, 13
   jmp exitGetInput
   notInputX :
   cmp al, 'c'
   jnz notInputC
   mov bx, 14
   jmp exitGetInput
   notInputC :
   cmp al, 'v'
   jnz notInputV
   mov bx, 15
   jmp exitGetInput
   notInputV :
   jmp skip
   exitGetInput:
   cmp byte [board+bx], 0
   jne skip
   ;turn 1
   mov ax, 0
   mov al, [turn]
   div cx
   cmp ah, 0 ; Compare the remainder with 0.
   jne turn2
   mov byte [board+bx],0x1F
   jmp incrementTurn
    turn2:
   ;turn 2
   mov byte [board+bx], 0x28
    incrementTurn:
   inc byte [turn]
    skip:
    pop cx
    pop si
    pop ax
    pop bx
    ret
cordinatesCalculate:
    cmp bx, 0
    jnz notZero
    mov si, 494
    jmp exitCordinateCalculate
    notZero:
    cmp bx, 1
    jnz notOne
    mov si, 504
    jmp exitCordinateCalculate
    notOne:
    cmp bx, 2
    jnz notTwo
    mov si, 514
    jmp exitCordinateCalculate
    notTwo:
    cmp bx, 3
    jnz notThree
    mov si, 524
    jmp exitCordinateCalculate
    notThree:
    cmp bx, 4
    jnz notFour
    mov si, 974
    jmp exitCordinateCalculate
    notFour:
    cmp bx, 5
    jnz notFive
    mov si, 984
    jmp exitCordinateCalculate
    notFive:
    cmp bx, 6
    jnz notSix
    mov si, 994
    jmp exitCordinateCalculate
    notSix:
    cmp bx, 7
    jnz notSeven
    mov si, 1004
    jmp exitCordinateCalculate
    notSeven:
    cmp bx, 8
    jnz notEight
    mov si, 1454
    jmp exitCordinateCalculate
    notEight:
    cmp bx, 9
    jnz notNine
    mov si, 1464
    jmp exitCordinateCalculate
    notNine:
    cmp bx, 10
    jnz notTen
    mov si, 1474
    jmp exitCordinateCalculate
    notTen:
    cmp bx, 11
    jnz notEleven
    mov si, 1484
    jmp exitCordinateCalculate
    notEleven:
    cmp bx, 12
    jnz notTweleve
    mov si, 1934
    jmp exitCordinateCalculate
    notTweleve:
    cmp bx, 13
    jnz notThirteen
    mov si, 1944
    jmp exitCordinateCalculate
    notThirteen:
    cmp bx, 14
    jnz notFourteen
    mov si, 1954
    jmp exitCordinateCalculate
    notFourteen:
    cmp bx, 15
    jnz notFifteen
    mov si, 1964
    jmp exitCordinateCalculate
    notFifteen:
    cmp bx, 16
    jnz notSixteen
    mov si, 1974
    jmp exitCordinateCalculate
    notSixteen:
    exitCordinateCalculate:
    ret
placeValue:
    push ax
    push bx
    push cx
    push dx
    push si
    push di
    mov ax, 0xb800
    mov es, ax
    mov dx, 0
    placeValueLoop:
    mov si, 0
    mov ah, 0x30 ; Set AH for black foreground and cyan background
    ;mov ah, 0x34 ; Set AH for red foreground and cyan background
    ;mov ah, 0x31 ; Set AH for blue foreground and cyan background
    ;mov ah, 0x32 ; Set AH for green foreground and cyan background
    ;mov ah, 0x36 ; Set AH for yellow foreground and cyan background
    ;mov ah, 0x35 ; Set AH for magenta foreground and cyan background
    mov cl, [board+bx]
    add cl, 0x30 ;0x30=48  0x1F=31   48+31=79   79=O
    cmp cl, '0'
    jnz SimpleCl ; to replace 0 with space so that we know that no value is placed there
    mov cl, 0x20
    SimpleCl:
    mov al, cl
    call cordinatesCalculate
    mov word [es:si], ax
    inc dx
    inc bx
    cmp dx, 15
    jbe placeValueLoop

    pop di
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    ret

clearRegister:
	xor ax, ax
	xor bx, bx
	xor cx, cx
	xor dx, dx
	xor si, si
	xor di, di
	ret
clearscreen:
	push ax
	push cx
	push di
	mov ax, 0xb800
	mov es, ax
	mov ax, 0x0720
	mov cx, 4000
	mov di, 0
	rep stosw
	pop di
	pop cx
	pop ax
	ret
box:
    push ax
    push si
    push di
    mov ax, 0xb800
    mov es, ax
    mov di, 492
    mov si, 652
    firstRowBox1:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 658
    jnz firstRowBox1
    mov di, 502
    mov si, 662
    firstRowBox2:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 668
    jnz firstRowBox2
    mov di, 512
    mov si, 672
    firstRowBox3:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 678
    jnz firstRowBox3
    mov di, 522
    mov si, 682
    firstRowBox4
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 688
    jnz firstRowBox4
    ;first row completed
    mov di, 972
    mov si, 1132
    SecondRowBox1:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1138
    jnz SecondRowBox1
    mov di, 982
    mov si, 1142
    secondRowBox2:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1148
    jnz secondRowBox2
    mov di, 992
    mov si, 1152
    secondRowBox3:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1158
    jnz secondRowBox3
    mov di, 1002
    mov si, 1162
    secondRowBox4:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1168
    jnz secondRowBox4
    ; second row completed
    mov di, 1452
    mov si, 1612
    thirdRowBox1:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1618
    jnz thirdRowBox1
    mov di, 1462
    mov si, 1622
    thirdRowBox2:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1628
    jnz thirdRowBox2
    mov di, 1472
    mov si, 1632
    thirdRowBox3:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1638
    jnz thirdRowBox3
    mov di, 1482
    mov si, 1642
    thirdRowBox4:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 1648
    jnz thirdRowBox4
    ; third row completed
    mov di, 1932
    mov si, 2092
    fourthRowBox1:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 2098
    jnz fourthRowBox1
    mov di, 1942
    mov si, 2102
    fourthRowBox2:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 2108
    jnz fourthRowBox2
    mov di, 1952
    mov si, 2112
    fourthRowBox3:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 2118
    jnz fourthRowBox3
    mov di, 1962
    mov si, 2122
    fourthRowBox4:
    mov word [es:di],0xB020
    add di, 2
    mov word [es:si],0xB020
    add si, 2
    cmp si, 2128
    jnz fourthRowBox4
    ; fourth row completed
    pop di
    pop si
    pop ax
    ret