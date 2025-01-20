                ORG 0
                ; DISPLAY SETUP
                LCD_P EQU P2
                LCD_RS EQU P1.4
                LCD_RW EQU P1.5
                LCD_E EQU P1.6

                LCD_D_REG_2 EQU 055H
                LCD_D_REG_1 EQU 056H

                ; LCD DELAY
                LCD_DELAY_2    EQU 05H
                LCD_DELAY_1    EQU 10H

                ; KEYPAD SETUP
                KEY_SINGLE_PRESS    EQU     7FH   ; 
                KEYPAD_P            EQU     P3    ; PORT = C(7654)R(3210)

                ; 7 SEG DISPLAY SETUP
                M_7SEG_DISP_OUT_PORT        EQU     P0
                M_7SEG_DISP_INDEX_0         EQU     50H

                M_7SEG_DISP_DIGITS_NO       EQU     04H
                M_7SEG_DISP_DIGITS_0_PORT   EQU     P1.0
                M_7SEG_DISP_DIGITS_1_PORT   EQU     P1.1
                M_7SEG_DISP_DIGITS_2_PORT   EQU     P1.2
                ; M_7SEG_DISP_DIGITS_3_PORT   EQU     P1.3

                ; COUNTER SETUP
                COUNTER_ADDR_IN_0       EQU 60H
                COUNTER_ADDR_IN_1       EQU 61H
                COUNTER_ADDR_IN_2       EQU 62H
                COUNTER_ADDR_REG     EQU R1
                COUNTER_DIGIT_NO    EQU 03H
                COUNTER_DIGIT_REG   EQU R3

                SEC_DELAY_REG       EQU R7

                ; OVEN SETUP
                OVEN_START_PIN      EQU P1.3
                OVEN_PAUSE_PIN      EQU P1.7

                CLR OVEN_START_PIN
                CLR OVEN_PAUSE_PIN

                SETB M_7SEG_DISP_DIGITS_0_PORT
                CLR M_7SEG_DISP_DIGITS_1_PORT
                CLR M_7SEG_DISP_DIGITS_2_PORT


                MOV SP, #70H
                MOV PSW, #00H



; ============== MAIN CODE START =====================
MAIN:           ; MAIN CODE START
                LCALL LCD_INIT
                LCALL LCD_CSR
                LCALL LCD_CI

                ; LCD STRING DISPLAY
                MOV DPTR, #LCD_STR
                LCALL LCD_STR_PRINT

                LCALL LCD_CL2

                CLR KEY_SINGLE_PRESS

                ; MOV COUNTER_DIGIT_REG, #COUNTER_DIGIT_NO
                ; MOV COUNTER_ADDR_REG, #COUNTER_ADDR
    ; KEY_AGAIN:
    ;             LCALL KEY_GET
    ;             CLR C
    ;             SUBB A, #30H
    ;             MOV @COUNTER_ADDR_REG, A

    ;             ;LCALL LCD_WRITE_DATA
    ;             ; JMP KEY_AGAIN

    ;             MOV A, @COUNTER_ADDR_REG
    ;             LCALL LCD_WRITE_NUM
                
    ;             INC COUNTER_ADDR_REG

    ;             DJNZ COUNTER_DIGIT_REG, KEY_AGAIN
                
                LCALL COUNTER_INPUT

    OVEN_WAIT_START:
                JNB OVEN_START_PIN, OVEN_WAIT_START

    MOV A, #'S'
    LCALL LCD_WRITE_DATA

    ; SECOND DELAY
    MOV SEC_DELAY_REG, #62H
    SEC_DELAY_L0:
                MOV R4, #0FFH
    SEC_DELAY_L1:
                MOV R5, #0FFH
        SEC_DELAY_L2:
                MOV R6, #0FFH
            SEC_DELAY_L3:
                
                MOV A, #'C'
                LCALL LCD_WRITE_DATA

                ; 7SEG DISPLAY CODE
                LCALL COUNTER_DISPLAY_7SEG
                
                MOV A, #'D'
                LCALL LCD_WRITE_DATA
                
                ; EMERGENCY PAUSE
                LCALL EMERGENCY_STOP
            ; EMERGENCY_PAUSE:
            ;     MOV A, #'E'
            ;     LCALL LCD_WRITE_DATA

            ;     JNB OVEN_PAUSE_PIN, EMERGENCY_PAUSE

                DJNZ R6, SEC_DELAY_L3
                DJNZ R5, SEC_DELAY_L2
                DJNZ R4, SEC_DELAY_L1

                DJNZ SEC_DELAY_REG, SEC_DELAY_L0

    LCALL LCD_CLR
    LCALL LCD_CSR
    LCALL LCD_CI

    ; LCD STRING DISPLAY
    MOV DPTR, #LCD_END_STR
    LCALL LCD_STR_PRINT


    IC_HOLD:    JMP IC_HOLD
    MAIN_END:   LJMP PROG_END;END
; ============== MAIN CODE END ========================



; ============== SUBROUTINE / FUNCTIONS ===============

; OVEN INTEGRATE
EMERGENCY_STOP:
                ;MOV A, #'E'
                ;LCALL LCD_WRITE_DATA
                JB OVEN_PAUSE_PIN, EMERGENCY_STOP
                RET

COUNTER_INPUT:
                ; TAKE INPUT AS INDEX 2
                LCALL KEY_GET_NUM
                MOV COUNTER_ADDR_IN_2 , A
                MOV A, COUNTER_ADDR_IN_2
                LCALL LCD_WRITE_NUM
                
                ; TAKE INPUT AS INDEX 1
                LCALL KEY_GET_NUM
                MOV COUNTER_ADDR_IN_1 , A
                MOV A, COUNTER_ADDR_IN_1
                LCALL LCD_WRITE_NUM

                ; TAKE INPUT AS INDEX 0
                LCALL KEY_GET_NUM
                MOV COUNTER_ADDR_IN_0 , A
                MOV A, COUNTER_ADDR_IN_0
                LCALL LCD_WRITE_NUM
                RET

COUNTER_DISPLAY_7SEG:
            
                ; LCALL LCD_CLR
                ; LCALL LCD_CI
                
                ; MOV A, COUNTER_ADDR_IN_2
                ; LCALL LCD_WRITE_NUM

                ; MOV COUNTER_ADDR_REG, COUNTER_ADDR
                MOV A, COUNTER_ADDR_IN_2
                LCALL M_7SEG_DISP_OUT_2

                ;MOV A, #'2'
                ;LCALL LCD_WRITE_DATA

                ; INC COUNTER_ADDR_REG
                
                ; MOV A, @COUNTER_ADDR_REG
                ; LCALL LCD_WRITE_NUM

                MOV A, COUNTER_ADDR_IN_1
                LCALL M_7SEG_DISP_OUT_1

                ;MOV A, #'1'
                ;LCALL LCD_WRITE_DATA

                ; INC COUNTER_ADDR_REG

                ; MOV A, @COUNTER_ADDR_REG
                ; LCALL LCD_WRITE_NUM

                MOV A, COUNTER_ADDR_IN_0
                LCALL M_7SEG_DISP_OUT_0

                ;MOV A, #'0'
                ;LCALL LCD_WRITE_DATA

                ; MOV A, #'C'
                ; LCALL LCD_WRITE_DATA
                RET



; FOR LCD
LCD_STR_PRINT:  ;MOV DPTR, #LCD_STR
    LSP_AGAIN:
                CLR A ;set A=0 (match found)
                MOVC A, @A+DPTR ;get ASCII code from table
                JZ LSP_END
                LCALL LCD_WRITE_DATA
                INC DPTR
                SJMP LSP_AGAIN
    LSP_END:    RET


LCD_DELAY:      PUSH LCD_D_REG_2
                PUSH LCD_D_REG_1
                MOV LCD_D_REG_2, #LCD_DELAY_2
    LCD_D_A_1:  MOV LCD_D_REG_1, #LCD_DELAY_1
    LCD_D_A_2:  DJNZ LCD_D_REG_1, LCD_D_A_2
                DJNZ LCD_D_REG_2, LCD_D_A_1
                POP LCD_D_REG_1
                POP LCD_D_REG_2
                RET

LCD_CMD:        LCALL LCD_READY     ;send command to LCD
                MOV LCD_P, A        ;copy reg A to port 1
                CLR LCD_RS              ;LCD_RS=0 for command
                CLR LCD_RW              ;R/W=0 for write
                SETB LCD_E              ;LCD_E=1 for high pulse
                LCALL LCD_DELAY     ;give LCD some time
                CLR LCD_E               ;LCD_E=0 for H-to-L pulse
                LCALL LCD_DELAY     ;give LCD some time
                RET


LCD_WRITE_DATA: LCALL LCD_READY     ;write data to LCD
                MOV LCD_P, A        ;copy reg A to port1
                SETB LCD_RS             ;LCD_RS=1 for data
                CLR LCD_RW              ;R/W=0 for write
                SETB LCD_E              ;LCD_E=1 for high pulse
                LCALL LCD_DELAY     ;give LCD some time
;                 LCALL REG_DELAY     ;give LCD some time
                CLR LCD_E               ;LCD_E=0 for H-to-L pulse
                LCALL LCD_DELAY     ;give LCD some time
                RET

LCD_WRITE_NUM:  LCALL LCD_READY     ;write data to LCD
                ADD A, #30H         ; CONVERT ASCII NUM
                MOV LCD_P, A        ;copy reg A to port1
                SETB LCD_RS             ;LCD_RS=1 for data
                CLR LCD_RW              ;R/W=0 for write
                SETB LCD_E              ;LCD_E=1 for high pulse
                LCALL LCD_DELAY     ;give LCD some time
;                 LCALL REG_DELAY     ;give LCD some time
                CLR LCD_E               ;LCD_E=0 for H-to-L pulse
                LCALL LCD_DELAY     ;give LCD some time
                RET

LCD_READY:      SETB LCD_P.7
                CLR LCD_RS
                SETB LCD_RW

    LCD_WAIT:   CLR LCD_E
                LCALL LCD_DELAY
                SETB LCD_E
                JB LCD_P.7, LCD_WAIT
                RET

LCD_INIT:       MOV A, #38H         ;init. LCD 2 lines, 5x7 matrix
                ACALL LCD_CMD
                LCALL LCD_COFF         ;dispplay on, cursor on
                LCALL LCD_CMD
                RET

LCD_CL1:        MOV A, #80H         ; CURSOR AT BEGINNING OF LINE 1
                LCALL LCD_CMD
                RET

LCD_CL2:        MOV A, #0C0H         ; CURSOR AT BEGINNING OF LINE 2
                LCALL LCD_CMD
                RET

LCD_CON:        MOV A, #0FH         ; Display on, cursor blinking
                LCALL LCD_CMD
                RET

LCD_COFF:       MOV A, #0CH         ; Display on, cursor off
                LCALL LCD_CMD
                RET

LCD_CLR:        MOV A, #01H         ; Clear Display screen
                LCALL LCD_CMD
                RET

LCD_CD:         MOV A, #04H         ; Decrement cursor (shift cursor to left)
                LCALL LCD_CMD
                RET

LCD_CI:         MOV A, #06H         ; Increment cursor (shift cursor to right)
                LCALL LCD_CMD
                RET

LCD_CSL:        MOV A, #10H         ; Shift cursor position to left
                LCALL LCD_CMD
                RET

LCD_CSR:        MOV A, #14H         ; Shift cursor position to left
                LCALL LCD_CMD
                RET

; FOR KEYPAD
KEY_GET_NUM:
                LCALL KEY_GET
                CLR C
                SUBB A, #30H
                RET

KEY_GET:        
                MOV KEYPAD_P, #0F0H
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
      ; END KEY_GET

KEY_CHECK_COL:  MOV A, KEYPAD_P
                ANL A, #0F0H
                CJNE A, #0F0H, KEY_CHECK_SINGLE_PRESS
                CLR KEY_SINGLE_PRESS
                JMP KEY_CHECK_COL
    KEY_CHECK_SINGLE_PRESS:
                JB KEY_SINGLE_PRESS, KEY_CHECK_COL
    KEY_CHC_0:  MOV B, #00H
                CJNE A, #0E0H, KEY_CHC_1
                JMP KEY_CHC_END
    KEY_CHC_1:  
                INC B
                CJNE A, #0D0H, KEY_CHC_2
                JMP KEY_CHC_END
    KEY_CHC_2:  
                INC B
                CJNE A, #0B0H, KEY_CHC_3
                JMP KEY_CHC_END
    KEY_CHC_3:  
                INC B
                ;CJNE A, #0F7H, KEY_CHC_END
                ;JMP KEY_CHC_END
    KEY_CHC_END:
                SETB KEY_SINGLE_PRESS
                RET

KEY_CHECK_ROW: PUSH 0F0H
    KEY_CHR_0:
               MOV B, #00H
               SETB KEYPAD_P.0
               MOV A, KEYPAD_P
               ANL A, #0F0H
               CJNE A, #0F0H, KEY_CHR_1
               JMP KEY_CHR_END
    KEY_CHR_1:
               INC B
               SETB KEYPAD_P.1
               MOV A, KEYPAD_P
               ANL A, #0F0H
               CJNE A, #0F0H, KEY_CHR_2
               JMP KEY_CHR_END
    KEY_CHR_2:
               INC B
               SETB KEYPAD_P.2
               MOV A, KEYPAD_P
               ANL A, #0F0H
               CJNE A, #0F0H, KEY_CHR_3
               JMP KEY_CHR_END
    KEY_CHR_3:
               INC B
               ; SETB KEYPAD_P.3
               ; MOV A, KEYPAD_P
               ; ANL A, #0F0H
               ; CJNE A, #0F0H, KEY_CHR_END
    KEY_CHR_END:
                MOV A, B
                POP 0F0H
                RET

; MULTIPLE 7 SEGMENT DISPLAY
M_7SEG_DISP_OUT_0:
                ;MOV A, #'i'
                ;LCALL LCD_WRITE_DATA

                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A


                ;MOV A, #'I'
                ;LCALL LCD_WRITE_DATA


                CPL M_7SEG_DISP_DIGITS_0_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_0_PORT

                ;MOV A, #'i'
                ;LCALL LCD_WRITE_DATA

                RET
                
M_7SEG_DISP_OUT_1:
                ;MOV A, #'o'
                ;LCALL LCD_WRITE_DATA

                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A

                ;MOV A, #'O'
                ;LCALL LCD_WRITE_DATA

                CPL M_7SEG_DISP_DIGITS_1_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_1_PORT

                ;MOV A, #'o'
                ;LCALL LCD_WRITE_DATA
                RET

M_7SEG_DISP_OUT_2:
                

                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A


                CPL M_7SEG_DISP_DIGITS_2_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_2_PORT

                

                RET

; M_7SEG_DISP_OUT_3:
;                 LCALL GET_INDEX_VALUE
;                 MOV M_7SEG_DISP_OUT_PORT, A
;                 CPL M_7SEG_DISP_DIGITS_3_PORT
;                 LCALL M_7SEG_DELAY
;                 CPL M_7SEG_DISP_DIGITS_3_PORT
;                 RET

GET_INDEX_VALUE:
                MOV DPTR, #M_7SEG_ARRAY
                MOVC A, @A+DPTR
                ; COMLEMENT IF NEEDED
                CPL A
                
M_7SEG_DELAY:
                NOP
                NOP
                NOP
    ;             MOV R3, #0FFH
    ; M_7SEG_DELAY_AGAIN:
    ;             NOP
    ;             DJNZ R3, M_7SEG_DELAY_AGAIN
                RET

; =================== DATA LOOK UP TABLE =============================
    ; END OF THE STRING HAS TO BE 0
    LCD_STR:  
                DB 'L', 'C', 'D', ' ', 'D', 'I', 'S', 'P', 'L', 'A', 'Y', ' ', 'S', 'T', 'R', ' ', '.', 0

    LCD_END_STR:
                DB 'O', 'V', 'E', 'N', ' ', 'T', 'A', 'S', 'K', ' ', 'D', 'O', 'N', 'E', ' ', '!', 0

    KEYPAD_DATA:
                DB '7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', 'C', '0', '=', '+' , 0

    M_7SEG_ARRAY:
                DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH, 6FH, 6FH, 6FH, 6FH, 6FH, 0


PROG_END:
                END

