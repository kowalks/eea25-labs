;
; lab1.asm
;
; Created: 9/9/2021 4:03:23 AM
; Author : vagrant
;


;***************
;* Constantes  *
;***************
; Constantes para configurar baud rate (2400:416, 9600:103, 57600:16, 115200:8).
.EQU		BAUD_RATE = 16
.EQU		RETURN = 0x0A			; Retorno do cursor.
.EQU		LINEFEED = 0x0D			; Descida do cursor.

;*****************************
; Segmento de código (FLASH) *
;*****************************
.CSEG

; Ponto de entrada para RESET.
     .ORG	0 
			JMP  	RESET

     .ORG	0x100
RESET:
			LDI		R16,0b00111100				; Seleciona PD2 - PD5 como OUTPUT
			OUT		DDRD,R16
			LDI		R20,0b00000000				; Contador (R20) inicial em 0
			LDI		R22,0b00000000				; Contador de overflow (R22) inicial em 0
			OUT		PORTD,R20					; Escreve em PORTD
			
			LDI		R16,LOW(RAMEND)				; Inicializa Stack Pointer.
			OUT		SPL,R16						; Para ATMega328 RAMEND=08ff.
			LDI		R16,HIGH(RAMEND)
			OUT		SPH,R16

			CALL 	USART_INIT					; Inicializa USART.

FIRST_PROMPT:
			LDI		ZH,HIGH(2*PROMPT_INICIAL)	; Imprime ...
			LDI		ZL,LOW(2*PROMPT_INICIAL)
			CALL 	PRINT_STRING

			LDI		R16,'I'						; Opção inicial padrão é incremento
			STS		CARACTERE,R16

FOREVER:
			CALL 	USART_LAZY_RECEIVE			; R16 <- caractere recebido.
			SBRS 	R17,RXC0
			JMP		WAIT_SWITCH
			STS		CARACTERE,R16

CHAR_PROMPT:
			LDI		ZH,HIGH(2*PROMPT_ESCOLHA)	; Imprime ...
			LDI		ZL,LOW(2*PROMPT_ESCOLHA)
			CALL 	PRINT_STRING
			CALL 	USART_TRANSMIT			; Imprime caractere recebido.
			LDI		R16,RETURN
			CALL 	USART_TRANSMIT
			LDI		R16,LINEFEED
			CALL 	USART_TRANSMIT

WAIT_SWITCH:								; Escuta por ativação do SWITCH
			IN		R16, PIND
			ANDI 	R16,0b10000000
			BRNE 	FOREVER

WAIT_SWITCH_RELEASE:						; Espera SWITCH desativar
			IN		R16, PIND
			ANDI 	R16,0b10000000
			BREQ 	WAIT_SWITCH_RELEASE
			
			LDS		R18,CARACTERE
			CPI		R18,'d'					; compara com o R18
			BREQ 	DECREMENTS				
			CPI		R18,'D'
			BREQ 	DECREMENTS				; if R18!=0, then we decrement...
INCREMENTS:									; else we increment
			INC		R20
			CPI		R20,16
			BREQ 	OVERFLOW
			JMP		OUTPUT
DECREMENTS:									; code for decrement
			CPI		R20,0
			BREQ	UNDERFLOW
			DEC		R20
OUTPUT:
			MOV		R21,R20		; R21 = R20<<2 (porque as portas PD0 e PD1 são usadas pelo terminal)
			LSL		R21
			LSL		R21
			OUT		PORTD,R21	; LED output
			;OUT		PORTE,R22	; SEG Display output
			JMP		FOREVER

OVERFLOW:
			INC		R22
			LDI		R20,0
			JMP		OUTPUT
UNDERFLOW:
			DEC		R22
			LDI		R20,15
			JMP		OUTPUT


;**************************************************
;  PRINT_STRING                                   *
;  Subrotina                                      *
;  Envia mensagem apontada por Z em CODSEG.       *
;  O caractere '$' indica o término da mensagem.  *
;**************************************************
PRINT_STRING:
			PUSH	R16						; Salva o registrador R16.

PRINT_STRING_LOOP:
			LPM		R16,Z+
			CPI		R16,'$'
			BREQ	PRINT_STRING_END		; Se não chegou no caractere de término '$', usa USART.
			CALL	USART_TRANSMIT
			JMP		PRINT_STRING_LOOP

PRINT_STRING_END:
			POP		R16						; Restaura R16 e retorna.
			RET
				
;*************************************************************************************
;  PROTOCOLO USART

;*******************************************
;  USART_INIT                              *
;  Subrotina para inicializar a USART.     *
;*******************************************

; Inicializa USART: modo assincrono, 57600 bps 8N1.
; Os registradores são:
;     - UBRR0 (USART0 Baud Rate Register)
;     - UCSR0 (USART0 Control Status Register B)
;     - UCSR0 (USART0 Control Status Register C)

USART_INIT:
			LDI		R17,HIGH(BAUD_RATE)			; Estabelece Baud Rate.
			STS		UBRR0H,R17
			LDI		R16,LOW(BAUD_RATE)
			STS		UBRR0L,R16
			LDI		R16,(1<<RXEN0)|(1<<TXEN0)	; Habilita receptor e transmissor.

			STS		UCSR0B,R16
			LDI		R16,(0<<USBS0)|(1<<UCSZ01)|(1<<UCSZ00)	; Frame: 8 bits dado, 1 stop bit,
			STS		UCSR0C,R16								;        sem paridade.

			RET


;*******************************************
;  USART_TRANSMIT                          *
;  Subrotina para transmitir R16 por meio  *
;  da USART                                *
;*******************************************

USART_TRANSMIT:
			PUSH	R17					; Salva R17 na pilha.

WAIT_TRANSMIT:
			LDS		R17,UCSR0A
			SBRS	R17,UDRE0			; Aguarda BUFFER do transmissor ficar vazio.		
			RJMP	WAIT_TRANSMIT
			STS		UDR0,R16			; Escreve dado de R16 no BUFFER.
			
			POP		R17					; Restaura R17 da pilha e retorna.
			RET

;*******************************************
;  USART_RECEIVE                           *
;  Subrotina                               *
;  Aguarda a recepção de dado pela USART   *
;  e retorna com o dado em R16.            *
;*******************************************

USART_RECEIVE:
			PUSH	R17					; Salva R17 na pilha.

WAIT_RECEIVE:
			LDS		R17,UCSR0A
			SBRS	R17,RXC0			; Aguarda chegada do dado.
			RJMP	WAIT_RECEIVE
			LDS		R16,UDR0			; Le dado do BUFFER e escreve em R16.
			
			POP		R17					; Restaura R17 da pilha e retorna.
			RET


;*******************************************
;  USART_LAZY_RECEIVE                      *
;  Subrotina                               *
;  Recebe os dados pela USART se há algum  *
;  e retorna com o dado em R16.            *
;*******************************************

USART_LAZY_RECEIVE:
			LDS		R17,UCSR0A
			SBRC 	R17,RXC0
			LDS		R16,UDR0			; Le dado do BUFFER e escreve em R16.
			RET


;*************************************************************************************
;  DATA

;*******************************************
; Strings e mensagens a serem impressas.   *
;    '$' é usado como terminador.          *
;*******************************************

PROMPT_INICIAL:
		.DB		":: Press I for increasing the counter ",RETURN,LINEFEED,":: Press D for decreasing the counter",RETURN,LINEFEED,RETURN,LINEFEED,'$'

PROMPT_ESCOLHA:
		.DB		"O caractere escolhido foi: ",'$'
		

;************************************
; Segmento de dados (RAM)           *
; Mostra como alocar espaço na RAM  *
; para variaveis.                   *
;************************************
.DSEG
     .ORG	0x200
CARACTERE:		.BYTE	1

.EXIT