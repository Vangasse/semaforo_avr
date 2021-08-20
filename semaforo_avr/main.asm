;Semáforo Álvaro Otacílio x Sandoval Arroxelas
;Arthur Vangasse, Alan Pereira, João Arthur
;Sinal 1: Álvaro Otácilio (sul) -> Álvaro Otácilio (norte)
;Sinal 2: Álvaro Otácilio (sul) -> Sandoval Arroxelas
;Sinal 3: Sandoval Arroxelas -> Álvaro Otácilio (sul e norte)
;Sinal 4: Álvaro Otacílio (norte) -> Sandoval Arroxelas e Álvaro Otacílio (sul)
;Sinal 5: Pedestres da Álvaro Otacílio
;explicar as variáveis
.def temp = r16
.def green_leds = r17 ;Sinal Verde
.def yellow_leds = r18 ;Sinal Amarelo
.def red_leds = r19 ;Sinal Vermelho
.def counter = r20
.def leds = r22
.cseg
;Explicar esses jumps
jmp reset
.org OC1Aaddr
jmp OCI1A_Interrupt

;Funções para setar os estados dos sinais
;Função que seta o primeiro estado: Sinal 3 Verde, Sinais 1, 2, 4, 5 Vermelhos
if_state_1:
	ldi green_leds, 0b00100
	ldi yellow_leds, 0b00000
	ldi red_leds, 0b11011
	ret

;Função que seta o segundo estado: Sinal 3 Amarelo, Sinais 1, 2, 4, 5 Vermelhos
if_state_2:
	ldi green_leds, 0b00000
	ldi yellow_leds, 0b00100
	ldi red_leds, 0b11011
	ret

;Função que seta o terceiro estado: Sinal 5 Verde, Sinais 1, 2, 3, 4 Vermelhos
if_state_3:
	ldi green_leds, 0b10000
	ldi yellow_leds, 0b00000
	ldi red_leds, 0b01111
	ret

;Função que seta o quarto estado: Sinais 1, 2 Verdes, Sinais 3, 4, 5 Vermelhos
if_state_4:
	ldi green_leds, 0b00011
	ldi yellow_leds, 0b00000
	ldi red_leds, 0b011100
	ret

;Função que seta o quinto estado: Sinal 1 Verde, Sinal 2 Amarelo, Sinais 3, 4, 5 Vermelhos
if_state_5:
	ldi green_leds, 0b00001
	ldi yellow_leds, 0b00010
	ldi red_leds, 0b011100
	ret

;Função que seta o sexto estado: Sinal 1 Verde, Sinais 2, 3, 4, 5 Vermelhos
if_state_6:
	ldi green_leds, 0b00001
	ldi yellow_leds, 0b00000
	ldi red_leds, 0b011110
	ret

;Função que seta o sétimo estado: Sinais 1 e 4 Verdes, Sinais 2, 3, 5 Vermelhos
if_state_7:
	ldi green_leds, 0b01001
	ldi yellow_leds, 0b00000
	ldi red_leds, 0b010110
	ret

;Função que seta o oitavo estado: Sinal 1 Verde, Sinal 4 Amarelo, Sinais 2, 3, 5 Vermelhos
if_state_8:
	ldi green_leds, 0b00001
	ldi yellow_leds, 0b01000
	ldi red_leds, 0b010110
	ret

;Função que seta o nono estado: Sinais 1 e 4 Amarelos, Sinais 2, 3, 5 Vermelhos
if_state_9:
	ldi green_leds, 0b00000
	ldi yellow_leds, 0b01001
	ldi red_leds, 0b010110
	ret

;Função que seta o décimo estado: Sinal 1 Amarelo, Sinais 2, 3, 4, 5 Vermelhos
if_state_10:
	ldi green_leds, 0b00000
	ldi yellow_leds, 0b00001
	ldi red_leds, 0b011110
	ret

;Interrupção por tempo a cada segundo
OCI1A_Interrupt:
	;explicar as 3 linhas seguintes
	push r16
	in r16, SREG
	push r16

	;Checagem dos estados
	tst r20
	brne skip_1
	rcall if_state_1
	skip_1:

		cpi r20, 2
		brne skip_2
		rcall if_state_2
	skip_2:

		cpi r20, 3
		brne skip_3
		rcall if_state_3
	skip_3:

		cpi r20, 4
		brne skip_4
		rcall if_state_4
	skip_4:

		cpi r20, 5
		brne skip_5
		rcall if_state_5
	skip_5:

		cpi r20, 6
		brne skip_6
		rcall if_state_6
	skip_6:

		cpi r20, 7
		brne skip_7
		rcall if_state_7
	skip_7:

		cpi r20, 8
		brne skip_8
		rcall if_state_8
	skip_8:

		cpi r20, 9
		brne skip_9
		rcall if_state_9
	skip_9:

		cpi r20, 10
		brne skip_10
		rcall if_state_10
	skip_10:

		cpi r20, 11
		brne skip_11
		ldi r20, 0 ;Zera o contador
		rjmp skip_inc ;Necessário para restaurar o sistema
	skip_11:

		inc r20 ;Incrementa o contador
	skip_inc:

	;Explicar as próximas linhas
		out PORTB, green_leds
		out PORTC, yellow_leds
		out PORTD, red_leds
		;Coloque o breakpoint na linha abaixo
		pop r16
		out SREG, r16
		pop r16
		reti

reset:
	;explicar a pilha
	;Stack initialization
	ldi temp, low(RAMEND)
	out SPL, temp
	ldi temp, high(RAMEND)
	out SPH, temp
	;explicar a configuração da interrupção
	;as linhas tratando sobre a variavel leds, parece ser inútil para o nosso código, rever.
	;leds display alternating pattern
	ldi temp, $FF
	out DDRB, temp
	ldi leds, $FF
	out PORTB, leds ;alternating pattern

	#define CLOCK 8.0e6 ;clock speed
	.equ PRESCALE = 0b100 ;/1 prescale
	.equ PRESCALE_DIV = 256
	#define DELAY 1.0e-3 ;seconds
	.equ WGM = 0b0100 ;Waveform generation mode: CTC
	;you must ensure this value is between 0 and 65535
	.equ TOP = int(0.5 + (CLOCK/PRESCALE_DIV*DELAY))
	.if TOP > 65535
	.error "TOP is out of range"
	.endif

	;On MEGA series, write high byte of 16-bit timer 
	;registers first
	ldi temp, high(TOP) ;initialize compare value (TOP)
	sts OCR1AH, temp
	ldi temp, low(TOP)
	sts OCR1AL, temp
	ldi temp, ((WGM&0b11) << WGM10) ;lower 2 bits of WGM
	sts TCCR1A, temp
	;upper 2 bits of WGM and clock select
	ldi temp, ((WGM>> 2) << WGM12)|(PRESCALE << CS10)
	sts TCCR1B, temp ;start counter

	lds r16, TIMSK1
	sbr r16, 1 <<OCIE1A
	sts TIMSK1, r16

	sei
	main_lp:
		rjmp main_lp