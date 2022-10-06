# A Stub to develop assembly code using QtSPIM

	# Declare main as a global function
	.globl main 

	# All program code is placed after the
	# .text assembler directive
	.text 		

# The label 'main' represents the starting point
main:
	# Exit the program by means of a syscall.
	# There are many syscalls - pick the desired one
	# by placing its code in $v0. The code for exit is "10"

	# Register Map:
	# $a0 = argument to system call
	# $v0 = System call type or temporary user input
	# $s0 = first user input
	# $s1 = second user input
	# $s2 = coin toss result
	# $s3 = starting address of board array
	
	la $s3, board					# Loading starting address of board array

	la $a0, introMsg				# Loading address of Welcome Message
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the system call

	la $a0, introMsg2				# Loading address of Version Message
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the system call

	la $a0, introMsg3				# Loading address of Implementation Message
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the System call

	la $a0, introMsg4				# Loading address of Asking for 2 Input Message
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the System call

	li $v0, 5						# Setting systemCall to 4 (Read Int)
	syscall							# Executing the System call
	move $s0, $v0					# Moving the first user inputted number into register $s0
	sw $s0,Z						# Save global Z

	li $v0, 5						# Setting systemCall to 4 (Read Int)
	syscall							# Executing the System call
	move $s1, $v0					# Moving the second user inputted number into register $s1
	sw $s1,W						# Save global W	

	la $a0, players					# Loading address of Player and Comp characters
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the System call

	jal get_random					# Jump and Link to get a random number between 0-1
	jal flipCoin					# Jump and Link to use the random number to get a number in range
	move $s2,$v0					# Save the coin toss result

	beq $s2, 1, playerFirst			# If the coin toss lands on 1, jump to playerFirst
	beq $s2, 0, compFirst			# If the coin toss lands on 0, jump to compFirst

	j done							# jump to the done block to exit the program
playerFirst:
	# Block used to print that the coin has been tossed and the player will go first
	# Register Map:
	# $a0 = first argument to print string systemcall
	# $v0 = the system call type
	la $a0, playerCoin				# Loading address of Player Wins Coin Toss
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the System call
	
	jal printBoard					# Print board before asking jumping to player turn
	jal playerTurn					# Jump and Link to function that will deal with User Input
	j mainGame						# Jump to mainGame Function
compFirst:
	# Block used to print that the coin has been tossed and the computer will go first
	# Register Map:
	# $a0 = first argument to print string systemcall
	# $v0 = the system call type
	la $a0, compCoin				# Loading address of Computer wins Coin Toss
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the System call
	
	j mainGame						# Jump to mainGame Function
playerTurn:
	playerLoop:
	# Block used to retreive the user input, and make sure the input is between 0 and 9
	# if it is, it will call the dropToken function to update the board with the user input
	# Register Map:
	# $a0 = User Input
	# $a1 = The token type ('H')
	# $v0 = System call type
		la $a0, playerInput			# Loading address of Asking for user input
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call

		li $v0, 5					# Setting systemCall to 5 (Read Int)
		syscall						# Executing the System call

		bge $v0, 9, playerLoop		# If the user input is greater than 9 ask for input again
		ble $v0, 0, playerLoop		# If the user input is less than 0 ask for input again
		move $s4, $v0				# Move user input to $s4 if between 0 and 9
		move $a0, $s4				# Move user input to $a0 as for dropToken

		addi $sp, $sp, -4			# Create space in stack by subtracting 4
		sw $ra, 0($sp)				# Saving return address into space in stack we created back to main game function
		li $a1, 72					# 'H' in ascii

		jal dropToken				# Jump and link to dropToken function to update board

		lw $ra 0($sp)				# Load the previous return address to return to main game function
		addi $sp, $sp, 4			# fill in space we previously created in the stack by adding 4

		beq $v0, -1, columnFull		# Iterate playerLoop again due to Invalid move due to column full
		jr $ra						# Jump to the return address
		columnFull:
			# Block used to print that the column selected by the player is full
			# Register Map:
			# $a0 = argument to system call
			# $v0 = System call type
			la $a0, colFullMsg		# Loading address of column Full message
			li $v0, 4				# Setting systemCall to 4 (Print String)
			syscall					# Executing the System call
			
			j playerLoop			# Loop through asking player input if the column is full
compTurn:
	compLoop:
	# Block used to retrieve the computer column
	# Register Map:
	# $a0 = the first argument to pass into dropToken Function
	# $v0 = the result from the getRandom function
	# $s4 = the random column for computer
		addi $sp, $sp, -4			# Create space in stack by subtracting 4
		sw $ra, 0($sp)				# Saving return address to return to mainGame function

		jal get_random				# Jump to getRandom function to get random number
		jal compCol					# Use random number to get a number in range

		move $s4, $v0				# Move the result of getRandom into the first argument register
		move $a0, $s4				# moving the random computer column from $s4 into first argument register for dropToken

		li $a1, 67					# Loading the ASCII index of 'C' into second argument register

		jal dropToken				# Jump and link to dropToken function to update board

		lw $ra 0($sp)				# Load the previous return address to the return address of mainGame
		addi $sp, $sp, 4			# fill in space we previously created in the stack by adding 4

		beq $v0, -1, compLoop		# Iterate compLoop again due to Invalid move due to column full

		la $a0, compChoice			# Loading address of Stating the computer chosen column
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call

		li $v0, 1					# Setting System call to print integer
		move $a0, $s4				# moving the random number from $s4 into argument register to be printed
		syscall						# Executing system call

		la $a0, newLine				# Loading address of new line
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call

		jr $ra						# Jump to the return address to get back to mainGame
dropToken:
	# This block is used to drop the token ('H' or 'C') 
	# by updating the current element of board array
	# Block consists of multiple blocks that are in charge
	# of looping through the block/Checking if that location
	# is valid and exiting
	# Register Map:
	# $v0 = the return value
	# $a0 = Token type
	# $a1 = current table element
	# $t0 = iteration register
	# $t1 = board array offset
	# $t2 = updated address of current element of board array
	# $t3 = the next board element
	li $v0, -1						# Loading -1 into $v0
	li $t0, 5						# Loading 5 into $t0
	dropTokenLoop:
		# Block used to loop through checking/calculating the next available cell for token
		# Register Map:
		# $t0 = iteration register
		# $t1 = board array offset
		# $t2 = current address of board array
		# $t3 = current board element value
		beq $t0, -1, dropTokenExit	# If i is equal to -1 jump to dropTokenExit
		mul $t1, $t0, 9				# multiply i by 9 and assigning result to $t1
		add $t1, $a0, $t1			# i * 9 + move index, Needed to multiply by 9 due to being a 1D array
		move $t2, $s3				# Move the base address of board array into $t2
		add $t2, $t2, $t1			# Increment the index of board array by the index previously calculated
		lb $t3, 0($t2)				# loading next table element
		beq $t3, 45, dropTokenValid	# if the next table element is equal to 45, jump to drop token valid function
		addi $t0, $t0, -1			# decrement i by 1
		j dropTokenLoop				# loop through droptokenloop again
	dropTokenExit:
		# Block used to exit the drop Token function entirely
		# Register Map:
		# $ra = return address
		jr $ra						# Jump to the return address
	dropTokenValid:
		# Block used to save the available cell and break out of the droptoken function
		# Register Map:
		# $a1 = the first argument register that holds the value at the current board array
		# $v0 = the return register
		# $ra = return address
		sb $a1, 0($t2)				# save the current table element to $a1
		move $v0, $t1				# Move the index to the $v0 register
		jr $ra						# Jump to the return address
mainGame:
	# Game Loop used to iterate through player and computer turns and print the winner if any
	# Register Map:
	# $t5 = result from isFull Function
	# $s4 = the address of the last played cell
	# $v0 = result from the checkWin Function
	jal isFull						# Jump and link to see if board is full
	bne $t5, 0, done				# Jump to done when board is full

	jal compTurn					# Jump and Link to the compTurn function
	move $s4, $t2					# Moving the last cell of token location into register
	jal printBoard					# Jump and Link to the print board function
	jal checkWin					# Jump and link to check for win after computer turn
	beq $v0, 1, compWin				# if win detected after computer turn jump to compwin Function

	jal playerTurn					# Jump and Link to the playerTurn Function
	move $s4, $t2					# Moving the last cell of token location into register
	jal printBoard					# Jump and Link to the print board function
	jal checkWin					# jump and link to check for win after player turn
	beq $v0, 1, playerWin			# if win detected after player turn jump to player win function

	j mainGame						# Loop through the mainGame function again
	playerWin:
		# Block used to print the board along with the winner of the game
		# Register Map:
		# $a0 = argument to system call
		# $v0 = system call type
		jal printBoard				# jump and link to print board function
		
		la $a0, playerWinMsg		# Loading address of Player Win Message
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call

		j done						# Jump to done
	compWin:
		# Block used to print the board along with the winner of the game
		# Register Map:
		# $a0 = argument to system call
		# $v0 = system call type
		jal printBoard				# jump and link to print board function

		la $a0, compWinMsg			# Loading address of Comp win message
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call

		j done						# Jump to Done
printBoard:
	# Block used to print the board
	# Inner blocks are used to Loop through printing the board
	# as well as exiting the loop when the board has been fully printed
	# Register Map:
	# $a0 = first argument to system call
	# $v0 = system call type
	# $t0 = variable i used to iterate through block
	# $t1 = base address of board array
	# $s3 = base address of board array
	li $t0, 0						# i = 0
	move $t1, $s3					# move the base address of board array into $t1

	la $a0, topHeader				# Loading address of intro message 3
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the System call

	la $a0, bottomHeader			# Loading address of intro message 3
	li $v0, 4						# Setting systemCall to 4 (Print String)
	syscall							# Executing the System call

	printLoop:
		# Block used to loop through each element in the board array
		# Register Map:
		# $t0 = i
		# $t3 = remainder
		# $a0 = argument to systemcall
		# $v0 = system call type
		beq $t0, 53, exitPrintBoard	# Jump to exit print board if i is 53
		li $v0, 11					# Load System call to (Print Char)
		lb $a0, 0($t1)				# Set char to be printed as current element of board array
		syscall						# Executing the System call

		li $t3, 9					# Set temporary register $t3 as 9
		div $t0, $t3				# divide the index by 9
		mfhi $t3					# keep the high remainder
		beq $t3, 8, printNewLine 	# if $t3 is 8 jump to print a new line

		la $a0, space				# Loading address of space
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call
	printLoopEnd:
		# Block used to increment the index of loop and move the board array offset
		# Register Map:
		# $t0 = i
		# $t1 = current address of board array
		addi $t0, $t0, 1			# i++
		addi $t1, $t1, 1			# Increment base address of board array
		j printLoop					# jump to printLoop
	printNewLine:
		# Block used to print a new line after 8 elements of printing the board
		# Register Map:
		# $a0 = argument to systemcall
		# $v0 = system call type
		la $a0, newLine			# Loading address of new line
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call
		j printLoopEnd				# jump to printLoopEnd block
	exitPrintBoard:
		# Block used to exit the printBoard block entirely after printing the board
		# Register Map:
		# $v0 = System Call type
		# $a0 = argument to system call
		# $ra = return address
		li $v0, 11					# Load system call to (Print Char)
		lb $a0, 0($t1)				# print character of the current element of board array
		syscall						# Executing the System call

		la $a0, bottomBoard			# Loading address of space
		li $v0, 4					# Setting systemCall to 4 (Print String)
		syscall						# Executing the System call

		jr $ra						# Jump to return address

get_random:
	# Register map:
	#  $s0 = Z
	#  $s1 = W

	# PUSH onto stack
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $ra,0($sp)		# Save $ra
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $a0,0($sp)		# Save $a0
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $a1,0($sp)		# Save $a1
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $s0,0($sp)		# Save $s0
	addi $sp,$sp,-4		# Adjust stack pointer
	sw $s1,0($sp)		# Save $s1

	li $t0,36969		# $t0 = constant (36969)
	li $t1,18000		# $t1 = constant (18000)
	li $t2,65535		# $t2 = constant (65535)

	lw $s0,Z		# Load global Z from memory
	lw $s1,W		# Load global W from memory

	and $t3,$s0,$t2		# (Z & 65535)
	mul $t3,$t0,$t3		# 36969 * (Z & 65535)  (only lower 32 bits)
	srl $t4,$s0,16		# (Z >> 16)
	addu $s0,$t3,$t4	# Z = 36969 * (Z & 65535) + (Z >> 16)
	sw $s0,Z		# Save global Z

	and $t3,$s1,$t2		# (W & 65535)
	mul $t3,$t1,$t3		# 18000 * (Z & 65535)  (only lower 32 bits)
	srl $t4,$s1,16		# (W >> 16)
	addu $s1,$t3,$t4	# W = 18000 * (Z & 65535) + (W >> 16)
	sw $s1,W		# Save global W	

	sll $t3,$s0,16		# Z << 16
	addu $t3,$t3,$s1	# (Z << 16) + W
	
	# Store random Number in $v0
	move $v0, $t3

	# POP from stack
	lw $s1,0($sp)		# Restore $s1
	addi $sp,$sp,4		# Adjust stack pointer
	lw $s0,0($sp)		# Restore $s0
	addi $sp,$sp,4		# Adjust stack pointer
	lw $a1,0($sp)		# Restore $a1
	addi $sp,$sp,4		# Adjust stack pointer
	lw $a0,0($sp)		# Restore $a0
	addi $sp,$sp,4		# Adjust stack pointer
	lw $ra,0($sp)		# Restore $ra
	addi $sp,$sp,4		# Adjust stack pointer

	# Return
	jr $ra
flipCoin:
	# block used to calculate the random_in_range function in C
	# to mimic a coin toss, by dividing the random number by the range we set
	# Register Map:
	# $v0 = number given by get_random / result
	# $t4 = range : (high - low) + low
	# $ra = return address
	# $sp = space created for the stack
	addi $sp, $sp, -4			# Create space in stack by subtracting 4
	sw $ra, 0($sp)				# Saving return address into space in stack we created

	li $t4, 2					# Loading the range by adding 1 - 0 + 0
	divu $v0, $t4				# Dividing the random number by the range
	mfhi $v0					# Saving the high remainder as the result

	lw $ra 0($sp)				# Load the previous return address to the new return address
	addi $sp, $sp, 4			# fill in space we previously created in the stack by adding 4

	jr $ra						# Jumping back through return address
compCol:
	# block used to calculate the random_in_range function in C
	# to obtain a valid number for the computer's turn by dividing 
	# the random number by the range we set
	# Register Map:
	# $v0 = number given by get_random / result
	# $t4 = range : (high - low) + low
	# $ra = return address
	# $sp = space created for the stack
	addi $sp, $sp, -4			# Create space in stack by subtracting 4
	sw $ra, 0($sp)				# Saving return address into space in stack we created

	li $t4, 7					# Loading the "high" in register $t4
	divu $v0, $t4				# dividing the random number we got from get_random with the high
	mfhi $v0					# saving the high remainder as the result

	addi $v0, $v0, 1			# Adding the low range to the remainder

	lw $ra 0($sp)				# Load the previous return address to the new return address
	addi $sp, $sp, 4			# fill in space we previously created in the stack by adding 4

	jr $ra						# Jumping back through return address
isFull:
	# Block used to check if the board is full
	# Register Map:
	# $t0 = i
	# $t1 = base address of board array
	# $t2 = current element at board[i]
	# $t5 = the return value
	li $t0, 0					# loading $t0 as 0
	move $t1, $s3				# Moving base address of array into $t1
	isFullLoop:
		# Block used to loop through and check the top of each column of the board
		# Register Map:
		# $t0 = iteration register
		# $t1 = board array offset
		# $t2 = value at current board index
		bge $t0, 9, isFullTrue	# exit if i is greater than or equal to 9
	
		addi $t1, $t1, 1		# Add 1 to traverse through board array
		lb $t2, 0($t1)			# Load the current element character into $t2
		beq $t2, 45, isFullFalse	# exit with return 0 if board[i] is '-'

		addi $t0, $t0, 1		# i++
		j isFullLoop			# Iterate through loop again
	isFullTrue:
		# Block used to set the return value as 1 (True)
		# Register Map:
		# $t5 = return register
		# $ra = return address
		li $t5, 1				# Set $t5 as 1 to say "True"
		jr $ra					# Return back to address this function was called
	isFullFalse:
		# Block used to set the return value as 0 (False)
		# Register Map:
		# $t5 = return register
		# $ra = return address
		li $t5, 0				# Set $t5 as 0 to say "False"
		jr $ra					# Return back to address this function was called
checkWin:
	# Calls check direction 4 times with each call passing in a different parameter
	# In order to check for a win in each possible direction. When a win is detected
	# the register $v0 will be changed
	# $sp = registers for the stack
	# $ra = the return address
	# $a0 = the first argument to the checkDirection function
	# $a1 = the second argument to the checkDirection Function
	# $v0 = the result/return value of the checkDirection/return
	addi $sp, $sp, -4			# Create space in stack by subtracting 4
	sw $ra, 0($sp)				# Saving return address to return to mainGame function

	move $a1, $s4				# save the index of lastCell into argument register 1

	li $a0, -10					# loading first argument as -10 for checkDirection
	jal checkDirection			# Calling checkDirection with two arguments
	beq $v0, 1, checkWinExit	# exit if a win is detected

	li $a0, -9					# loading first argument as -9 for checkDirection
	jal checkDirection			# calling checkDirection with two arguments
	beq $v0, 1, checkWinExit	# exit if a win is detected

	li $a0, -8					# loading first argument as -8 for checkDirection
	jal checkDirection			# calling checkDirection with two arguments
	beq $v0, 1, checkWinExit	# exit if a win is detected

	li $a0, -1					# loading first argument as -1 for checkDirection
	jal checkDirection			# calling checkDirection with two arguments
	beq $v0, 1, checkWinExit	# exit if a win is detected

	li $v0, 0					# set return value to 0
	j checkWinExit				# exit with return value of 0
	checkWinExit:
		# block used to exit from the check win exit block to the saved return address
		# Register map:
		# $sp = stack registers
		# $ra = return address
		lw $ra 0($sp)				# Load the previous return address to the return address of mainGame
		addi $sp, $sp, 4			# fill in space we previously created in the stack by adding 4
		jr $ra					# jump back to return address
checkDirection:
	# Block used to check for win in each possible direction
	# Register Map:
	# $a0 = direction
	# $a1 = index of last cell : board[index]
	# $t0 = base address of board array
	# $t1 = currCell index
	# $t2 = counter
	# $t3 = address of board[currCell]
	# $t4 = i
	# $t5 = value of board[currCell]
	# $s6 = value of board[lastCell]
	# $s7 = holder for lastCell index
	move $t0, $s3				# moving the base address of board array to temporary register
	move $t1, $s3				# Setting another temporary register with base address of array
	li $t2, 1					# Initializing counter as 1
	li $t3, 0					# Reset currCell to 0
	li $t4, 0					# Initializing i as 0
	li $t5, 0					# Initializing value of board[currCell] as 0
	li $s6, 0					# Initializing value of board[lastCell] as 0
	li $s7, 0					# Initializing the currCell holder to 0
	sub $t1, $a1, $t1			# Calculating the index of the last cell by subtracting the lastCell address
	move $s7, $t1				# Moving the calculated currCell into register
	lb $s6, 0($a1)				# value of board[lastCell]
	checkDirectionLoop:
		# Block used to iterate in the specified direction and determine if the next index is the same
		# Register Map:
		# $a0 = direction
		# $a1 = last played address array
		# $s7 = index of last played cell
		# $s6 = value of board[lastCell]
		# $t5 = value at board[currcell]
		# $t4 = iteration register
		# $t3 = address of last played cell
		bge $t4, 2, DirectionExit	# exit loop if i is greater than equal to 2
		
		move $t3, $a1
		add $t3, $a1, $a0		# inialzing currCell as lastCell + direction
		lb $t5, 0($t3)			# value of board[currCell]

		move $t1, $s7			# Moving the currCell into temporary register
		add $t1, $t1, $a0		# Index : currCell += direction

		beq $t5, $s6, DirectionWhile		# jump to while loop of check direction
		j ContinueLoop			# if reached here, skip while Loop
		DirectionWhile:
			# Block used to iterate and detect if the next cell is also the same type to detect a win
			# Register Map:
			# $a0 = direction
			# $s6 = value of board[lastCell]
			# $s5 = register used to divide by the currCell
			# $t5 = value at board[currcell]
			# $t3 = address of last played cell
			# $t2 = counter
			# $t1 = index of the current cell
			bne $t5, $s6, ContinueLoop		# jump to exit while loop of check direction
			addi $t2, $t2, 1	# counter++
			
			li $s5, 9			# inializing $s5 as 9 to divide
			div $t1, $s5		# currCell % maxCol
			mfhi $s5			# saving the remainder in register $s5

			beq $s5, 0, DirectionExit		# break if remainder is 0
			beq $s5, 8, DirectionExit		# break if remainder is 8

			add $t1, $t1, $a0	# currCell += direction

			blt $t1, 0, DirectionExit		# Break if currCell is less than 0

			add $t3, $s3, $t1	# calculate the board offset by adding the base address by currCell
			lb $t5, 0($t3)		# Value of board[currCell]

			j DirectionWhile	# Loop through directionwhile block again
		ContinueLoop:
			# Block used to jump out of while loop or skip the while loop
			# Register Map:
			# $a0 = direction
			# $t4 = iteration register
			mul $a0, $a0, -1	# direction *= -1
			addi $t4, $t4, 1	# i++
			j checkDirectionLoop			# Loop through again
	DirectionExit:
		# Block used to set the return value and return to the return address
		# Register Map:
		# $v0 = return register
		# $t2 = counter
		# $ra = return address
		bge $t2, 5, CounterTrue	# Return true if counter >= 5
		li $v0, 0				# Load result with 0 if not counter >= 5
		jr $ra					# Jump and return to return address
		CounterTrue:
			# Block used to set the return value to 1 (True) and return to the return address
			# Register Map:
			# $v0 = return value
			# $ra = return address
			li $v0, 1			# Load Result with 1 if counter >= 5
			jr $ra				# Jump and return to return address
done:
	li $v0, 10 # Sets $v0 to "10" to select exit syscall
	syscall # Exit

	# All memory structures are placed after the
	# .data assembler directive
	.data

	# The .word assembler directive reserves space
	# in memory for a single 4-byte word (or multiple 4-byte words)
	# and assigns that memory location an initial value
	# (or a comma separated list of initial values)
	# For example:
	# value:	.word 12
board:		.asciiz "C-------CH-------HC-------CH-------HC-------CH-------H"
topHeader:	.asciiz "  1 2 3 4 5 6 7\n"
bottomHeader:	.asciiz " ---------------\n"
W:			.word 12
Z:			.word 12
introMsg:	.asciiz "Welcome to Connect Four, Five-in-a-Row Variant\n"
introMsg2:	.asciiz "Version 1.0\n"
introMsg3:	.asciiz	"Implemented by Jabez Lee\n"
introMsg4:	.asciiz	"Enter two positive numbers to initialize the random number generator.\n"
playerCoin:	.asciiz	"Coin Toss ... HUMAN goes first.\n"
compCoin:	.asciiz "Coin Toss ... COMPUTER goes first.\n"
newLine:	.asciiz "\n"
players:	.asciiz "Human Player (H)\nComputer Player (C)\n"
space:		.asciiz " "
bottomBoard:.asciiz "\n ---------------\n"
playerInput:.asciiz "What column would you like to drop token into? Enter 1-7: "
compChoice:	.asciiz "Computer chose Column: "
playerWinMsg: .asciiz "HUMAN Won\n"
compWinMsg:	.asciiz "COMPUTER Won\n"
colFullMsg:	.asciiz "Column is full\n"