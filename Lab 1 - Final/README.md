# Lab 1 - Final

## Instruções

O objetivo do laboratório 1 - Final é **criar um projeto de sistema digital**, com base nos labs 1 partes A e B, utilizando as seguintes ferramentas:
- Proteus :: montagem do esquemático e simulação do firmware; e
- IDE Atmel Studio :: ambiente de desenvolvimento integrado que "chamará" o assembler para geração da imagem executável.

**Não utilizar arquivos de projetos prontos.**

É importante nesse lab passar pelos passos de criação dos projetos e configurações em cada uma das duas ferramentas.

## Requisitos

O sistema digital a ser desenvolvido deverá cumprir os seguintes requisitos:

- **REQ01** - O arquivo do esquemático, no Proteus, deverá utilizar um uC ATmega328P com circuito de XTAL para 16 MHz.
- **REQ02** - O arquivo do esquemático, no Proteus, deverá possuir um circuito de RESET para o uC ATmega328P.
- **REQ03** - O arquivo do esquemático, no Proteus, deverá possuir um terminal de comunicação serial para servir de interface homem-máquina utilizando o protocolo USART, com configuração 57600 bps 8N1.

- **REQ04** - O arquivo esquemático, no Proteus, deverá possuir um circuito para quatro LEDs (D0, D1, D2, D3) de saída.

- **REQ05** - O arquivo esquemático, no Proteus, deverá possuir um circuito para uma chave (SWITCH) de entrada.

- **REQ06** - Realizar a configuração do fuses (CKSEL, SUT) no Proteus para a simulação considerar os 16 MHz para operação do uC.

- **REQ07** - O programa em Assembly deverá implementar uma comunicação serial, protocolo USART, com configuração 57600 bps, 8N1.

- **REQ08** - Ao ser energizado ou resetado, o programa deverá exibir uma mensagem de seleção de comando via interface serial. As possibilidades de comando são:
    - *:: Press I for increasing the counter*
    - *:: Press D for decreasing the counter*

- **REQ09** - Ao pressionar o SWITCH, o programa deverá realizar a função correspondente, incremento ou decremento, de acordo com a última confirmação de seleção de comando realizada via interface serial.

- **REQ10** - O valor inicial da contagem deve ser 0.

- **REQ11** - O valor final da contagem deve ser 15.

- **REQ12** - Ao chegar no valor final da contagem e um incremento for solicitado, a contagem deve voltar ao valor inicial.

- **REQ13** - Ao chegar no valor inicial da contagem e um decremento for solicitado, a contagem deve voltar ao valor final.

- **REQ14** - O programa deverá exibir uma mensagem de confirmação do comando selecionado via interface serial.

- **REQ15** - O comando padrão (inicial) para a contagem deverá ser o de incrementar a contagem.

- **REQ16** - O valor atual da contagem deverá ser exibido utilizando os quatro LEDs D3 (MSB) e D0 (LSB).

- **REQ17 (BÔNUS)** - Implementar um display de 7 segmentos no circuito digital para mostrar o número de vezes em que a contagem saturou, tanto voltando do valor máximo para o mínimo (incremento), como do valor mínimo para o máximo (decremento).

*O material de apoio e as notas de aulas poderão ser consultadas para se realizar esse laboratório. Informações sobre comunicação serial estão presentes na semana 02. Os códigos fornecidos pelo professor poderão compor a solução final. Não utilizar códigos da internet.*