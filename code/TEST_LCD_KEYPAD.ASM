                ORG 0
                ; DISPLAY SETUP
                LCD_P EQU P2
                LCD_RS EQU P1.4
                LCD_RW EQU P1.5
                LCD_E EQU P1.6

                LCD_DELAY_L0_LOC EQU 6FH
                ;LCD_DELAY_L1_LOC EQU 6EH

                ; LCD DELAY
                LCD_DELAY_L0_COUNT    EQU 22H
                ;LCD_DELAY_L1_COUNT    EQU 10H

                ; KEYPAD SETUP
                KEY_SINGLE_PRESS    EQU     7FH   ; 
                KEYPAD_P            EQU     P3    ; PORT = C(7654)R(3210)




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
    KEY_AGAIN:
                LCALL KEY_GET
                LCALL LCD_WRITE_DATA
                JMP KEY_AGAIN



    IC_HOLD:    JMP IC_HOLD
    MAIN_END:   LJMP PROG_END;END
; ============== MAIN CODE END ========================



; ============== SUBROUTINE / FUNCTIONS ===============
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


LCD_DELAY:      ;PUSH LCD_DELAY_L0_LOC
                ;PUSH LCD_DELAY_L1_LOC
                MOV LCD_DELAY_L0_LOC, #LCD_DELAY_L0_COUNT
    LCD_DELAY_L0:  
    ;             MOV LCD_DELAY_L1_LOC, #LCD_DELAY_L1_COUNT
    ; LCD_DELAY_L1:  
    ;             DJNZ LCD_DELAY_L1_LOC, LCD_DELAY_L1
                DJNZ LCD_DELAY_L0_LOC, LCD_DELAY_L0
                ;POP LCD_DELAY_L1_LOC
                ;POP LCD_DELAY_L0_LOC
                
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
                LCALL LCD_COFF      ;dispplay on, cursor on
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

KEY_GET:       MOV KEYPAD_P, #0F0H
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



; =================== DATA LOOK UP TABLE =============================
    ; END OF THE STRING HAS TO BE 0
    LCD_STR:  DB 'L', 'C', 'D', ' ', 'D', 'I', 'S', 'P', 'L', 'A', 'Y', ' ', 'S', 'T', 'R', ' ', '.', 0
                NOP
    KEYPAD_DATA:
               DB '7', '8', '9', '/', '4', '5', '6', '*', '1', '2', '3', '-', 'C', '0', '=', '+' , 0
               NOP


PROG_END:
                END

