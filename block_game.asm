.model tiny
.386
.data
;========================This will be a 4x4 grid================================
instruction db 13, 10, "Use arrow-keys to move 'blank box' and replace a number."
			db 13, 10, "Goal is to place the numbers in order, use ESC for exit."
			db 13, 10, "Must look like this:"
			db 13, 10, " ___ ___"
			db 13, 10, "| 1 | 2 |"
			db 13, 10, "|___|___|"
			db 13, 10, "| 3 | _ |"
			db 13, 10, "|___|___|$"
winMsg db "WINNER!!!$"
loseMsg db "GAME OVER$"
;Template for grid starts at (2,10)
gridTop db 13, 10, " ___ ___ ___ ___$"
gridBox db 13, 10, "|   |   |   |   |"
	db 13, 10, "|___|___|___|___|$"
;Numbers being pushed
array db 0,6,13,4,3,14,1,15,2,5,11,9,7,10,8,12
;coordinates for blank
index dw 0
x db 0
y db 0
.code
org 100h
start:
;========================Initialization of Table===========================
;set video mode and clear screen
mov		ah,0		;set mode function
mov     al,3        ;80x25 color text
int     10h         ;set mode
;print instructions
mov     dx, offset instruction
mov     ah, 9
int     21h
;create grid
mov     dx, offset gridTop
mov     ah, 9
int     21h
mov		cl, 4		;count to draw grid
mov     dx, offset gridBox
mov     ah, 9
;will just make an empty table
makeTable:
	int     21h
	dec     cl
	jnz     makeTable
;==============================Add Checkered Color===========================
;color the table
mov		cl, 1		;left col
mov		ch, 10		;upper row
mov		dl, 3		;right col
mov		dh, 11      ;lower row
mov 	ax, 0600h 	;color
mov		bh, 17h
color:
	int		10h
	add		cl, 8		;increment coordinates
	add		dl, 8
	cmp		cl, 13
	jle		checkDone	
	mov		bl, ch		;col correctness from row 2->3
	and		bl, 1		;left col mod 2
	shl		bl, 4		;0 or 8
	add		cl, bl
	add		dl, bl
	sub		cl, 20		;increment rows? if yes
	sub		dl, 20
	add		ch, 2
	add		dh, 2
checkDone:				;else
	cmp		ch, 16		;is beyond last row?
	jle		color
	
;==================================Update Table=================================
updateTable:            ;call when we redraw table
	mov		si, 0		;counter for array print
	mov		cl, 0		;counter for rows
fillTable:
;set up screen coordinates
	mov		ax, si
	and		al, 3		;al modulo 4 for row
	cmp		al, 0		;check if end of col+1
;because we use col=0 to determine row++, we use counter
	jne		next		
	cmp		si, 0		;not the first number
	je		next
	inc 	cl			;inc rows
next:
;set up cell coordinates
	shl		al, 2       ;shift by a factor of 2
	add		al, 2		;from top left corner
	mov		dl, al		;set Column
	mov		dh, cl  	;set Row
	shl		dh, 1
	add		dh, 10		;from top left corner
	mov		bh, 0   	;Display page
	mov		ah, 02h 	;SetCursorPosition
	int		10h
;print numbers into table
	mov		al, array[si]		;get array element
	cmp		al, 0				;fill with blank if element=0 [blank]
	jne		print
	mov		index, si			;save index of blank
	mov		x, dl				;save coordinates of blank
	mov		y, dh
	;fills it with blank
	mov 	al, ' '
	mov 	bh, 0		;Display page
	mov 	ah, 0Eh		;Teletype
	int 	10h			;print first blank
	int 	10h			;print next blank
	jmp		skip
print:		;print in table
	cmp		al, 10		;see if num is 10 or more
	jl		printSingles
	sub 	al, 10		;save your ones digit
	mov 	ch, al		;place your number in temp
	mov 	al, '1'
	mov 	bh, 0		;Display page
	mov 	ah, 0Eh		;Teletype
	int 	10h			;print tens place
	mov 	al,ch		;move back your ones digit to print
	xor 	ch,ch
printSingles:
	add		al, '0'		;hex->dec
	mov		bh, 0		;Display page
	mov		ah, 0Eh		;Teletype
	int		10h
skip:
	inc		si
	cmp		si, 16
	jne		fillTable
;===================================Update Cursor==================================
;position of nxn grid
	mov     ah, 2       ;move cursor function
	mov		dl, x		;update cursor
	mov		dh, y
	mov     bh, 0		;page 0
	int     10h			;move cursor
;====================================Check Complete================================
check_completion:
	mov		si, 0		;counter for array
	cmp		array[0], 1 ;does it start at 1?
	jne		getKey
check:
	cmp		si, 14		;everything,but last was checked
	je		winner		;print winning message		
	mov		al, array[si]
	inc		si
	cmp		al, array[si]
	jl		check
;=====================================Key Commands=================================
getKey:
;get keystroke	
	mov     AH,0			;keyboard input function
	int     16h         	;AH=scan code,AL=ascii code
	cmp     AH,72           ;up arrow?
	je      CURSOR_UP       ;yes, execute
	cmp     AH,75           ;left arrow?
	je      CURSOR_LEFT     ;yes, execute
	cmp     AH,77           ;right arrow?
	je      CURSOR_RIGHT    ;yes, execute
	cmp     AH,80           ;down arrow?
	je      CURSOR_DOWN     ;yes, execute
	cmp     AL,1Bh			;ESC (exit character)?
	je      endGame   		;yes, exit
;KEY DIRECTIONS and memory update
CURSOR_UP:
	cmp		y, 10				;top border
	jle		getKey
	mov		si, index
	mov		al, array[si]		;save temp value
	sub     si, 4				;other value to swap
	xchg    al, array[si]		;swap starts
	add		si, 4
	mov		array[si], al
	jmp		updateTable
CURSOR_LEFT:
	cmp		x, 2				;left border
	jle		getKey
	mov		si, index
	mov		al, array[si]		;save temp value
	dec     si					;other value to swap
	xchg    al, array[si]		;swap starts
	inc		si
	mov		array[si], al
	jmp		updateTable
CURSOR_RIGHT:
	cmp		x, 14				;right border
	jge		getKey
	mov		si, index
	mov		al, array[si]		;save temp value
	inc     si					;other value to swap
	xchg    al, array[si]		;swap starts
	dec		si
	mov		array[si], al
	jmp		updateTable
CURSOR_DOWN:
	cmp		y, 16				;bottom border
	jge		getKey
	mov		si, index
	lea		ax, array
	mov		al, array[si]		;save temp value
	add     si, 4				;other value to swap
	xchg    al, array[si]		;swap starts
	sub		si, 4
	mov		array[si], al
	jmp		updateTable
;=======================================END GAME===========================
winner:
	mov     ah, 2       ;move cursor function
	mov		dl, 0		;update cursor
	mov		dh, 20
	mov     bh, 0		;page 0
	int     10h			;move cursor
	mov		dx, offset winMsg
    mov		ah, 9
    int		21h
	jmp		exit
endGame:
;DOS exit
	mov     ah, 2       ;move cursor function
	mov		dl, 0		;update cursor
	mov		dh, 20
	mov     bh, 0		;page 0
	int     10h			;move cursor
	mov		dx, offset loseMsg
    mov		ah, 9
    int		21h
exit:
	mov     ah, 2       ;move cursor function
	mov		dl, 0		;update cursor
	mov		dh, 22
	mov     bh, 0		;page 0
	int     10h			;move cursor
	mov     AH,4Ch
	int     21h
end start
