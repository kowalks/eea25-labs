# Lab 11 - Final

## Instruções

O objetivo do "Laboratório 11 Final" é **compreender minúcias do funcionamento da unidade de controle e avaliar funções complexas do MP8**, utilizando as seguintes ferramentas:
- Proteus **versão 8.9** :: esquema elétrico e simulação
- MP8 :: processador de 8 bits no Proteus

Utilize a estrutura de arquivos apresentada no **Lab 11 Warmup A**.

## Questões

- **Q1.** Na unidade funcional do MP8, o registrador Stack Pointer (SP) é constituído por circuitos integrados contadores, transceptores e portas lógicas, capazes de operar segundos as especificações do MP8, por meio da aplicação de diversos sinais de controle. Explique o funcionamento interno do registrador, descrevendo os tipos de sinais de controle, bem como o fluxo dos bits nos barramentos. Para tanto, tenha em mente as operações de incremento (INC), decremento (DEC), carregamento de dados (LH e LL) e habilitação de dados (EHD e ELD) ou endereços (EAA).

- **Q2.** Na figura 8 da apostila 'MicroIndesign.pdf', tem-se a unidade de controle microprogramada do MP8. Essa unidade é uma máquina sequencial que muda de estado na borda de subida dos pulsos de CLOCK. Suponha que, imediatamente antes de uma borda de subida do pulso, temos as seguintes condições na unidade de controle:
    - Campos do registrador de microcódigo: (A1,A0) = (1,1), (C3,C2,C1,C0) = (0,0,0,1) e Próximo Microendereço = p;
    
    - Saída do Micro PC = a;

    - Saída da Memória de Mapeamento = m;
    
    - Saída do Micro Stack = s.

    Imediatamente após a borda de subida do pulso de CLOCK, determine a saída do Multiplexador de Micro-endereços quando CARRY vale 0 ou 1.

As questões adiante (**Q3 a Q6**) referem-se ao **Lab 11 Warmup A**. 

Simule e explique o funcionamento de cada uma das funções a seguir. Para a simulação, use os resultados do **Lab 11 Warmup A** (.hex e .map compilados com o gmicprog) e desenvolva um programa em assembly (.asm compilado com o zmac) capaz de executar **todas as quatro funções abaixo**. Tome como exemplo os programas de teste da pasta **TESTPROGS**.

- **Q3.** FILLBLOCK (08H)

- **Q4.** MOVBLOCK (10H)

- **Q5.** LONGADD (18H)

- **Q6.** LONGSUB (20H)