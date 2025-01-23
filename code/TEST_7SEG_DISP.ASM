                ORG 0
                ; 7 SEG DISPLAY SETUP
                M_7SEG_DISP_OUT_PORT        EQU     P0
                M_7SEG_DISP_INDEX_0         EQU     50H
                ; NUMBER OF DISPLAY WILL BE USED
                M_7SEG_DISP_DIGITS_NO       EQU     4

                IF M_7SEG_DISP_DIGITS_NO > 0
                M_7SEG_DISP_DIGITS_0_PORT   EQU     P1.0
                ENDIF
                IF M_7SEG_DISP_DIGITS_NO > 1
                M_7SEG_DISP_DIGITS_1_PORT   EQU     P1.1
                ENDIF
                IF M_7SEG_DISP_DIGITS_NO > 2
                M_7SEG_DISP_DIGITS_2_PORT   EQU     P1.2
                ENDIF
                IF M_7SEG_DISP_DIGITS_NO > 3
                M_7SEG_DISP_DIGITS_3_PORT   EQU     P1.3
                ENDIF

                M_7SEG_DELAY_L0_LOC         EQU     63H
                M_7SEG_DELAY_L1_LOC         EQU     64H
                M_7SEG_DELAY_L2_LOC         EQU     65H

                M_7SEG_DELAY_L0_COUNT       EQU     0FFH
                M_7SEG_DELAY_L1_COUNT       EQU     04H
                M_7SEG_DELAY_L2_COUNT       EQU     01H


                MOV SP, #70H
                MOV PSW, #00H



; ============== MAIN CODE START =====================
MAIN:           ; MAIN CODE START
                LCALL M_7SEG_INIT

                MOV R2, #00H
                MOV R3, #20H
    LOOP:           
                MOV A, R2
                IF M_7SEG_DISP_DIGITS_NO > 3
                LCALL M_7SEG_DISP_OUT_3
                ENDIF

                MOV A, R2
                ADD A, #01H
                IF M_7SEG_DISP_DIGITS_NO > 2
                LCALL M_7SEG_DISP_OUT_2
                ENDIF
                
                MOV A, R2
                ADD A, #02H
                IF M_7SEG_DISP_DIGITS_NO > 1
                LCALL M_7SEG_DISP_OUT_1
                ENDIF

                MOV A, R2
                ADD A, #03H
                IF M_7SEG_DISP_DIGITS_NO > 0
                LCALL M_7SEG_DISP_OUT_0
                ENDIF

                DJNZ R3, LOOP
                INC R2
                CJNE R2, #10H, LOOP
                MOV R2, #00H
                JMP LOOP

    IC_HOLD:    JMP IC_HOLD
    MAIN_END:   LJMP PROG_END;END
; ============== MAIN CODE END ========================



; ============== SUBROUTINE / FUNCTIONS ===============

; MULTIPLE 7 SEGMENT DISPLAY

M_7SEG_INIT:    ; SETUP OUTPUT(0) PORTS FOR 7 SEG DISPLAY
                MOV M_7SEG_DISP_OUT_PORT, #00H

                IF M_7SEG_DISP_DIGITS_NO > 0
                CLR M_7SEG_DISP_DIGITS_0_PORT
                ENDIF
                IF M_7SEG_DISP_DIGITS_NO > 1
                CLR M_7SEG_DISP_DIGITS_1_PORT
                ENDIF
                IF M_7SEG_DISP_DIGITS_NO > 2
                CLR M_7SEG_DISP_DIGITS_2_PORT
                ENDIF
                IF M_7SEG_DISP_DIGITS_NO > 3
                CLR M_7SEG_DISP_DIGITS_3_PORT
                ENDIF
                RET

IF M_7SEG_DISP_DIGITS_NO > 0
M_7SEG_DISP_OUT_0:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_0_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_0_PORT
                RET
ENDIF
IF M_7SEG_DISP_DIGITS_NO > 1
M_7SEG_DISP_OUT_1:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_1_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_1_PORT
                RET
ENDIF
IF M_7SEG_DISP_DIGITS_NO > 2
M_7SEG_DISP_OUT_2:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_2_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_2_PORT
                RET
ENDIF
IF M_7SEG_DISP_DIGITS_NO > 3
M_7SEG_DISP_OUT_3:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_3_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_3_PORT
                RET
ENDIF

GET_INDEX_VALUE:
                MOV DPTR, #M_7SEG_ARRAY
                MOVC A, @A+DPTR
                CPL A   ; COMLEMENT IF NEEDED
                
M_7SEG_DELAY:
                NOP
                NOP
                NOP
                MOV M_7SEG_DELAY_L0_LOC, #M_7SEG_DELAY_L0_COUNT
    M_7SEG_DELAY_L0:
                MOV M_7SEG_DELAY_L1_LOC, #M_7SEG_DELAY_L1_COUNT
    M_7SEG_DELAY_L1:
                MOV M_7SEG_DELAY_L2_LOC, #M_7SEG_DELAY_L2_COUNT
    M_7SEG_DELAY_L2:
                DJNZ M_7SEG_DELAY_L2_LOC, M_7SEG_DELAY_L2
                DJNZ M_7SEG_DELAY_L1_LOC, M_7SEG_DELAY_L1
                DJNZ M_7SEG_DELAY_L0_LOC, M_7SEG_DELAY_L0
                RET



; =================== DATA LOOK UP TABLE =============================
    ; END OF THE STRING HAS TO BE 0
    M_7SEG_ARRAY:
                DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH, 77H, 7CH, 39H, 5EH, 79H, 71H, 0
                ;   0 ,  1 ,  2 ,  3 ,  4 ,  5 ,  6 ,  7 ,  8 ,  9 ,  A ,  b ,  C ,  d ,  E ,  F ;


PROG_END:
                END

