.text
main:


ldi $r1, 10
ldi $r2, 20
nop
nop
nop
nop
sw $r1, 0($r2)
nop
nop
nop
nop
lw $r3, 0($r2)
nop
nop
nop
nop
add $r0, $r3, $r3
nop
nop
nop
nop
.data