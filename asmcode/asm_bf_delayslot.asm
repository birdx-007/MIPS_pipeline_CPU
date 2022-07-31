.text
main:
#prepare test data
addi $t0,$zero,0x61656165
sw $t0,0x00000000($zero)
sw $t0,0x00000004($zero)
addi $t0,$zero,0x00006165
sw $t0,0x00000008($zero)
addi $t0,$zero,0x00006561
sw $t0,0x00000200($zero)
#prepare parameter
addi $a0,$zero,10
addi $a1,$zero,0x00000000
addi $a2,$zero,2
#addi $a3,$zero,0x00000200 delayslot->18
#call brute_force
jal brute_force
addi $a3,$zero,0x00000200
#end
end:
j end
nop

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
li $t0 0
li $t2 0
loop_i:
slt $at $s0 $t0
bne $at $zero loop_i_end
#
li $t1 0
loop_j:
slt $at $t1 $s1
beq $at $zero loop_j_end
add $t3 $t0 $t1
add $t3 $a1 $t3
lbu $t3 0($t3)
add $t4 $a3 $t1
lbu $t4 0($t4)
bne $t3 $t4 loop_j_end
#addi $t1 $t1 1 delayslot->52
j loop_j
addi $t1 $t1 1
loop_j_end:
bne $t1 $s1 if2_end
addi $t2 $t2 1
if2_end:
#
#addi $t0 $t0 1 delayslot->60
j loop_i
addi $t0 $t0 1
loop_i_end:
##
move $v0 $t2
###
lw $ra 8($sp)
lw $s0 4($sp)
lw $s1 0($sp)
#addi $sp $sp 12 delayslot->70
jr $ra
addi $sp $sp 12