.text
main:
ldi $r1, 123
ldi $r2, 123
ldi $r3, 130
beq $r1, $r3, second
beq $r1, $r2, first
bgt $r3, $r1, second

first:
addi $r2, $r2, 10
bgt $r2, $r3, second
halt

second:
addi $r1, $r1, 100
sub $r1, $r1, $r0

.data