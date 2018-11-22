;
; AssemblerApplication16.asm
;
; Created: 2018-05-09 오후 4:22:52
; Author : USER
;


; Replace with your application code

.INCLUDE "M128DEF.INC"
.ORG 0

CBI DDRE,5              ; PE5 INPUT 설정
LDI R16,0XFF            
OUT DDRA,R16           ; PA0~PA7 OUTPUT 설정	

S0 : SBIC PINE,5         ; 스위치를 누르면 S1 이동
     RJMP S0             ; 스위치 누를 때까지 S0 반복

S1 : LDI R16,0X80        ; R16에 디지털 기준 비트 값 저장
     LDI R18,0X80        ; R18에 출력할 디지털 변환 값 저장
     LDI R19,0            ; R19에 0 저장
     LDI R17,0XA5        ; R17에 임의의 아날로그 값 저장     
     STS 0X301,R17      ; 주소에 R17에 저장된 아날로그 값 저장
     OUT PORTA,R18

S2 : LDS R17,0X301       ; 주소에 저장된 아날로그 값 불러옴
     SUB R17,R18
     BRCC S3             ; R17 >= R18 이면 S3 이동
     RJMP S4             ; R17 < R18  이면 S4 이동

S3 : LSR R16             ; 기준 비트 오른쪽으로 SHIFT
     ADD R18,R16         ; 예상 디지털 변환 값 증가
     OUT PORTA,R18
     CP R16,R19          ; 기준 비트가 0이면(0비트까지 비교 끝나면)
     BREQ S0             ; 초기 상태로 이동
     RJMP S2             ; 비교가 덜 끝나면 아날로그 값과 재 비교

S4 : SUB R18,R16
     LSR R16 
     ADD R18,R16         ; 예상 디지털 변환 값 감소
     OUT PORTA,R18  
     CP R16,R19           ; 기준 비트가 0이면(0비트까지 비교 끝나면)
     BREQ S0              ; 초기 상태로 이동
     RJMP S2               ; 비교가 덜 끝나면 아날로그 값과 재 비교
