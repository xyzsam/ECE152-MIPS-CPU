# TSP implementation for MIPS
#
# Notes on register conventions
# ===============
# $r0 = zero
# $r2, $r3 = $v0, $v1
# $r4-$r7 = $a0-$a3
# $r8-$r15 = $t0 -$t7 caller saves
# $r16-$r23 = $s0-$s7 callee saves
# $r24, $r25 = start and end loc of availablePoints
# $r28 = pointer to global data
# $r29 = stack pointer
# $r30 = frame pointer
# $r31 = return addr
#
# Global variables, in order from $r28
# 0($28) numPoints
# 1($28) minPath
# 2($28) xp1,
# 3($28) yp1,
# 4($28) xp2,
# 5($28) yp2...
# availablePoints


.text
#===============MAIN==============================
main:
# hardcode addresses
ldi $r29, 32768 # stack pointer
ldi $r28, 1024 # start of global data

addi $r29, $r29, -8 # stack
ldi $r13, 268435455 # minPath
sw $r13, 1($r28)

jal input_start
# store in global area
#lw $r0, 0($r24)
#lw $r2, 1($r24)

# manipulation of queue
#addi $r4, $r24, 0
#addi $r5, $r25, 0
#jal mem_shift_up


#addi $r25, $r25, -1 # decrement queue size

# input arguments to find_path
lw $r4, 0($r28)
ldi $r5, -1
ldi $r6, 0
jal find_path

lw $r4, 1($r28)
jal output


addi $r29, $r29, 8
halt

#===============INPUT==========================

input_start:
addi $r29, $r29, -4
ldi $r9, 10 # line feed
ldi $r10, 13 # carriage return
ldi $r11, 44 # comma
sw $ra, 0($r29)
sw $r16, 1($r29)
sw $r17, 2($r29)
jal input_loop # get number of points

sw $r12, 0($r28) # save numPoints
ldi $r18, 1
sll $r14, $r12, $r18 # move numPoints to $r14, multiply by 2 (x and y)
ldi $r15, 0
addi $r16, $r28, 2 # global data offset (1 + 1 for first data point)
add $r24, $r16, $r14

input_coord_loop:
beq $r14, $r15, input_end
ldi $r12, 1
srl $r18, $r15, $r12 # shift by 1
add $r20, $r24, $r18 # add the value to $r24
add $r25, $r0, $r20  # increment $r25 every other time
sw $r18, 0($r20)
ldi $r12, 0
jal input_loop
sw $r12, 0($r16)
addi $r16, $r16, 1 # increment address offset
addi $r15, $r15, 1 # increment counter
#addi $r4, $r12, 0 # output argument
j input_coord_loop

input_loop:
input $r8
output $r8
beq $r8, $r11, input_ret
beq $r8, $r9, input_ret
beq $r8, $r10, input_ret
# $r12 holds the number
addi $r8, $r8, -48
ldi $r13, 3
sll $r17, $r12, $r13 # multiply by 10
add $r17, $r17, $r12
add $r17, $r17, $r12
add $r12, $r17, $r8 # add the number just inputted
j input_loop

input_ret:
ret

input_end:
lw $r17, 2($r29)
lw $r16, 1($r29)
lw $ra, 0($r29)
addi $r29, $r29, 4
ret


#===============OUTPUT=========================
# prints the number in $r4
div:
ldi $r11,0 #initialize quotient to 0
ldi $r9, 10 #shift 10 left
ldi $r13,27
sll $r9,$r9,$r13

divloop:
ldi $r10,5
beq $r9,$r10,enddiv
j skip

skip:
sub $r10,$r8,$r9 #remainder - divisor
bgt $r0,$r10,divless

divgreater:
sub $r8,$r8,$r9 #remainder = remainder - divisor
ldi $r13,1
sll $r11,$r11,$r13
addi $r11,$r11,1 #add 1 into quotient
srl $r9,$r9,$r13
j divloop

divless:
ldi $r13,1
sll $r11,$r11,$r13 #add 0 into quotient
srl $r9,$r9,$r13
j divloop

enddiv:
ret


output:
addi $r8, $r4, 0 # mov $r4 to $r8
addi $r29,$r29,-2 #push stack
ldi $r10,-1
sw $r10,0($r29)
sw $ra,1($r29)
ldi $r11,1

intloop:
jal div

addi $r29,$r29,-1 #push stack
sw $r8,0($r29) #store remainder on stack
add $r8,$r11,$r0 #move quotient into new dividend
beq $r8,$r0,outputint
j intloop

outputint:
ldi $r9,48 #ascii offset = 48
ldi $r11,1
outputloop:
lw $r8,0($r29)
addi $r29,$r29,1 #pop stack
ldi $r10,-1
beq $r8,$r10,finishoutput
j outputloop1
finishoutput:
lw $ra,0($r29)
addi $r29,$r29,1
ret

outputloop1:
add $r8,$r8,$r9
output $r8
j outputloop

#===============FIND PATH======================
# recursively searches for the path that minimizes the distance traveled
# $a0($r4) = pointsLeft, $a1($r5) = prevPoint, $a2($r6) = dist
find_path:
addi $r29, $r29, -8
sw $ra, 0($r29)
sw $r4, 3($r29) # save pointsLeft
sw $r5, 4($r29) # save prevPoint
sw $r6, 5($r29) # save dist

beq $r4, $r0, find_path_ret1 # if (points_left == 0) go to ret1
ldi $r9, 0 # counter = 0

find_path_loop:
beq $r9, $r4, find_path_ret2 # for loop
lw $r20, 0($r24) # ptOut = availablePoints.peek()
sw $r9, 1($r29) # caller saved registers
sw $r20, 2($r29) # save ptOut for when recursion returns
addi $r4, $r24, 0 # arguments to mem_shift_up. we can modify mem_shift_up to just use thesedirectly later.
addi $r5, $r25, 0
jal mem_shift_up # availablePoints.remove()
addi $r25, $r25, -1 # decrease size of queue
lw $r5, 4($r29) # prevPoint argument
addi $r4, $r20, 0 # ptOut argument
jal distance # $r2 = distance(ptOut, prevPoint)
lw $r4, 3($r29)
addi $r4, $r4, -1 # pointsLeft - 1
add $r6, $r6, $r2 # dist = dist + toNextPoint ($r2)
addi $r5, $r20, 0 # move ptout to second argument register
jal find_path # recursive call
lw $r20, 2($r29) # load ptOut
lw $r4, 3($r29) # load pointsLeft
lw $r6, 5($r29) # load dist
lw $r9, 1($r29) # load counter
addi $r25, $r25, 1 # expand size of availablePoints
sw $r20, 0($r25) # availablePoints.add(ptOut)
addi $r9, $r9, 1 # counter ++
#sub $r6, $r6, $r2 # undo the dist+toNextPoint operation
j find_path_loop

lw $ra, 0($r29)
addi $r29, $r29, 8
ret

find_path_ret1:
lw $r8, 1($r28)
bgt $r8, $r6, find_path_new_min # if (minPath > dist)
lw $ra, 0($r29)
addi $r29, $r29, 8
ret

find_path_new_min:
sw $r6, 1($r28) # minPath = dist
lw $ra, 0($r29)
addi $r29, $r29, 8
ret

find_path_ret2:
lw $ra, 0($r29)
addi $r29, $r29, 8
ret

#===============DISTANCE FORMULA================
distance:
# $a0 = pt1, $a1 = pt2
ldi $r8, -1 
beq $r4, $r8, early_ret # if pt1 == -1 return
beq $r5, $r8, early_ret # if pt2 == -2 return
j distance_start

early_ret:
ldi $r2, 0
ret

distance_start:
addi $r29, $r29, -16  # push stack down
# save s0-s7?
add $r8, $r4, $r0 # mov a0 to t0
add $r9, $r5, $r0 # mov a1 to t1

# calculate memory offset of pt1 coordinates
ldi $r16, 1
sll $r17, $r8, $r16 # s1 = a0 * 2 : offset of pt1
sll $r18, $r9, $r16 # s2 = a1 * 2 : offset of pt2
addi $r16, $r28, 2
add $r17, $r16, $r17 # pt1_x_addr = ($r28 + 2) + s1
add $r18, $r16, $r18 # pt2_x_addr = ($r28 + 2) + s2

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

#=================BOOTH MULTIPLICATION=================
mult: 
addi $r8, $r4, 0 # mov a0 to t0. tempM
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
addi $r29, $r29, -8 # stack
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
addi $r29, $r29, -8
lw $r8, 0($r4) # load top word into $r10
sub $r9, $r5, $r4 # size of block - 1
addi $r9, $r9, 1 # size of block
sw $r8, 0($r29) # save first word into mem
ldi $r10, 2 # increment of 2 words to avoid lots of stalls
ldi $r11, 1 # increment of 1 word to account for even cases
sw $r16, 1($r29) # callee saved registers
sw $r17, 2($r29)
sw $r18, 3($r29)
sw $r19, 4($r29)
add $r16, $r4, $r0 # $r16 = current location in mem. 
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
