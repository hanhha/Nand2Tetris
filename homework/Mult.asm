// Nand2Tetris course
// Multiples R0 and R1, store result in R2

// Multipling by adding R0 to itself R2 times

	@ R2
	M = 0       // R2 = 0

	@ R1
	D = M
	@ END
	D; JEQ      // Finish if R1 = 0 ( multiples R0 to 0 )
(CONT)
	@ R0
	D = M       // D = R0
	@ R2
	M = D + M   // R2 = R2 + D (<=> R2 = R2 + R0)
	@ R1
	MD = M - 1  // D = R1 = R1 - 1
	@ CONT
	D; JGT      // continue loop if R1 > 0
(END)
	@END
	0; JMP      // infinite loop ends a hack program 
