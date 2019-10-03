OP_STORE_1 .FILL x5000
ENTER_OP
		ld r6 , OP_STORE_1
ENTER_OP_LOOP	jsr INPUT_OP ;result in r2
		;ld r3 , OP_RAW_CHAR
		;add r3 , r3 , #-10
		add r0 , r0 , #-10;r0 has last raw char inputted
        brz ENTER_OP_READY
		add r1 , r2 , #0
		jsr PUSH_R1_OP
		br ENTER_OP_LOOP

ENTER_OP_READY	lea r0 , MSG_OP_OK
		puts
		br MENU
			
MSG_NUM_OK .stringz "\nOP's ok!"

INPUT_OP		; subroutine, leaves stuff in r4
		; save r7 so we dont lose where we came from
		st r3 ,  OP_R3
		st r7, 	 OP_R7

OP_NO_SAVE	lea r0 , MSG_NEXT_OP
		
		; we dont need to save r7 so as long we
		; dont go to something that also goes to a subroutine

		MSG_NEXT_OP .stringz "\n:"

		puts
		and r3 , r3 , #0
		st r3 , OP_RAW_CHAR
        and r4 , r4 , #0 ; counter of valid op's
        and r2 , r2 , #0 ; will hold valid op result
		
		; R1 will be aux dummy reg

OP_I	getc	; gets c in r0
		st r0, OP_RAW_CHAR
		add r1 , r0 , #-10
		brz OP_READY
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
            out	; echo r0 with original value
            add r2 , r3 , #0 ; put mapped value in r2
            add r4 , r4 , #1 ; add 1 valid op count
            br OP_I
OP_READY    add r4 , r4 , #0
            brzn OP_I
            out
            ld r3 , OP_R3
            ld r7 , OP_R7
            ret

OP_R3 .FILL 0
OP_R7 .FILL 0
OP_RAW_CHAR .FILL 0

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

CAP_OP .FILL #0