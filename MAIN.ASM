ASSUME CS:CODE,DS:DATA

CODE SEGMENT

;Initializing Data Segment
MOV DX,DATA
MOV DS,DX
MOV ES,DX

;Clearing the screen
MOV AX,3 
INT 10H

;Welcome Screen
MOV CX,80
MOV AX,0200H
MOV DL,'='

;Print the first line
LINE0: INT 21H
LOOP LINE0

;Skip a line
MOV DL,10
INT 21H

;Print the second line
MOV DL,'='
MOV CX,80
LINE1: INT 21H
LOOP LINE1

;Move caret position
MOV DX,0105H
INT 10H

;Turn off the cursor
MOV CX,2607H
MOV AH,1
INT 10H

;Title animation
MOV AH,02H 
LEA SI,WM
XOR CX,CX
MOV AH,02H
PEC:
MOV DL,[SI+BX]
INT 21H
MOV DX,5000H
MOV AH,86H
INT 15H
MOV AH,02H
INC BX
CMP BX,68
JNE PEC

;Move cursor back to original position
MOV DX,0400H
XOR BX,BX
INT 10H

;Turn on the cursor back
MOV CX,0607H
MOV AH,1
INT 10H

;Print the display message
LEA DX,DM
MOV AH,09H
INT 21H

;Initialize pointer(s) for the start and the end array address
LEA SI,S
LEA DI,S+20

;BP will temporarily store the value until it's passed into the array
;BH shall store the number of digits the number currently has
;CX shall hold the sum (to avoid re-iteration during addition)

MOV BX,000AH
XOR CX,CX
XOR BP,BP   

SCAN:
;Wait for a char
MOV AX,0800H
INT 21H

;If the user has pressed enter
CMP AL,13
JNE backspace

TEST BH,BH
JNZ GV

MOV AX,[SI-2]
MOV [SI],AX
MOV BP,SP
MOV BX,000AH

$$$$: XOR DX,DX
      DIV BX
      PUSH DX
      TEST AX,AX
      JNZ $$$$

MOV AH,02H

$$$: POP DX
     ADD DL,30H
     INT 21H
     CMP SP,BP
     JL $$$

JMP WHILST
GV: MOV [SI],BP
    XOR BP,BP


WHILST:
MOV AH,02H
MOV DL,0AH
INT 21H
XOR BX,BX
ADD CX,[SI]
JNC &
INC C
&:
ADD SI,2
CMP DI,SI
JE CALC
JMP SCAN

backspace:
CMP AL,08H
JNE CHAR

TEST BH,BH
JZ SCAN

MOV AH,02H
MOV DL,08H
INT 21H
MOV DL,20H
INT 21H 
MOV DL,08H
INT 21H

MOV AX,BP
XOR DX,DX
MOV BP,000AH
DIV BP
MOV BP,AX
DEC BH
JMP SCAN

CHAR:
;Wait for enter or backspace if the no. of digits is 4
CMP BH,4
JE SCAN

;Only accept numbers
CMP AL,47
JNG SCAN
CMP AL,58
JNL SCAN

CMP BH,1
JNE &&
TEST BP,BP
JZ NI

&&:

INC BH

MOV DL,AL
MOV AH,02H
INT 21H

MOV BL,DL
XOR DX,DX
MOV AX,BP
MOV BP,000AH
MUL BP
MOV BP,AX
MOV DL,BL
ADD BP,DX
SUB BP,30H
NI:
JMP SCAN

CALC:
MOV BP,CX
INT 21H

MOV CX,80
MOV DL,'='
MOV AH,02H

f0: INT 21H
LOOP f0

MOV CX,0BH
MOV DL,' '
LOOP3: INT 21H
LOOP LOOP3

LEA DX,TAI
MOV AH,09H
INT 21H

MOV CX,80
MOV DL,'='
MOV AH,02H

fl: INT 21H
LOOP fl

MOV AX,BP
MOV BX,000AH
XOR DX,DX
LEA SI,R+5

MOV DL,C
DIV BX
ADD DL,30H
XCHG byte ptr [SI],DL
DEC SI
MOV byte ptr [SI],'.'

@: DIV BX
   ADD DX,30H
   DEC SI
   MOV [SI],DL
   XOR DX,DX
   TEST AX,AX
   JNZ @

;Turn off the cursor
MOV CX,2607H
MOV AH,1
INT 10H

MOV BP,SI
LEA DI,R+6
SUB DI,SI
XOR BX,BX

INC BL
CPRINTF:
INC BL

MOV AH,13H
MOV DX,113CH
MOV CX,DI
INT 10H

MOV AH,86H
MOV CX,0CH
MOV DX,0F850H
INT 15H

CMP BL,0FH
JNE CPRINTF

;Turn on the cursor back
MOV CX,0607H
MOV AH,1
INT 10H

EXIT:
MOV AX,4C00H    
INT 21H

CODE ENDS

DATA SEGMENT

WM DB  'An assembly program to print the average of salaries of 10 employees'
DM DB  'Please enter the 4-digit salary of any 10 of your employees:',10,'$'
TAI DB 'The average salary of the above ten employees is',10,'$'

C DB 0         ;COUNT
S DW 10 DUP(0) ;SAL
R DB 6 DUP(0)  ;RES

DATA ENDS

END
