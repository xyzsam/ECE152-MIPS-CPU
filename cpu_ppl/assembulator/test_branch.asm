.text
main:

ldi $r1, 5
ldi $r2, 2
ldi $r3, 5
nop
nop
nop
nop
beq $r1, $r2, target1
beq $r1, $r3, target2
target1:
add $r0, $r0, $r0
target2:
add $r4, $r1, $r2
nop
nop
nop
nop

.data