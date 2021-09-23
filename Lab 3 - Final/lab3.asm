;************************************************************************
;*   LAB3.ASM                                                           *
;*                                                                      *
;*   MCU alvo: Atmel ATmega2560s                                        *
;*   Frequencia: X-TAL : 16 MHz                                         *
;*   Compilador: AVR Assembler 2 (Atmel Studio 7.0)                     *
;*                                                                      *
;*   Implementa projeto de controle de três servomotores independentes  *
;*     comandados por inteface em terminal por meio de protocolo USART  *
;*     8N1 para comunicação com o controlador e por pulso Fast PWM      *
;*     para controle do ângulo de cada servomotor. Para isso, foram     *
;*     necessários um TIMER1 que recebe pulsos da saída Clk=16MHz/1024  *
;*     do PRESCALER e conta pulsos de 0 a 39999, de modo a gerar uma    *
;*     frequência de 50Hz na saída. Em cima desse sinal, o OCR1x é      *
;*     colocado para modular diferentes larguras de pulso, que corres-  *
;*     pondem a diferentes ângulos em cada servomotor.                  *
;*     0 a 15625, valor com o qual OCR1A é inicializado.  Assim,        *
;*     de 1024 X 15625 = 16000000 em 16000000 pulsos é produzida uma    *
;*     interrupção (uma interrupção por segundo).                       *
;*                                                                      *
;*   Descricao:                                                         *
;*                                                                      *
;*       Inicializa o Stack Pointer com RAMEND;                         *
;*       Configura  as portas de saída em PB dos pulsos e em PD do      *
;*         terminal                                                     *    
;*       Configura a USART0 para operar no modo assincrono com          *
;*            9600 bps,                                                 *
;*            1 stop bit,                                               *
;*            sem paridade;                                             *
;*            interrupções de recebimento de dado                       *
;*       Inicializa o TIMER1 para operar no Modo 14 para gerar pulsos   *
;          regulares na frequência de 50Hz                              *
;*       Inicializa as variáveis CONTx com os valores padrão            *
;*       Habilita interrupções com "SEI";                               *
;*                                                                      *
;*       A parte principal do programa fica em loop puxando o valor     *
;*         atual das variáveis CONTx para OCR1x.                        *
;*       Quando há dado chegando pela USART, armazena os caracteres     *
;*         nos registradores até que se complete cinco caracteres.      *
;*       Nesse momento, há uma validação para ver se o input segue      *
;*         o padrão estabelecido e, em caso afirmativo, são feitos      *
;*         os ajustes necessários em OCR1x para que, por esse canal,    *
;*         o pulso tenha a largura correta.                             *
;*       Os valores de OCR1x já foram calculados, e são armazenados     *
;*         no segmento de dados do controlador.                         *
;*                                                                      *
;*                                                                      *
;*                             Created: 23/09/2021 13:30:00             *
;************************************************************************

;***************
;* Constantes  *
;***************
; Constantes para configurar baud rate (2400:416, 9600:103, 57600:16, 115200:8).

   .equ  BAUD_RATE = 103
   .equ  RETURN = 0x0A          ; Retorno do cursor.
   .equ  LINEFEED = 0x0D        ; Descida do cursor.
   .equ  BACKSPACE = 0x08
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
   call  TIMER1_INIT_MODE14     ; Inicializa TIMER1.
   call  CONT_INIT              ; Inicializa as variáveis de contagem.
   sei                          ; Habilita interrupções.

;**************************************************************************************
;                                LOOP PRINCIPAL DO PROGRAMA                           *
;**************************************************************************************
; Aqui, ficamos sempre pegando os valores na RAM de CONTx e jogando para OCR1x.
; Isso é necessário, porque quando o timer atinge OCR1x, o valor é zerado.

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



;*************************************************************
;  INTERRUPÇÃO DEVIDO À CHEGADA DE DADOS POR MEIO DA USART1  *
;*************************************************************

USART1_INTERRUPT:
   inc   r20
   lds   r19, udr1           
IF0:                    ; Se for backspace, apaga o caractere
   cpi   r19, BACKSPACE
   brne  IF1
   dec   r20
   dec   r20
   jmp   END_IF

IF1:                    ; Verifica a quantidade de caracteres lidos atualmente
   cpi   r20, 1         ; Caso seja o primeiro caractere
   brne  IF2
   mov   r21, r19       ; Armaena em r21
   jmp   END_IF
IF2:
   cpi   r20, 2         ; Caso seja o segundo caractere
   brne  IF3
   mov   r22, r19       ; Armaena em r22
   jmp   END_IF
IF3:
   cpi   r20, 3         ; Caso seja o terceiro caractere
   brne  IF4
   mov   r23, r19       ; Armaena em r23
   jmp   END_IF
IF4:
   cpi   r20, 4         ; Caso seja o quarto caractere
   brne  IF5
   mov   r24, r19       ; Armaena em r24
   call  END_IF
IF5:
   cpi   r20, 5         ; Caso seja o quinto caractere
   brne  END_IF
   mov   r25, r19       ; Armazena em r25
   call  PROCESS_INPUT  ; Processa o input com cinco caracteres
   push  r16
   ldi   r16,RETURN     ; Transmite Enter (CR e LF)
   call  USART1_TRANSMIT
   ldi   r16,LINEFEED
   call  USART1_TRANSMIT
   pop   r16
END_IF:
   reti


;*************************************
; Processamento dos caracteres lidos *
;*************************************
PROCESS_INPUT:
   cpi   r21,'S'        ; check protocol
   brne  END_INPUT
   
   subi  r24, '0'       ; ascii to bin
   subi  r25, '0'       ; ascii to bin
   ldi   r21, 10
   mul   r24, r21
   add   r25, r0        ; r25 <- r24*10 + r25

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
   push  r17					; Salva R17 na pilha.

WAIT_RECEIVE1:
   lds   r17,ucsr1a
   sbrs  r17,rxc1
   rjmp  WAIT_RECEIVE1          ;Aguarda chegada do dado.
   lds   r16,udr1               ;Le dado do BUFFER e retorna.

   pop   r17					; Restaura R17 e retorna.
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
   ldi   r16, 183
   ldi   r17, 11
   sts   CONTA+1, r17
   sts   CONTA, r16
   sts   CONTB+1, r17
   sts   CONTB, r16
   sts   CONTC+1, r17
   sts   CONTC, r16

   ret


   .org  0x200
POSL:
   .db 183,194,205,216,227,239,250,5,16,27,38,49,60,71,83,94,105,116,127,138,149,160,171,183,194,205,216,227,238,249,4,15,27,38,49,60,71,82,93,104,115,127,138,149,160,171,182,193,204,215,227,238,249,4,15,26,37,48,59,71,82,93,104,115,126,137,148,159,171,182,193,204,215,226,237,248,3,15,26,37,48,59,70,81,92,103,115,126,137,148,159, ' '
POSH:
   .db 11,11,11,11,11,11,11,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,12,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,13,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,15,15,15,15,15,15,15,15,15,15,15,15,15,15,15, ' '
NEGL:
   .db 183,172,161,150,139,127,116,105,94,83,72,61,50,39,27,16,5,250,239,228,217,206,195,183,172,161,150,139,128,117,106,95,83,72,61,50,39,28,17,6,251,239,228,217,206,195,184,173,162,151,139,128,117,106,95,84,73,62,51,39,28,17,6,251,240,229,218,207,195,184,173,162,151,140,129,118,107,95,84,73,62,51,40,29,18,7,251,240,229,218,207, ' '
NEGH:
   .db 11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,11,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,10,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,9,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,7,7,7,7,7, ' '

;************************************
; Segmento de dados (RAM)           *
; Mostra como alocar espaço na RAM  *
; para variaveis.                   *
;                                   *
;************************************
.dseg
   .org  0x400
CONTA:
   .byte 2
CONTB:
   .byte 2
CONTC:
   .byte 2


;*****************************
; Finaliza o programa fonte  *
;*****************************
   .exit
