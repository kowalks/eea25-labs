# Lab 3 - Final

## Instruções

O objetivo do "laboratório 3 Final" **é criar um projeto de sistema digital**, com base nos labs anteriores (warmups), utilizando as seguintes ferramentas:
- Proteus :: montagem do esquemático e simulação do firmware; e
- IDE Atmel Studio :: ambiente de desenvolvimento integrado que "chamará" o assembler para geração da imagem executável.

**Não utilizar arquivos de projetos prontos.**

É importante nesse lab passar pelos passos de criação dos projetos e configurações em cada uma das duas ferramentas.

## Requisitos

O sistema digital a ser desenvolvido deverá cumprir os seguintes requisitos:

- **REQ01.** O sistema deve usar um uC ATMega2560 com clock de 16 MHz.

- **REQ02.** O sistema deve possuir circuito de RESET.

- **REQ03.** O sistema deve ser capaz de controlar três servo-motores (servos), independentemente.

- **REQ04.** O sistema deve ser simulado com três servos independentes.

- **REQ05.** O sistema deve iniciar a posição de cada servo em zero.

- **REQ06.** O sistema deverá possuir um temporizador que deve ser ajustado para o modo 14.

- **REQ07.** O sistema deve produzir sinais de controle para os servos com período de 20 ms.

- **REQ08.** A largura dos pulsos do sinal de controle deve ser modulável entre 1 ms e 2 ms.

- **REQ09.** O temporizador deve dividir o sinal de clock por 8.

- **REQ10.** Os pulsos de controle de cada servo devem ser pelos terminais OC1A, OC1B  e OC1C.

- **REQ11.** O sistema deve possuir comunicação serial USART.

- **REQ12.** O sistema deve receber valores entre -90 e +90 graus (valores inteiros) via USART para cada um dos três servos. Protocolo a ser seguido:
    **SXsAA**
    * S - (fixo) servo-motor :: 1 byte
    * X - número do servo {0,1,2} :: 1 byte
    * s - sinal do ângulo {-,+} :: 1 byte
    * AA - Ângulo {00, 01, ..., 90} :: 2 bytes

- **REQ13.** O sistema deve manter fixa a última posição ajustada de cada servo.

*O material de apoio e as notas de aulas poderão ser consultadas para se realizar esse laboratório. Os códigos fornecidos pelo professor poderão compor a solução final. Não utilizar códigos da internet.*