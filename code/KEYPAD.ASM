   ORG  00H 
   RS  EQU P1.5
   EN EQU P1.6
   KP_PORT EQU P3 
   
   MOV  SP, #70H 
   MOV  PSW, #00H
   
LCD_IN:  MOV  A, #38H   ;init. LCD 2 lines, 5x7 matrix 
   ACALL COMNWRT   ;call command subroutine 
   ACALL  DELAY   ;give LCD some time 
   MOV   A, #0FH   ;dispplay on, cursor on 
   ACALL COMNWRT   ;call command subroutine 
   ACALL  DELAY   ;give LCD some time 
   MOV  A, #01    ;clear LCD 
   ACALL COMNWRT   ;call command subroutine 
   ACALL  DELAY   ;give LCD some time 
   MOV  A, #06H   ;shift cursor right 
   ACALL COMNWRT   ;call command subroutine 
   ACALL  DELAY   ;give LCD some time 
   MOV  A, #80H   ;cursor at line 1 postion 4 
   ACALL COMNWRT   ;call command subroutine 
   ACALL  DELAY   ;give LCD some time
   LJMP KEYBOARD_STARTS
   
   
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Keyboard starts;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
KEYBOARD_STARTS:MOV KP_PORT,#0FH
K1:CLR KP_PORT.7
   CLR KP_PORT.6
   CLR KP_PORT.5
   CLR KP_PORT.4
   MOV A,KP_PORT
   ANL A,#00001111B
   CJNE A,#00001111B,K1
   
;CONFIGURING PUSH BUTTONS     
K2:JNB P2.3,POW_PUSH_INTER; IF POWER PUSH BUTTON IS PRESSED
   JNB P2.4,PRIME_PUSH_INTER; IF CHECK PRIME PUSH BUTTON IS PRESSED. JUMPING TO INTERMEDIATE LOCATION AS ADDRESS WAS GOING OUT OF RANGE
   JNB P2.5,GCD_PUSH_INTER; IF GCD/LCM PUSH BUTTON IS PRESSED
   JNB P2.6,EQUAL_PUSH_INTER; IF EQUALS PUSH BUTTON IS PRESSED
   JNB P2.7,RESET_PUSH_INTER; IF RESET PUSH BUTTON IS PRESSED
   
   LCALL DELAY
   MOV A,KP_PORT
   ANL A,#00001111B
   CJNE A,#00001111B,OVER
   SJMP K2
   
OVER:LCALL DELAY
     MOV A,KP_PORT
   ANL A,#00001111B
   CJNE A,#00001111B,OVER1
   SJMP K2 
   
OVER1:CLR KP_PORT.7
      SETB KP_PORT.6
      SETB KP_PORT.5
      SETB KP_PORT.4
      MOV A,KP_PORT
      ANL A,#00001111B
      CJNE A,#00001111B,ROW_0

      CLR KP_PORT.6
      SETB KP_PORT.7
      SETB KP_PORT.5
      SETB KP_PORT.4
      MOV A,KP_PORT
      ANL A,#00001111B
      CJNE A,#00001111B,ROW_1
      
      CLR KP_PORT.5
      SETB KP_PORT.7
      SETB KP_PORT.6
      SETB KP_PORT.4
      MOV A,KP_PORT
      ANL A,#00001111B
      CJNE A,#00001111B,ROW_2
      
      CLR KP_PORT.4
      SETB KP_PORT.7
      SETB KP_PORT.6
      SETB KP_PORT.5
      MOV A,KP_PORT
      ANL A,#00001111B
      CJNE A,#00001111B,ROW_3
      
ROW_0:MOV DPTR,#KCODE0
      SJMP FIND
ROW_1:MOV DPTR,#KCODE1
      SJMP FIND
ROW_2:MOV DPTR,#KCODE2
      SJMP FIND
ROW_3:MOV DPTR,#KCODE3
      SJMP FIND
FIND: RRC A
      JNC MATCH
      INC DPTR 
      SJMP FIND
      

COMNWRT: LCALL READY   ;send command to LCD 
   MOV  P1, A    ;copy reg A to port 1 
   CLR  RS    ;RS=0 for command 
   CLR  RW    ;R/W=0 for write 
   SETB  E    ;E-1 for high pulse  
   ACALL DELAY   ;give LCD some time 
   CLR  E    ;E=0 for H-to-L pulse 
   RET 

 
DATAWRT: LCALL READY   ;write data to LCD 
   MOV  P1, A    ;copy reg A to port1 
   SETB  RS    ;RS=1 for data 
   CLR  RW    ;R/W=0 for write 
   SETB  E    ;E=1 for high pulse 
   ACALL DELAY   ;give LCD some time 
   CLR  E    ;E=0 for H-to-L pulse 
   RET 
   
READY:  SETB  P1.7 
   CLR  RS 
   SETB  RW 
WAIT:  CLR  E 
   LCALL DELAY 
   SETB  E 
   JB  P1.7, WAIT 
   RET 
 
DELAY:SETB PSW.3
      SETB PSW.4  
      MOV  R3, #50   ;50 or higher for fast CPUs 
HERE2:MOV  R4, #255   ;R4=255 
HERE: DJNZ  R4, HERE   ;stay untill R4 becomes 0 
      DJNZ   R3, HERE2
      CLR PSW.3
      CLR PSW.4 
      RET 





;ASCII LOOK-UP TABLE FOR EACH ROW  
KCODE0: DB '1','2','3','4'    ;ROW 0 
KCODE1: DB '5','6','7','8'    ;ROW 1 
KCODE2: DB '9','0','(',')'    ;ROW 2 
KCODE3: DB '+','-','*','/'    ;ROW 3

PRIME_PROMPT1: DB 'NUMBER FOR PRIME',0
PRIME_PROMPT2: DB 'CHECKING- ',0
GCD_PROMPT1: DB 'NUMBERS FOR GCD/',0
GCD_PROMPT2: DB 'LCM: ',0
   END 