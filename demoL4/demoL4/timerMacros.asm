.listmac
;macro for jmp instructions in isr vector
#define ISR(isr_addr,isr_start_label) .cseg .org isr_addr jmp isr_start_label

;macro for creating a variable
#define LET(variable_name) .dseg variable_name : .byte 1 .cseg

;macro for creating a multi-byte variable
#define LETS(variable_name,number_of_bytes) .dseg variable_name : .byte number_of_bytes .cseg


.MACRO U16_READ ; args - rdH,rdL,rrH,rrL reads rrH:rrL to rdH:rdL
lds @0 , @2 ; read high byte
lds @1 , @3 ; read low byte
.ENDMACRO ; end the macro definition

.MACRO U16_WRITE ; args - rdH,rdL,rrH,rrL writes rrH:rrL to rdH:rdL
sts @0 , @2 ; write high byte
sts @1 , @3 ; write low byte
.ENDMACRO ; end the macro definition

.MACRO U16_CP ; args - rdH,rdL,rrH,rrL compares rdH:rdL to rrH:rdL
CP @1 , @3 ; compare low byte
CPC @0 , @2 ; compare high byte w/ carry bit from low byte
.ENDMACRO ; end the macro definition

.MACRO U16_ADD ; args rdH,rdL,rrH,rrL adds rdH:rdL to rrH:rrL and stores in rdH:rdL
ADD @1 , @3 ; add the low bytes
ADC @0 , @2 ; add the high bytes w/ carry bit from low bytes
.ENDMACRO ; end the macro definition

.MACRO U16_SUB ; args rdH,rdL,rrH,rrL subtracts rrH:rrL from rdH:rdL and stores in rdH:rdL
SUB @1 , @3 ; subtract the low bytes
SBC @0 , @2 ; subtract the high bytes w/ carry bit from low bytes
.ENDMACRO ; end the macro definition