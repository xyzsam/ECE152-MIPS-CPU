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
ldi $r8, 5
ldi $r9, 4
ldi $r10, 3
ldi $r11, 1
ldi $r12, 2 # numPoints

sw $r8, 0($r28)
sw $r9, 1($r28)
sw $r10, 2($r28)
sw $r11, 3($r28)
sw $r12, 4($r28)

ldi $r4, 1024
ldi $r5, 1028
jal mem_shift_up


lw $r8, 0($r28)
lw $r9, 1($r28)
lw $r10, 2($r28)
lw $r11, 3($r28)
lw $r12, 4($r28)

addi $r8, $r8, 48
addi $r9, $r9, 48
addi $r10, $r10, 48
addi $r11, $r11, 48
addi $r12, $r12, 48

output $r8
output $r9
output $r10
output $r11
output $r12

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
ldi $r16, 1
sll $r17, $r8, $r16 # s1 = a0 * 2 : offset of pt1
sll $r18, $r9, $r16 # s2 = a1 * 2 : offset of pt2
addi $r16, $r28, 1
add $r17, $r16, $r17 # pt1_x_addr = ($r28 + 1) + s1
add $r18, $r16, $r18 # pt2_x_addr = ($r28 + 1) + s2

# load in coordinates. use t0-t7 to avoid having to save other registers
lw $r8, 0($r17)
lw $r9, 1($r17)
lw $r10, 0($r18)
lw $r11, 1($r18)
sw $r9, 0($r29) # caller saved registers
sw $r11, 1($r29)
sw $ra, 3($r29) # save $ra
# compute distance
sub $r4, $r8, $r10 # a0 = x1 - x2. put it directly into a0
add $r5, $r4, $r0 # copy a0 into a1 since we are squaring
jal mult
sw $r2, 2($r29) # save result of ($t0)^2
lw $r9, 0($r29) # load caller saved registers
lw $r11, 1($r29)
sub $r4, $r9, $r11 # a1 = y1 - y2, put it directly into a1
add $r5, $r4, $r0
jal mult
lw $r3, 2($r29) # load ($t0)^2
add $r2, $r2, $r3 # add squares, store in $v0
lw $ra, 3($r29)
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


#==================MEMORY SHIFT DOWN==================
# circularly shifts a block of dmem down by a word. 
# arguments are the starting and end word addresses.
# the last word in the block is moved to the top
mem_shift_down:
ldi $r8, 8 # stack offset
sub $r29, $r29, $r10
lw $r8, 0($r5) # load last word into $r10
sub $r9, $r5, $r4 # size of block - 1
addi $r9, $r9, 1 # size of block
sw $r8, 0($r29) # save last word into mem
ldi $r10, 2 # decrement of 2 words to avoid lots of stalls
ldi $r11, 1 # decrement of 1 word to account for even cases
sw $r16, 1($r29) # callee saved registers
add $r16, $r5, $r0 # $r16 = current location in mem. put it here to avoid stall
sw $r17, 2($r29)
sw $r18, 3($r29)
sw $r19, 4($r29)
mem_shift_down_loop:
beq $r16, $r4, mem_shift_down_ret # if current loc = top of block, return
sub $r17, $r16, $r4 # distance from top of block
beq $r17, $r11, mem_dec_1 # if distance is only 1 word
sub $r16, $r16, $r10 # loop counter, subtract 2 words
lw $r18, 0($r16) # load two words at a time and interleave stores to avoid stalls
lw $r19, 1($r16)
sw $r18, 1($r16)
sw $r19, 2($r16)
j mem_shift_down_loop
mem_shift_down_resume_1:
lw $r18, 0($r16)
sw $r18, 1($r16) # will have to stomach a stall here..
# continue straight to return code then

mem_shift_down_ret:
lw $r8, 0($r29) # load last word
lw $r16, 1($r29) # callee saved registers
lw $r17, 2($r29)
lw $r18, 3($r29)
lw $r18, 4($r29)
sw $r8, 0($r4) # save last word to top block
addi $r29, $r29, 8 # push stack back
ret

mem_dec_1:
sub $r16, $r16, $r11 # subtract 4 instead
j mem_shift_down_resume_1


#==================MEMORY SHIFT UP=========================
# circularly shifts a block of dmem up by a word. 
# arguments are the starting and end word addresses.
# the top word in the block is moved to the down
mem_shift_up:
ldi $r8, 8 # stack offset
sub $r29, $r29, $r10
lw $r8, 0($r4) # load top word into $r10
sub $r9, $r5, $r4 # size of block - 1
addi $r9, $r9, 1 # size of block
sw $r8, 0($r29) # save first word into mem
ldi $r10, 2 # increment of 2 words to avoid lots of stalls
ldi $r11, 1 # increment of 1 word to account for even cases
sw $r16, 1($r29) # callee saved registers
add $r16, $r4, $r0 # $r16 = current location in mem. put it here to avoid stall
sw $r17, 2($r29)
sw $r18, 3($r29)
sw $r19, 4($r29)
mem_shift_up_loop:
beq $r16, $r5, mem_shift_up_ret # if current loc = bottom of block, return
sub $r17, $r5, $r16 # distance from bottom of block
beq $r17, $r11, mem_shift_up_resume_1 # if distance is only 1 word
lw $r18, 1($r16) # load two words at a time and interleave stores to avoid stalls
lw $r19, 2($r16)
sw $r18, 0($r16)
sw $r19, 1($r16)
add $r16, $r16, $r10 # loop counter, add 2 words
j mem_shift_up_loop
mem_shift_up_resume_1:
lw $r18, 1($r16)
sw $r18, 0($r16) # will have to stomach a stall here..

# continue straight to return code then

mem_shift_up_ret:
lw $r8, 0($r29) # load top word
lw $r16, 1($r29) # callee saved registers
lw $r17, 2($r29)
lw $r18, 3($r29)
lw $r18, 4($r29)
sw $r8, 0($r5) # save top word to last block
addi $r29, $r29, 8 # push stack back
ret

halt

.data
