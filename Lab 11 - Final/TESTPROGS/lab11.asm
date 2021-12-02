;*************************************************************************
; lab11.ASM                                                              *
;    Programa teste para as instruções FILLBLOCK, MOVBLOCK, LONGADD e    *
;      LONGSUB, que não fazem parte do conjunto de instruções8080/8085.  *
;                                                                        *
;    O objetivo do programa é começar com uma BASE e PARC e realizar as  *
;      operações:                                                        *
;               - x0 = BASE                                              *
;               - xn = 3*x(n-1) - PARC                                   *
;      O resultado é guardado na RAM em ordem da sequência               *
;                                                                        *
;    FILLBLOCK codificada com o byte [08H]                               *
;      Preenche BC posicoes da memoria, a partir do endereco HL          *
;      com a constante A.                                                *
;      Nao deixa efeitos colaterais em PSW,BC,DE e HL.                   *
;                                                                        *
;    LONGADD é codifivada com o byte [18H].                              *
;      Soma os numeros de C bytes apontados por HL e DE                  *
;      e coloca o resultado a partir do endereço HL.                     *
;      Os numeros são armazenados do byte mais significativo             *
;      para o menos significativo. Afeta apenas CARRY.                   *
;                                                                        *
;    LONGSUB é codifivada com o byte [20H].                              *
;      Subtrai o numero de C bytes apontado por DE                       *
;      do numero de C bytes apontado por HL e coloca o                   *
;      o resultado a partir do endereço HL.                              *
;      Os numeros são armazenados do byte mais significativo             *
;      para o menos significativo. Afeta apenas CARRY.                   *
;                                                                        *
;    MOVBLOCK é codificada com o byte [10H].                             *
;        Copiar BC bytes a partir do endereco DE para o endereco HL.     *
;        Nao deixa efeitos colaterais em PSW,BC,DE e HL.                 *
;    O programa assume um hardware dotado dos seguintes elementos:       *
;                                                                        *
;    - Processador MP8 (8080/8085 simile);                               *
;    - ROM de 0000H a 1FFFh;                                             *
;    - RAM de E000h a FFFFh;                                             *
;    - UART 8250A vista nos enderecos 08H a 0Fh;                         *
;    - PIO de entrada vista no endereço 00h;                             *
;    - PIO de saída vista no endereço 00h.                               *
;                                                                        *
;    Para compilar e "linkar" o programa, pode ser usado o assembler     *
;    "zmac", com a linha de comando:                                     *
;                                                                        *
;         "zmac -8 --oo lst,hex lab11.asm".                              *
;                                                                        *
;    zmac produzirá na pasta zout o arquivo "lab11.hex",                 *
;    imagem do código executável a ser carregado no projeto Proteus      *
;    e também o arquivo de listagem "lab11.lst".                         *
;                                                                        *
;*************************************************************************

; Define origem da ROM e da RAM (este programa tem dois segmentos).
; Diretivas nao podem comecar na primeira coluna.

CODIGO		EQU	0000H

DADOS		EQU	0E000H

TOPO_RAM	EQU	0FFFFH

;*******************************************
; Definicao de macros par que zmac reconheca
; novos mnemonicos de instrucao.
;*******************************************

FILLBLOCK	MACRO
                DB	08H
                ENDM	

MOVBLOCK	MACRO
                DB	10H
                ENDM	

LONGADD		MACRO
                DB	18H
                ENDM	

LONGSUB		MACRO
                DB	20H
                ENDM	


LONGCMP		MACRO
                DB	28H
                ENDM	

JMP256		MACRO
                DB	0CBH
                ENDM

;********************
; Início do código  *
;********************

        ORG     CODIGO

; Preenche a memória RAM com a constante FF para definir workspace
INICIO:         LXI	B,0100H
                LXI	H,DADOS
                MVI	A,0FFH
                FILLBLOCK

; Coloca a constante CONSTBASE na RAM
                LXI     B,16
                LXI     D,CONSTBASE
                LXI     H,BASE
                MOVBLOCK

; Coloca a constante CONSTPARC na RAM
                LXI     D,CONSTPARC
                LXI     H,PARC
                MOVBLOCK

; Carrega a base para aux
                LXI     D,CONSTBASE
                LXI     H,AUX
                MOVBLOCK

; Define as areas para o programa executar
                LXI     H,BASE+64
                LXI     D,BASE

; Calcula as operacoes descritas
LOOP_PROG:      LXI     D,AUX           ; D <- $AUX
                MOVBLOCK                ; [H...H+16] <- [D...D+16] aka [H..H+16] <- AUX
                LONGADD                 ; [H...H+16] <- [D...D+16] + [H...H+16] aka [H..H+16] <- 2*AUX
                LONGADD                 ; [H...H+16] <- [D...D+16] + [H...H+16] aka [H..H+16] <- 3*AUX
                LXI     D,PARC          ; D <- $PARC
                LONGSUB                 ; [H...H+16] <- [H...H+16] - [D...D+16] aka [H..H+16] <- 3*AUX - PARC
; Salva o valor corrent em AUX e move para a próxima posição
                XCHG                    ; D <-> H
                LXI     H,AUX           ; H <- $AUX
                MOVBLOCK                ; [H...H+16] <- [D...D+16] aka AUX <- [H..H+16]
                XCHG                    ; H <-> D

; Performa H <- H + 16 (próxima posição)
                LXI     B,1000H         ; Soma 16 (do registrador B) com a parte baixa de HL
                MOV     A,B
                ADD     L
                MOV     L,A

                LXI     B,0             ; Soma a parte alta de HL com o carry da operação anterior
                MOV     A,B
                ADC     H
                MOV     H,A

; Prepara para o Loop e testa condição
                LXI     B,16

                JC      FIM_LOOP
                JMP     LOOP_PROG
                
FIM_LOOP:       JMP $


; HL <- HL + DE
                
CONSTBASE:      DB      00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,01H
CONSTPARC:      DB      00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,00H,01H

        ORG	DADOS
BASE:           DS      16
PARC:           DS      16
AUX:            DS      16


        END	INICIO

