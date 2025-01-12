                PAGE 0                          ; suppress page headings in ASW listing file

; serial I/O at 19200 bps, N-8-1

                cpu Z8601

CR              equ 0DH
LF              equ 0AH
ESCAPE          equ 1BH

SIO             equ 0F0H            ; serial I/O register
TMR             equ 0F1H            ; timer mode register
T1              equ 0F2H            ; counter/timer 1 regsiter
PRE1            equ 0F3H            ; prescaler 1 register
T0              equ 0F4H            ; counter/timer 0 register
PRE0            equ 0F5H            ; prescaler 0 register
P2M             equ 0F6H            ; port 2 mode register
P3M             equ 0F7H            ; port 3 mode register
P01M            equ 0F8H            ; port 0 and 1 mode register
IPR             equ 0F9H            ; interrupt priority register
IRQ             equ 0FAH            ; interrupt request register
IMR             equ 0FBH            ; interrupt mask register
FLAGS           equ 0FCH            ; flag register
RP              equ 0FDH            ; register pointer
SPH             equ 0FEH            ; stack pointer
SPL             equ 0FFH            ; stack pointer

PORT3           equ  03H
PORT2           equ  02H
PORT1           equ  01H
PORT0           equ  00H

                assume  rp:00H
                
                org 000CH
                srp #00H
                clr IMR            ; clear interrupt mask                
                ld P01M,#10010110B ; program port 1 as AD7-AD0, port 0 as A15-A8, internal stack, normal memory timing

                ld SPL,#68H  
                ld T0,#3           ; timer 0 value for 19200 bps
                ld PRE0,#5         ; prescaler value for 19200 bps
                ld P3M,#01000001B  ; program SERIAL IN, SERIAL OUT, PARITY OFF, port 2 pull-ups active                
                ld TMR,#03         ; start timer 0
                ld FLAGS,#2        ; don't know what this does, but it's necessary for the serial to work
                ei                 ; enable interrupts (for serial polling)
                
loop:           call serin
                call serout
                jp loop
                
serout:         tm IRQ,#00010000B  ; ready to transmit?                
                jr z,serout        ; zero means not ready
                and IRQ,#11101111B ; clear ready bit
                ld SIO,R9          ; load the serial port with the character in R9                
                ret

serin:          tm IRQ,#00001000B  ; serial input ready?
                jr z,serin         ; zero means no character
                and IRQ,#11110111B ; else, clear serial input bit
                ld R9,SIO          ; read character from serial port into R9
                ret
                
                end
