# Lab 3 - Final

## Instruções

O objetivo do "laboratório 7" **é criar um projeto de sistema digital**, com base nos labs anteriores (warmups), utilizando as seguintes ferramentas:
- Proteus :: montagem do esquemático e simulação do firmware; e
- IDE Atmel Studio :: ambiente de desenvolvimento integrado que "chamará" o assembler/compiler para geração da imagem executável.

**Não utilizar arquivos de projetos prontos.**

O software poderá ser desenvolvido tanto na linguagem Assembly como C.
Utilizar o hardware (projeto do Proteus) em anexo, visando padronização no desenvolvimento do projetos.
Qualquer problema encontrado no hardware (se existir algum) deverá ser reportado e corrigido pelo aluno.

## Requisitos

O sistema digital a ser desenvolvido deverá cumprir os seguintes requisitos:

- **REQ01.** Deverá ser desenvolvido um único software para as versões master e slave. O que diferencia o uC master do uC slave é o sinal ALTO em PL7 para master e BAIXO em PL7 para slave. O master deve acionar o LED em PF0, e o slave deve deixá-lo "apagado". O master deve exibir a mensagem no terminal "\<hash> \*\*\* MASTER \*\*\*". O slave deve exibir a mensagem "\<hash> \*\*\* SLAVE ***". Somente o slave deverá executar o comando. USART em 57600 bps configurado para 8N1.

    Obs: \<hash> é o número do último commit do seu projeto, quando ele estiver finalizado.

- **REQ02.** Os comandos deverão ser digitados no terminal do master e exibidos no terminal do slave. 

- **REQ03.** O slave deve retornar com ACK para o master em caso de comando válido e executado.

- **REQ04.** O slave deve retornar com INVALID para o master em caso de comando inválido.

- **REQ05.** O sistema deve iniciar a posição de cada servo-motor em zero, controlando os três de maneira independente.

- **REQ06.** O sistema deverá possuir um temporizador que deve ser ajustado para o modo 14,  deve produzir sinais de controle para os servos com período de 20 ms, e a largura dos pulsos do sinal de controle deve ser modulável entre 1 ms e 2 ms.

- **REQ07.** O sistema deve receber valores entre -90 e +90 graus (valores inteiros) via USART para cada um dos três servos, conectados em OC1A, OC1B e OC1C. Seguir as legendas do esquemático para o número do servo. Protocolo a ser seguido:
    **SXsAA**
    * S - (fixo) servo-motor :: 1 byte
    * X - número do servo {0,1,2} :: 1 byte
    * s - sinal do ângulo {-,+} :: 1 byte
    * AA - Ângulo {00, 01, ..., 90} :: 2 bytes

- **REQ08.** O sistema deve receber valores entre ON e OFF para controle dos dois LEDS em PH0 (LED0) e PH1 (LED1). Protocolo a ser seguido:
    **LXCCC**
    * L - (fixo) LED :: 1 byte
    * X - número do LED {0,1} :: 1 byte
    * CCC - comand {ONN,OFF} :: 3 bytes

- **REQ09.** O sistema deve manter fixa a última posição ajustada de cada servo e cada LED.

- **REQ10.**  Criar um *header file* chamado "commit.h" e fazer um *define* com o hash do último commit (**após ter terminado toda a implementação**). Esse número do hash, deverá ser mostrado no terminal (tanto do master como do slave como um identificador). Detalhes no vídeo de apresentação do lab. Fazer um commit final apenas com a alteração do hash desse último commit.

*O material de apoio e as notas de aulas poderão ser consultadas para se realizar esse laboratório. Os códigos fornecidos pelo professor poderão compor a solução final. Não utilizar códigos da internet.*