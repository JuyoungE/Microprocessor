;
; AssemblerApplication16.asm
;
; Created: 2018-05-09 오후 4:22:52
; Author : USER
;


; Replace with your application code

/*
 * GccApplication8.c
 *
 * Created: 2018-11-21 오후 11:22:07
 * Author : USER
 */ 

#include <avr/io.h>
#include <stdlib.h>


int main(void){
unsigned short value;

DDRE = 0xCF;  //스위치 PE4,PE5 input 설정
DDRA = 0xFF;  // LED output 설정
DDRB |=(1<<4) ; // 부저 output 설정
DDRC = 0xFF; // 7SEGMENT 설정
DDRG = 0x0F; // FND PG3-0 select output 설정
DDRE = 0xCF;  //스위치 PE4,PE5 input 설정
DDRA = 0xFF;  // LED output 설정
DDRB |=(1<<4) ; // 부저 output 설정
DDRC = 0xFF; // 7SEGMENT 설정
DDRG = 0x0F; // FND PG3-0 select output 설정

ADMUX = 0x41;
ADCSRA = 0x87;

while(1)
{   value = read_adc();
	show_adc(value);   }

return 0;



}

unsigned short read_adc()
{
	unsigned short value;
	unsigned char  adc_high;
	ADCSRA |= 0x40;    // ADC start conversion, ADSC = ‘1’
	while ((ADCSRA & 0x10) == 0);   // ADC 변환 완료 검사
	value = ADCL;      // 변환된 Low 값 읽어오기
	adc_high = ADCH;   // 변환된 High 값 읽어오기
	return value;
}

void show_adc(unsigned short value)
{
	unsigned short temp;
	temp = (value*4)/10;
	if (temp > 40){      // 기준값 이상이면
		timer();
	}
}

void timer(){
	EICRA = 0x0A;
	EIMSK = 0x03;
	TIMSK=(1<<OCIE1A);
	sei();
	TCNT1H=0;
	TCNT1L=0;
	OCR1AH=0xF4;
	OCR1AL=0X23;
	TCCR1A=0;
	TCCR1B=0x0C;
	
	int i,n[4];
	
	unsigned char digit[10] = {0x3f, 0x06, 0x5b,
	0x4f, 0x66, 0x6d, 0x7c, 0x07, 0x7f, 0x67};
	unsigned char fnd_sel[4] = {0x01, 0x02, 0x04, 0x08};
	int A=600 ;
	int sw=0;
	
	while(1){
		
		n[3] = A/60;
		n[2] = (A/60)%10;
		n[1] = (A%60)/10;
		n[0] = (A%60)%10;
		
		for(i=0;i<4;i++){
			PORTG = fnd_sel[i];
			if(i==2){
				PORTC = digit[n[i]]+0x80 ;
				else PORTC = digit[n[i]];
				_delay_ms(2);
			}
	//부저음 정의
	#define DO 0
	#define RE 1
	#define MI 2
	#define FA 3
	#define SOL 4
	#define RA 5
	#define SI 6
	#define DDO 7
	#define EOS -1 // End Of Song  표시
	#define ON 0
	#define OFF 1

	volatile int state, tone;
	char f_table[8] = {17, 43, 66, 77, 97, 114, 117, 137}; // 도레미파솔라시도 에 해당하는 TCNT0 값을 미리 계산해 놓은 값
	int song[] = {SOL,MI,MI,FA,RE,RE,DO,RE,MI,FA,SOL,SOL,SOL,SOL,MI,MI,MI,FA,RE,RE,DO,MI,SOL,SOL,MI,MI,MI,EOS};// 산토끼 계명
	
	if(A==0){
		PORTG = 0X0F;
		PORTC = digit[0];
		
		int i=0;
		TCCR0 = 0x03;                   // 프리스케일러 8분주
		TIMSK |= 0x01;                    // 오버플로우 인터럽트 활성화, 즉, TOIE0 비트 세트
		TCNT0 = f_table[song[i]]; // TCNT0 초기화
		sei();                                 // 전역인터럽트 활성화
		do {
			tone = song[i++]; // 노래 음계
			_delay_ms(500);                // 한 계명당 지속 시간
		}while(tone != EOS);
	}
}

}

ISR(TIMER1_COMPA_vect)
{

	unsigned short value;
	if  (A==0) { PORTA ^=0X55; }
	else     {   A=A-1;  }
}
	
ISR(TIMER0_OVF_vect) // Timer/Counter0 오버플루우 인터럽트
{
	if (state == OFF)
	{
		PORTB |= 1 << 4; // 버저 포트 ON
		state = ON;
	}
	else
	{
		PORTB &= ~(1 << 4);         // 버저 포트 OFF
		state = OFF;
	}
	TCNT0 = f_table[tone];
}

ISR(INT0_vect)
{
	if(A<900&sw<2)
	A=A+30;
	sw++;
}

ISR(INT1_vect){
	if(A>300||sw>0)
	A=A-30;
	sw--;
} else A=0;
}



