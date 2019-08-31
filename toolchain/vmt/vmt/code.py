#!/usr/bin/env python3

import sys
from .spec import *

class code (object):
	def __init__ (self, prefix = ""):
		self.bool_num = 0
		self.prefix = prefix

	def translate (self, cmd_strt):
		if cmd_strt ["type"] == "AR":
			return self.ar_trans (cmd_strt ["arg1"])
		elif cmd_strt ["type"] == "PU" or cmd_strt ["type"] == "PO":
			return self.me_trans (cmd_strt ["type"], cmd_strt ["arg1"], cmd_strt ["arg2"])
		else:
			return None

	def ar_trans (self, cmd):
		if cmd == "add": #pop stack to D; add D to sp* then store back to sp
			asm = pop2D () + p2Stack_1 () + "M=M+D\n"
		elif cmd == "sub":
			asm = pop2D () + p2Stack_1 () + "M=M-D\n"
		elif cmd == "eq" or cmd == "gt" or cmd == "lt":
			asm = self.bool_gen (cmd)
		elif cmd == "and":
			asm = pop2D () + p2Stack_1 () + "M=M&D\n"
		elif cmd == "or":
			asm = pop2D () + p2Stack_1 () + "M=M|D\n"
		elif cmd == "neg":
			asm = p2Stack_1 () + "M=-M\n"
		elif cmd == "not":
			asm = p2Stack_1 () + "M=!M\n"
		return asm

	def bool_gen (self, cmd):
		asm = pop2D () + p2Stack_1 () + "D=M-D\n"
		asm = asm + "@" + self.prefix + "_BOOL_TRUE." + str (self.bool_num) + "\n"
		if cmd == "eq":
			asm = asm + "D;JEQ\n"
		elif cmd == "gt":
			asm = asm + "D;JGT\n"
		elif cmd == "lt":
			asm = asm + "D;JLT\n"
		asm = asm + "@SP\nA=M-1\nM=0\n"
		asm = asm + "@" + self.prefix + "_BOOL_END." + str (self.bool_num) + "\n"
		asm = asm + "0;JMP\n"
		asm = asm + "(" + self.prefix + "_BOOL_TRUE." + str (self.bool_num) + ")\n"
		asm = asm + "@SP\nA=M-1\nM=0\nM=-1\n(" + self.prefix + "_BOOL_END." + str (self.bool_num) + ")\n"
		self.bool_num += 1
		return asm

	def me_trans (self, cmd, segment, index):
		if segment == "static":
			asm = "@" + self.prefix + "." + str (index) + "\n"
		else:
			asm = segSymbols [segment] (segment, index) # After this, A and R13 is storing desired address
		if cmd == "PU":
			if segment == "constant":
				asm = asm + "D=A\n" + D2push () 
			else:
				asm = asm + "D=M\n" + D2push () 
		else: #cmd == "PO"
			if segment == "constant" or segment == "pointer" or segment == "temp" or segment == "static":
				asm = pop2D () + asm + "M=D\n"
			else:
				asm = pop2D () + backupD () + asm + store () 
		return asm
