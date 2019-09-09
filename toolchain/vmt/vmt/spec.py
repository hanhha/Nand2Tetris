#!/usr/bin/env python3

def raise_unknown (arg):
	raise ValueError (arg + " is invalid.")

def pop2D ():
	return decSP () + p2Stack () + "D=M\n"

# special push 0, 1 and -1 (One Zero MinusOne 2 push)
def OZM2push (val):
	if val not in (0, 1, -1):
		raise_unknown (val)
	else:
		return p2Stack () + "M=" + str(val) + "\n" + incSP ()

def D2push ():
	return p2Stack () + "M=D\n" + incSP ()

def incSP ():
	return "@SP\nAM=M+1\n"

def decSP ():
	return "@SP\nAM=M-1\n"

def p2Stack (): #set A = MEM[SP]
	return "@SP\nA=M\n"

def p2Stack_1 (): #set A = MEM[SP-1]
	return "@SP\nA=M-1\n"

def backupD ():
	return "@R14\nM=D\n"

def store ():
	return "@R14\nD=M\n@R13\nA=M\nM=D\n"

# Address translations
# Desired address must be store to R13
def trans_cons (segment, index):
	return "@" + str (index) + "\n" # A = constant

def trans_lcl (segment, index):
	#LCL + index
	return "@LCL\nD=M\n@" + str(index) + "\nD=A+D\n@R13\nAM=D\n" # Set A = R13 = addr

def trans_arg (segment, index):
	return "@ARG\nD=M\n@" + str(index) + "\nD=A+D\n@R13\nAM=D\n" # Set A = R13 = addr

def trans_this (segment, index):
	return "@THIS\nD=M\n@" + str(index) + "\nD=A+D\n@R13\nAM=D\n" # Set A = R13 = addr

def trans_that (segment, index):
	return "@THAT\nD=M\n@" + str(index) + "\nD=A+D\n@R13\nAM=D\n" # Set A = R13 = addr

def trans_pnt (segment, index):
	if index > 1:
		raise_unknown (index)
	addr = 3 + index
	return "@" + str(addr) + "\n" # A = constant

def trans_tmp (segment, index):
	if index > 7:
		raise_unknown (index)
	addr = 5 + index
	return "@" + str(addr) + "\n" # A = constant

def pushCtx (name, arg_nu):
	asm =       "@LCL\nD=M\n"  + D2push ()       # push LCL
	asm = asm + "@ARG\nD=M\n"  + D2push ()       # "
	asm = asm + "@THIS\nD=M\n" + D2push ()       # "
	asm = asm + "@THAT\nD=M\n" + D2push ()       # "
	asm = asm + "@SP\nD=M\n@" + str (arg_nu + 5) + "\nD=D-A\n@ARG\nM=D\n" # ARG = SP - n - 5
	asm = asm + "@SP\nD=M\n@LCL\nM=D\n"          # LCL = SP
	asm = asm + "@" + name + "\n0;JMP\n"         # goto name
	return asm

def popCtx ():
	asm = "@LCL\nD=M\n@R13\nM=D\n"                    # R13 = LCL
	asm = asm + "@5\nA=D-A\nD=M\n@R15\nM=D\n"         # R15 = RET = *(R13-5) 
	asm = asm + "@SP\nA=M-1\nD=M\n@ARG\nA=M\nM=D\n"   # *ARG = pop () 
	asm = asm + "D=A\n@SP\nM=D+1\n"                   # SP = ARG + 1
	asm = asm + "@R13\nAM=M-1\nD=M\n@THAT\nM=D\n"     # Restore THAT = *(R13 - 1)
	asm = asm + "@R13\nAM=M-1\nD=M\n@THIS\nM=D\n"     # Restore THIS = *(R13 - 2)
	asm = asm + "@R13\nAM=M-1\nD=M\n@ARG\nM=D\n"      # Restore ARG  = *(R13 - 3)
	asm = asm + "@R13\nAM=M-1\nD=M\n@LCL\nM=D\n"      # Restore LCL  = *(R13 - 4)
	asm = asm + "@R15\nA=M\n0;JMP\n"             # Goto return-addr
	return asm

segSymbols = {"argument" : trans_arg,
			  "local"    : trans_lcl,
              "static"   : None,
              "constant" : trans_cons,
              "this"     : trans_this,
              "that"     : trans_that,
              "pointer"  : trans_pnt,
              "temp"     : trans_tmp}
