# Course: ECE 152 (Spring 2012) - Introduction to Computer Architecture
# Description: calculate Nth Fibonacci number
# Revised: January 12, 2012

.text
main:
ldi $r5,32768
addi $r5,$r5,-2 #push stack

ldia $r1,str1
jal printstr #print input request

jal readint
sw $r3,1($r5) #save input

lw $r1,1($r5)
jal fib
sw $r2,0($r5) #save final answer

ldia $r1,str2
jal printstr #print first part of response

lw $r1,1($r5)
jal printint #print n

ldia $r1,str3
jal printstr #print second part of response

lw $r1,0($r5)
jal printint #print answer

ldi $r2,13 #carriage return
output $r2

halt


readint:
ldi $r2,48 #r2 = 48 (ascii offset)
ldi $r3,0

readloop:
input $r1
ldi $r4,2
ldi $r6,7
sll $r4,$r4,$r6
and $r4,$r4,$r1
beq $r4,$r0,overbad
j readloop

overbad:
output $r1
ldi $r4,10 #line feed character
beq $r1,$r4,retoverbad
j overbad1
retoverbad:
ret

overbad1:
ldi $r4,13 #carriage return
beq $r1,$r4,retoverbad1
j overbad2
retoverbad1:
ret

overbad2:
ldi $r6,3
sll $r4,$r3,$r6 #mutliply by 10
add $r4,$r4,$r3
add $r4,$r4,$r3
add $r3,$r4,$r0 #copy result back to r3
sub $r1,$r1,$r2 #subtract off bias
add $r3,$r3,$r1 #new current int
j readloop


fib:
#$r1 = fib argument
#$r2 = fib return value
#$r3 = return value copy
#$r4 = input copy + immediates

addi $r5,$r5,-3 #push stack
sw $ra,2($r5) #store return address
ldi $r4,2
bgt $r4,$r1,base

notbase:
sw $r1,1($r5) #store input n
addi $r1,$r1,-2 #n-2
jal fib #fib(n-2)
sw $r2,0($r5) #store result
lw $r1,1($r5) #restore input
addi $r1,$r1,-1 #n-1
jal fib #fib(n-1)
lw $r3,0($r5) #restore result
add $r2,$r2,$r3 #return value = fib(n-2) + fib(n-1)
lw $ra,2($r5) #restore return address
addi $r5,$r5,3 #pop stack
ret

base:
add $r2,$r1,$r0 #return input
lw $ra,2($r5)
addi $r5,$r5,3 #pop stack
ret


printstr:
ldi $r3,1
printloop:
lw $r2,0($r1)
beq $r2,$r0,retprintstr
j notnull
retprintstr:
ret

notnull:
add $r1,$r1,$r3
output $r2
j printloop


#r1 = dividend/remainder
#r2 = divisor
#r3 = test
#r4 = quotient

div:
ldi $r4,0 #initialize quotient to 0
ldi $r2,10 #shift 10 left
ldi $r6,27
sll $r2,$r2,$r6

divloop:
ldi $r3,5
beq $r2,$r3,enddiv
j skip

skip:
sub $r3,$r1,$r2 #remainder - divisor
blt $r3,$r0,divless

divgreater:
sub $r1,$r1,$r2 #remainder = remainder - divisor
ldi $r6,1
sll $r4,$r4,$r6
addi $r4,$r4,1 #add 1 into quotient
srl $r2,$r2,$r6
j divloop

divless:
ldi $r6,1
sll $r4,$r4,$r6 #add 0 into quotient
srl $r2,$r2,$r6
j divloop

enddiv:
ret


printint:
addi $r5,$r5,-2 #push stack
ldi $r3,-1
sw $r3,0($r5) #mark top
sw $ra,1($r5)

intloop:
jal div

addi $r5,$r5,-1 #push stack
sw $r1,0($r5) #store remainder on stack
add $r1,$r4,$r0 #move quotient into new dividend
beq $r1,$r0,outputint
j intloop

outputint:
ldi $r2,48 #ascii offset = 48
outputloop:
lw $r1,0($r5)
addi $r5,$r5,1 #pop stack
ldi $r3,-1
beq $r1,$r3,finishoutput
j outputloop1
finishoutput:
lw $ra,0($r5)
addi $r5,$r5,1
ret

outputloop1:
add $r1,$r1,$r2
output $r1
j outputloop


.data
str1:
.char G
.char i
.char v
.char e
.word 32	# ASCII space
.char m
.char e
.word 32	# ASCII space
.char n
.word 58	# ASCII :
.word 0		# ASCII null to end string
str2:
.char f
.char i
.char b
.word 40	# ASCII (
.word 0		# ASCII null to end string
str3:
.word 41	# ASCII )
.word 32	# ASCII space
.char =
.word 32	# ASCII space
.word 0		# ASCII null to end string
