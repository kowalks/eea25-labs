# Lab 10 - Final

## Instruções

O objetivo do "Laboratório 10 Final" é **construir instruções no microprograma do processador MP8**, com base nos labs anteriores (warmups), utilizando as seguintes ferramentas:
- Proteus :: simulação do projeto 'MP8_Lab.pdsprj';
- GMICPROG :: compilação do microprograma 'MP8Lab.txt';
- ZMAC :: compilação do assembly em 'testpchl.asm'.

**Utilizar os arquivos da pasta 'MP8_Lab', copiando-a inteiramente na raiz (C:\\).**

**No arquivo 'MP8Lab.txt', complete a implementação das instruções contidas no final do arquivo:**
- a. JC a16
- b. LXI B,d16
- c. LXI D,d16
- d. ADD E
- e. MOV E,A
- f. ACI d8
- g. MOV D,A
- h. DAD D
- i. MOV E,M
- j. XCHG
- k. PCHL

**Após implementar as funções, simular no Proteus, com o arquivo 'testpchl.hex' carregado no componente U190 (Root sheet 1), obtendo resultado semelhante ao mostrado no vídeo da aula da Semana 14.**

## Requisitos

O sistema digital a ser desenvolvido deverá cumprir os seguintes requisitos:

- **REQ01.** O sistema deve usar o projeto 'MP8_Lab.pdsprj'.

- **REQ02.** O sistema deve exibir mensagem de texto no terminal virtual.

- **REQ03.** O sistema deve receber mensagem de texto no terminal virtual.

- **REQ04.** O sistema deve processar as mensagens trocadas conforme previsto no código.

- **REQ05.** O sistema deve implementar a função 'JC a16'.

- **REQ06.** O sistema deve implementar a função 'LXI B,d16'.

- **REQ07.** O sistema deve implementar a função 'LXI D,d16'.

- **REQ08.** O sistema deve implementar a função 'ADD E'.

- **REQ09.** O sistema deve implementar a função 'MOV E,A'.

- **REQ10.** O sistema deve implementar a função 'ACI d8'.

- **REQ11.** O sistema deve implementar a função 'MOV D,A'.

- **REQ12.** O sistema deve implementar a função 'DAD D'.

- **REQ13.** O sistema deve implementar a função 'MOV E,M'.

- **REQ14.** O sistema deve implementar a função 'XCHG'.

- **REQ15.** O sistema deve implementar a função 'PCHL'.


*O material de apoio e as notas de aulas poderão ser consultadas para se realizar esse laboratório. Os códigos fornecidos pelo professor poderão compor a solução final. Não utilizar códigos da internet.*