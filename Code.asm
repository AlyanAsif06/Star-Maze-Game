org 0x0100

jmp start


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;bounces
initialiseBoundaries:       ; for top row, bottom row and left column
        mov si, topRow
        mov ax, 0
        mov cx, 80
    topRowLoop:
        mov [si], ax
        add ax, 2
        add si, 2
        loop topRowLoop
    
        mov si, bottomRow
        mov ax, 24*160
        mov cx, 80
    bottomRowLoop:
        mov [si], ax
        add ax, 2
        add si, 2
        loop bottomRowLoop
    
        mov si, leftColumn
        mov ax, 0
        mov cx, 24
    leftColumnLoop:
        mov [si], ax
        add ax, 160
        add si, 2
        loop leftColumnLoop
    
        ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


clearscreen:
            mov  ax, 0xb800         
            mov  es, ax             
            mov  di, 0              
nextchar:   mov  word [es:di], 0x0720 
            add  di, 2              
            cmp  di, 4000           
            jne  nextchar           
			ret
			
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

storeCollision :
    mov [si], di  ;adding cordinates in collision array
    inc word [collisionCount]
    add si, 2
    ret


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

initialiseScreen :
    mov ax, 0xB800
    mov es, ax
    mov si, collision
    
    mov di, 158
    call storeCollision
    
    mov cx, 25
    mov ax, 0x2220
    
    verticalLine: 
        mov  word [es:di], ax 
        add di, 160
        call storeCollision
        loop verticalLine
    
    mov cx, 10
    mov di, (160*6) + 16       ;starting from 6th row, 8th column & ending on 16th row, 8th column as cx=10
    call storeCollision
    
    first:              ;obstacle
        mov  word [es:di], ax 
        call storeCollision
        add di, 160
        loop first
        
    mov cx, 10
    mov di, (160*8) + 90       ;starting from 8th row, 45th column & ending on 18th row, 55th column as cx=10
    call storeCollision
    
    second:              ;obstacle
        mov  word [es:di], ax 
        call storeCollision
        add di, 160
        loop second
    
    mov cx, 10
    mov di, (160*4) + 106       ;starting from 8th row, 53th column & ending on 18th row, 63th column as cx=10
    call storeCollision
    
    third:              ;obstacle
        mov  word [es:di], ax 
        call storeCollision
        add di, 160
        loop third
        
        
    mov cx, 16      
    mov di, (160 * 7) + 34      ;starting from 7th row, 17th column & ending on 33th row, 36th column cx = 16
    call storeCollision
    
    fourth:          ;obstacle
        mov  word [es:di], ax 
        call storeCollision
        add di, 2
        loop fourth
        
    
    mov cx, 16      
    mov di, (160 * 16) + 40      ;starting from 16th row, 20th column & ending on 32th row, 20th column cx = 16
    call storeCollision


    fifth:          ;obstacle
        mov  word [es:di], ax 
        call storeCollision
        add di, 2
        loop fifth
        
    mov cx, 16      
    mov di, (160 * 7) + 120      ;starting from 7th row, 60th column & ending on 33th row, 60th column cx = 16
    call storeCollision

    sixth:          ;obstacle
        mov  word [es:di], ax 
        call storeCollision
        add di, 2
        loop sixth
 
 
    ;star
    mov di, (160*23) + 80
    mov  word [es:di], 0x092A  
    mov word[position], di      ;so position can be updated in myTimer
    
    ;goal
    mov di, 162      
    mov  word [es:di], 0x4420
    
    
    
    ret
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

movestar:
    mov di, [position]              ;moving di to star's place
    mov word [es:di], 0x0720        ;to replace star with black space
    
    cmp word [direction], 1
    je moveRight
    cmp word [direction], -1
    je moveLeft
    cmp word [direction], 2
    je moveUp
    cmp word [direction], -2
    je moveDown
    mov word [es:di], 0x092A        ;so if direction != 1,-1,2,-2
    ret
    
    moveRight:
        add word [position], 2
        jmp draw
        
    moveLeft:
        sub word [position], 2
        jmp draw
        
    moveUp:
        sub word [position], 160
        jmp draw
        
    moveDown:
        add word [position], 160
        jmp draw
        
    draw:
        mov di, [position]
        mov word [es:di], 0x092A
        ret
        
        
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
        
        
YOULOST:          ;print func
    call restoreISR
    
    mov ax, 0xb800      ; Add this
    mov es, ax          ; and this
    
    mov si, lostString
    mov di, 546
    mov cx, 14    ;length of string
    mov ah, 0x4F
    nextchar1:
        lodsb
        stosw
        loop nextchar1
        
    jmp waitEnter
    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

YOUWON:
    call restoreISR
    
    mov ax, 0xb800      ; Add this
    mov es, ax          ; and this
    
    mov si, winString
    mov di, 546
    mov cx, 14
    mov ah, 0x2F
    nextchar2:
        lodsb
        stosw
        loop nextchar2
        
    jmp waitEnter
    

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
waitEnter:  
    ;printing
    mov si, menuString
    mov di, 834
    mov cx, 46
    mov ah, 0x70
    nextchar3:
        lodsb
        stosw
        loop nextchar3
        


    mov ah, 0
    int 16h              
    cmp al, 13           
    je restart
    cmp al, 27           
    je near end 
    jmp waitEnter        

restart:
    mov byte [gameOver], 0
    mov word [position], 0
    mov word [direction], 1
    mov word [collisionCount], 0
    call clearscreen
    call initialiseBoundaries
    call initialiseScreen
    jmp start            ; jump back to start

    
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



mykeyboard:
    pusha
    push ds
    push es
    push cs
    pop ds
    
    mov ax, 0xb800
    mov es, ax
    
    in al, 0x60
    
    cmp al, 0x48    ;up
    je upwards 
    
    cmp al, 0x50    ;down
    je downwards
    
    cmp al, 0x4d    ;right
    je rightwards
    
    cmp al, 0x4b   ;left
    je leftwards
    
    
    skip:
    pop es
    pop ds
    popa
    jmp far [cs:oldkeyboard]
    
    
    upwards:
        mov word[direction], 2
        jmp skip
        
    downwards:
        mov word[direction], -2
        jmp skip
    
    rightwards:
        mov word[direction], 1
        jmp skip
        
    leftwards:
        mov word[direction], -1
        jmp skip
    


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


myTimer:
    pusha
    push ds
    push es
    
    mov ax, cs
    mov ds, ax
    
    add word [count], 1
    cmp word [count], 2
    jne near skip2
    mov word[count], 0
    
    mov ax, 0xb800
    mov es, ax
    call movestar
    
    
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;CHECKING YOU LOST
    
    
    ;iterating over "collision" array "collisionCount" many times to see when each time the star moves, is it in contact with any of the 'di' position on screen. If current di position of star matches any value in the entire array, means collion is detected; hence you lost
    mov cx, [collisionCount]
    mov si, collision   ;points to array
    detectingCollision:
        cmp di, [si]
        je lostFlag
        add si, 2
        loop detectingCollision

    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;CHECKING YOU WON
    
    
    cmp di, 162       ;star reached the top left goal
    je wonFlag
    
    
    
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;CHECKING BOUNCE ON TOP, BOTTOM OR LEFT
    
    mov cx, 80         ;includes top row 
    mov si, topRow   ;points to array
    detectingBounce1:
        cmp di, [si]
        je bouncedown
        add si, 2
        loop detectingBounce1
    
    mov cx, 80         ;includes bottom row 
    mov si, bottomRow   ;points to array
    detectingBounce2:
        cmp di, [si]
        je bounceup
        add si, 2
        loop detectingBounce2
    
    mov cx, 24         ;includes left column 
    mov si, leftColumn   ;points to array
    detectingBounce3:
        cmp di, [si]
        je bounceright
        add si, 2
        loop detectingBounce3
        
        
    jmp skip2
    
    
    bouncedown: 
        mov word [direction], -2     ;bounce downwards
        jmp skip2
    bounceup:
        mov word [direction], 2     ;bounce downwards
        jmp skip2
    bounceright:
        mov word [direction], 1     ;bounce downwards
        jmp skip2
    
    
    skip2:
    pop es
    pop ds
    popa
    jmp far [cs:oldtimer]
    
    
    lostFlag:
        mov byte [gameOver], 1
        jmp skip2
    wonFlag:
        mov byte [gameOver], 2
        jmp skip2


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


start :
    call clearscreen
    call initialiseBoundaries
    call initialiseScreen
    
    
    ;preserving and hooking timer interrupt
    mov ax, 0
	mov es, ax 
	mov ax, [es:8*4]
	mov [oldtimer],ax
	mov ax, [es:8*4+2]
	mov [oldtimer+2], ax
	cli 
	mov word [es:8*4], myTimer
	mov [es:8*4+2], cs
	sti
	
	;preserving and hooking keyboard interrupt
    mov ax, 0
	mov es, ax 
	mov ax, [es:9*4]
	mov [oldkeyboard],ax
	mov ax, [es:9*4+2]
	mov [oldkeyboard+2], ax
	cli 
	mov word [es:9*4], mykeyboard
	mov [es:9*4+2], cs
	sti
	
	
    infinite:
    cmp byte [gameOver], 1
    je YOULOST
    cmp byte [gameOver], 2
    je YOUWON
    jmp infinite




restoreISR:
    ; the OG ISRs are back in town !!!!
    mov ax, 0
    mov es, ax
    cli
    mov ax, [oldtimer]
    mov word [es:8*4], ax
    mov ax, [oldtimer+2]
    mov word [es:8*4+2], ax
    
    mov ax, [oldkeyboard]
    mov word [es:9*4], ax
    mov ax, [oldkeyboard+2]
    mov word [es:9*4+2], ax
    sti
    
    ret
    
end:
    mov ax, 0x4c00  
    int 21h





gameOver: db 0      

oldkeyboard: dw 0,0
oldtimer: dw 0,0
count: dw 0
position: dw 0
direction: dw 1     ; 1 = right, -1 = left, 2 = up, -2 = down

collision: times 200 dw 0        ; array for storing cordinates of all obstacles in following manner : verticle line, obstacle 1-6 (1-3 are verticle, 4-6 are horizontal) 
collisionCount : dw 0   ; basically size of collision array

lostString: db 'LMAO you lost!'
winString: db 'LESGO you won!'
menuString: db 'Press ENTER to play again or Press ESC to exit'

topRow: times 80 dw 0       ;for bounces
bottomRow: times 80 dw 0
leftColumn: times 24 dw 0


