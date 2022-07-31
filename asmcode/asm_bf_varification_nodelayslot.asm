.text
main:
#prepare test data
addi $t0 $zero 0x61656165
sw $t0 0x00000000($zero)
sw $t0 0x00000004($zero)
addi $t0 $zero 0x00006165
sw $t0 0x00000008($zero)
addi $t0 $zero 0x00006561
sw $t0 0x00000200($zero)
#prepare parameter
addi $a0 $zero 10
addi $a1 $zero 0x00000000
addi $a2 $zero 2
#addi $a3,$zero,0x00000200 delayslot->18
#call brute_force
jal brute_force
addi $a3,$zero,0x00000200
addi $t0 $zero 1 
sw $t0 0x4000000C($zero) #address of LED

#count some time
addiu $t0 $zero 0x00ffffff
loop_counter:
beq $t0 $zero display
#addi $t0 $t0 -1 delayslot->28
j loop_counter
addi $t0 $t0 -1

#display on DIGI
display:
addi $t0 $zero 3 
sw $t0 0x4000000C($zero) #address of LED
move $a0 $v0 #result now in $a0
addi $s0 $zero 0x40000010 #address of DIGI
move $s1 $v0
addi $s2 $zero 16 #AN
loop_display:
srl $s2 $s2 1
bne $s2 $zero wait_start
addi $s2 $zero 8
wait_start:
addiu $t0 $zero 10000
loop_waitdisplay:
beq $t0 $zero loop_waitdisplay_end
addi $t0 $t0 -1
j loop_waitdisplay
loop_waitdisplay_end:

#encode
sll $v0 $s2 8 #AN now in $v0[11:8]
beq $s2 1 an0
beq $s2 2 an1
beq $s2 4 an2
#AN3=1
sll $t0 $a0 16
j encode
an2:
#AN2=1
sll $t0 $a0 20
j encode
an1:
#AN1=1
sll $t0 $a0 24
j encode
an0:
#AN0=1
sll $t0 $a0 28
encode:
srl $t0 $t0 28
beq $t0 0 case0
beq $t0 1 case1
beq $t0 2 case2
beq $t0 3 case3
beq $t0 4 case4
beq $t0 5 case5
beq $t0 6 case6
beq $t0 7 case7
beq $t0 8 case8
beq $t0 9 case9
beq $t0 10 casea
beq $t0 11 caseb
beq $t0 12 casec
beq $t0 13 cased
beq $t0 14 casee
#f:1110001
addi $v0 $v0 0x71
j encode_end
casee:
#e:1111001
addi $v0 $v0 0x79
j encode_end
cased:
#d:1011110
addi $v0 $v0 0x5e
j encode_end
casec:
#c:0111001
addi $v0 $v0 0x39
j encode_end
caseb:
#b:1111100
addi $v0 $v0 0x7c
j encode_end
casea:
#a:1110111
addi $v0 $v0 0x77
j encode_end
case9:
#9:1101111
addi $v0 $v0 0x6f
j encode_end
case8:
#8:1111111
addi $v0 $v0 0x7f
j encode_end
case7:
#7:0000111
addi $v0 $v0 0x07
j encode_end
case6:
#6:1111101
addi $v0 $v0 0x7d
j encode_end
case5:
#5:1101101
addi $v0 $v0 0x6d
j encode_end
case4:
#4:1100110
addi $v0 $v0 0x66
j encode_end
case3:
#3:1001111
addi $v0 $v0 0x4f
j encode_end
case2:
#2:1011011
addi $v0 $v0 0x5b
j encode_end
case1:
#1:0000110
addi $v0 $v0 0x06
j encode_end
case0:
#0:0111111
addi $v0 $v0 0x3f
encode_end:

sw $v0 0($s0)
j loop_display

brute_force:
##### your code here #####
addi $sp $sp -12
sw $ra 8($sp)
sw $s0 4($sp)
sw $s1 0($sp)
###
sub $s0 $a0 $a2
move $s1 $a2
##
li $t2 0
li $t0 0
loop_i:
bgt $t0 $s0 loop_i_end
#
li $t1 0
loop_j:
bge $t1 $s1 loop_j_end
add $t3 $t0 $t1
add $t3 $a1 $t3
lbu $t3 0($t3)
add $t4 $a3 $t1
lbu $t4 0($t4)
bne $t3 $t4 loop_j_end
addi $t1 $t1 1
j loop_j
loop_j_end:
bne $t1 $s1 if2_end
addi $t2 $t2 1
if2_end:
#
addi $t0 $t0 1
j loop_i
loop_i_end:
##
move $v0 $t2
###
lw $ra 8($sp)
lw $s0 4($sp)
lw $s1 0($sp)
addi $sp $sp 12
jr $ra
