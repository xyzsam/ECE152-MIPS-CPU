.text
main:

ldi $r1, 5
ldi $r2, 2
ldi $r3, 5
sw $r3, 0($r1)
lw $r4, 0($r1)
nop
nop
bgt $r4, $r2, target1
add $r6, $r2, $r3
beq $r1, $r3, target2
target2:
add $r4, $r1, $r2
nop
nop
nop
nop
target1:
nop
nop
nop
nop
add $r0, $r1, $r6
add $r5, $r4, $r1
nop
nop
nop
nop
.data