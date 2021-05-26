sub g,00111b
mov c,g
mul c,5
subt: mov a,b 
call addition   ;used to call addition label 
mov d,c
div d,4
print " Name : \"Sarvesh\" \n \tRollno. : 343\n"
print g
ext
addition  : ADD g,12
call yes
mov a,d
ret              ;return to last address in stack
mov b,a
ret
yes: 
add a,45
ret



