# Course: ECE 152 (Spring 2012) - Introduction to Computer Architecture
# Description: read int from keyboard, store int, then print int
# Revised: January 12, 2012

.text
main:
ldi   $r5,32768         # initialize $r5 as stack pointer

ldia $r1,mystring       # load address of mystring into $r1

jal  printstr           # print string starting at Mem[$r1]

jal  readint            # $r3 = read int from keyboard

ldi  $r1,1              #
sub  $r5,$r5,$r1        # push the int onto stack
sw   $r3,0($r5)         #

ldia $r1,otherstring
jal  printstr

lw   $r1,0($r5)         #
ldi  $r2,1              # pop the int off stack
add  $r5,$r5,$r2        #
jal  printint           # print int contained in $r1

ldi  $r2,13             # $r2 = carriage return
output $r2              # print $r2

halt                    # done


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
bgt $r0,$r3,divless

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
sw $r3,0($r5)
sw $r31,1($r5)
ldi $r4,1

intloop:
jal div

addi $r5,$r5,-1 #push stack
sw $r1,0($r5) #store remainder on stack
add $r1,$r4,$r0 #move quotient into new dividend
beq $r1,$r0,outputint
j intloop

outputint:
ldi $r2,48 #ascii offset = 48
ldi $r4,1
outputloop:
lw $r1,0($r5)
addi $r5,$r5,1 #pop stack
ldi $r3,-1
beq $r1,$r3,finishoutput
j outputloop1
finishoutput:
lw $r31,0($r5)
addi $r5,$r5,1
ret

outputloop1:
add $r1,$r1,$r2
output $r1
j outputloop


.data
mystring:
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
otherstring:
.char n
.word 32	# ASCII space
.char =
.word 32	# ASCII space
.word 0		# ASCII null to end string
