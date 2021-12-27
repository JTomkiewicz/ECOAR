#open the file
	li a7, 1024 	#system call for file_open
	la a0, fname 	#address of filename string
	li a1, 0 	# flags: 0-read file
	ecall 		#file descriptor of opened file in a0

#save the file descriptor
	mv s1, a0

#check if file was opened correctly (file_descriptor<>-1)
#...

#read data from file
	li a7, 63	#system call for file_read
	mv a0, s1	#move file descr from s1 to a0
	la a1, buf	#address of data buffer
	li a2, 4048	#amount to read (bytes)
	ecall

#check how much data was actually read
	beq zero,a0, fclose 	#branch if no data is read
#...

#close the file
fclose:
	li a7, 57	#system call for file_close
	mv a0, s1	#move file descr from s1 to a0
	ecall 