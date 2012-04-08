.text
main:

ldi $r1, 1
nop
nop
nop
nop
ldi $r2, 2
nop
nop
nop
nop
nop
add $r3, $r1, $r2
nop
nop
nop
nop
nop
sub $r3, $r3, $r0 #test subtract AND read $r3
and $r4, $r1, $r2
sub $r4, $r4, $r0 # read $r4
or $r5, $r1, $r2
sub $r5, $r5, $r0
sll $r6, $r2, $r1
sub $r6, $r6, $r0
srl $r7, $r2, $r1
sub $r7, $r7, $r0

.data