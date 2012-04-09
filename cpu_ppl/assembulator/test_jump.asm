.text
main:

ldi $r1, 5
ldi $r2, 2
ldi $r3, 26
nop
nop
nop
nop
add $r4, $r2, $r3
jal target3
target3:
add $r4, $r31, $r1
.data