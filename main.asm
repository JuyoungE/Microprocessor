;
; AssemblerApplication16.asm
;
; Created: 2018-05-09 오후 4:22:52
; Author : USER
;


; Replace with your application code
	  LDI   R16,HIGH(RAMEND)
      OUT   SPH, R16
      LDI   R16, LOW(RAMEND)
      OUT   SPL, R16

      CBI   DDRE,4
      SBI   DDRA,7

MAIN:   

      CBI   PORTA,7 ;LED끔
      SBIC PINE,4	;스위치를 누르면 동작 시작
      RJMP MAIN		;스위치를 누를 때까지 재감지
      CALL DELAY_1S	;타이머를 이용한 딜레이 함수 불러오기
      SBI   PORTA,7 ;LED 불 킴
      CALL DELAY_1S
      RJMP MAIN

DELAY_1S:
      LDI   R20, 0X00
      OUT   TCNT1H, R20		;temp=0
      OUT   TCNT1L, R20		;TCNT1L=0, TCNT1H=temp

      LDI   R20, HIGH(62499) ;atmega128 경우 16MHz/256=62500Hz
      OUT   OCR1AH,R20
      LDI   R20, LOW(62499)
      OUT   OCR1AL,R20

      LDI   R20, 0X00
      OUT   TCCR1A,R20	;WGM11:10==00
      LDI   R20, 0X0C	;WGM13:12==01, cs=clk/256
      OUT   TCCR1B,R20

AGAIN:
      IN    R20,TIFR	;TIFR을 읽음
      SBRS  R20,OCF1A	;OCF1A가 set이면 skip
      RJMP  AGAIN	
      LDI   R20,1<<OCF1A	 
      OUT   TIFR,R20	;OCF1A flag를 clear
      LDI   R19,0
      OUT   TCCR1B,R19	;timer를 종료
      OUT   TCCR1A,R19
      RET