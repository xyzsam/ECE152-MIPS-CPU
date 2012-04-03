.text
main:

ldi $r1, 123
ldi $r2, 100
sw $r1, 0($r2)
lw $r3, 0($r2)
sub $r3, $r3, $r0

.data