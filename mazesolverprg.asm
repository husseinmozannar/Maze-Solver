title "mazesolver" ; Program title (optional)
list p=16f84A ; Identifies device
radix hex ; Set default radix
include "p16f84A.inc" ; Includes symbol definitions
COUNT1	EQU	d'12' ; used in delay
COUNT2	EQU	d'13' ;used in delay
COUNT3	EQU	d'14' ;used
COUNT0	EQU	d'15' ; for tmr0
COUNT4	EQU	d'16'
MODE_SELECT	EQU d'20' ; used to indicate mode flag bits,bit7:if mode selected,bit6:default,bit5:obstacle,bit4:maze ; BIT0:ITERATIONS
POINTS_SET	EQU	D'21'	; bit7=1 : start set, bit6=1 : end set, bit 5: obstacles are set
S1	EQU d'40' ;	CONVENTION FOR SYMBOLS: BIT7: START , BIT6: END, BIT5:OBSTACLE,BIT4: EMPTY, BIT3:VISITED
S2	EQU d'41'
S3	EQU d'42'
S4	EQU d'43'
S5	EQU d'44'
S6	EQU d'45'
S7	EQU d'46'
S8	EQU d'47'
S9	EQU d'48'
S10	EQU d'49'
S11	EQU d'50'
S12	EQU d'51'
S13	EQU d'52'
S14	EQU d'53'
S15	EQU d'54'
S16	EQU d'55'
S17	EQU d'56'
S18	EQU d'57'
S19	EQU d'58'
S20	EQU d'59'
ITERATIONS	EQU	d'63' ; which iteration? :)
REM_OBS	EQU	d'64' ; ANTHONY'S ADDITION
OBS_CLOCK	EQU d'65' 
COUNT_OBSTACLE	EQU	d'66' ; TO KNOW HOW MANY OBSTACLES WE WENT THROUGH
TO_PUT	EQU	d'67'
LCD_ROW	EQU	d'68'
LCD_COLUMN	EQU	d'69'
START_ROW	EQU	D'70'
START_COLUMN	EQU	D'71'
START_FSR	EQU	D'72'
CURR_FSR	EQU	D'73'



    ORG 0x0
    GOTO MAIN ; main program
    ORG 0x4 ; start of interrupt routine
    BTFSC	INTCON,RBIF
    GOTO	RBINT
    GOTO	TMR0INT

    ; here check source of interrupt and call routine and end routine with RETFIE	



MAIN
    BSF	STATUS,RP0 ; GO TO BANK 1
     ; set portA as output
    MOVLW	b'10000111' ;FOR TIMER0
    MOVWF	OPTION_REG

    MOVLW	b'11110000'
    MOVWF	TRISB ;SET PORT B AS INPUT AND OUTPUT ,MSB FIRST
    CLRF	TRISA ; SET PORT A AS OUTPUT
    BCF	STATUS,RP0 ; GO TO BANK 0
    CALL	DELAY40ms ; WAIT FOR POWER ON
    MOVLW	B'00010' 
    CALL	WRITE
    MOVLW	B'00010' 
    CALL	WRITE
    MOVLW	B'01000' ; 2 line mode and 5x7
    CALL	WRITE
    MOVLW	B'00000' 
    CALL	WRITE
    MOVLW	B'01110' ; display ON ,CURSOR OFF, BLINK OFF 
    CALL	WRITE

    MOVLW	B'00000' 
    CALL	WRITE

    MOVLW	B'00001' ;CLEAR DISPLAY
    CALL	WRITE

    MOVLW	B'00000' 
    CALL	WRITE
    MOVLW	B'00110' ; INCREMENT AND SHIFT OFF
    CALL	WRITE ;DONE 4 BIT MODE LCD
    CALL	WRITE_MAZE

    CALL	WRITE_WHITESPACE
    CALL	WRITE_S
    MOVLW	B'10100';O
    CALL	WRITE
    MOVLW	B'11111'
    CALL	WRITE

    MOVLW	B'10100';L
    CALL	WRITE
    MOVLW	B'11100'
    CALL	WRITE

    MOVLW	B'10101';V
    CALL	WRITE
    MOVLW	B'10110'
    CALL	WRITE
    CALL	WRITE_E
    MOVLW	B'10101';R
    CALL	WRITE
    MOVLW	B'10010'
    CALL	WRITE ; END WRITING MAZE SOLVER,  ,TILL NOW GOOD

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    MOVLW	B'00000' ;CLEAR DISPLAY 
    CALL	WRITE
    MOVLW	B'00001' ;CLEAR DISPLAY
    CALL	WRITE

    CALL	WRITE_WHITESPACE
    CALL	WRITE_WHITESPACE
    CALL	WRITE_WHITESPACE
    CALL	WRITE_STAR
    MOVLW	B'10100';D DEFAULT STARTS HERE
    CALL	WRITE
    MOVLW	B'10100'
    CALL	WRITE	

    CALL	WRITE_E

    MOVLW	B'10100';F
    CALL	WRITE
    MOVLW	B'10110'
    CALL	WRITE

    CALL	WRITE_A

    MOVLW	B'10101';U
    CALL	WRITE
    MOVLW	B'10101'
    CALL	WRITE

    MOVLW	B'10100';L
    CALL	WRITE
    MOVLW	B'11100'
    CALL	WRITE

    MOVLW	B'10101';T
    CALL	WRITE
    MOVLW	B'10100'
    CALL	WRITE ; END OF DEFAULT

    MOVLW	B'00001100';change line +1 
    CALL	WRITE
    MOVLW	B'00000001'
    CALL	WRITE

    MOVLW	B'10100';O
    CALL	WRITE
    MOVLW	B'11111'
    CALL	WRITE
    MOVLW	B'10100';B
    CALL	WRITE
    MOVLW	B'10010'
    CALL	WRITE
    CALL	WRITE_S
    MOVLW	B'10101';T
    CALL	WRITE
    MOVLW	B'10100'
    CALL	WRITE
    CALL	WRITE_A
    MOVLW	B'10100';C
    CALL	WRITE
    MOVLW	B'10011'
    CALL	WRITE
    MOVLW	B'10100';L
    CALL	WRITE
    MOVLW	B'11100'
    CALL	WRITE
    CALL	WRITE_E
    CALL	WRITE_WHITESPACE
    CALL	WRITE_WHITESPACE
    CALL	WRITE_WHITESPACE
    CALL	WRITE_MAZE
    CLRF	MODE_SELECT
    CLRF	PORTB
    BSF	MODE_SELECT,6
    CLRF	INTCON
    CLRF	TMR0
    BSF	INTCON,GIE
    BSF	INTCON,RBIE
    infLOOP	GOTO	infLOOP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;																																													  ;
;																																													  ;
;																																												      ;																																													  ;
;																																													  ;
;																																													  ;
;							       SUBROUTINES																																	  ;
;									GO HERE																																	  ;
;										|																																			  ;
;										|																																			  ;
;										|																																			  ;
;										V																																			  ;
;																																													  ;
;																																													  ;
;																																													  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SETNUMADDR	;DONT LOOK AT THIS
    MOVLW	B'01000'; SET ADDRESS FOR ITERATION NUM
    CALL	WRITE
    MOVLW	B'01111'
    CALL	WRITE
    RETURN

;WRITE_ITR01 ; USE THIS ONCE AT THE BEGINNING OF ALGORITHM (WRITES "ITR01" ON THE RIGHT);;;;;;;;;;;;;;;;;;;;;;
;    MOVLW	B'01000'; SET ADDRESS FOR I
;    CALL	WRITE
;    MOVLW	B'01011'
;    CALL	WRITE
;
;    MOVLW	B'10100';I
;    CALL	WRITE
;    MOVLW	B'11001'
;    CALL	WRITE
;
;    MOVLW	B'10101';T
;    CALL	WRITE
;    MOVLW	B'10100'
;    CALL	WRITE
;
;    MOVLW	B'10101';R
;    CALL	WRITE
;    MOVLW	B'10010'
;    CALL	WRITE
;
;    MOVLW	B'10011';0
;    CALL	WRITE
;    MOVLW	B'10000'
;    CALL	WRITE
;
;    MOVLW	B'10011';1
;    CALL	WRITE
;    MOVLW	B'10001'
;    CALL	WRITE
;
;
;    CLRF	ITERATIONS
;    BCF	MODE_SELECT,0
;    RETURN
;
;SET_ITERATION	;USE THIS IN ALGORITHM: WHEN YOU WANT TO START NEW ITERATION(OTHER THAN THE FIRST ONE), CALL THIS, MAKE SURE TO GO_BACK_CURSOR AFTER CALLING THIS(IF NEEDED);;;;;;;;;;;;;;;;;;;;;
;    BTFSC	MODE_SELECT,0
;    GOTO	THEDARKSIDE;IF ITERATIONS>10, GO HERE
;
;    BTFSC	ITERATIONS,0
;    GOTO	I3
;    BTFSC	ITERATIONS,1
;    GOTO	I4
;    BTFSC	ITERATIONS,2
;    GOTO	I5
;    BTFSC	ITERATIONS,3
;    GOTO	I6
;    BTFSC	ITERATIONS,4
;    GOTO	I7
;    BTFSC	ITERATIONS,5
;    GOTO	I8
;    BTFSC	ITERATIONS,6
;    GOTO	I9
;    BTFSC	ITERATIONS,7
;    GOTO	I10
;    GOTO	I2
;
;THEDARKSIDE
;    BTFSC	ITERATIONS,0
;    GOTO	I2
;    BTFSC	ITERATIONS,1
;    GOTO	I3
;    BTFSC	ITERATIONS,2
;    GOTO	I4
;    BTFSC	ITERATIONS,3
;    GOTO	I5
;    BTFSC	ITERATIONS,4
;    GOTO	I6
;    BTFSC	ITERATIONS,5
;    GOTO	I7
;    GOTO	I11	
;
;
;I2
;    BSF	ITERATIONS,0
;    CALL	SETNUMADDR
;    MOVLW	B'10011';2
;    CALL	WRITE
;    MOVLW	B'10010'
;    CALL	WRITE
;    RETURN
;
;I3
;    RLF	ITERATIONS,1
;    CALL	SETNUMADDR
;    MOVLW	B'10011';3
;    CALL	WRITE
;    MOVLW	B'10011'
;    CALL	WRITE
;    RETURN
;
;I4
;    RLF	ITERATIONS,1
;    CALL	SETNUMADDR
;    MOVLW	B'10011';4
;    CALL	WRITE
;    MOVLW	B'10100'
;    CALL	WRITE
;    RETURN
;
;I5
;    RLF	ITERATIONS,1
;    CALL	SETNUMADDR
;    MOVLW	B'10011';5
;    CALL	WRITE
;    MOVLW	B'10101'
;    CALL	WRITE
;    RETURN
;I6
;    RLF	ITERATIONS,1
;    CALL	SETNUMADDR
;    MOVLW	B'10011';6
;    CALL	WRITE
;    MOVLW	B'10110'
;    CALL	WRITE
;    RETURN
;
;I7
;    RLF	ITERATIONS,1
;    CALL	SETNUMADDR
;    MOVLW	B'10111';7
;    CALL	WRITE
;    MOVLW	B'10010'
;    CALL	WRITE
;    RETURN
;
;I8
;    RLF	ITERATIONS,1
;    CALL	SETNUMADDR
;    MOVLW	B'10011';8
;    CALL	WRITE
;    MOVLW	B'11000'
;    CALL	WRITE
;    RETURN
;
;I9
;    RLF	ITERATIONS,1
;    CALL	SETNUMADDR
;    MOVLW	B'10011';9
;    CALL	WRITE
;    MOVLW	B'11001'
;    CALL	WRITE
;    RETURN
;
;I10
;    CLRF	ITERATIONS
;    BSF	MODE_SELECT,0
;    MOVLW	B'01000'; SET ADDRESS BEFORE ITERATION NUM
;    CALL	WRITE
;    MOVLW	B'01110'
;    CALL	WRITE
;
;    MOVLW	B'10011';1
;    CALL	WRITE
;    MOVLW	B'10001'
;    CALL	WRITE
;
;    MOVLW	B'10011';0
;    CALL	WRITE
;    MOVLW	B'10000'
;    CALL	WRITE
;    RETURN
;
;I11
;    BSF	ITERATIONS,0
;    CALL	SETNUMADDR
;    MOVLW	B'10011';1
;    CALL	WRITE
;    MOVLW	B'10001'
;    CALL	WRITE
;    RETURN



SET_AND_WRITE_PATH
	MOVLW	B'01100'; SET ADDRESS FOR P
    CALL	WRITE
    MOVLW	B'01011'
    CALL	WRITE
	
	MOVLW	B'10101';P
    CALL	WRITE
    MOVLW	B'10000'
    CALL	WRITE

	CALL	WRITE_A
	MOVLW	B'10101';T
    CALL	WRITE
    MOVLW	B'10100'
    CALL	WRITE

	MOVLW	B'10100';H
    CALL	WRITE
    MOVLW	B'11000'
    CALL	WRITE
	CALL	GO_BACK_CURSOR
	RETURN

FINISH_SOLVE_TRUE
    ;has to print PATH * AND WAIT, THEN GO BACK TO MAIN OR SMTH
	    CALL	SET_AND_WRITE_PATH
		CALL	WRITE_STAR
		infss
			goto infss ;INFINITE LOOP WHEN DONE
		GOTO	RETY ;ADDED
    ;;;;;;;;;;;;;;;;NOT DONE
FINISH_SOLVE_FALSE
	    ;has to print PATH X AND WAIT, THEN GO BACK TO MAIN OR SMTH
		CALL	SET_AND_WRITE_PATH
		MOVLW	B'10101';X
	    CALL	WRITE
	    MOVLW	B'11000'
	    CALL	WRITE
		goto	infss ;INFINITE LOOP WHEN DONE
		GOTO	RETY;ADDED
		;;;;;;;;;;;;;;;; kamen not done

SOLVE ;CONVENTION FOR SYMBOLS: BIT7: START , BIT6: END, BIT5:OBSTACLE,BIT4: EMPTY, BIT3:VISITED, BIT1:CANT GO LEFT, BIT0: CANT GO RIGHT
	    MOVLW	B'00000' ;CLEAR DISPLAY 
	    CALL	WRITE
	    MOVLW	B'00001' ;CLEAR DISPLAY
	    CALL	WRITE

		MOVF	START_ROW,0
	    MOVWF	LCD_ROW
	    MOVF	START_COLUMN,0
	    MOVWF	LCD_COLUMN
	    CALL	PRINT_MAZE ;PRINT THE MAZE ON LCD
	    MOVF	START_FSR,0
	    MOVWF	CURR_FSR
		MOVWF	FSR ;ADDED
		BSF	S1,1
		BSF	S11,1
		BSF	S10,0
		BSF	S20,0 ;SETTING THE BOUNDRIES
		CALL	GO_BACK_CURSOR ;FUNCTION TO SET CURSOR TO LCD_ROW AND LCD_COLUMN
	    ; MODIFY CURRSOR AND BLINK OFF: DO

		MOVLW	d'45'  ; THIS IS ONLY FOR DEFAULT MODE ,JUST TO MAKE SURE FOR TESTING
		MOVWF	FSR ;ADDED
	    MOVLW	B'00001000';change line +1 
	    MOVWF	LCD_ROW
	    CALL	WRITE
	    MOVLW	B'00000101' 
	    MOVWF	LCD_COLUMN
	    CALL	WRITE
	    GOTO    SOLVE_REC


SOLVE_REC
		CALL	DELAY200ms ;at every iteration reprint the maze to show progress, REDO INSIDE EACH !!!!!!!
	    BTFSS   INDF, 0
	    GOTO    GO_RIGHT
check_left
		BTFSS   INDF, 1
	    GOTO    GO_LEFT
check_down
	    BTFSS   LCD_ROW,2
	    GOTO    GO_DOWN
check_up
	    BTFSC   LCD_ROW,2
	    GOTO    GO_UP
solve_end
	    BTFSS   INDF, 7
	    GOTO    NO_SOLUTION 			
	    GOTO	FINISH_SOLVE_FALSE ;NO SOLUTION FOUND END THE ALGO
    
NO_SOLUTION
		CALL	GO_BACK_CURSOR
		MOVLW	B'00100000'
		MOVWF	TO_PUT
		CALL	PLACE_ITEM ;place item does necessary changes and prints on screen , it changes INDF and prints on screen
		CALL	CLEAR_VISITED ;CLEAR VISITED LOCATIONS, works

	;    CALL    SET_ITERATION
	    GOTO    SOLVE
GO_RIGHT
	    INCF    FSR	;GO_RIGHT
	    BTFSC   INDF, 7 ;CHECK IF START POSITION
	    GOTO    GO_RIGHT_FALSE  
	    BTFSC   INDF,5  ;CHECK IF OBSTACLE
	    GOTO    GO_RIGHT_FALSE
	    BTFSC   INDF,3  ;CHECK IF VISITED
	    GOTO    GO_RIGHT_FALSE
	    BTFSC   INDF, 6 ;CHECK IF END
	    GOTO    FINISH_SOLVE_TRUE
	    GOTO    GO_RIGHT_TRUE   ;SUCCESS

GO_RIGHT_TRUE
		INCF    LCD_COLUMN
	    CALL    GO_BACK_CURSOR ; update cursor
		MOVLW	B'00001000'
		MOVWF	TO_PUT
;		MOVF	FSR,0
;		MOVWF	CURR_FSR
		CALL	PLACE_ITEM ;
		CALL    GO_BACK_CURSOR ;update cursor
	    GOTO    SOLVE_REC
	    
GO_RIGHT_FALSE
	    DECF    FSR	;GO_BACK
	    GOTO	check_left
    
GO_LEFT ;WAS "GO_RIGHT"
	    DECF    FSR	;GO_LEFT
	    BTFSC   INDF, 7 ;CHECK IF START POSITION
	    GOTO    GO_LEFT_FALSE  
	    BTFSC   INDF,5  ;CHECK IF OBSTACLE
	    GOTO    GO_LEFT_FALSE
	    BTFSC   INDF,3  ;CHECK IF VISITED
	    GOTO    GO_LEFT_FALSE
	    BTFSC   INDF, 6 ;CHECK IF END
	    GOTO    FINISH_SOLVE_TRUE
	    GOTO    GO_LEFT_TRUE   ;SUCCESS

GO_LEFT_TRUE
		MOVLW	B'00001000'
		MOVWF	TO_PUT
		MOVF	FSR,0
		MOVWF	CURR_FSR
		DECF    LCD_COLUMN
	    CALL    GO_BACK_CURSOR
		CALL	PLACE_ITEM ;
		CALL    GO_BACK_CURSOR
	    GOTO    SOLVE_REC
    
GO_LEFT_FALSE
	    INCF    FSR	;GO_BACK
	    GOTO	check_down

GO_UP
	    MOVLW   d'10'
	    SUBWF    FSR,1	;GO UP
	    BTFSC   INDF, 7 ;CHECK IF START POSITION
	    GOTO    GO_UP_FALSE  
	    BTFSC   INDF,5  ;CHECK IF OBSTACLE
	    GOTO    GO_UP_FALSE
	    BTFSC   INDF,3  ;CHECK IF VISITED
	    GOTO    GO_UP_FALSE
	    BTFSC   INDF, 6 ;CHECK IF END
	    GOTO    FINISH_SOLVE_TRUE
	    GOTO    GO_UP_TRUE   ;SUCCESS

GO_UP_TRUE
	    MOVLW	B'00001000'
		MOVWF	LCD_ROW ;go to row1
	    CALL    GO_BACK_CURSOR
		MOVLW	B'00001000'
		MOVWF	TO_PUT
		MOVF	FSR,0
		MOVWF	CURR_FSR
		CALL	PLACE_ITEM ;CHANGE IT TO OBSTACLE
		CALL    GO_BACK_CURSOR
	    GOTO    SOLVE_REC
	    
GO_UP_FALSE
	    MOVLW   d'10' ;FIXED
	    ADDWF    FSR,1	;GO DOWN
	    GOTO	solve_end
	    
GO_DOWN
	    MOVLW   d'10'
	    ADDWF    FSR,1	;GO DOWN
	    BTFSC   INDF, 7 ;CHECK IF START POSITION
	    GOTO    GO_DOWN_FALSE  
	    BTFSC   INDF,5  ;CHECK IF OBSTACLE
	    GOTO    GO_DOWN_FALSE
	    BTFSC   INDF,3  ;CHECK IF VISITED
	    GOTO    GO_DOWN_FALSE
	    BTFSC   INDF, 6 ;CHECK IF END
	    GOTO    FINISH_SOLVE_TRUE
	    GOTO    GO_DOWN_TRUE   ;SUCCESS

GO_DOWN_TRUE
		MOVLW	B'00001100'
		MOVWF	LCD_ROW ; GOTO ROW2
	    CALL    GO_BACK_CURSOR
		MOVLW	B'00001000'
		MOVWF	TO_PUT
		MOVF	FSR,0
		MOVWF	CURR_FSR
		CALL	PLACE_ITEM ;CHANGE IT TO OBSTACLE
		CALL    GO_BACK_CURSOR
	    GOTO    SOLVE_REC
    
GO_DOWN_FALSE
	    MOVLW   d'10'
	    SUBWF    FSR,1	;GO DOWN
	    GOTO	check_up
;;;;;;;		;;;;;;;;;;;;;	;;;;;;;;;;;;;;;;;
	;ANTHONY'S ADDITION	
WRITE_REM_OBS_5
    MOVLW	B'01000';SET OBS ADDRESS
    CALL	WRITE
    MOVLW	B'01100';
    CALL	WRITE

    MOVLW	B'10100';O
    CALL	WRITE
    MOVLW	B'11111'
    CALL	WRITE
    MOVLW	B'10100';B
    CALL	WRITE
    MOVLW	B'10010'
    CALL	WRITE
    CALL	WRITE_S ; WROTE OBS

    MOVLW	B'01100';SET REM ADDRESS
    CALL	WRITE
    MOVLW	B'01011';
    CALL	WRITE

    MOVLW	B'10101';R
    CALL	WRITE
    MOVLW	B'10010'
    CALL	WRITE
    CALL	WRITE_E
    MOVLW	B'10100';M
    CALL	WRITE
    MOVLW	B'11101'
    CALL	WRITE ; WROTE REM
    CALL	WRITE_WHITESPACE

    MOVLW	B'10011'; 5
    CALL WRITE
    MOVLW	B'10101'
    CALL WRITE

    CLRF	REM_OBS
    BSF	REM_OBS,4
    RETURN ;RETURN OR GO SOMEWHERE?
WRITE_REM_NUM
    ;MUST HAVE REGISTER TO COUNT OBSTACLES REM
    BTFSC	REM_OBS,4
    CALL	PRINT4 ; PRINTS 4 (MAZE MODE) AND RETURNS CURSOR TO ORIGINAL PLACE
    BTFSC	REM_OBS,3
    CALL	PRINT3
    BTFSC	REM_OBS,2
    CALL	PRINT2
    BTFSC	REM_OBS,1
    CALL	PRINT1
    BTFSC	REM_OBS,0
    CALL	PRINT0
    RETURN
	

PRINT4
    CALL	REM_NUM_ADDRESS

    MOVLW	B'10011'; 4
    CALL WRITE
    MOVLW	B'10100'
    CALL WRITE

    RRF	REM_OBS,1
    BCF	REM_OBS,7	

    CALL	GO_BACK_CURSOR
    RETURN
PRINT3
    CALL	REM_NUM_ADDRESS

    MOVLW	B'10011'; 3
    CALL WRITE
    MOVLW	B'10011'
    CALL WRITE

    RRF	REM_OBS,1
    BCF	REM_OBS,7

    CALL	GO_BACK_CURSOR
    RETURN
PRINT2
    CALL	REM_NUM_ADDRESS

    MOVLW	B'10011'; 2
    CALL WRITE
    MOVLW	B'10010'
    CALL WRITE

    RRF	REM_OBS,1
    BCF	REM_OBS,7

    CALL	GO_BACK_CURSOR
    RETURN
PRINT1
    CALL	REM_NUM_ADDRESS

    MOVLW	B'10011'; 1
    CALL WRITE
    MOVLW	B'10001'
    CALL WRITE

    RRF	REM_OBS,1
    BCF	REM_OBS,7

    CALL	GO_BACK_CURSOR
    RETURN
PRINT0
    CALL	REM_NUM_ADDRESS

    MOVLW	B'10011'; 0
    CALL WRITE
    MOVLW	B'10000'
    CALL WRITE

    RRF	REM_OBS,1
    BCF	REM_OBS,7	

    CALL	GO_BACK_CURSOR
    RETURN

REM_NUM_ADDRESS
    MOVLW	B'01100';SET NUM ADDRESS 
    CALL	WRITE
    MOVLW	B'01111'
    CALL	WRITE;
    RETRUN
	
GO_BACK_CURSOR
    MOVF	LCD_ROW,0
    CALL	WRITE
    MOVF	LCD_COLUMN
    CALL	WRITE
    RETURN


;;;;;;;;	;;;;;;;;;;;;	;;;;;;;;;;;;;;;;

RBINT
    CALL	DELAYonemilli
    BTFSC	PORTB,4 ; check here source of interrupt and call appropriate subroutine
    GOTO	INT5
    GOTO	MOVE 
INT5	BTFSC	PORTB,5
    GOTO	INT6
    GOTO	CONFIRM
INT6	BTFSC	PORTB,6
    GOTO	INT7
    GOTO 	START
INT7	BTFSC	PORTB,7
    GOTO	RETY
    GOTO	ENDPOINT
RETY	BCF	INTCON,RBIF
    RETFIE

MOVE
    BTFSS	MODE_SELECT,7 ; if we pressed move, we check if we already selected a mode
    GOTO	POINTER_MOVE ;else move pointer CALL OR GOTO???
    BTFSS	MODE_SELECT,5 ;now if we are in our obstacle mode
    GOTO	RETY
    GOTO	OBSTACLE_MOVE

    ;DO FOR OBSTACLE MODE LATER	


OBSTACLE_MOVE
    BTFSC	INDF,1 ; IF END OF ROW 2 ,BETTER WAY IS TO CHECK IF FSR=S11 , I HAVE SET FOR OBSTACLE 11 ( END OF ROW 2 ) BIT1=1 
    GOTO	RETY ;SHOULD CALL ALGORITHM BEFORE !!!
    BTFSC	INDF,0 ; IF END OF ROW1 ,IF ELSE STRUCTURE, CHECK FSR=S10 ,I HAVE SET FOR OBSTACLE 10 ( END OF ROW 1 ) BIT0=1 
    GOTO	set_row1_act ;change to call set_row1 if error
    BTFSC	OBS_CLOCK,0
    GOTO	MOVE_DEC
    GOTO	MOVE_INC
MOVE_INC
    MOVLW	B'00001' ; THIS IS MOVE CURSOR
    CALL	WRITE
    MOVLW	B'00100' ;RIGHT
    CALL	WRITE
    INCF	LCD_COLUMN
    INCF	FSR		
    GOTO RETY
MOVE_DEC

    MOVLW	B'00001' ; THIS IS MOVE CURSOR
    CALL	WRITE
    MOVLW	B'00000' ;LEFT
    CALL	WRITE
    DECF	LCD_COLUMN
    DECF	FSR
    GOTO	RETY
set_row1_act ;just to make it callable 
    CALL	SET_ROW1
    GOTO	RETY	


DELAY200ms 
    CALL	DELAY40ms	
    CALL	DELAY40ms
    CALL	DELAY40ms
    CALL	DELAY40ms	
    CALL	DELAY40ms	
    RETURN

SET_ROW1 ; Moves cursor and FSR pointer to end of the second row 
;   MOVLW	B'00000'
;   CALL	WRITE
;   MOVLW	B'00100' ; SET DECREMENT MODE
;   CALL	WRITE
    MOVLW	B'00001100';change line +1 
    MOVWF	LCD_ROW
    CALL	WRITE
    MOVLW	B'00001001' 
    MOVWF	LCD_COLUMN
    CALL	WRITE
    BSF	OBS_CLOCK,0 ;SET IT TO 1 MEANING DEC
    movlw	d'59' ;BACK TO 59
    movwf	FSR ;to RAM
    RETURN

CONFIRM
    BTFSS	MODE_SELECT,7
    GOTO	CONFIRM_FALSE ;if it hasnt been pressed before: time to set a mode and initialize 
    GOTO	CONFIRM_TRUE ; action according to mode
		
CONFIRM_FALSE
    BSF	MODE_SELECT,7
    BTFSS	MODE_SELECT,6
    GOTO	CHECK_5
    GOTO	DEFAULT_INIT;ADD GOTO RETY IN THE END
CHECK_5
	BTFSS	MODE_SELECT,5
    GOTO	CHECK_4
    GOTO	OBSTACLE_INIT
CHECK_4	GOTO	MAZE_INIT


CONFIRM_TRUE
    BTFSC	MODE_SELECT,6
    GOTO	DEFAULT_RUN;ADD GOTO RETY IN THE END
    BTFSC	MODE_SELECT,5
    GOTO	OBSTACLE_DO ; NEED TO DO
    GOTO	MAZE_OBS ;NEED TO DO


MAZE_OBS ;USED TO PUT OBSTACLE IN MAZE MODE ;
    MOVLW	b'00100000'
    MOVWF	TO_PUT	; PREPARE ARGUMENT AS OBSTACLE	
    BTFSC	POINTS_SET,5 ;if we have already placed 5 obstacles
    GOTO	MAZE_CANT
    CALL	PLACE_ITEM
    CALL	WRITE_REM_NUM
    BTFSC	COUNT_OBSTACLE,4 ;check if after placing the obstacle we have now 5 obs
    BSF	POINTS_SET,5; SET MEANING 
    CALL	CHECK_REQ ;check if we can start algorithm
    GOTO	RETY
MAZE_CANT	;dont place obstacle
    BSF	PORTB,0
    CALL	DELAY40ms ;THIS SERVES FOR A SHORT BUZZ
    BCF	PORTB,0
    GOTO	RETY




OBSTACLE_DO
    ; try to put obstacle , and increment obstacle count if succesfuul : its own subroutine
    ; at the end check if number of obstacles has reached its limit, if so call algorithm 
    MOVLW	b'00100000'
    MOVWF	TO_PUT	; PREPARE ARGUMENT AS OBSTACLE	
    BTFSC	COUNT_OBSTACLE,4 ;CHECK IF 5 TIMES SHIFTED LEFT
    GOTO	RETY;SULD CALL ALGORITHM IN PLACE and stop all other stuff !!!!
    CALL	PLACE_ITEM
    GOTO	RETY

		
PLACE_ITEM ;this routine has argument TO_PUT and places the object at current FSR and CURSOR :keeps cursor in place
    BTFSC	INDF,4 ;CHECK IF EMPTY, else dont place anything
    GOTO	PLACE_TRUE
    GOTO	PLACE_FALSE
PLACE_TRUE	
    BTFSC	TO_PUT,7
    GOTO	PLACE_START 
    BTFSC	TO_PUT,6
    GOTO	PLACE_END 
    BTFSC	TO_PUT,5
    GOTO	PLACE_RECT
    BTFSC	TO_PUT,3
    GOTO	PLACE_STAR
PLACE_FINISH
    MOVLW	B'00001' ; THIS IS MOVE CURSOR
    CALL	WRITE
    MOVLW	B'00000' ;left
    CALL	WRITE	
    RETURN ; 
PLACE_FALSE
    BSF	PORTB,3
    CALL	DELAY40ms
    BCF	PORTB,3
    RETURN

PLACE_STAR
	BCF	INDF,4
	BSF	INDF,3
	CALL	WRITE_STAR
	GOTO	PLACE_FINISH
PLACE_RECT
    BCF	INDF,4
    BSF	INDF,5 ;UPDATE MEMORY
    CALL	WRITE_RECT
    RLF	COUNT_OBSTACLE;update number of obstacles
    ;update number of obstacles
    GOTO	PLACE_FINISH

PLACE_START
    MOVF	LCD_ROW,0
    MOVWF	START_ROW
    MOVF	LCD_COLUMN,0
    MOVWF	START_COLUMN ;SET START LOCATION FROM CURRENT LOCATION
    MOVF	FSR,0
    MOVWF	START_FSR ;SET START FSR
    BCF	INDF,4
    BSF	INDF,7
    CALL	WRITE_S
    BSF	POINTS_SET,7 ;update that start is placed
    GOTO	PLACE_FINISH

PLACE_END
    BCF	INDF,4
    BSF	INDF,6
    CALL	WRITE_E
    BSF	POINTS_SET,6 ;update that end is placed
    GOTO	PLACE_FINISH



CHECK_REQ
    BTFSS	POINTS_SET,7
    RETURN
    BTFSS	POINTS_SET,6
    RETURN
    BTFSS	POINTS_SET,5
    RETURN	
    CLRF	INTCON;SHOULD NOW START ALGORITHM : theoretically
    MOVLW	B'00000' ;CLEAR DISPLAY 
    CALL	WRITE
    MOVLW	B'00001' ;CLEAR DISPLAY
    CALL	WRITE
    GOTO	MAIN ; go to algorithm


OBSTACLE_INIT
    MOVLW	B'00000' ;CLEAR DISPLAY 
    CALL	WRITE
    MOVLW	B'00001' ;CLEAR DISPLAY
    CALL	WRITE
    ;FIRST CLEAR DISPLAY
    CALL	MAZE_INIT_EMPTY
    CLRF	S1
    BSF	S1,7 ;START
    CLRF	S20
    BSF	S20,6 ;HAVE PUT THE START AND END POINTS	
    CALL	PRINT_MAZE
    CALL	WRITE_COORD
    MOVLW	B'00000';	set cursor on, blink on, display on. 
    CALL	WRITE
    MOVLW	B'01111'
    CALL	WRITE
    BSF	PORTB,3 ;green LED on
    MOVLW	d'41'
    MOVWF	FSR; 
    MOVLW	b'00000000'
    MOVF	OBS_CLOCK
    MOVLW	b'00000001'
    MOVF	COUNT_OBSTACLE
    MOVLW	B'00001000';change line +1 
    CALL	WRITE
    MOVLW	B'00000001' ;start from 2nd column , works
    CALL	WRITE	
    MOVLW	B'00001000'  ;SET START POINT ADDRESS
    MOVWF	START_ROW
    MOVWF	LCD_ROW
    MOVLW	B'00000000'
    MOVWF	START_COLUMN
    MOVWF	LCD_COLUMN
    BSF	S10,0 ;BOUNDS
    BSF	S11,1 ;BOUNDS
    MOVLW	D'40'
    MOVWF	START_FSR
    ;INITIALIZE FSR ,AND SET POINTER TO FIRST OF SCREEN, INITALIZE LCD ADRESS TO 0
    ; initialize obs_clock to 0
    ;INITIALIZE COUNT_OBS TO 0
    GOTO RETY ;PRINTED AND INITALIZED MAZE 
		

MAZE_INIT
    MOVLW	B'00000' ;CLEAR DISPLAY 
    CALL	WRITE
    MOVLW	B'00001' ;CLEAR DISPLAY
    CALL	WRITE
    ;FIRST CLEAR DISPLAY
    CALL	MAZE_INIT_EMPTY
    CALL	PRINT_MAZE
    CALL	WRITE_REM_OBS_5
    BSF	PORTB,3 ;green LED on
    BSF	PORTB,2 ;RED
    MOVLW	B'00000';	set cursor on, blink on, display on. 
    CALL	WRITE
    MOVLW	B'01111'
    CALL	WRITE
    MOVLW	B'00001000';change line +1 
    CALL	WRITE
    MOVLW	B'00000000' ;start from 1st column , works
    CALL	WRITE
    BSF	S10,0 ;BOUNDS
    BSF	S11,1 ;BOUNDS	
    CLRF	OBS_CLOCK ;CLEAR BOTH
    MOVLW	b'00000001'
    MOVWF	COUNT_OBSTACLE
    CLRF	POINTS_SET
    MOVLW	d'40' ;set to start of maze
    MOVWF	FSR;
    MOVLW	H'20'
    MOVWF	COUNT0 ;TMR0 COUNTER SETUP
    ; NOW PRINT REM AND OBS 
    CLRF	LCD_COLUMN ;TO KEEP TRACK OF ADDRES OF LCD CURSOR
    MOVLW	B'00000100'
    MOVWF	LCD_ROW
    BSF	INTCON,T0IE;ENABLE TMR0 INTERRPUTS
    GOTO	RETY

DEFAULT_RUN 
    ;CALL ALGORITHM
	GOTO	SOLVE
    GOTO RETY

DEFAULT_INIT	
    ; CLEAR DISPLAY
    MOVLW	B'00000' ;CLEAR DISPLAY 
    CALL	WRITE
    MOVLW	B'00001' ;CLEAR DISPLAY
    CALL	WRITE
    CALL	MAZE_INIT_EMPTY

    CLRF	S1
    BSF	S1,5 ;OBS
    CLRF	S12
    BSF	S12,5 ;OBS
    CLRF	S14
    BSF	S14,5 ;OBS
    CLRF	S15
    BSF	S15,5 ;OBS
    CLRF	S19
    BSF	S19,5 ;OBS
    CLRF	S20
    BSF	S20,5 ;OBS
    CLRF	S6
    BSF	S6,7;START
    CLRF	S11 ;END
    BSF	S11,6	;INITIALIZED MAZE PROPERLY
    MOVLW	B'00001000'  ;SET START POINT ADDRESS
    MOVWF	START_ROW
    MOVLW	B'00000101'
    MOVWF	START_COLUMN

    CALL	PRINT_MAZE ;printed maze
    CALL	WRITE_COORD
    MOVLW	B'00000';	set cursor on, blink on, display on. 
    CALL	WRITE
    MOVLW	B'01111'
    CALL	WRITE
    MOVLW	d'45'
    MOVWF	START_FSR ;START FSR
	MOVWF	CURR_FSR
    BSF	PORTB,2 ;RED LED ON
    GOTO RETY





START
    BTFSS	MODE_SELECT,4
    GOTO	RETY
    MOVLW	b'10000000'
    MOVWF	TO_PUT	; PREPARE ARGUMENT AS OBSTACLE	
    BTFSC	POINTS_SET,7
    GOTO	MAZE_CANT
    CALL	PLACE_ITEM
    CALL	CHECK_REQ
    GOTO	RETY
		

ENDPOINT
    BTFSS	MODE_SELECT,4
    GOTO	RETY
    MOVLW	b'01000000'
    MOVWF	TO_PUT	; PREPARE ARGUMENT AS OBSTACLE	
    BTFSC	POINTS_SET,6
    GOTO	MAZE_CANT
    CALL	PLACE_ITEM
    CALL	CHECK_REQ
    GOTO	RETY

TMR0INT ; this is complete and working
    DECFSZ	COUNT0,f 
    GOTO	RET
    MOVLW	H'20'
    MOVWF	COUNT0 ;TMR0 COUNTER SETUP
    BTFSC	INDF,1 ; IF END OF ROW 2 ,BETTER WAY IS TO CHECK IF FSR=S11 , I HAVE SET FOR OBSTACLE 11 ( END OF ROW 2 ) BIT1=1 
    goto	SET_ROW2_act ;SHOULD CALL ALGORITHM BEFORE !!!
    BTFSC	INDF,0 ; IF END OF ROW1 ,IF ELSE STRUCTURE, CHECK FSR=S10 ,I HAVE SET FOR OBSTACLE 10 ( END OF ROW 1 ) BIT0=1 
    goto	SET_ROW1_act2
    BTFSC	OBS_CLOCK,0
    GOTO	MOVE_DEC_M
    GOTO	MOVE_INC_M
MOVE_INC_M
    MOVLW	B'00001' ; THIS IS MOVE CURSOR
    CALL	WRITE
    MOVLW	B'00100' ;RIGHT
    CALL	WRITE
    INCF	LCD_COLUMN;KEEP TRACK OF LCD ADDRESS
    INCF	FSR		
    GOTO RET
MOVE_DEC_M
    MOVLW	B'00000'
    CALL	WRITE
    MOVLW	B'00100' ; SET DECREMENT MODE
    CALL	WRITE
    MOVLW	B'00001' ; THIS IS MOVE CURSOR
    CALL	WRITE
    MOVLW	B'00000' ;LEFT
    CALL	WRITE
    DECF	LCD_COLUMN ;KEEP TRACK OF LCD ADDRESS
    DECF	FSR ;update fsr
    GOTO	RET

RET	
    CLRF	TMR0
    BCF	INTCON,T0IF
    RETFIE


SET_ROW2_act
    call    SET_ROW2
    GOTO    RET
SET_ROW1_act2
    call    SET_ROW1
    GOTO    RET	

SET_ROW2  
    MOVLW	B'00001000';change line +1 
    MOVWF	LCD_ROW
    CALL	WRITE
    MOVLW	B'00000000' ; 0TH COLUMN 
    MOVWF	LCD_COLUMN
    CALL	WRITE

    BCF	OBS_CLOCK,0 ;SET IT TO 0 MEANING inc
    movlw	d'40' ;1st column
    movwf	FSR ;to RAM
    RETURN



POINTER_MOVE ; USED FOR MODE SELECTION
    BTFSS	MODE_SELECT,6
    GOTO	CHECK5
    MOVLW	B'01000';GO TO DEFAULT  address
    CALL	WRITE
    MOVLW	B'00011'
    CALL	WRITE
    CALL	WRITE_WHITESPACE ;remove *
    MOVLW	B'01100';GO TO OBSTACLE 
    CALL	WRITE
    MOVLW	B'00000'
    CALL	WRITE
    CALL	WRITE_STAR
    BCF	MODE_SELECT,6
    BSF	MODE_SELECT,5
    GOTO	RETY
CHECK5
    BTFSS	MODE_SELECT,5
    GOTO	CHECK4
    MOVLW	B'01100';GO TO OBSTACLE 
    CALL	WRITE
    MOVLW	B'00000'
    CALL	WRITE
    CALL	WRITE_WHITESPACE
    MOVLW	B'01100';GO TO MAZE
    CALL	WRITE
    MOVLW	B'01011'
    CALL	WRITE
    CALL	WRITE_STAR
    BCF	MODE_SELECT,5
    BSF	MODE_SELECT,4
    GOTO	RETY
CHECK4	
    MOVLW	B'01100';GO TO MAZE
    CALL	WRITE
    MOVLW	B'01011'
    CALL	WRITE
    CALL	WRITE_WHITESPACE
    MOVLW	B'01000';GO TO DEFAULT add 
    CALL	WRITE
    MOVLW	B'00011'
    CALL	WRITE
    CALL	WRITE_STAR
    CLRF	MODE_SELECT
    BSF	MODE_SELECT,6
    GOTO	RETY

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; WRITING SUBROUTINES MOSTLY;;;;;;;;;;;
WRITE__
    MOVLW	B'10101';_
    CALL	WRITE
    MOVLW	B'11111'
    CALL	WRITE
    RETURN
WRITE_RECT
    MOVLW	B'11111';||
    CALL	WRITE
    MOVLW	B'11111'
    CALL	WRITE
    RETURN
WRITE_STAR
    MOVLW	B'10010';*
    CALL	WRITE
    MOVLW	B'11010'
    CALL	WRITE
    RETURN

WRITE_WHITESPACE
    MOVLW	b'10010'
    CALL	WRITE
    MOVLW	B'10000'
    CALL	WRITE
    RETURN

WRITE_S	
    MOVLW	b'10101'
    CALL	WRITE
    MOVLW	B'10011'
    CALL	WRITE
    RETURN

WRITE_A 
    MOVLW	B'10100';A
    CALL	WRITE
    MOVLW	B'10001'
    CALL	WRITE
    RETURN

WRITE_E
    MOVLW	B'10100';E
    CALL	WRITE
    MOVLW	B'10101'
    CALL	WRITE
    RETURN


WRITE	MOVWF	PORTA ;TO WRITE TO LCD
    CALL	ET
    RETURN

WRITE_MAZE 
    MOVLW	B'10100';M
    CALL	WRITE
    MOVLW	B'11101'
    CALL	WRITE
    CALL	WRITE_A
    MOVLW	B'10101';Z
    CALL	WRITE
    MOVLW	B'11010'
    CALL	WRITE
    CALL	WRITE_E
    RETURN


MAZE_INIT_EMPTY; USED TO SET THE MAZE ALL EMPTY 
    movlw	d'40' ;initialize pointer   THIS IS USED TO READ THE SYMBOLS OF OUR MAZE, we intialize the FSR to the address and read from the INDF register
    movwf	FSR ;to RAM
    movlw	d'21' ;checkkk
    movwf	COUNT3
MAZE_INIT_LOOP
    DECFSZ	COUNT3,F ;ITERATE 20 times
    GOTO	MAZE_INIT_ACTION
    RETURN
MAZE_INIT_ACTION
    CLRF	INDF
    BSF	INDF,4 ;SET 4TH BIT TO 1: EMPTY
    INCF	FSR
    GOTO	MAZE_INIT_LOOP			


CLEAR_VISITED
    movlw	d'40' ;initialize pointer   
    movwf	FSR ;
    movlw	d'21' ; ITERATE OVER ALL MAZE
    movwf	COUNT4
CLEAR_VISITED_LOOP
    DECFSZ	COUNT4,F
    GOTO	CLEAR_VISITED_ACTION
    GOTO	CLEAR_VISITED_END
CLEAR_VISITED_ACTION
    BTFSS	INDF,3
	GOTO	CLEAR_VISTED_SKIP
	BSF	INDF,4
	BCF	INDF,3 ;SET IT TO EMPTY IF IT IS VISITED
CLEAR_VISTED_SKIP
    INCF	FSR
    GOTO	CLEAR_VISITED_LOOP
CLEAR_VISITED_END
	CALL	GO_BACK_CURSOR
	MOVF	CURR_FSR,0
	MOVWF	FSR ; POSSIBLY NO NEED
	RETURN 



PRINT_MAZE ;used to print maze on LCD
    MOVLW	B'01000';GO TO START OF	LCD
    CALL	WRITE
    MOVLW	B'00000'
    CALL	WRITE
    movlw	d'40' ;initialize pointer   
    movwf	FSR ;
    CALL	PRINT_MAZE_SUB
    MOVLW	B'01100';GO TO SECOND LINE
    CALL	WRITE
    MOVLW	B'00000'
    CALL	WRITE
    movlw	d'50' ;initialize pointer   
    movwf	FSR ;
    CALL	PRINT_MAZE_SUB
    RETURN

PRINT_MAZE_SUB
    movlw	d'11'
    movwf	COUNT3
PRINT_MAZE_LOOP
    DECFSZ	COUNT3,F
    GOTO	PRINT_MAZE_ACTION
    RETURN
PRINT_MAZE_ACTION
    BTFSC	INDF,7
    CALL	WRITE_S
    BTFSC	INDF,6
    CALL	WRITE_E
    BTFSC	INDF,5
    CALL	WRITE_RECT
    BTFSC	INDF,4
    CALL	WRITE__
    BTFSC	INDF,3
    CALL	WRITE_STAR
    INCF	FSR
    GOTO	PRINT_MAZE_LOOP
		

ET	BSF	PORTB,1;subroutine to send messages to LCD: toogle routine, can USE 10ms instead of 40ms
    NOP
    BCF	PORTB,1
    CALL	DELAY40ms ; do it in 10ms if we have code lines
    RETURN

DELAYonemilli	Movlw	H'07'
    movwf	COUNT2
LOOPP	NOP
    INCFSZ	COUNT2,F
    GOTO	LOOPP
    RETURN


DELAY40ms	MOVLW	H'00' ;40 ms delay subroutine
    MOVWF	COUNT2
    MOVLW	D'52'
    MOVWF	COUNT1
LOOP	
    INCFSZ	COUNT2,F
    GOTO	LOOP
    DECFSZ	COUNT1,F
    GOTO	LOOP
    RETURN

WRITE_COORD
    MOVLW	B'01000';SET ADDRS AT 0X0D 
    CALL	WRITE
    MOVLW	B'01101'
    CALL	WRITE	
    CALL WRITE_S
    CALL	WRITE_WHITESPACE
    MOVLW	B'10100'; @
    CALL	WRITE
    MOVLW	B'10000'
    CALL	WRITE

    MOVLW	B'01100';SET ADDRS AT 0X4D 
    CALL	WRITE
    MOVLW	B'01101'
    CALL	WRITE

    MOVLW	B'10011'; 0
    CALL	WRITE
    MOVLW	B'10000'
    CALL	WRITE	

    MOVLW	B'10010'; WRITE "," 
    CALL	WRITE
    MOVLW	B'11100'
    CALL	WRITE

    BTFSS	MODE_SELECT,6
    GOTO	SKEEPEE ; IF BIT 6 IS 0, THIS MEANS I AM IN OBSTACLE(IMPLEMENTED IN SKEEPEE)
    MOVLW	B'10011'; WRITE 5 
    CALL	WRITE
    MOVLW	B'10101'
    CALL	WRITE	
    RETURN
SKEEPEE	
    MOVLW	B'10011'; 0
    CALL	WRITE
    MOVLW	B'10000'
    CALL	WRITE
    RETURN
    END ; last in program