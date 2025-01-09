                ORG 0
                ; DISPLAY SETUP
                RS EQU P3.5
                RW EQU P3.6
                E EQU P3.7
                LCD_P EQU P0

                MOV SP, #70H
                MOV PSW, #00H

                ; CLOCK SETUP
                HH EQU R3
                MM EQU R4
                SS EQU R5
                CLOCK_REG_START EQU 03H

                REG_DELAY_COUNTER       EQU R7
                REG_DELAY_TIME          EQU 255D
                REG_DELAY_COUNTER_MUL   EQU R6
                REG_DELAY_TIME_MUL      EQU 05D

                LCD_DELAY_TIME_L EQU 0F5H
                LCD_DELAY_TIME_H EQU 0FFH
;                 LCD_DELAY_TIME_H EQU 0CEH

                ; DELAY
                DELAY_TIME_L    EQU 60H
                DELAY_TIME_H    EQU 61H

                ; TIMER
                SEC_DELAY_MUL EQU 2D
                SEC_DELAY_LT EQU 00H
                SEC_DELAY_HT EQU 0FFH
                MOV TMOD, #11H


                MOV HH, #00H
                MOV MM, #00H
                MOV SS, #00H

; ============== MAIN CODE START =====================
MAIN:           ; MAIN CODE START
                LCALL LCD_INIT
    WHILE:
                LCALL CLOCK
;                 LCALL LCD_CSR
;                 LCALL LCD_CI
;                 MOV A, #31H
;                 LCALL LCD_WRITE_DATA
                LCALL LCD_CL1
                LCALL DISP_CLOCK

                ; ALARM
                LCALL LCD_CL2
                MOV DPTR, #ALARM_STR
                LCALL LCD_STR_PRINT



                SJMP WHILE

    MAIN_END:   ;END
; ============== MAIN CODE END ========================



; ============== SUBROUTINE / FUNCTIONS ===============

LCD_STR_PRINT:  ;
                ;MOV DPTR, #ALARM_STR
    LSP_AGAIN:
                CLR A ;set A=0 (match found)
                MOVC A, @A+DPTR ;get ASCII code from table
                JZ LSP_END
                LCALL LCD_WRITE_DATA
                INC DPTR
                SJMP LSP_AGAIN
    LSP_END:    RET

DISP_CLOCK:     ;

                MOV 65H, #03                ; DISP 3 TIMES FOR (HH, MM, SS)
                MOV R0, #CLOCK_REG_START
    DC_AGAIN:   ;
                MOV A, @R0
                LCALL A2DEC
                ADD A, #30H
                LCALL LCD_WRITE_DATA
                MOV A, B
                ADD A, #30H
                LCALL LCD_WRITE_DATA

                MOV A, #':'
                LCALL LCD_WRITE_DATA

                INC R0
                DJNZ 65H, DC_AGAIN

;                 MOV A, HH
;                 LCALL A2DEC
;                 LCALL LCD_WRITE_DATA
;                 MOV A, B
;                 LCALL LCD_WRITE_DATA
                RET





; DISP_CLOCK:     LCALL
LCD_DELAY:      MOV DELAY_TIME_L, #LCD_DELAY_TIME_L
                MOV DELAY_TIME_H, #LCD_DELAY_TIME_H
                LCALL DELAY
                RET

CLOCK:
                MOV A, SS
;                 LCALL A2DEC

                LCALL SEC_DELAY
                INC SS         ; RUNNING CLOCK

                ; SECOND ROTATION
                CJNE SS, #60D, CLOCK_END
                MOV SS, #00H
                INC MM

                ; MINUTE ROTATION
                CJNE MM, #60D, CLOCK_END
                MOV MM, #00H
                INC HH

                ; HOUR ROTATION
                CJNE HH, #12, CLOCK_END
                MOV HH, #00H

    CLOCK_END:  NOP
                RET





SEC_DELAY:      ; TIMER SETUP (TIMER-0 & MODE-1)
                ; FREQ = 11.0592 MHz
                ; T    =
;                 MOV DELAY_COUNTER, 10
                MOV REG_DELAY_COUNTER_MUL, #SEC_DELAY_MUL
    SD_AGAIN:
                MOV TL0, #SEC_DELAY_LT
                MOV TH0, #SEC_DELAY_HT
                SETB TR0
    CD_AGAIN:   JNB TF0, CD_AGAIN
                CLR TR0
                CLR TF0
                DJNZ REG_DELAY_COUNTER_MUL, SD_AGAIN
                RET

DELAY:          ; GENERAL DELAY FUNCTION (INPUT DELAY_TIME_H, DELAY_TIME_L)
                MOV TL0, DELAY_TIME_L
                MOV TH0, DELAY_TIME_H
                SETB TR0
    D_AGAIN:    JNB TF0, D_AGAIN
                CLR TR0
                CLR TF0
                RET

A2DEC:          ; HEX NUM IN A
                MOV B, #10D         ; BASE OF DEC
                DIV AB
;                 MOV @R0, B          ; DEC = REMAINDER (B)
                PUSH 0F0H           ; PUSH REMAINDER (B) TO STACK
                MOV B, #10D         ; BASE OF DEC
                DIV AB
                MOV A, B            ; (DEC_H)
                POP 0F0H            ; POP STACK TO B (DEC_L)
                RET

LCD_CMD:        LCALL LCD_READY     ;send command to LCD
                MOV LCD_P, A        ;copy reg A to port 1
                CLR RS              ;RS=0 for command
                CLR RW              ;R/W=0 for write
                SETB E              ;E-1 for high pulse
                LCALL LCD_DELAY     ;give LCD some time
;                 LCALL REG_DELAY     ;give LCD some time
                CLR E               ;E=0 for H-to-L pulse
                LCALL LCD_DELAY     ;give LCD some time

                RET


LCD_WRITE_DATA: LCALL LCD_READY     ;write data to LCD
                MOV LCD_P, A        ;copy reg A to port1
                SETB RS             ;RS=1 for data
                CLR RW              ;R/W=0 for write
                SETB E              ;E=1 for high pulse
                LCALL LCD_DELAY     ;give LCD some time
;                 LCALL REG_DELAY     ;give LCD some time
                CLR E               ;E=0 for H-to-L pulse
                LCALL LCD_DELAY     ;give LCD some time
                RET

LCD_READY:      SETB LCD_P.7
                CLR RS
                SETB RW

    LCD_WAIT:   CLR E
                LCALL LCD_DELAY
;                 LCALL REG_DELAY     ;give LCD some time
                SETB E
;                 ;==
; 		CLR LCD_P.7
;                 ;==
                JB LCD_P.7, LCD_WAIT
                RET

LCD_INIT:       MOV A, #38H         ;init. LCD 2 lines, 5x7 matrix
                ACALL LCD_CMD

                LCALL LCD_COFF         ;dispplay on, cursor on

                LCALL LCD_CMD

;                 LCALL LCD_CLR

;                 LCALL LCD_CI
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

REG_DELAY:
                MOV REG_DELAY_COUNTER_MUL, #REG_DELAY_TIME_MUL
    REG_AGAIN1: MOV REG_DELAY_COUNTER, #REG_DELAY_TIME_MUL
    REG_AGAIN2: DJNZ REG_DELAY_COUNTER, REG_AGAIN2
                DJNZ REG_DELAY_COUNTER_MUL, REG_AGAIN1
                RET

; =================== DATA LOOK UP TABLE =============================
    ORG 300H
    ; END OF THE STRING HAS TO BE 0
    ALARM_STR:  DB 'A', 'L', 'A', 'R', 'M', ' ', ':', 0
                NOP

                END

