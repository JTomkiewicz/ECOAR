###################################
#
# Jakub Tomkiewicz
# Index: 300183
#
# RiscV Project No. 21
# Adding Text
#
####################################

.eqv BMP_FILE_SIZE 230454 # 320 x 240 x 3 + 54
.eqv BYTES_PER_ROW 960 # 320 x 3

.data 

.align 4
res:	.space 2
inFileName: .asciz "source.bmp"
outFileName: .asciz "dest.bmp"

.text

main:

jal	read_bmp

#put red pixel in bottom left corner	
	li	a0, 0		#x
	li	a1, 0		#y
	li 	a2, 0x00FF0000	#color - 00RRGGBB
	jal	put_pixel

#get pixel color - $a0=x, $a1=y, result $v0=0x00RRGGBB
	li	a0, 0		#x
	li	a1, 0		#y
	jal     get_pixel
	
#put green pixel one pixel above	
	li	a0, 0		#x
	li	a1, 1		#y
	li 	a2, 0x0000FF00	#color - 00RRGGBB
	jal	put_pixel

#get pixel color - $a0=x, $a1=y, result $v0=0x00RRGGBB
	li	a0, 0		#x
	li	a1, 1		#y
	jal     get_pixel
	
#put blue pixel one pixel above
	li	a0, 0		#x
	li	a1, 2		#y
	li 	a2, 0x000000FF	#color - 00RRGGBB
	jal	put_pixel
	
#get pixel color - $a0=x, $a1=y, result $v0=0x00RRGGBB
	li	a0, 0		#x
	li	a1, 2		#y
	jal     get_pixel

	jal	save_bmp

exit:	li 	a7,10		#Terminate the program
	ecall

# ============================================================================
read_bmp:
# description: reads the contents of a bmp file into memory
# arguments: none
# return: none
	addi sp, sp, -4		#push $s1
	sw s1, 0(sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 0		#flags: 0-read file
        ecall
	mv s1, a0      # save the file descriptor

#read file
	li a7, 63
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, 0(sp)		#restore (pop) s1
	addi sp, sp, 4
	jr ra

# ============================================================================
save_bmp:
# description: saves bmp file stored in memory to a file
# arguments: none
# return: none
	addi sp, sp, -4		#push s1
	sw s1, (sp)
#open file
	li a7, 1024
        la a0, fname		#file name 
        li a1, 1		#flags: 1-write file
        ecall
	mv s1, a0      # save the file descriptor
	
#check for errors - if the file was opened
#...

#save file
	li a7, 64
	mv a0, s1
	la a1, image
	li a2, BMP_FILE_SIZE
	ecall

#close file
	li a7, 57
	mv a0, s1
        ecall
	
	lw s1, (sp)		#restore (pop) $s1
	addi sp, sp, 4
	jr ra

# ============================================================================
put_pixel:
#description: 
#	sets the color of specified pixel
#arguments: a0 - x coordinate, a1 - y coordinate, a2 - 0RGB - pixel color
#return: none

	la t1, image	#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2	#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 #t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0	#$t3= 3*x
	add t1, t1, t3	#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address 
	
	#set new color
	sb a2,(t2)		#store B
	srli a2,a2,8
	sb a2,1(t2)		#store G
	srli a2,a2,8
	sb a2,2(t2)		#store R

	jr ra

# ============================================================================
get_pixel:
# description: returns color of specified pixel
# arguments: a0 - x coordinate, a1 - y coordinate
# return: a0 - 0RGB - pixel color

	la t1, image		#adress of file offset to pixel array
	addi t1,t1,10
	lw t2, (t1)		#file offset to pixel array in $t2
	la t1, image		#adress of bitmap
	add t2, t1, t2		#adress of pixel array in $t2
	
	#pixel address calculation
	li t4,BYTES_PER_ROW
	mul t1, a1, t4 		#t1= y*BYTES_PER_ROW
	mv t3, a0		
	slli a0, a0, 1
	add t3, t3, a0		#$t3= 3*x
	add t1, t1, t3		#$t1 = 3x + y*BYTES_PER_ROW
	add t2, t2, t1	#pixel address 
	
	#get color
	lbu a0,(t2)		#load B
	lbu t1,1(t2)		#load G
	slli t1,t1,8
	or a0, a0, t1
	lbu t1,2(t2)		#load R
        slli t1,t1,16
	or a0, a0, t1
					
	jr ra