; demoL4.asm
; Created: 4/21/2025 1:02:42 PM
; Author : Joe Maloney

;include the register address definitions
.include "m328PBdef.inc"
.include "timerMacros.asm"


ISR(0x0,RESET) ; reset entry point
ISR(TIMER1_OVFaddr,TIMER1_COMPA); TOP interrupt

.cseg
.org 0x100

RESET:
rcall config_timer ;init timer
sei; enable interrupts
RESET_L1: ;loop entry point
rjmp RESET_L1 ; infinite loop

TIMER1_COMPA:
.equ increment_size = 5
cli
U16_READ r17, r16, OCR1AH, OCR1AL ;load the current compare A register value to r17:r16

U16_CP r17, r16, r21, r20 ; compare to the TOP value
brge FLIP_DIR ; branch if OCR1A >= TOP

U16_CP r17, r16, r1, r0 ; compare OCR1A to zero 
brlt FLIP_DIR ; branch if OCR1A < 0
breq FLIP_DIR ; branch if OCR1A = 0


TIM1_UPDATE_OCR1A: 
cpi r30, 0x0 ; compare the direction register to zero
breq TIM1_INC ;increment if direction == 0

TIM1_DEC: U16_SUB r17, r16, r19, r18 ; change OCR1A in r17:r16
rjmp TIM1_UPDATE_WRITE

TIM1_INC: U16_ADD r17, r16, r19, r18 ; change OCR1A in r17:r16

TIM1_UPDATE_WRITE:
U16_WRITE OCR1AH, OCR1AL, r17, r16 ; write new value to OCR1A
TIM1_COMPA_RET: sei
reti

FLIP_DIR: com r30 ; flip the direction register
rjmp TIM1_UPDATE_OCR1A

config_timer:
.equ ddr_b = (1<<DDRB1) ;pin 1 on port B as output
.equ config_a = ((1<<WGM11) | (1<<COM1A1)) ;WGM mode fast PWM, clear on compare match when up-counting, set at BOTTOM
.equ config_b = ((1<<WGM13) | (1<<WGM12) | (1<<CS11) | (1<<CS10)) ;WGM mode fast PWM, clock = 16M/64 = 250KHz

clr r30 ;r30 used for direction, r30 = 0x0 is counting up

ldi r16, ddr_b
out DDRB, r16 ; write value to reg 

ldi r16,(1<<TOIE1)
sts TIMSK1, r16; enable TOP interrupt

ldi r16,config_a
sts TCCR1A, r16; write value to reg

clr r16
ldi r17, 0x1
U16_WRITE TCNT1H, TCNT1L, r16, r16 ; clear count
U16_WRITE OCR1AH, OCR1AL, r16, r17 ; set compare A reg to 1

ldi r16, 0x1B
ldi r17, 0x08
U16_WRITE ICR1H, ICR1L, r17, r16 ; set the ICR1 register to 2075 (0x81B) for 120Hz TOP

clr r19 ; used for high byte in increment ISR, always zero
ldi r18, increment_size ; used for low byte in addition

ldi r20, 0x1B
ldi r21, 0x08;store the TOP value in r21:r20

clr r0
clr r1 ; use r1:r0 for comparing to zero in ISR

ldi r16, config_b
sts TCCR1B, r16; write value to reg, start timer
ret

