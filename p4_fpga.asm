.orig x0000 ; change to x0000 for fpga version
MSG_MENU .stringz "\n\n--RPN CALC--\n1 Enter Stack\n2 View Stack\n3 Make Op's\n4 Clean Stack\n"
MSG_ENTER_NUM	.stringz "\n\nNumbers:"
MSG_WHAT .stringz "\nWrong Input!"
MSG_HIGH .stringz "\nHIGHEST:\n"
MSG_LOW .stringz "\nLOWEST:\n"
MSG_OP .stringz "\nOP's: \n"	

; jsrPUTSMSG <-> pputs
; jsrPUTCHAR <-> oout
; jsrGETCHAR <-> ggetc
; op stack in x7000
; data stack in x4000
BEGIN		ld r5 , DATA_STORE_1 ; init data stack	
		br MENU
ENTER_STACK		lea r0, MSG_ENTER_NUM
		jsr PUTSMSG
		br ENTER_NUM

MENU		lea r0 , MSG_MENU	;Shows menu and ask for option
		jsr PUTSMSG
		jsr INPUT	; r4 now has option
		add r1 , r4 , #-1
		brz ENTER_STACK
		add r1 , r4 , #-2
		brz VIEW_STACK
		add r1 , r4 , #-3
		brz MAKE_OP
		add r1 , r4 , #-4
		brz CLEAN_STACK
		; else invalid option
		br WHAT	
WHAT		lea r0 , MSG_WHAT
		jsr PUTSMSG
		br MENU	

VIEW_STACK			;save reg
		lea r0 MSG_VIEW
		jsr PUTSMSG
		MSG_VIEW .stringz "\nSTACK:\n"
		;set start point
		ld r3 , DATA_STORE_1
		add r3 , r3 , #1 ;no need to increase, for showing in correct order
		;ld r2,CAP;
		;add r3,r3,r2 ; last position
		
		; set how many to show
		ld r4 , CAP; so SHOW_PREP knows how many to show
		
		;set next operator
		and r6,r6,#0
		;add r6,r6,#-1
		add r6,r6,#1
		jsr SHOW_PREP
		br MENU
DATA_STORE_1 .FILL x4000
		
CAP		.FILL #0	

CLEAN_STACK	lea r0, MSG_CLEAN
		jsr PUTSMSG
CLEAN_LOOP	ld r1 , CAP
		brz MENU
		jsr POP_R1_DATA
		br CLEAN_LOOP
MSG_CLEAN .stringz "\n---CLEANING STACK---\n"		
SHOW_PREP	; Needs r3 with address of data array
		; Needs r4 with N
		; Needs r6 with the number to sum for the next
		st r7, SHOW_R7		 
		;add r3 , r3 , #1
SHOW_LOOP	lea r0 , MSG_SEP
		jsr PUTSMSG
		add r4, r4, #-1		
		brn SHOW_END	
		ldr r0, r3, #0
		
		jsr DISPD
		add r3, r3, r6
		br SHOW_LOOP

SHOW_END ld r7, SHOW_R7
		ret		
SHOW_R7 .FILL 0

OP_RAW_CHAR .FILL #0

MSG_SEP .stringz ","
OP_STORE_1 .FILL x7000
MAKE_OP	lea r0 , MSG_OPS
		jsr PUTSMSG
		ld r6 , OP_STORE_1
		and r0, r0, #0
		st r0,CAP_OP
		and r4,r4,#0
ENTER_OP_LOOP	ld r3 , OP_RAW_CHAR
		add r3 , r3 , #-10
		;add r0 , r0 , #-10;r0 has last raw char inputted
        	brz ENTER_OP_READY
		jsr INPUT_OP ;result in r2
		add r1 , r2 , #0
		brz ENTER_OP_LOOP
		jsr PUSH_R1_OP
		add r4,r4,#1 ; to avoid enter without operand
		br ENTER_OP_LOOP

ENTER_OP_READY	and r1, r1, #0
		st r1 , OP_RAW_CHAR
		add r4,r4,#0
		brz ENTER_OP_LOOP
		lea r0 , MSG_OP_OK
		jsr PUTSMSG
		br DO_OPS

DO_OPS		ld r4 , CAP_OP  ;#iterator counter
		ld r6 , OP_STORE_1
DO_OPS_LOOP	ld r1 , CAP
		add r1,r1,#-2
		brn NOT_ENOUGH
		add r6 , r6 , #1 ; first op
		jsr POP_R1_DATA ;second operand
		add r2 , r1 , #0 ; r2 has 2nd operand
		jsr POP_R1_DATA ;first operand
		;add r3 , r1 , #0 ; not needed , r1 has 1st operand
		; condition for subroutines
		; stack order: next to last, last
		; operand order: 1st, 2nd
		;add r1 , r2 , #0 ; not needed
		;add r2 , r3 , #0 ; not needed
		ldr r3 , r6 , #0 ; R3 now has operation
		
		
        ; % -3  =>  3
        ; *  2  => -2
        ; +  3  => -3
        ; ,  4  => -4
        ; -  5  => -5
        ; /  7  => -7
		add r0 , r3 , #3
		brz MOD_CASE
		add r0 , r3, #-2
		brz MUL_CASE
		add r0, r3, #-3
		brz SUM_CASE
		add r0, r3, #-5
		brz SUB_CASE
		add r0, r3, #-7
		brz DIV_CASE

MUL_CASE	jsr MUL
		br DROP_RESULT
SUM_CASE	jsr SUM
		br DROP_RESULT
SUB_CASE	jsr SUB
		br DROP_RESULT
DIV_CASE	jsr DIV
		br DROP_RESULT
MOD_CASE	jsr MOD
		br DROP_RESULT
		br DO_OPS_LOOP
DROP_RESULT	jsr PUSH_R1_DATA
		
		; r1 holds the answer
		add r0 , r1, #0
		jsr DISPD
		lea r0 , MSG_SEP
		jsr PUTSMSG
		add r4 , r4 , #-1
		brz END_OPS
		br DO_OPS_LOOP
END_OPS		
		lea r0 , MSG_LF
		jsr PUTSMSG
		br MENU		
MSG_OP_OK .stringz "\nANS:"
MSG_OPS .stringz "\nOP's:"
MSG_NEXT_OP .stringz "\n:"
MSG_LF .stringz ""


NOT_ENOUGH	lea r0,MSG_NOT_ENOUGH
		jsr PUTSMSG
		br MENU

INPUT_OP		; subroutine, leaves stuff in r4
		; save r7 so we dont lose where we came from
		st r3 ,  OP_R3
		st r7, 	 OP_R7
		st r4 , OP_R4


OP_NO_SAVE	lea r0 , MSG_NEXT_OP
		
		; we dont need to save r7 so as long we
		; dont go to something that also goes to a subroutine

		jsr PUTSMSG
		and r3 , r3 , #0
		st r3 , OP_RAW_CHAR
        and r4 , r4 , #0 ; counter of valid op's
        and r2 , r2 , #0 ; will hold valid op result
		
		; R1 will be aux dummy reg

OP_I	jsr GETCHAR	; gets c in r0
		st r0, OP_RAW_CHAR
		add r1 , r0 , #-10
		brz OP_READY2
        ; offset char for easier comparison in r3
		add r3, r0 , #-15	
		add r3 , r3 , #-15
        add r3 , r3 , #-10 ; offset of -40
        ; % -3  =>  3
        ; *  2  => -2
        ; +  3  => -3
        ; ,  4  => -4
        ; -  5  => -5
        ; /  7  => -7
		add r1 , r3 , #-4 ; check if "," was pressed
		brz OP_READY
		
		; % -3  =>  3
        add r1 , r3 , #3
		brz VALID_OP
        ; *  2  => -2
        add r1 , r3 , #-2
        brz VALID_OP
        ; +  3  => -3
        add r1 , r3 , #-3
        brz VALID_OP
        ; -  5  => -5
        add r1 , r3 , #-5
        brz VALID_OP
        ; /  7  => -7
        add r1 , r3 , #-7
        brz VALID_OP

        br OP_I	
		
VALID_OP	add r4 , r4 , #0 ; if we had already inputted a valid op, force , separator by the user
            brp OP_I
            jsr PUTCHAR	; echo r0 with original value
            add r2 , r3 , #0 ; put mapped value in r2
            add r4 , r4 , #1 ; add 1 valid op count
            br OP_I
OP_READY    add r4 , r4 , #0
	    brnz OP_I
OP_READY2   jsr PUTCHAR
            ld r3 , OP_R3
            ld r7 , OP_R7
	    ld r4 , OP_R4
            ret

OP_R3 .FILL 0
OP_R4 .FILL 0
OP_R7 .FILL 0


;LIFO STACK uses r1 as auxiliar register
PUSH_R1_OP	;r6 used as op stack register
		add r6 , r6 ,#1 ;point to next
		str r1 , r6 ,#0 ;save
		ld r1 , CAP_OP
		add r1 , r1 , #1
		st r1 , CAP_OP
		ldr r1 , r6 , #0  
		ret
POP_R1_OP	ld r1 , CAP_OP
		add r1 , r1 , #-1
		st r1 , CAP_OP
		ldr r1 , r6 , #0
		add r6 , r6 ,#-1
		ret

CAP_OP .FILL #0

;LIFO STACK uses r1 as auxiliar register
PUSH_R1_DATA	;r5 used as stack register
		add r5 , r5 ,#1 ;point to next
		str r1 , r5 ,#0 ;save
		ld r1 , CAP
		add r1 , r1 , #1
		st r1 , CAP
		ldr r1 , r5 , #0  
		ret
POP_R1_DATA	ld r1 , CAP
		add r1 , r1 , #-1
		st r1 , CAP
		ldr r1 , r5 , #0
		add r5 , r5 ,#-1
		ret

ENTER_NUM	;WARNING: AVOID MODIFYING r5 unless you restore its value
			;it mush have the stack pointer
		add r5 , r5 , #0
ENTER_NUM_LOOP	jsr INPUT ;r0 has number, if enter or comma directly, it is 0.
		ld r3 , INPUT_RAW_CHAR
		add r3 , r3 , #-10
		brz NUM_DONE
		add r1 , r0 , #0
		jsr PUSH_R1_DATA
		br ENTER_NUM_LOOP

NUM_DONE	ld r1, INPUT_HOW_MANY
		brz NO_INPUT
		add r1 , r0 , #0 ;enter the last, if no number it will input a 0, put a single + in op to eliminate
		jsr PUSH_R1_DATA
NO_INPUT	lea r0 , MSG_NUM_OK
		jsr PUTSMSG
		br MENU

			
MSG_NUM_OK .stringz "\nNums ok!"

INPUT		; subroutine, leaves stuff in r4
		; save r7 so we dont lose where we came from
		
		;st r0 , INPUT_R0
		;st r1 , INPUT_R1
		;st r2 , INPUT_R2
		st r3 , INPUT_R3
		;st r4 , INPUT_R4
		;st r5 , INPUT_R5
		;st r6 , INPUT_R6
		st r7, 	INPUT_R7



INPUT_NO_SAVE	lea r0 , MSG_NEXT
		
		; we dont need to save r7 so as long we
		; dont go to something that also goes to a subroutine

		MSG_NEXT .stringz "\n:"

		jsr PUTSMSG
		and r3 , r3 , #0
		st r3 , INPUT_RAW_CHAR
		st r3 , INPUT_HOW_MANY 	
		
		; R1 will be aux dummy reg
		; R2 will indicate if the number is negative or not
		; R4 will be accumulator, at the end will hold the final number
		
		and r2 , r2 , x0000
		and r4 , r4 , x0000
		and r3, r3, x0000 ; flag to know if it was a number, it counts the numbers of numbers
		
INPUT_I		jsr GETCHAR	; gets c in r0

		add r1 , r0 , #0
		st r1, INPUT_RAW_CHAR
		add r1 , r0 , #-10
		brz INPUT_READY
		
		add r1 , r0 , #-15	; check if "," was pressed
		add r1 , r1 , #-15
		add r1 , r1 , #-14
		brz YES_NEXT
		;jsr PUTCHAR	; echo what is in r0 (if not ,)
		
		; check if it is a negative number (-) (45)
		add r1 , r0 , #-15
		add r1 , r1 , #-15
		add r1 , r1 , #-15
		brz NEGATIVE

		; check if it is a number indeed
		add r1 , r0 , #0	; copy r0 in r1
		; check it is a number
		; first substract 48, if negative it is lower
		add r1 , r1 , #-16
		add r1 , r1 , #-16
		add r1 , r1 , #-16
		brn INPUT_I
		; we are already sure it is not lower
		; if it was a number we are now within 0 - 9
		; substract 9, if positive it was not a number
		add r1 , r1 , #-9
		brp INPUT_I	
		jsr PUTCHAR; if we put the jsr PUTCHAR here it wont even display letters
		;convert to number
		and r0 , r0 , xF
		add r3, r3, #1 ; to know how many number chars were inserted apart from enter
ACCUM		add r1 , r4 , #0 ; r1 <- 1 r4
		brn OVERFLOW
		add r4 , r4 , r4 ; r4 <- 2 r1
		brn OVERFLOW
		add r4 , r4 , r4 ; r4 <- 4 r1
		brn OVERFLOW
		add r4 , r4 , r1 ; r4 <- 5 r1
		brn OVERFLOW
		add r4 , r4 , r4 ; r4 <- 10 r1
		brn OVERFLOW		
		add r4 , r4 , r0 ; r4 <= 10 r1 + r0
		brn OVERFLOW
		br INPUT_I
		
NEGATIVE	not r2 , r2
			jsr PUTCHAR ;r0 is 45 we can echo here (jsr PUTCHAR) if jsr PUTCHAR outside if after number check
		br INPUT_I		

OVERFLOW	add r1 , r4 , r4 ; check if it was possibly -32768
		brz CASE
OVERFLOW_2		lea r0 , MSG_OVERFLOW
		MSG_OVERFLOW .stringz "\nOverflow"
		jsr PUTSMSG
		br INPUT_NO_SAVE
CASE		add r1, r2, #0 ; check if negative flag is on
		brzp OVERFLOW_2 ; if it is not negative, then it cant be -32768, is a valid overflow
		br INPUT_I	
INPUT_READY	st r3, INPUT_HOW_MANY
		;ld r0 , INPUT_R0
		;ld r1 , INPUT_R1
		;ld r2 , INPUT_R2
		ld r3 , INPUT_R3
		;ld r4 , INPUT_R4
		;ld r5 , INPUT_R5
		;ld r6 , INPUT_R6
		ld r7, INPUT_R7
		add r0 , r4 , #0
		ret	; go home boy
INPUT_R0 .FILL 0
INPUT_R1 .FILL 0
INPUT_R2 .FILL 0
INPUT_R3 .FILL 0
INPUT_R4 .FILL 0
INPUT_R5 .FILL 0
INPUT_R6 .FILL 0
INPUT_R7 .FILL 0
INPUT_RAW_CHAR .FILL 0
INPUT_HOW_MANY .FILL 0
MSG_NOT_ENOUGH .stringz "\nERROR, NOT ENOUGH OPERANDS"
YES_NEXT	; if enter was first char, it will just assume thats a 0
		;check if no number was pressed
		add r3,r3,#0
		brz INPUT_I
		; check if we need to negate
		add r1 , r4 , #0
		add r2 , r2 , #0
		brz DONT_NEGATE
		not r1 , r1
		add r1 , r1 , #1
		; either way we have the correct stuff in r1
		; move it back to r4
DONT_NEGATE	add r4 , r1 , #0
		br INPUT_READY
;YES_ENTER	br INPUT_READY
NEGATE_R1	; places in r1 the 2complement of r1
		not r1 , r1
		add r1 , r1 , #1
		ret



; Following subroutines are from https://github.com/jrcurtis/lc3/blob/master/tests/lab5.asm
;
; Takes a 2's complement integer and displays its DECIMAL representation.
;
; THIS FUNCTION IS DIRECTLY DERIVED FROM DISPLAY ABOVE.
; THE ONLY MODIFICATION IS SIMPLIFIED OUTPUT. THE ALGORITHM IS THE SAME.
; BLOCK COMMENTS HAVE BEEN REMOVED FOR REDUNDANCY AND SPACE SAVING.
; THIS EXPECTS IN R0 THE NUMBER TO BE DISPLAYED

DISPD	ADD R0, R0, #0		; to assert if the number is not zero
	BRnp DISPD_NON_ZERO
	ST r7, DISPD_R7			; store home
	LD R0, DISPD_0		; load 0 in ascii
	jsr PUTCHAR			; display to console
	LD R7, DISPD_R7		; load r7 again to return
	ret
DISPD_NON_ZERO
	; PREPARATION
	ST R0, DISPD_R0		; store original value of registers
	ST R1, DISPD_R1
	ST R2, DISPD_R2
	ST R3, DISPD_R3
	ST R4, DISPD_R4
	ST R5, DISPD_R5
	ST R7, DISPD_R7
	ADD r1, r0,r0
	brz SPECIAL_CASE
	AND R1, R1, #0	; clear r1
	ADD R1, R1, #1	; R1 holds current multiple of ten
	AND R2, R2, #0	; clear r2
	ADD R2, R2, #1	; R2 used by multiply and divide routines
	AND R3, R3, #0	; R3 holds current power of ten
	AND R4, R4, #0	; R4 holds plurality of current multiple
	AND R5, R5, #0	; R5 holds original number from R0
	ADD R5, R5, R0	; (because R0 needed for output)
	BRzp DISPD_LOOP_ASC ; assert number is not negative
	NOT R5, R5	; if it is negate it
	ADD R5, R5, #1	; Negate to positive
	LD R0, DISPD_NEG	; Input is negative. Display negative sign.
	jsr PUTCHAR		; Now we may continue with de ascending loop
DISPD_LOOP_ASC		; this loop is to find the largest power of 10 used by the number
			; but it actually overshoots...
	AND R1, R1, #0	; clear r1
	ADD R1, R1, R5	; Set R1 to number
			; first cycle do note that r2 = 1
	JSR DIV		; How many times does ten*x go into number?
	add r1,r1,#-10
	BRn DISPD_LOOP_DESC	; If zero, then exit loop , here r3 is max power of 10 + 1 and r2 is 10 to that power (overshoots)
	AND R1, R1, #0		; Otherwise, keep multiplying, clear r1
	ADD R1, R1, #10		; set r1 to 10
	JSR MUL		; Highest multiple of ten up by one
			; first cycle r1 <= r1=10 * r2=1
	ADD R3, R3, #1	; One more power of ten
	AND R2, R2, #0	; clear r2
	ADD R2, R2, R1	; Store mul result in R2 for next loop, it is 10 to the power
	BR DISPD_LOOP_ASC
DISPD_LOOP_DESC		; by here r2 and r3 are overshooting (1 more power than it is actually)
	AND R1, R1, #0	; clear r1
	ADD R1, R1, R2	; Here R1 is current multiple of ten we're looking at
	LD R4, DISPD_0
DISPD_LOOP_DESC_AGAIN
	AND R2, R2, #0	; clear r2
	ADD R2, R2, R1	; Now we have a multiple of ten in R2 (divisor)
	AND R1, R1, #0
	ADD R1, R1, R5	; So we get our input number in R1 (dividend)
	JSR DIV		; And see how many times the one fits in the other
; Here is where we actually display something
	ADD R0, R1, R4	; ascii 0 + offset of the number
	jsr PUTCHAR
	JSR MUL		; Multiply power of ten by result of integer division
	NOT R1, R1
	ADD R1, R1, #1	; And negate result
	ADD R5, R5, R1	; And subtract it from input number
	ADD R3, R3, #0	; If power of ten is zero
	BRz DISPD_END	; then we've output the last digit
	AND r1, r1, x0000
	add r1, r2, #0
	and r2,r2,#0
	add r2,r2,#10
	jsr DIV	; Divide our multiple of ten by ten
	; result is already in r1 for beginning of the loop
	add r3, r3, #-1
	
	BR DISPD_LOOP_DESC_AGAIN
DISPD_END
	LD R0, DISPD_R0
	LD R1, DISPD_R1
	LD R2, DISPD_R2
	LD R3, DISPD_R3
	LD R4, DISPD_R4
	LD R5, DISPD_R5
	LD R7, DISPD_R7
	RET
SPECIAL_CASE
	lea r0, CASE_STR
	jsr PUTSMSG
	br DISPD_END
DISPD_NEG	.FILL #45	; Negative sign
DISPD_0		.FILL #48	; ASCII 0
DISPD_R0	.FILL 0
DISPD_R1	.FILL 0
DISPD_R2	.FILL 0
DISPD_R3	.FILL 0
DISPD_R4	.FILL 0
DISPD_R5	.FILL 0
DISPD_R7	.FILL 0
CASE_STR	.stringz "-32768"


;
; Multiplies two integers.
;
; Preconditions: The number in R1 is multiplied with the number in R2.
; Postconditions: The number in R1 will be the product.
;
MUL	ST R0, MUL_R0
	ST R2, MUL_R2
	ST R3, MUL_R3
	AND R3, R3, #0	; R3 holds flag for negative
	ADD R1, R1, #0
	BRn MUL_NEG_1	; If operand 1 is negative, flip flag
MUL_CHECK_NEG_2
	ADD R2, R2, #0
	BRn MUL_NEG_2	; And if operand 2 is negative
MUL_POST_CHECK_NEG	; Now we know our arguments are positive
	AND R0, R0, #0	; R0 holds original number (absolute value)
	ADD R0, R0, R1
	AND R1, R1, #0	; R1 to 0 so adding R0 R2 times gives correct result
	BRnzp MUL_LOOP
MUL_NEG_1 ; First operand is negative
	NOT R3, R3	; Negative flag is negative when answer is negative
	NOT R1, R1	; Negate operand 1 (both numbers must be positive)
	ADD R1, R1, #1
	BRnzp MUL_CHECK_NEG_2
MUL_NEG_2 ; Second operand is negative
	NOT R3, R3
	NOT R2, R2	; Negate operand 2
	ADD R2, R2, #1
	BRnzp MUL_POST_CHECK_NEG
MUL_LOOP
	ADD R2, R2, #-1
	BRn MUL_POST_LOOP
	ADD R1, R1, R0	; Add R1 to itself (original saved in R0) R2 times
	BRnzp MUL_LOOP
MUL_POST_LOOP
	ADD R3, R3, #0
	BRzp MUL_CLEANUP	; If negative flag not set
	NOT R1, R1		; If it is, negate answer
	ADD R1, R1, #1
MUL_CLEANUP
	LD R0, MUL_R0
	LD R2, MUL_R2
	LD R3, MUL_R3
	RET
MUL_R0	.FILL 0
MUL_R2	.FILL 0
MUL_R3	.FILL 0


;
; Divides two integers.
;
; Preconditions: R1 is the dividen, R2 the divisor.
; Postconditions: R1 holds the quotient.
;
DIV	ST R0, DIV_R0
	ST R2, DIV_R2
	ST R3, DIV_R3
	AND R0, R0, #0	; R0 holds our quotient
	AND R3, R3, #0	; R3 holds negative flag
DIV_CHECK_ZERO_2
	add r2,R2,#0
	BRZ DIV_BY_0
DIV_CHECK_NEG_1	ADD R1, R1, #0
	BRn DIV_NEG_1	; If first argument is negative flip flag

DIV_CHECK_NEG_2
	ADD R2, R2, #0
	Brn DIV_NEG_2	; Or the second	
DIV_POST_CHECK_NEG
	NOT R2, R2
	ADD R2, R2, #1	; R2 (divisor) negated for repeated subtraction
	BRnzp DIV_LOOP
DIV_NEG_1 ; First operand is negative
	NOT R1, R1	; Negate first argument (both must be positive)
	ADD R1, R1, #1
	NOT R3, R3
	BRnzp DIV_CHECK_NEG_2
DIV_NEG_2 ; Second operand is negative
	NOT R2, R2	; Negate second argument
	ADD R2, R2, #1
	NOT R3, R3
	BRnzp DIV_POST_CHECK_NEG
DIV_LOOP
	ADD R1, R1, R2
	BRn DIV_CLEANUP	; We've subtracted once too many
	ADD R0, R0, #1	; Number of times it fits in goes up
	BRnzp DIV_LOOP
DIV_CLEANUP
	ADD R3, R3, #0
	BRzp DIV_NOT_NEG
	NOT R0, R0	; Here we know the output is negative, so negate it!
	ADD R0, R0, #1
DIV_NOT_NEG
	AND R1, R1, #0
	ADD R1, R1, R0	; Put our result in R1 for return
	LD R0, DIV_R0
	LD R2, DIV_R2
	LD R3, DIV_R3
	ADD R1, R1, #0	; Set condition codes for calling routine
	RET
DIV_BY_0 
	LD R0, DIV_R0
	LD R2, DIV_R2
	LD R3, DIV_R3
	And r1,r1,#0 ; set by default that result is zero
	RET
DIV_R0	.FILL 0
DIV_R2	.FILL 0
DIV_R3	.FILL 0

GETCHAR: LDI r0, KBSR ; Read the Keyboard Status Register (KBSR) to check if there is a new char available (x8000)
brzp GETCHAR ; If KBSR != x8000, jump to GetChar
LDI r0, KBDR ; Read the Keyboard Data Register (KBDR) to take the incoming character
ret ; Subroutine return

PUTCHAR: st r0, PCR0  ; Store R0 into memory to keep a copy of the incoming character

PUTCHAR2: ldi r0, DSR ; Read the Display Status Register (DSR) to check if a character can be transmitted (x8000)
brzp PUTCHAR2 ; If (DSR != x8000), jump to PutChar2
ld r0 PCR0 ; Restore the character taken from the Keyboard to be sent to the display
sti r0, DDR ; Write the Display Data Register (DDR) with the character taken from the Keyboard
ret ; Subroutine return
PCR0: .FILL 0

PUTSMSG: st r0, PMR0 ; Store R0 into memory to keep a copy of the next char address
ldr r0,r0,#0; Load the char to be sent
brz PUTSMSGE ; Return if the char is NULL
st r7, PMR7 ; Store R7 because is needed by RET instruction
jsr PUTCHAR ; Send the char in R0
ld r7, PMR7 ; Restore R7
ld r0, PMR0 ; Restore the address of the char sent
add r0,r0,#1 ; Compute the address of the next char
br PUTSMSG ; Send the next char

PUTSMSGE: ret ; Subroutine return

PMR0 .FILL 0
PMR7 .FILL 0
KBSR: .FILL xFE00 ; Keyboard Status Register Address
KBDR: .FILL xFE02 ; Keyboard Data Register Address
DSR: .FILL xFE04 ; Display Status Register Address
DDR: .FILL xFE06 ; Display Data Register Address


;
; Divides two integers, returns remainder.
;
; Preconditions: R1 is the dividen, R2 the divisor.
; Postconditions: R1 holds the remainder.
;
; THIS ROUTINE WAS DIRECTLY DERIVED FROM DIV ABOVE. THE ONLY DIFFERENCE IS
; WHICH NUMBER IS LEFT IN R1 AT THE END OF THE ROUTINE.
;
MOD 
	ST R0, MOD_R0
	ST R1, MOD_R1
	ST R2, MOD_R2
	ST R3, MOD_R3
	ST R7, MOD_R7
	add r2,r2,#0
	brz MOD_BY_0
	jsr DIV
	; r1 is quotient, r2 is still divisor
	; divident = quotient* divisor + remainder
	; remainder = divident - quotient*divisor
	
	jsr MUL
	; r1 is quotient* divisor
	
	ld r2 , MOD_R1 ; load original divident
	not r1 , r1
	add r1 , r1 , #1
	add  r1, r2,r1 ; r1 <- original divident - quotient * divisor = remainder
	
MOD_CLEANUP
	LD R0, MOD_R0
	LD R2, MOD_R2
	LD R3, MOD_R3
	LD R7, MOD_R7
	ADD R1, R1, #0	; Set condition codes for calling routine
	RET
MOD_BY_0 	
	LD R0, MOD_R0
	LD R2, MOD_R2
	LD R3, MOD_R3
	LD R7, MOD_R7
	ADD R1, R1, #0	; Set condition codes for calling routine, set by default result is original number
	ret
	
MOD_R0	.FILL 0
MOD_R1  .FILL 0
MOD_R2	.FILL 0
MOD_R3	.FILL 0
MOD_R7  .FILL 0

; R1 <- R1 + R2
SUM add r1 , r1 , r2
    ret

; R1 <- R1 - R2
SUB 	st r1 , SUB_R1
	st r7 , SUB_R7
 	add r1 , r2 , #0
	jsr NEGATE_R1
	add r2 , r1, #0
	ld r1 , SUB_R1
	add r1 , r1 , r2
	ld r7, SUB_R7
	ret

SUB_R1 .FILL #0
SUB_R7 .FILL #0
.end