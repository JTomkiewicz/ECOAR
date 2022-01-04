# ============================================================================
#
# Jakub Tomkiewicz
# Index: 300183
#
# RISC-V Project No. 21 Adding Text
#
# ============================================================================

.eqv BMP_FILE_SIZE 230454	# 320 x 240 x 3 + 54
.eqv BYTES_PER_ROW 960		# 320 x 3

.data 

	res:	.space 2
	inFileName: .asciz "source.bmp"
	outFileName: .asciz "dest.bmp"
	image: .space BMP_FILE_SIZE
	input1: .space 80
	msg1: .asciz "\nInput message to print (numbers and dots are be printed, other symbols will be ignored): "
	msg2: .asciz "\nInput starting x (only integer allowed): "
	msg3: .asciz "\nInput starting y (only integer allowed): "

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
	li a7, 4		# system call for print_string
	la a0, msg2		# address of string 
	ecall
	
	# read starting integer (x position)
	li a7, 5		# system call for read_int
	ecall
	
	mv a5, a0		# store int in a5
	
	# display msg3
	li a7, 4		# system call for print_string
	la a0, msg3		# address of string
	ecall
	
	# read starting integer (y position)
	li a7, 5		    		
	ecall
	
	mv a6, a0		# store int in a6
	
	# go to loop throught input1 string
    	la a3, input1		
    	j goToLoop		# jump to loop

saveAndExit:
	# at the end save bmp file
	jal	save_bmp

exit:	li 	a7,10		# terminate program
	ecall

# ============================================================================
read_bmp:
# description: read content of a bmp file into memory
# arguments: none
# return: none
	addi sp, sp, -4		
	sw s1, 0(sp)
	
	# open file
	li a7, 1024
        la a0, inFileName	# file name 
        li a1, 0		# flag 0 (read file)
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
	
	lw s1, 0(sp)		# restore (pop)
	addi sp, sp, 4
	jr ra

# ============================================================================
save_bmp:
# description: saves bmp file from memory to a bmp file
# arguments: none
# return: none
	addi sp, sp, -4		
	sw s1, (sp)
	
	# open file
	li a7, 1024
        la a0, outFileName	# file name 
        li a1, 1		# flag 1 (write file)
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
	
	lw s1, (sp)		# restore (pop)
	addi sp, sp, 4
	jr ra

# ============================================================================
put_pixel:
#description: set the color of given pixel
#arguments: a0 (x coordinate), a1 (y coordinate), a2 (0RGB - pixel color)
#return: none
	la t1, image		# adress of file offset to pixel array
	addi t1, t1, 10
	lw t2, (t1)		# file offset to pixel array in t2
	la t1, image		# adress of bitmap
	add t2, t1, t2		# adress of pixel array in t2
	
	add a0, a0, a5		# !IMPORTANT draw at position x saved in a5
	add a1, a1, a6		# !IMPORTANT draw at position y saved in a6
	
	# pixel address calculation
	li t4, BYTES_PER_ROW
	mul t1, a1, t4 		# t1= y * BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		# t3 = 3 * x
	add t1, t1, t3		# t1 = 3x + y * BYTES_PER_ROW
	add t2, t2, t1		# pixel address 
	
	# set new color
	sb a2, (t2)		# store B
	srli a2, a2, 8
	sb a2, 1(t2)		# store G
	srli a2, a2, 8
	sb a2, 2(t2)		# store R

	jr ra
	
# ============================================================================
goToLoop:
#description: loop throught text
#arguments: a3 (address of 1st char of the input1)
#return: none
    la a3, input1 		# str = address of input buffer

whileLoop:    
    lbu t5, (a3)		# *str - store char
    
    beq t5, zero, pastWhile 	# zero register always contains 0 * str == '\0'
    li s0, '0'			
    beq t5, s0, drawZero	# if char is 0 then draw 0
    li s0, '1'
    beq t5, s0, drawOne		# if char is 1 then draw 1
    li s0, '2'
    beq t5, s0, drawTwo		# if char is 2 then draw 2
    li s0, '3'
    beq t5, s0, drawThree	# if char is 3 then draw 3
    li s0, '4'
    beq t5, s0, drawFour	# if char is 4 then draw 4
    li s0, '5'
    beq t5, s0, drawFive	# if char is 5 then draw 5
    li s0, '6'
    beq t5, s0, drawSix		# if char is 6 then draw 6
    li s0, '7'
    beq t5, s0, drawSeven	# if char is 7 then draw 7
    li s0, '8'
    beq t5, s0, drawEight	# if char is 8 then draw 8
    li s0, '9'
    beq t5, s0, drawNine	# if char is 9 then draw 9
    li s0, '.'
    beq t5, s0, drawDot		# if char is dot then draw dot
    
    addi a3, a3, 1 	     	# go to next char
    
    b whileLoop			# go to the beginning of loop
    
pastWhile:
    j saveAndExit		# after the loop go save the bmp and exit

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
	
	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
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
	
	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
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
	
	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
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
	
	li	a0, 6		
	li	a1, 1		
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
	b whileLoop		# go back to while loop
	
# ============================================================================
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
	b whileLoop		# go back to while loop

# ============================================================================
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
	b whileLoop		# go back to while loop
	
# ============================================================================
drawNine:
# print 9	
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
	b whileLoop		# go back to while loop
	
# ============================================================================
drawDot:
# print .	
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
	
	li	a0, 2		
	li	a1, 1		
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
	
	li	a0, 5		
	li	a1, 1		
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

	addi a3, a3, 1 	     	# next char from string
	addi a5, a5, 8		# print next letter at x + 8
	b whileLoop		# go back to while loop
