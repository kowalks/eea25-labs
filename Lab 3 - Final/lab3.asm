;*******************************************************************
;*   LAB1.ASM                                                      *
;*                                                                 *
;*   MCU alvo: Atmel ATmega2560s                                    *
;*   Frequencia: X-TAL : 16 MHz                                    *
;*   Compilador: AVR Assembler 2 (Atmel Studio 7.0)                *
;*                                                                 *
;*   Descricao:                                                    *
;*                                                                 *
;*       Inicializa o Stack Pointer com RAMEND;                    *
;*       Configura a USART para operar no modo assincrono com      *
;*            57600 bps,                                           *
;*            1 stop bit,                                          *
;*            sem paridade;                                        *
;*       Fica em loop executando as seguintes tarefas:             *
;*            1. Emite mensagem solicitando a escolha por          *
;*               incremento (I) ou decremento (D)                  *
;*            2. Caso seja escolhida alguma opção, emite mensagem  *
;*               de confirmação                                    *
;*            3. Incrementa contador se for pressionado o SWITCH   *
;*               na porta PD7 e exibe contagem nas portas PD2-PD5  *
;*            4. Caso tenha overflow ou underflow do contador,     * 
;*               atualiza display de 7 segmentos em PB0-PB3        *
;*            4. Vai para o passo 1.                               * 
;*                                                                 *
;*                             Created: 09/09/2021 13:30:00        *
;*******************************************************************

;***************
;* Constantes  *
;***************
; Constantes para configurar baud rate (2400:416, 9600:103, 57600:16, 115200:8).

   .equ  BAUD_RATE = 103
   .equ  RETURN = 0x0A          ; Retorno do cursor.
   .equ  LINEFEED = 0x0D        ; Descida do cursor.
   .equ  USART1_INTERRUPT_vect = 0x0048
   .equ  CONST_ICR1 = 39999    ; Constante para o registrador OCR1A do TIMER1.
     
;*****************************
; Segmento de código (FLASH) *
;*****************************
   .cseg

; Ponto de entrada para RESET.
   .org  0 
   jmp   START

;*************************************************
;  PONTO DE ENTRADA DAS INTERRUPÇÕES DA USART    *
;*************************************************
   .org  USART1_INTERRUPT_vect
   jmp   USART1_INTERRUPT


   .org  0x100
START:
   ldi   r16, low(ramend)       ; Inicializa Stack Pointer.
   out   spl, r16               
   ldi   r16, high(ramend)
   out   sph, r16

   call  INIT_PORTS             ; Inicializa PORTH.
   call  USART1_INIT            ; Inicializa USART0.
   call  TIMER1_INIT_MODE14      ; Inicializa TIMER1.
   call  CONT_INIT
   sei                          ; Habilita interrupções.


FOR_LOOP:
   lds   r16, CONTA
   lds   r17, CONTA+1
   sts   ocr1ah, r17
   sts   ocr1al, r16

   lds   r16, CONTB
   lds   r17, CONTB+1
   sts   ocr1bh, r17
   sts   ocr1bl, r16

   lds   r16, CONTC
   lds   r17, CONTC+1
   sts   ocr1ch, r17
   sts   ocr1cl, r16
   
   jmp FOR_LOOP



USART1_INTERRUPT:
   inc   r20
IF1:
   cpi   r20, 1
   brne  IF2
   lds   r21, udr1
   jmp   END_IF
IF2:
   cpi   r20, 2
   brne  IF3
   lds   r22, udr1
   jmp   END_IF
IF3:
   cpi   r20, 3
   brne  IF4
   lds   r23, udr1
   jmp   END_IF
IF4:
   cpi   r20, 4
   brne  IF5
   lds   r24, udr1
   call  END_IF
IF5:
   cpi   r20, 5
   brne  END_IF
   lds   r25, udr1
   call  PROCESS_INPUT
   push  r16
   ldi   r16,RETURN
   call  USART1_TRANSMIT
   ldi   r16,LINEFEED
   call  USART1_TRANSMIT
   pop   r16
END_IF:
   reti



PROCESS_INPUT:
   cpi   r21,'S'        ; check protocol
   brne  END_INPUT
   
   subi  r24, '0'       ; ascii to bin
   subi  r25, '0'       ; ascii to bin
   ldi   r21, 10
   mul   r24, r21
   add   r25, r0        ; r25 <- r24*10 + r25


   sleep
POSITIVE_ANGLES:
   cpi   r23, '+'
   brne  NEGATIVE_ANGLES
   ldi   ZL, low(POSL<<1)
   ldi   ZH, high(POSL<<1)
   add   ZL, r25
   lpm   r27, Z            ; r27 stores low part of positive angle 
   ldi   ZL, low(POSH<<1)
   ldi   ZH, high(POSH<<1)
   add   ZL, r25
   lpm   r26, Z            ; r26 stores high part for positive angle
   jmp   TEST_SERVO_0
NEGATIVE_ANGLES:
   cpi   r23, '-'
   brne  END_INPUT
   ldi   ZL, low(NEGL<<1)
   ldi   ZH, high(NEGL<<1)
   add   ZL, r25
   lpm   r27, Z            ; r27 stores low part of negative angles
   ldi   ZL, low(NEGH<<1)
   ldi   ZH, high(NEGH<<1)
   add   ZL, r25
   lpm   r26, Z            ; r26 stores high part for negative angles

TEST_SERVO_0:
   cpi   r22, '0'
   brne  TEST_SERVO_1
   sts   CONTA+1, r26
   sts   CONTA, r27
   jmp   END_INPUT
TEST_SERVO_1:
   cpi   r22, '1'
   brne  TEST_SERVO_2
   sts   CONTB+1, r26
   sts   CONTB, r27
   jmp   END_INPUT
TEST_SERVO_2:
   cpi   r22,'2'
   brne  END_INPUT
   sts   CONTC+1, r26
   sts   CONTC, r27
END_INPUT:
   ldi   r20, 0
   ret


;***********************************
;  INIT_PORTS                      *
;  Inicializa PORTB como saída     *
;    em PB5 e entrada nos demais   *
;    terminais.                    *
;  Inicializa PORTH como saída     *
;    e emite 0x00 em ambos.        *
;***********************************
INIT_PORTS:
   ldi   r16, 0b11100000        ; Para emitir em PB5 a onda quadrada gerada pelo TIMER1.
   out   ddrb, r16
   ret

;*****************************************
;  USART1_INIT                           *
;  Subrotina para inicializar a USART1.  *
;*****************************************
; Inicializa USART1: modo assincrono, 9600 bps, 1 stop bit, sem paridade.  
; Os registradores são:
;     - UBRR1 (USART1 Baud Rate Register)
;     - UCSR1 (USART1 Control Status Register B)
;     - UCSR1 (USART1 Control Status Register C)
USART1_INIT:
   ldi   r17, high(BAUD_RATE)   ;Estabelece Baud Rate.
   sts   ubrr1h, r17
   ldi   r16, low(BAUD_RATE)
   sts   ubrr1l, r16
   ldi   r16, (1<<rxcie1)|(1<<rxen1)|(1<<txen1)  ;Habilita receptor e transmissor.
   sts   ucsr1b, r16
   ldi   r16, (0<<usbs1)|(1<<ucsz11)|(1<<ucsz10)   ;Frame: 8 bits dado, 1 stop bit,
   sts   ucsr1c, r16            ;sem paridade.
   
   ret

;*************************************
;  USART1_TRANSMIT                   *
;  Subrotina para transmitir R16.    *
;*************************************
USART1_TRANSMIT:
   push  r17                    ;Salva R17 na pilha.

WAIT_TRANSMIT1:
   lds   r17, ucsr1a
   sbrs  r17, udre1             ;Aguarda BUFFER do transmissor ficar vazio.      
   rjmp  WAIT_TRANSMIT1
   sts   udr1, r16              ;Escreve dado no BUFFER.

   pop   r17                    ; Restaura R17 e retorna.
   ret

;*******************************************
;  USART1_RECEIVE                          *
;  Subrotina                               *
;  Aguarda a recepção de dado pela USART0  *
;  e retorna com o dado em R16.            *
;*******************************************
USART1_RECEIVE:
   push  r17						  ; Salva R17 na pilha.

WAIT_RECEIVE1:
   lds   r17,ucsr1a
   sbrs  r17,rxc1
   rjmp  WAIT_RECEIVE1          ;Aguarda chegada do dado.
   lds   r16,udr1               ;Le dado do BUFFER e retorna.

   pop   r17						  ; Restaura R17 e retorna.
   ret


;*********************************
; TIMER1_INIT_MODE14             *
; ICR1 = 40000, PRESCALER/8     *
;*********************************
TIMER1_INIT_MODE14:
; ICR1 = 40000
   ldi   r16, high(CONST_ICR1)
   sts   icr1h, r16
   ldi   r16, low(CONST_ICR1)
   sts   icr1l, r16

; WGM1[3:0]=1101 para modo 14
; COM1x[1:0]=10  para começar em BOTTOM=0 com sinal ativo e desativar ao chegar em OC1x
; CS1[2:0]=010   para PRESCALER/8
; OCIE1x=1       para ativar os três canais
   ldi   r16, (1<<com1a1) | (0<<com1a0) | (1<<com1b1) | (0<<com1b0) | (1<<com1c1) | (0<<com1c0) | (1<<wgm11) | (0<<wgm10)
   sts   tccr1a, r16
   ldi   r16,(0<<icnc1) | (0<<ices1) | (1<<wgm13) | (1<<wgm12) | (0<<cs12) |(1<<cs11) | (0<<cs10)
   sts   tccr1b, r16
   ldi   r16, (0<<icie1) | (0<<ocie1c) | (0<<ocie1b) | (0<<ocie1a) | (0<<toie1)
   sts   timsk1, r16
   ret


CONT_INIT:
   ldi   r16, 184
   ldi   r17, 11
   sts   CONTA+1, r17
   sts   CONTA, r16
   sts   CONTB+1, r17
   sts   CONTB, r16
   sts   CONTC+1, r17
   sts   CONTC, r16

   ret


;************************************
; Segmento de dados (RAM)           *
; Mostra como alocar espaço na RAM  *
; para variaveis.                   *
;                                   *
;************************************
.dseg
   .org  0x200
; POSL:
;    .db 184,195,206,217,228,240,251,6,17,28,39,50,61,72,84,95,106,117,128,139,150,161,172,184,195,206,217,228,239,250,5,16,28,39,50,61,72,83,94,105,116,128,139,150,161,172,183,194,205,216,228,239,250,5,16,27,38,49,60,72,83,94,105,116,127,138,149,160,172,183,194,205,216,227,238,249,4,16,27,38,49,60,71,82,93,104,116,127,138,149,160
; POSH:
;    .db 11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
; NEGL:
;    .db 184,173,162,151,140,128,117,106,95,84,73,62,51,40,28,17,6,251,240,229,218,207,196,184,173,162,151,140,129,118,107,96,84,73,62,51,40,29,18,7,252,240,229,218,207,196,185,174,163,152,140,129,118,107,96,85,74,63,52,40,29,18,7,252,241,230,219,208,196,185,174,163,152,141,130,119,108,96,85,74,63,52,41,30,19,8,252,241,230,219,208
; NEGH:
;    .db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7

POSL:
   .db 184,195,206,217,228,239,251,6,17,28,39,50,61,72,83,95,106,117,128,139,150,161,172,183,195,206,217,228,239,250,5,16,27,39,50,61,72,83,94,105,116,127,139,150,161,172,183,194,205,216,227,239,250,5,16,27,38,49,60,71,83,94,105,116,127,138,149,160,171,183,194,205,216,227,238,249,4,15,27,38,49,60,71,82,93,104,115,127,138,149,160
POSH:
   .db 11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15
NEGL:
   .db 184,173,162,151,139,128,117,106,95,84,73,62,51,39,28,17,6,251,240,229,218,207,195,184,173,162,151,140,129,118,107,95,84,73,62,51,40,29,18,7,251,240,229,218,207,196,185,174,163,151,140,129,118,107,96,85,74,63,51,40,29,18,7,252,241,230,219,207,196,185,174,163,152,141,130,119,108,96,85,74,63,52,41,30,19,8,252,241,230,219,208
NEGH:
   .db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7

   .org  0x400
CONTA:
   .byte 2
CONTB:
   .byte 2
CONTC:
   .byte 2

   .org 0x600
STRING:
   .byte 4
LENGTH:
   .byte 1

;*****************************
; Finaliza o programa fonte  *
;*****************************
   .exit
