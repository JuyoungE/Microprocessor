;
; AssemblerApplication3.asm
;
; Created: 2018-05-14 오후 3:44:29
; Author : USER
;


; Replace with your application code
	  
	  .ORG  0
	  RJMP	MAIN
	  .ORG	0X1C
	  RJMP	LED

MAIN: 
      LDI   R16,HIGH(RAMEND)
      OUT   SPH, R16
      LDI   R16, LOW(RAMEND)
      OUT   SPL, R16

	  LDI	R20,0XFF
	  OUT	DDRA,R20
	  LDI   R25,0X01  
      
	  LDI   R20,(1<<OCIE1A)
	  OUT   TIMSK,R20
	  SEI

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
	  
HERE: JMP	HERE

LED : 
	 OUT PORTA,R25
	 INC R25

	  LDI   R20,1<<OCIE1A	 
      OUT   TIFR,R20	;OCF1A flag를 clear
      LDI   R19,0
      OUT   TCCR1B,R19	;timer를 종료
      OUT   TCCR1A,R19

	  LDI   R20, 0X00
      OUT   TCCR1A,R20	;WGM11:10==00
      LDI   R20, 0X0C	;WGM13:12==01, cs=clk/256
      OUT   TCCR1B,R20

	 RETI
