    ORG 0
    ; DISPLAY SETUP
        LCD_P   EQU P2
        LCD_RS  EQU P1.4
        LCD_RW  EQU P1.5
        LCD_E   EQU P1.6

    ; LCD DELAY
        LCD_DELAY_L0_ADDRESS    EQU 6FH
        LCD_DELAY_L0_COUNT      EQU 22H

    ; KEYPAD SETUP
        ; bool ( BIT ADDRESSABLE )
        IS_KEY_SINGLE_PRESS  EQU     7FH
        ; PORT CONNECTION ==>> C(4-1)->P(7-4) + R(4-1)->P(3-0)
        KEYPAD_PORT                    EQU     P3


    ; 7 SEG DISPLAY SETUP
        M_7SEG_DISP_OUT_PORT        EQU     P0
        M_7SEG_DISP_INDEX_0         EQU     50H
        ; NUMBER OF DISPLAY WILL BE USED
        M_7SEG_DISP_DIGITS_NO       EQU     3

        IF M_7SEG_DISP_DIGITS_NO > 0
        M_7SEG_DISP_DIGITS_0_PIN   EQU     P1.0
        ENDIF
        IF M_7SEG_DISP_DIGITS_NO > 1
        M_7SEG_DISP_DIGITS_1_PIN   EQU     P1.1
        ENDIF
        IF M_7SEG_DISP_DIGITS_NO > 2
        M_7SEG_DISP_DIGITS_2_PIN   EQU     P1.2
        ENDIF
        IF M_7SEG_DISP_DIGITS_NO > 3
        M_7SEG_DISP_DIGITS_3_PIN   EQU     P1.3
        ENDIF

    ; TIME_DELAY SETUP
        TIME_DELAY_L0_COUNT         EQU     55H
        TIME_DELAY_L1_COUNT         EQU     56H


    ; OVEN_COUNTER SETUP
        ; INPUT VARIABLE FOR DIGIT 0,1,2
        COUNTER_INPUT_DIGIT_0 EQU 60H
        COUNTER_INPUT_DIGIT_1 EQU 61H
        COUNTER_INPUT_DIGIT_2 EQU 62H

        ; OVEN_COUNTER LEVEL 0,1,2 FOR DIGIT 0,1,2
        COUNTER_L0         EQU     63H
        COUNTER_L1         EQU     64H
        COUNTER_L2         EQU     65H

        ; OVEN SETUP
        OVEN_START_PIN              EQU P1.3
        OVEN_PAUSE_PIN              EQU P1.7
        
        ; bool ( BIT ADDRESSABLE )
        OVEN_TIME_GREATER_60_BIT    EQU 7EH 

        

        MOV SP, #70H
        MOV PSW, #00H



; ============== MAIN CODE START =====================
MAIN:   ; MAIN CODE START
        LCALL LCD_INIT      ; SETUP LCD DISPLAY
        CLR IS_KEY_SINGLE_PRESS

    GET_OVEN_READY:
        ; SETUP OVEN PINS AS OUTPUT(0), INPUT(1)
        LCALL OVEN_INIT
        LCALL LCD_CLEAR

        LCALL LCD_CURSOR_LINE_1
        MOV DPTR, #OVEN_READY_MSG
        LCALL LCD_STR_PRINT ; LCD STRING DISPLAY

        LCALL LCD_CURSOR_LINE_2
        MOV DPTR, #OVEN_TIMER_MSG
        LCALL LCD_STR_PRINT ; LCD STRING DISPLAY

    TAKE_TIMER_INPUT:
        LCALL COUNTER_VALUE_INPUT

        LCALL OVEN_CHECK_TIME_60

    GET_OVEN_START:
        ; PRESS 'ON/C' IN KEYPAD TO START/END
        LCALL OVEN_WAIT_START_END

        LCALL M_7SEG_INIT
        LCALL OVEN_COUNTER_INIT

        LCALL OVEN_COUNTER  ; START COUNTER    

        LCALL OVEN_STOP
        LCALL OVEN_BUZZER   ; ACTIVATES BUZZER

    GET_OVEN_END:
        LCALL LCD_CLEAR

        ;LCD STRING DISPLAY
        MOV DPTR, #OVEN_END_MSG
        LCALL LCD_STR_PRINT

        ; PRESS 'ON/C' IN KEYPAD TO START/END
        LCALL OVEN_WAIT_START_END

    GET_OVEN_REPEAT:
        JMP GET_OVEN_READY    ; STRAT OVER
        

    MAIN_END:   LJMP PROG_END;END
; ============== MAIN CODE END ========================



; ============== SUBROUTINE / FUNCTIONS ===============
; OVEN INTEGRATE
OVEN_TASK_GREATER_60:
        JNB OVEN_TIME_GREATER_60_BIT, OVEN_TASK_GREATER_60_RETURN
        MOV A, COUNTER_L1
        RRC A
        JC OVEN_TASK_GREATER_60_RETURN
        LCALL OVEN_PRINT_GREATER_60
    OVEN_TASK_GREATER_60_RETURN:
            RET

OVEN_COUNTER:
    ; SECOND DELAY
    SEC_DELAY_L0:
                MOV R4, #0F0H
        SEC_DELAY_L1:
                    MOV R5, #01H
            SEC_DELAY_L2:
                    MOV R6, #01H
                SEC_DELAY_L3:
                    ; EMERGENCY PAUSE
                    LCALL EMERGENCY_STOP

                    ; 7SEG DISPLAY CODE
                    LCALL COUNTER_DISPLAY_7SEG

                DJNZ R6, SEC_DELAY_L3
            DJNZ R5, SEC_DELAY_L2
        DJNZ R4, SEC_DELAY_L1

        ; CONDITION APPLIED FOR TIME > 60S
        LCALL OVEN_TASK_GREATER_60

    COUNTER_DECREMENT:
        DJNZ COUNTER_L0, OVEN_COUNTER
                MOV COUNTER_L0, #0AH
        DJNZ COUNTER_L1, OVEN_COUNTER
                MOV COUNTER_L1, #0AH
        DJNZ COUNTER_L2, OVEN_COUNTER
                ;MOV COUNTER_L2, #0AH
        RET

EMERGENCY_STOP: 
        JB OVEN_PAUSE_PIN, EMERGENCY_END
        LCALL OVEN_STOP
        LCALL LCD_CLEAR
        LCALL LCD_CURSOR_LINE_1
        ;LCD STRING DISPLAY
        MOV DPTR, #LCD_OVEN_EMERGENCY_STOP
        LCALL LCD_STR_PRINT
        
        LCALL LCD_CURSOR_LINE_2
        ;LCD STRING DISPLAY
        MOV DPTR, #LCD_OVEN_REMAINING_TIME
        LCALL LCD_STR_PRINT
        LCALL OVEN_LCD_TIME_PRINT
    
    ; WAIT
    OVEN_PAUSE: JNB OVEN_PAUSE_PIN, OVEN_PAUSE
                LCALL OVEN_START
                
    EMERGENCY_END:
                RET

OVEN_BUZZER:    
        ; NOT_START & NOT_PAUSE == OVEN_END
        ; NOR(START , PAUSE) == OVEN_END
        CLR OVEN_START_PIN
        CLR OVEN_PAUSE_PIN
        RET

OVEN_INIT:; SETUP OVEN PINS
        CLR OVEN_START_PIN              ; OVEN START PIN AS OUTPUT(0)
        SETB OVEN_PAUSE_PIN             ; OVEN PASUE PIN AS INPUT(1)
        CLR OVEN_TIME_GREATER_60_BIT    ; CLEAR OVEN_TIME_LESS_60 BOOL
        RET

OVEN_CHECK_TIME_60: 
        ; CHECK IF TIME IS GREATER THAN 60 SEC
        MOV A, COUNTER_INPUT_DIGIT_2
        JNZ OVEN_TIME_G_60
        MOV A, COUNTER_INPUT_DIGIT_1
        CLR C
        SUBB A, #06H
        JNC OVEN_TIME_G_60
        CLR OVEN_TIME_GREATER_60_BIT
        RET
    OVEN_TIME_G_60:
        SETB OVEN_TIME_GREATER_60_BIT
        RET

OVEN_LCD_TIME_PRINT:
        MOV A, COUNTER_L2
        DEC A
        LCALL LCD_WRITE_NUMBER
        MOV A, COUNTER_L1
        DEC A
        LCALL LCD_WRITE_NUMBER
        MOV A, COUNTER_L0
        DEC A
        LCALL LCD_WRITE_NUMBER
        RET

OVEN_WAIT_START_END:
        ; PRESS 'ON/C' IN KEYPAD TO START/END
        ; MOV A, #'S'
        ; LCALL LCD_WRITE_DATA
        LCALL KEY_GET_FROM_TABLE
        CJNE A, #'C', OVEN_WAIT_START_END
        LCALL OVEN_START        ; START THE OVEN
        RET

OVEN_START:     
        SETB OVEN_START_PIN     ; START THE OVEN
        LCALL LCD_CLEAR
        LCALL LCD_CURSOR_LINE_1
        ;LCD STRING DISPLAY
        MOV DPTR, #LCD_OVEN_RUNNING
        LCALL LCD_STR_PRINT

        JNB OVEN_TIME_GREATER_60_BIT, NOT_TIME_GREATER_60
        LCALL OVEN_PRINT_GREATER_60
        RET
    NOT_TIME_GREATER_60:
        LCALL LCD_CURSOR_LINE_2
        ;LCD STRING DISPLAY
        MOV DPTR, #LCD_NOT_TIME_G_60_STR
        LCALL LCD_STR_PRINT
        RET

OVEN_PRINT_GREATER_60:
        LCALL LCD_CURSOR_LINE_2
        ;LCD STRING DISPLAY
        MOV DPTR, #TIME_GREATER_60_MSG
        LCALL LCD_STR_PRINT
        
        MOV A, COUNTER_L2
        DEC A
        MOV B, #0AH
        MUL AB
        ADD A, COUNTER_L1
        DEC A
        RRC A
        LCALL LCD_WRITE_NUMBER
        RET

OVEN_STOP :     
        CLR  OVEN_START_PIN     ; STOP  THE OVEN
        RET

OVEN_COUNTER_INIT:
        MOV COUNTER_L2, COUNTER_INPUT_DIGIT_2
        MOV COUNTER_L1, COUNTER_INPUT_DIGIT_1
        MOV COUNTER_L0, COUNTER_INPUT_DIGIT_0
        INC COUNTER_L2
        INC COUNTER_L1
        INC COUNTER_L0
        RET

COUNTER_VALUE_INPUT:  
        ; TAKE INPUT FOR INDEX 2
        LCALL KEY_GET_NUMBER
        MOV COUNTER_INPUT_DIGIT_2 , A
        MOV A, COUNTER_INPUT_DIGIT_2
        LCALL LCD_WRITE_NUMBER

        ; TAKE INPUT FOR INDEX 1
        LCALL KEY_GET_NUMBER
        MOV COUNTER_INPUT_DIGIT_1 , A
        MOV A, COUNTER_INPUT_DIGIT_1
        LCALL LCD_WRITE_NUMBER

        ; TAKE INPUT FOR INDEX 0
        LCALL KEY_GET_NUMBER
        MOV COUNTER_INPUT_DIGIT_0 , A
        MOV A, COUNTER_INPUT_DIGIT_0
        LCALL LCD_WRITE_NUMBER
        RET

COUNTER_DISPLAY_7SEG:
        MOV A, COUNTER_L2
        DEC A
        LCALL M_7SEG_DISP_OUT_2

        MOV A, COUNTER_L1
        DEC A
        LCALL M_7SEG_DISP_OUT_1

        MOV A, COUNTER_L0
        DEC A
        LCALL M_7SEG_DISP_OUT_0
        RET

; FOR LCD
LCD_STR_PRINT:  
        ;MOV DPTR, #LCD_STR
    LCD_STR_PRINT_AGAIN:
        CLR A           ;set A=0 (match found)
        MOVC A, @A+DPTR ;get ASCII code from table
        JZ LSP_END
        LCALL LCD_WRITE_DATA
        INC DPTR
        SJMP LCD_STR_PRINT_AGAIN
    LSP_END:    
        RET


LCD_DELAY:
        MOV LCD_DELAY_L0_ADDRESS, #LCD_DELAY_L0_COUNT
    LCD_DELAY_L0:
        DJNZ LCD_DELAY_L0_ADDRESS, LCD_DELAY_L0        
        RET

LCD_CMD:        
        LCALL LCD_READY     ;send command to LCD
        MOV LCD_P, A        ;copy reg A to port 1
        CLR LCD_RS          ;LCD_RS=0 for command
        CLR LCD_RW          ;R/W=0 for write
        SETB LCD_E          ;LCD_E=1 for high pulse
        LCALL LCD_DELAY     ;give LCD some time
        CLR LCD_E           ;LCD_E=0 for H-to-L pulse
        LCALL LCD_DELAY     ;give LCD some time
        RET


LCD_WRITE_DATA: 
        LCALL LCD_READY     ;write data to LCD
        MOV LCD_P, A        ;copy reg A to port1
        SETB LCD_RS         ;LCD_RS=1 for data
        CLR LCD_RW          ;R/W=0 for write
        SETB LCD_E          ;LCD_E=1 for high pulse
        LCALL LCD_DELAY     ;give LCD some time
        CLR LCD_E           ;LCD_E=0 for H-to-L pulse
        LCALL LCD_DELAY     ;give LCD some time
        RET

LCD_WRITE_NUMBER:  
        LCALL LCD_READY     ;write data to LCD
        ADD A, #30H         ;CONVERT ASCII NUM
        MOV LCD_P, A        ;copy reg A to port1
        SETB LCD_RS         ;LCD_RS=1 for data
        CLR LCD_RW          ;R/W=0 for write
        SETB LCD_E          ;LCD_E=1 for high pulse
        LCALL LCD_DELAY     ;give LCD some time
        CLR LCD_E           ;LCD_E=0 for H-to-L pulse
        LCALL LCD_DELAY     ;give LCD some time
        RET

LCD_READY:      
        SETB LCD_P.7
        CLR LCD_RS
        SETB LCD_RW

    LCD_WAIT:   
        CLR LCD_E
        LCALL LCD_DELAY
        SETB LCD_E
        JB LCD_P.7, LCD_WAIT
        RET

LCD_INIT:       
    MOV A, #38H         ;init. LCD 2 lines, 5x7 matrix
    ACALL LCD_CMD
    LCALL LCD_COFF      ;dispplay on, cursor on
    LCALL LCD_CMD
    RET

LCD_CURSOR_LINE_1:        
    MOV A, #80H         ; CURSOR AT BEGINNING OF LINE 1
    LCALL LCD_CMD
    RET

LCD_CURSOR_LINE_2:        
    MOV A, #0C0H         ; CURSOR AT BEGINNING OF LINE 2
    LCALL LCD_CMD
    RET

LCD_CON:        
    MOV A, #0FH         ; Display on, cursor blinking
    LCALL LCD_CMD
    RET

LCD_COFF:       
    MOV A, #0CH         ; Display on, cursor off
    LCALL LCD_CMD
    RET

LCD_CLEAR:        
    MOV A, #01H         ; Clear Display screen
    LCALL LCD_CMD
    RET

LCD_CD:
    MOV A, #04H         ; Decrement cursor (shift cursor to left)
    LCALL LCD_CMD
    RET

LCD_CI:
    MOV A, #06H         ; Increment cursor (shift cursor to right)
    LCALL LCD_CMD
    RET

LCD_CSL:
    MOV A, #10H         ; Shift cursor position to left
    LCALL LCD_CMD
    RET

LCD_CSR:
    MOV A, #14H         ; Shift cursor position to left
    LCALL LCD_CMD
    RET

; FOR KEYPAD
KEY_GET_NUMBER:
    ; TAKE NUMBER INPUT FROM KEYPAD
    LCALL KEY_GET_FROM_TABLE
    CLR C
    SUBB A, #30H
    RET

KEY_GET_FROM_TABLE:        
        ; TAKE ASCII VALUE INPUT FROM KEYPAD 
        MOV KEYPAD_PORT, #0F0H

        LCALL KEY_CHECK_COL     ; B = COLUMN INDEX
        ;MOV B, A
        LCALL KEY_CHECK_ROW     ; A = ROW INDEX
        PUSH 0F0H
        MOV B, #04H
        MUL AB
        POP 0F0H
        ADD A, B
        MOV DPTR, #KEYPAD_DATA
        MOVC A, @A+DPTR
        RET

KEY_IGNORE_NOISE:
        MOV A, KEYPAD_PORT
        ANL A, #0F0H
        CJNE A, #0F0H, KEY_IGNORE_NOISE_2
        LCALL TIME_DELAY_20MS; DELAY 20MS
    KEY_IGNORE_NOISE_2:
        MOV A, KEYPAD_PORT
        ANL A, #0F0H
        CJNE A, #0F0H, KEY_IGNORE_NOISE_RETURN
        SJMP KEY_IGNORE_NOISE
    KEY_IGNORE_NOISE_RETURN:
        RET

KEY_CHECK_COL:  
        MOV A, KEYPAD_PORT
        ANL A, #0F0H
        CJNE A, #0F0H, KEY_CHECK_SINGLE_PRESS_LABEL
        CLR IS_KEY_SINGLE_PRESS
        JMP KEY_CHECK_COL
    KEY_CHECK_SINGLE_PRESS_LABEL:
        JB IS_KEY_SINGLE_PRESS, KEY_CHECK_COL
    KEY_CHECK_COLUMN_0:  
        MOV B, #00H
        CJNE A, #0E0H, KEY_CHECK_COLUMN_1
        JMP KEY_CHECK_COLUMN_END
    KEY_CHECK_COLUMN_1:  
        INC B
        CJNE A, #0D0H, KEY_CHECK_COLUMN_2
        JMP KEY_CHECK_COLUMN_END
    KEY_CHECK_COLUMN_2:  
        INC B
        CJNE A, #0B0H, KEY_CHECK_COLUMN_3
        JMP KEY_CHECK_COLUMN_END
    KEY_CHECK_COLUMN_3:  
        INC B
        ;CJNE A, #0F7H, KEY_CHECK_COLUMN_END
        ;JMP KEY_CHECK_COLUMN_END
    KEY_CHECK_COLUMN_END:
        SETB IS_KEY_SINGLE_PRESS
        RET

KEY_CHECK_ROW: 
        PUSH 0F0H
    KEY_CHECK_ROW_0:
        MOV B, #00H
        SETB KEYPAD_PORT.0
        MOV A, KEYPAD_PORT
        ANL A, #0F0H
        CJNE A, #0F0H, KEY_CHECK_ROW_1
        JMP KEY_CHECK_ROW_END
    KEY_CHECK_ROW_1:
        INC B
        SETB KEYPAD_PORT.1
        MOV A, KEYPAD_PORT
        ANL A, #0F0H
        CJNE A, #0F0H, KEY_CHECK_ROW_2
        JMP KEY_CHECK_ROW_END
    KEY_CHECK_ROW_2:
        INC B
        SETB KEYPAD_PORT.2
        MOV A, KEYPAD_PORT
        ANL A, #0F0H
        CJNE A, #0F0H, KEY_CHECK_ROW_3
        JMP KEY_CHECK_ROW_END
    KEY_CHECK_ROW_3:
        INC B
        ; SETB KEYPAD_PORT.3
        ; MOV A, KEYPAD_PORT
        ; ANL A, #0F0H
        ; CJNE A, #0F0H, KEY_CHECK_ROW_END
    KEY_CHECK_ROW_END:
        MOV A, B
        POP 0F0H
        RET

; MULTIPLE 7 SEGMENT DISPLAY

M_7SEG_INIT: ; SETUP OUTPUT(0) PORTS FOR 7 SEG DISPLAY
        MOV M_7SEG_DISP_OUT_PORT, #00H

        ; CONDITIONAL DIRECTIVES FOR MULTIPLE 7 SEG DISPLAY
        IF M_7SEG_DISP_DIGITS_NO > 0
            CLR M_7SEG_DISP_DIGITS_0_PIN
        ENDIF
        IF M_7SEG_DISP_DIGITS_NO > 1
            CLR M_7SEG_DISP_DIGITS_1_PIN
        ENDIF
        IF M_7SEG_DISP_DIGITS_NO > 2
            CLR M_7SEG_DISP_DIGITS_2_PIN
        ENDIF
        IF M_7SEG_DISP_DIGITS_NO > 3
            CLR M_7SEG_DISP_DIGITS_3_PIN
        ENDIF
        RET

IF M_7SEG_DISP_DIGITS_NO > 0
M_7SEG_DISP_OUT_0:
        LCALL GET_INDEX_VALUE
        MOV M_7SEG_DISP_OUT_PORT, A
        CPL M_7SEG_DISP_DIGITS_0_PIN
        LCALL TIME_DELAY_1MS
        CPL M_7SEG_DISP_DIGITS_0_PIN
        RET
ENDIF
IF M_7SEG_DISP_DIGITS_NO > 1
M_7SEG_DISP_OUT_1:
        LCALL GET_INDEX_VALUE
        MOV M_7SEG_DISP_OUT_PORT, A
        CPL M_7SEG_DISP_DIGITS_1_PIN
        LCALL TIME_DELAY_1MS
        CPL M_7SEG_DISP_DIGITS_1_PIN
        RET
ENDIF
IF M_7SEG_DISP_DIGITS_NO > 2
M_7SEG_DISP_OUT_2:
        LCALL GET_INDEX_VALUE
        MOV M_7SEG_DISP_OUT_PORT, A
        CPL M_7SEG_DISP_DIGITS_2_PIN
        LCALL TIME_DELAY_1MS
        CPL M_7SEG_DISP_DIGITS_2_PIN
        RET
ENDIF
IF M_7SEG_DISP_DIGITS_NO > 3
M_7SEG_DISP_OUT_3:
        LCALL GET_INDEX_VALUE
        MOV M_7SEG_DISP_OUT_PORT, A
        CPL M_7SEG_DISP_DIGITS_3_PIN
        LCALL TIME_DELAY_1MS
        CPL M_7SEG_DISP_DIGITS_3_PIN
        RET
ENDIF

GET_INDEX_VALUE:
        MOV DPTR, #M_7SEG_ARRAY
        MOVC A, @A+DPTR
        CPL A   ; COMLEMENT IF NEEDED


; TIME CALCULATED DELAY
TIME_DELAY_1MS:
        ; FOR f = 11Hz => T = 12/f = 1.09091us
        ; ==> n = 1ms/T = 916 = 3*L0.L1 + 3*L1 + 2 
        ; ==> L1 = (916 - 2) / ( 3*L0 + 3 )
        ; ==> L1 = 1 & L0 = 255
        MOV TIME_DELAY_L1_COUNT, #1
    TIME_DELAY_1MS_L1:
        MOV TIME_DELAY_L0_COUNT, #255
    TIME_DELAY_1MS_L0:
        DJNZ TIME_DELAY_L0_COUNT, TIME_DELAY_1MS_L0
        DJNZ TIME_DELAY_L1_COUNT, TIME_DELAY_1MS_L1
    RET

TIME_DELAY_20MS:
        ; FOR f = 11Hz => T = 1.09091us
        ; ==> n = 20ms/T = 18333 = 3*L0.L1 + 3*L1 + 2 
        ; ==> L1 = 23 & L0 = 255
        MOV TIME_DELAY_L1_COUNT, #23
    TIME_DELAY_20MS_L1:
        MOV TIME_DELAY_L0_COUNT, #255
    TIME_DELAY_20MS_L0:
        DJNZ TIME_DELAY_L0_COUNT, TIME_DELAY_20MS_L0
        DJNZ TIME_DELAY_L1_COUNT, TIME_DELAY_20MS_L1
    RET

; =================== DATA LOOK UP TABLE =============================
    ; END OF THE STRING HAS TO BE 0
    OVEN_READY_MSG:  
        DB 'O', 'V', 'E', 'N', ' ', 'I', 'S', ' ', 'R', 'E', 'A', 'D', 'Y', '.', 0
        ;NOP
    OVEN_TIMER_MSG:
        DB 'T', 'I', 'M', 'E', 'R', ' ', ':', ' ', 0
        ;NOP
    KEYPAD_DATA:
        DB '7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', 'C', '0', '=', '+' , 0
        ;NOP
    M_7SEG_ARRAY:
        DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH, 77H, 7CH, 39H, 5EH, 79H, 71H, 0
        ;   0 ,  1 ,  2 ,  3 ,  4 ,  5 ,  6 ,  7 ,  8 ,  9 ,  A ,  b ,  C ,  d ,  E ,  F ;
        ;NOP
    OVEN_END_MSG:
        DB 'O', 'V', 'E', 'N', ' ', 'T', 'A', 'S', 'K', ' ', 'D', 'O', 'N', 'E', ' ', '!', 0
    LCD_OVEN_EMERGENCY_STOP:
        DB 'E', 'M', 'E', 'R', 'G', 'E', 'N', 'C', 'Y', ' ', 'S', 'T', 'O', 'P', 0
    LCD_OVEN_REMAINING_TIME:
        DB 'R', 'E', 'M', 'A', 'I', 'N', 'I', 'N', 'G', ' ', ':', ' ', 0
    LCD_OVEN_RUNNING:
        DB 'O', 'V', 'E', 'N', ' ', 'R', 'U', 'N', 'N', 'I', 'N', 'G', 0
    LCD_NOT_TIME_G_60_STR:
        DB 'T', 'I', 'M', 'E', ' ', 'U', 'N', 'D', 'E', 'R', ' ', '6', '0', 's',  0
    TIME_GREATER_60_MSG:
        DB 'T', 'I', 'M', 'E', ' ', '=', '=', ' ', '2', '0', 's', ' ', 'x', ' ',  0

PROG_END:
    END

