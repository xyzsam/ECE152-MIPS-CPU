# TSP implementation for MIPS
#
# Notes on register conventions
# ===============
# $r0 = zero
# $r2, $r3 = $v0, $v1
# $r4-$r7 = $a0-$a3
# $r8-$r15 = $t0 -$t7 caller saves
# $r16-$r23 = $s0-$s7 callee saves
# $r24, $r25 = caller saves
# $r28 = pointer to global data
# $r29 = stack pointer
# $r30 = frame pointer
# $r31 = return addr
#
# Global variables, in order from $r28
# numPoints
# xp1, yp1, xp2, yp2...
# minPath
# stl?


.text
#===============MAIN==============================
main:
ldi $r29, 32768
ldi $r28, 1024

# for testing purposes, I'm hard coding some input
# coordinates
ldi $r8, 0
ldi $r9, 0
ldi $r10, 2
ldi $r11, 2
ldi $r12, 2 # numPoints
sw $r12, 0($r28)
sw $r8, 4($r28)
sw $r9, 8($r28)
sw $r10, 12($r28)
sw $r11, 16($r28)

ldi $r4, 0
ldi $r5, 1
jal distance

halt

#===============DISTANCE FORMULA================
distance:
# $a0 = pt1, $a1 = pt2

ldi $r8, 16
sub $r29, $r29, $r8 # push stack down
# save s0-s7?
add $r8, $r4, $r0 # mov a0 to t0
add $r9, $r5, $r0 # mov a1 to t1

# calculate memory offset of pt1 coordinates
ldi $r16, 3
sll $r17, $r8, $r16 # s1 = a0 * 8 : offset of pt1
sll $r18, $r9, $r16 # s2 = a1 * 8 : offset of pt2
addi $r16, $r28, 4
add $r17, $r16, $r17 # pt1_x_addr = ($r28 + 4) + s1
add $r18, $r16, $r18 # pt2_x_addr = ($r28 + 4) + s2

# load in coordinates. use t0-t7 to avoid having to save other registers
lw $r8, 0($r17)
lw $r9, 4($r17)
lw $r10, 0($r18)
lw $r11, 4($r18)
sw $r9, 0($r29) # caller saved registers
sw $r11, 4($r29)
sw $ra, 12($r29) # save $ra
# compute distance
sub $r4, $r8, $r10 # a0 = x1 - x2. put it directly into a0
add $r5, $r4, $r0 # copy a0 into a1 since we are squaring
jal mult
sw $r2, 8($r29) # save result of ($t0)^2
lw $r9, 0($r29) # load caller saved registers
lw $r11, 4($r29)
sub $r4, $r9, $r11 # a1 = y1 - y2, put it directly into a1
add $r5, $r4, $r0
jal mult
lw $r3, 8($r29) # load ($t0)^2
add $r2, $r2, $r3 # add squares, store in $v0
lw $ra, 12($r29)
addi $r29, $r29, 16 # stack
ret

#============BOOTH MULTIPLICATION=================
mult: 
ldi $r15, 8
add $r8, $r4, $r0 # mov a0 to t0. tempM
ldi $r15, 1
sll $r9, $r5, $r15 # tempX = $r5 << 1
ldi $r15, 16 # limit of counter
ldi $r14, 0 # counter = 0
ldi $r13, 3 # used for tempX AND 0x3
ldi $r12, 2 # used for branch comparison
ldi $r11, 1 # used for branch comparison
ldi $r2, 0 # v0 = product register
mult_loop:
beq $r15, $r14, mult_ret # if counter == 16, return
beq $r8, $r0, mult_ret # if the rest of the multiplicand is 0, return
beq $r9, $r0, mult_ret # if the rest of the multiplier is 0, return
and $r10, $r9, $r13 # get lower two bits of multiplier
beq $r10, $r11, addM # if bits = 1, add multiplicand
beq $r10, $r12, subM # if bits = 2, subtract multiplicand
mult_resume:
sll $r8, $r8, $r11
srl $r9, $r9, $r11
addi $r14, $r14, 1
j mult_loop

subM:
sub $r2, $r2, $r8
j mult_resume
addM:
add $r2, $r2, $r8
j mult_resume

mult_ret:
ret



halt

.data
