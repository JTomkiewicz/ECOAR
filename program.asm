###################################
#
# Jakub Tomkiewicz
# Index: 300183
#
# RiscV Project No. 21
# Adding Text
#
####################################

.eqv BMP_FILE_SIZE 230454	# 320 x 240 x 3 + 54
.eqv BYTES_PER_ROW 960		# 320 x 3

.data 

	.align 4
	res:	.space 2
	inFileName: .asciz "source.bmp"
	outFileName: .asciz "dest.bmp"
	image: .space BMP_FILE_SIZE
	input1: .space 80
	input2: .space 80
	input3: .space 80
	msg1: .asciz "\nOnly numbers and dots are allowed. Other symbols will be ignored!\nInput message to print: "
	msg2: .asciz "\nInput starting x: "
	msg3: .asciz "\nInput starting y: "

.text

main:
	# at first read file
	jal	read_bmp

	# display the msg1
	li a7, 4		# system call for print_string
	la a0, msg1		# address of string 
	ecall

	# read the input1
	li a7, 8		# system call for read_string
	la a0, input1		# address of buffer    
	li a1, 80		# max length
	ecall
	
	# display the msg2
	li a7, 4		
	la a0, msg2		
	ecall
	
	# read the input2
	li a7, 8		
	la a0, input2		    
	li a1, 80		
	ecall
	
	# display the msg3
	li a7, 4		
	la a0, msg3		
	ecall
	
	# read the input3
	li a7, 8		
	la a0, input3		    
	li a1, 80		
	ecall
	
	# go to loop throught input1 string
    	la a3, input1		# address of the buffer
    	j goToLoop

saveAndExit:
	# at the end save file
	jal	save_bmp

exit:	li 	a7,10		# terminate the program
	ecall

# ============================================================================
read_bmp:
# description: reads the contents of a bmp file into memory
# arguments: none
# return: none
	addi sp, sp, -4		# push $s1
	sw s1, 0(sp)
	
	# open file
	li a7, 1024
        la a0, inFileName	# file name 
        li a1, 0		# flags: 0-read file
        ecall
	mv s1, a0      		# save the file descriptor

	# read file
	li a7, 63
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

	# close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, 0(sp)		# restore (pop) s1
	addi sp, sp, 4
	jr ra

# ============================================================================
save_bmp:
# description: saves bmp file stored in memory to a file
# arguments: none
# return: none
	addi sp, sp, -4		# push s1
	sw s1, (sp)
	
	# open file
	li a7, 1024
        la a0, outFileName	# file name 
        li a1, 1		# flags: 1-write file
        ecall
	mv s1, a0      		# save the file descriptor

	# save file
	li a7, 64
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

	# close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, (sp)		# restore (pop) $s1
	addi sp, sp, 4
	jr ra

# ============================================================================
put_pixel:
#description: sets the color of specified pixel
#arguments: a0 - x coordinate, a1 - y coordinate, a2 - 0RGB - pixel color
#return: none

	la t1, image		# adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		# file offset to pixel array in $t2
	la t1, image		# adress of bitmap
	add t2, t1, t2		# adress of pixel array in $t2
	
	# pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		# t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		# $t3= 3*x
	add t1, t1, t3		# $t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1		# pixel address 
	
	# set new color
	sb a2,(t2)		# store B
	srli a2,a2,8
	sb a2,1(t2)		# store G
	srli a2,a2,8
	sb a2,2(t2)		# store R

	jr ra
	
# ============================================================================
goToLoop:
#description: loop throught text
#arguments: a0 - address of 1st char of string
#return: none
    la a3, input1 		# str = address of input buffer

whileLoop:    
    lbu t5, (a3)		# *str - store char in t1
    
    beq t5, zero, pastWhile 	# zero register always contains 0 * str == '\0'
    li s0, '0'
    beq t5, s0, drawZero
    li s0, '1'
    beq t5, s0, drawOne
    li s0, '2'
    beq t5, s0, drawTwo
    li s0, '3'
    beq t5, s0, drawThree
    li s0, '4'
    beq t5, s0, drawFour
    li s0, '5'
    beq t5, s0, drawFive
    li s0, '6'
    beq t5, s0, drawSix
    li s0, '7'
    beq t5, s0, drawSeven
    li s0, '8'
    beq t5, s0, drawEight
    #beq t5, s0, drawNine
    #beq t5, s0, drawDot
    addi a3, a3, 1 	     	# a0 = a0 + 1
    b whileLoop
    
pastWhile:
    j saveAndExit

# ============================================================================
drawZero:
# print 0	
	li	a0, 2		# x
	li	a1, 0		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
		
	li	a0, 3
	li	a1, 0
	li 	a2, 0x00000000
	jal	put_pixel

	li	a0, 4
	li	a1, 0
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 5
	li	a1, 0
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 6
	li	a1, 1
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 6
	li	a1, 2
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 6
	li	a1, 3
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 6
	li	a1, 4
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 6
	li	a1, 5
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 6
	li	a1, 6
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 5
	li	a1, 7
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 4
	li	a1, 7
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 3
	li	a1, 7
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 2
	li	a1, 7
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 1
	li	a1, 6
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 1
	li	a1, 5
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 1
	li	a1, 4
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 1
	li	a1, 3
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 1
	li	a1, 2
	li 	a2, 0x00000000
	jal	put_pixel
	
	li	a0, 1
	li	a1, 1
	li 	a2, 0x00000000
	jal	put_pixel
	
	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop
	
# ============================================================================
drawOne:
# print 1	
	li	a0, 2		# x
	li	a1, 0		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 5	
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3	
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop
	
# ============================================================================
drawTwo:
# print 2	
	li	a0, 1		# x
	li	a1, 5		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop
	
# ============================================================================
drawThree:
# print 3	
	li	a0, 1		# x
	li	a1, 1		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 6	
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel

	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop
	
# ============================================================================
drawFour:
# print 4	
	li	a0, 5		# x
	li	a1, 0		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 2	
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel

	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop
	
# ============================================================================
drawFive:
# print 5	
	li	a0, 1		# x
	li	a1, 0		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel

	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop
	
	# ============================================================================
drawSix:
# print 6	
	li	a0, 6		# x
	li	a1, 6		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 5	
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel

	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop
	
drawSeven:
# print 7	
	li	a0, 1		# x
	li	a1, 0		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2	
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6	
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel

	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop

drawEight:
# print 8	
	li	a0, 1		# x
	li	a1, 2		# y
	li 	a2, 0x00000000	# color - 00RRGGBB
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4 		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 0		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 1		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 2		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 3		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 3	
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 4		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 5		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 6		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 5		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 4		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 3		
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 2	
	li	a1, 7		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 6		
	li 	a2, 0x00000000	
	jal	put_pixel
	
	li	a0, 1		
	li	a1, 5	
	li 	a2, 0x00000000	
	jal	put_pixel

	addi a3, a3, 1 	     	# a0 = a0 + 1
	b whileLoop		# go back to while loop