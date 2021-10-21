/************************************************************************
 *   LAB7.C                                                             *
 *                                                                      *
 *   MCU alvo: Atmel ATmega2560                                         *
 *   Frequencia: X-TAL : 16 MHz                                         *
 *   Compilador: AVR Assembler 2 (Atmel Studio 7.0)                     *
 *                                                                      *
 *   Implementa projeto de controle de três servomotores diferentes e   *
 *   e de dois LEDs independentes. A arquitetura do sistema composta    *
 *   por dois controladores, "master" e "slave". O controlador master   *
 *   recebe os comandos digitados pelo usuário e envia para o           *
 *   controlador slave para processamento. O controlador slave recebe   *
 *   o comando enviado e processa. Caso seja válido, executa a operação *
 *   requerida. Após, retorna para o controlador master a confirmação   *
 *   de comando ACK ou INVALID se o comando for inválido.               *
 *                                                                      *
 *                             Created: 21/10/2021 13:30:00             *
 ************************************************************************/


#include <avr/io.h>
#include <stdio.h>
#include <math.h>
#include "commit.h"

#define F_CPU 16000000UL

// Function prototype for USART0
void USART0Init(void);
int USART0SendByte(char u8Data, FILE *stream);
int USART0ReceiveByte(FILE *stream);

// Function prototype for USART1
void USART1Init(void);
int USART1SendByte(char u8Data, FILE *stream);
int USART1ReceiveByte(FILE *stream);

// Function prototype for modules "master" and "slave"
void MasterModule(void);
void SlaveModule(void);

void initTempo(void);
void resetServo(void);

// Verifies if char is sign (aka + or -)
int isSign(char c) { return c == '+' || c == '-'; };

// Verifies if char is digit (from '0' to '9')
int isDigit(char d) { return d >= '0' && d <= '9'; }

//  Stream for USART0 and USART1 
FILE usart0_str = FDEV_SETUP_STREAM(USART0SendByte, USART0ReceiveByte, _FDEV_SETUP_RW);
FILE usart1_str = FDEV_SETUP_STREAM(USART1SendByte, USART1ReceiveByte, _FDEV_SETUP_RW);

/* Main function for system. Set ports for input, initialize USART and verifies master or slave */
int main()
{
    // Ports initialization
    DDRL = 0x00;
    DDRF = 0x01;
    DDRH = 0x03;

    // Serial communication initialization
    USART0Init();
    USART1Init();

    if (PINL & (1 << PINL7))
        MasterModule();
    else
        SlaveModule();
}


/* Master Module */
void MasterModule(void)
{
    char c, x, s, a1, a0;
    char str[4];

    // Identify MASTER operation on LED and TERMINAL
    PORTF = 1;
    fprintf(&usart0_str, "%s *** MASTER *** \n\n", LAST_COMMIT);

    while (1)
    {
        fprintf(&usart0_str, "Insert a command to the slave:\n");

        // Receiving command from user and transmitting to slave
        fscanf(&usart0_str, " %c", &c);
        fprintf(&usart0_str, "%c", c);
        fscanf(&usart0_str, " %c", &x);
        fprintf(&usart0_str, "%c", x);
        fscanf(&usart0_str, " %c", &s);
        fprintf(&usart0_str, "%c", s);
        fscanf(&usart0_str, " %c", &a1);
        fprintf(&usart0_str, "%c", a1);
        fscanf(&usart0_str, " %c", &a0);
        fprintf(&usart0_str, "%c", a0);
        
        fprintf(&usart1_str, "%c%c%c%c%c", c, x, s, a1, a0);
        fprintf(&usart0_str, "\n");

        // Receiving status from slave and printing in terminal
        fscanf(&usart1_str, " %c%c%c", &str[0], &str[1], &str[2]);
        if (str[0] == 'I')
        {
            fscanf(&usart1_str, "%c%c%c%c", &str[3], &str[4], &str[5], &str[6]);
            fprintf(&usart0_str, "INVALID\n\n");
        }
        else
        {
            fprintf(&usart0_str, "ACK\n\n");
        }
    }
}

/* Slave Module */
void SlaveModule(void)
{
    char c, x, s, a1, a0;
    unsigned int signal, angle;

    // Enables output for 2 LEDs on PORTR and 3 servos on PORTB
    DDRH = 0x03;
    DDRB = 0xE0;

    // Initialize tempo on MODE 14 to modulate PWM signal and set servos to angle 0°
    initTempo();
    resetServo();

    // Identify SLAVE operation on LED and TERMINAL
    PORTF = 0;
    fprintf(&usart0_str, "%s *** SLAVE *** \n\n", LAST_COMMIT);

    while (1)
    {
        // Listening to new inputs
        fscanf(&usart1_str, " %c%c%c%c%c", &c, &x, &s, &a1, &a0);
        fprintf(&usart0_str, "%c%c%c%c%c\n\n", c, x, s, a1, a0);

        // If it is a valid protocol
        if ((c == 'S') && (x >= '0' && x <= '2') && isSign(s) && isDigit(a1) && isDigit(a0) && (a1 < '9' || a0 == '0'))
        {
            // Returns to MASTER acknowledment 
            fprintf(&usart1_str, "ACK");

            // Compute angle from string to int
            angle = 10 * (a1 - '0') + (a0 - '0');
            if (s == '-')
                angle = -angle;

            // Compute signal for Timer in PWM mode
            signal = round(100 * (270 + angle) / 9) - 1;

            if (x == '0')
                OCR1A = signal;
            else if (x == '1')
                OCR1B = signal;
            else
                OCR1CH = signal;
        }
        else if ((c == 'L') && (x == '0' || x == '1') && (s == 'O') && (a1 == a0) && (a0 == 'F' || a0 == 'N'))
        {
            // Returns to MASTER acknowledment 
            fprintf(&usart1_str, "ACK");

            // Set LED x to ON or OFF depending on a0
            PORTH = (a0 == 'F') ? (~(1 << (x - '0')) & PORTH) : ((1 << (x - '0')) | PORTH);
        }
        else
            fprintf(&usart1_str, "INVALID");
    }
}


/* Initialize Tempo with ICR1 = 39999, PRESCALER/8, MODE 14, 
   starting with active signal for channels A, B and C  */
void initTempo(void)
{
    // Limit for counter 39999
    ICR1 = 39999;

    TCCR1A = (1 << COM1A1) | (0 << COM1A0) | (1 << COM1B1) | (0 << COM1B0) | (1 << COM1C1) | (0 << COM1C0) | (1 << WGM11) | (0 << WGM10);
    TCCR1B = (0 << ICNC1) | (0 << ICES1) | (1 << WGM13) | (1 << WGM12) | (0 << CS12) | (1 << CS11) | (0 << CS10);
    TIMSK1 = (0 << ICIE1) | (0 << OCIE1C) | (0 << OCIE1B) | (0 << OCIE1A) | (0 << TOIE1);
}

/* Start servos in 0° position.  */
void resetServo(void)
{
    OCR1AH = 11;
    OCR1AL = 183;
    OCR1BH = 11;
    OCR1BL = 183;
    OCR1CH = 11;
    OCR1CL = 183;
}




/*******************************************************
 *                     USART METHODS                   *
 *******************************************************/


/* Initialization with 8N1 and 57600bps baud rate */
void USART0Init(void)
{
    UCSR0A = (0 << RXC0) | (0 << TXC0) | (0 << UDRE0) | (0 << FE0) | (0 << DOR0) | (0 << UPE0) | (0 << U2X0) | (0 << MPCM0);
    UCSR0B = (0 << RXCIE0) | (0 << TXCIE0) | (0 << UDRIE0) | (1 << RXEN0) | (1 << TXEN0) | (0 << UCSZ02) | (0 << RXB80) | (0 << TXB80);
    UCSR0C = (0 << UMSEL01) | (0 << UMSEL00) | (0 << UPM01) | (0 << UPM00) | (0 << USBS0) | (1 << UCSZ01) | (1 << UCSZ00) | (0 << UCPOL0);
    UBRR0H = 0x00;
    UBRR0L = 16; // for 57600bps baud rate
}

/* Sends byte in USART0 (to work with fscanf and fprintf) */
int USART0SendByte(char u8Data, FILE *stream)
{
    if (u8Data == '\n')
        USART0SendByte('\r', stream);
    // Wait for previous byte transmission
    while (!(UCSR0A & (1 << UDRE0)))
        ;
    // Send byte
    UDR0 = u8Data;
    return 0;
}

/* Receives byte in USART0 (to work with fscanf and fprintf) */
int USART0ReceiveByte(FILE *stream)
{
    uint8_t u8Data;
    // Wait byte receive
    while (!(UCSR0A & (1 << RXC0)))
        ;
    u8Data = UDR0;
    // Returns received byte
    return u8Data;
}

/* Initialization with 8N1 and 57600bps baud rate */
void USART1Init(void)
{
    UCSR1A = (0 << RXC1) | (0 << TXC1) | (0 << UDRE1) | (0 << FE1) | (0 << DOR1) | (0 << UPE1) | (0 << U2X1) | (0 << MPCM1);
    UCSR1B = (0 << RXCIE1) | (0 << TXCIE1) | (0 << UDRIE1) | (1 << RXEN1) | (1 << TXEN1) | (0 << UCSZ12) | (0 << RXB81) | (0 << TXB81);
    UCSR1C = (0 << UMSEL11) | (0 << UMSEL10) | (0 << UPM11) | (0 << UPM10) | (0 << USBS1) | (1 << UCSZ11) | (1 << UCSZ10) | (0 << UCPOL1);
    UBRR1H = 0x00;
    UBRR1L = 16; // for 57600bps baud rate
}

/* Sends byte in USART1 (to work with fscanf and fprintf) */
int USART1SendByte(char u8Data, FILE *stream)
{
    if (u8Data == '\n')
        USART1SendByte('\r', stream);
    // Wait for previous byte transmission
    while (!(UCSR1A & (1 << UDRE1)))
        ;
    // Send byte
    UDR1 = u8Data;
    return 0;
}

/* Receives byte in USART1 (to work with fscanf and fprintf) */
int USART1ReceiveByte(FILE *stream)
{
    uint8_t u8Data;
    // Wait byte receive
    while (!(UCSR1A & (1 << RXC1)))
        ;
    u8Data = UDR1;
    // Returns received byte
    return u8Data;
}
