                ORG 0
                ; 7 SEG DISPLAY SETUP
                M_7SEG_DISP_OUT_PORT        EQU     P0
                M_7SEG_DISP_INDEX_0         EQU     50H

                M_7SEG_DISP_DIGITS_NO       EQU     04H
                M_7SEG_DISP_DIGITS_0_PORT   EQU     P1.0
                M_7SEG_DISP_DIGITS_1_PORT   EQU     P1.1
                M_7SEG_DISP_DIGITS_2_PORT   EQU     P1.2
                M_7SEG_DISP_DIGITS_3_PORT   EQU     P1.3


                MOV SP, #70H
                MOV PSW, #00H



; ============== MAIN CODE START =====================
MAIN:           ; MAIN CODE START
                SETB M_7SEG_DISP_DIGITS_0_PORT
                SETB M_7SEG_DISP_DIGITS_1_PORT
                SETB M_7SEG_DISP_DIGITS_2_PORT
                SETB M_7SEG_DISP_DIGITS_3_PORT
                
                MOV R2, #00H
    LOOP:           
                MOV A, R2
                LCALL M_7SEG_DISP_OUT_3
                INC R2

                MOV A, R2
                LCALL M_7SEG_DISP_OUT_2
                INC R2
                
                MOV A, R2
                LCALL M_7SEG_DISP_OUT_1
                INC R2

                MOV A, R2
                LCALL M_7SEG_DISP_OUT_0
                INC R2

                ;CJNE R2, #0AH, LOOP
                ;MOV R2, #00H
                MOV A, R2
                ANL A, #0FH
                MOV R2, A

                JMP LOOP

    IC_HOLD:    JMP IC_HOLD
    MAIN_END:   LJMP PROG_END;END
; ============== MAIN CODE END ========================



; ============== SUBROUTINE / FUNCTIONS ===============



M_7SEG_DISP_OUT_0:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_0_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_0_PORT
                RET
                
M_7SEG_DISP_OUT_1:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_1_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_1_PORT
                RET

M_7SEG_DISP_OUT_2:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_2_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_2_PORT
                RET

M_7SEG_DISP_OUT_3:
                LCALL GET_INDEX_VALUE
                MOV M_7SEG_DISP_OUT_PORT, A
                CPL M_7SEG_DISP_DIGITS_3_PORT
                LCALL M_7SEG_DELAY
                CPL M_7SEG_DISP_DIGITS_3_PORT
                RET

GET_INDEX_VALUE:
                MOV DPTR, #M_7SEG_ARRAY
                MOVC A, @A+DPTR
                ; COMLEMENT IF NEEDED
                CPL A
                
M_7SEG_DELAY:
                NOP
                MOV R3, #0FFH
    M_7SEG_DELAY_AGAIN:
                NOP
                DJNZ R3, M_7SEG_DELAY_AGAIN
                RET




; =================== DATA LOOK UP TABLE =============================
    ; END OF THE STRING HAS TO BE 0
    M_7SEG_ARRAY:
                DB 3FH, 06H, 5BH, 4FH, 66H, 6DH, 7DH, 07H, 7FH, 6FH, 6FH, 6FH, 6FH, 6FH, 6FH, 0


PROG_END:
                END

