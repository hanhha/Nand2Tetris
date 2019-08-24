// Nand2Tetris course 
// I/O handling example

	@ 0
	D = !A
	@ 0
	M = D     // R0 = all 1

(RENDER)
	@ 8191
	D = A
	@ 1
	M = D      // R1 = last 16b block of screen (8191)

(CONT_FLUSH_ROW)
	@ 1
	D = M
	@ SCREEN
	D = D + A
	@ 2
	M = D      // R2 = current physical row of screen (SCREEN + 16b block idx)

	@ 0
	D = M      // Load column pixel to D

	@ 2
	A = M
	M = D      // and set pixels in column from D's value

	@ 1
	D = M
	@DONE
	D; JEQ     // Jump to done if at row 0
	@ 1
	M = D - 1  // else set next block of screen ( R1 = R1 - 1)
	@CONT_FLUSH_ROW
	0; JMP     // continue next block

(DONE)
	@DONE
	0; JMP     // next iteration
	
