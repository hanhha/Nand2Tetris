#!/usr/bin/env python3

def raise_unknown (arg):
	raise ValueError (arg + " is an invalid argument.")

def pop2D ():
	return decSP () + p2Stack () + "D=M\n"

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

segSymbols = {"argument" : trans_arg,
			  "local"    : trans_lcl,
              "static"   : None,
              "constant" : trans_cons,
              "this"     : trans_this,
              "that"     : trans_that,
              "pointer"  : trans_pnt,
              "temp"     : trans_tmp}
