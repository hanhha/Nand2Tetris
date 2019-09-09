#!/usr/bin/env python3

import sys
from .spec import *

class code (object):
	def __init__ (self, prefix = ""):
		self.bool_num = [0] 
		self.ret_num = [0]
		self.prefix = [prefix] 

	@staticmethod
	def init_gen ():
		asm = "@256\nD=A\n@SP\nM=D\n"
		asm = asm + "@RET$Sys.init\nD=A\n" + D2push () # push return-addr
		asm = asm + pushCtx ("Sys.init", 0)
		asm = asm + "(RET$Sys.init)\n"
		return asm

	def translate (self, cmd_strt):
		if cmd_strt ["type"] == "AR":
			return self.ar_trans (cmd_strt ["arg1"])
		elif cmd_strt ["type"] == "PU" or cmd_strt ["type"] == "PO":
			return self.me_trans (cmd_strt ["type"], cmd_strt ["arg1"], cmd_strt ["arg2"])
		elif cmd_strt ["type"] == "FU":
			return self.fu_trans (cmd_strt ["arg1"], cmd_strt["arg2"])
		elif cmd_strt ["type"] == "RT":
			return self.rt_trans ()
		elif cmd_strt ["type"] == "LB":
			return self.lb_trans (cmd_strt ["arg1"])
		elif cmd_strt ["type"] == "GO":
			return self.go_trans (cmd_strt ["arg1"])
		elif cmd_strt ["type"] == "IF":
			return self.if_trans (cmd_strt ["arg1"])
		elif cmd_strt ["type"] == "CA":
			return self.ca_trans (cmd_strt ["arg1"], cmd_strt["arg2"])
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
		asm = asm + "@" + self.prefix[-1] + "$BTRUE$." + str (self.bool_num[-1]) + "\n"
		if cmd == "eq":
			asm = asm + "D;JEQ\n"
		elif cmd == "gt":
			asm = asm + "D;JGT\n"
		elif cmd == "lt":
			asm = asm + "D;JLT\n"
		asm = asm + "@SP\nA=M-1\nM=0\n"
		asm = asm + "@" + self.prefix[-1] + "$BEND$." + str (self.bool_num[-1]) + "\n"
		asm = asm + "0;JMP\n"
		asm = asm + "(" + self.prefix[-1] + "$BTRUE$." + str (self.bool_num[-1]) + ")\n"
		asm = asm + "@SP\nA=M-1\nM=0\nM=-1\n(" + self.prefix[-1] + "$BEND$." + str (self.bool_num[-1]) + ")\n"
		self.bool_num[-1] += 1
		return asm

	def me_trans (self, cmd, segment, index):
		if cmd == "PU" and segment == "constant" and (index in [0, 1, -1]):
			asm = OZM2push (index)
			return asm
		else:
			if segment == "static":
				asm = "@" + self.prefix[0] + "$." + str (index) + "\n"
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

	def fu_trans (self, name, lcl_num):
		asm = "(" + name + ")\n"

		self.prefix.append (name)
		self.bool_num.append (0)

		for i in range(lcl_num):
			asm = asm + OZM2push (0)
		return asm

	def rt_trans (self):
		self.prefix.pop ()
		self.bool_num.pop ()

		asm = popCtx ()
		return asm

	def lb_trans (self, name):
		asm = "(" + self.prefix[0] + "$" + name + ")\n"
		return asm

	def go_trans (self, name):
		asm = "@" + self.prefix[0] + "$" + name + "\n"
		asm = asm + "0;JMP\n"
		return asm

	def if_trans (self, name): 
		asm = pop2D ()
		asm = asm + "@" + self.prefix[0] + "$" + name + "\n"
		asm = asm + "D;JNE\n"
		return asm

	def ca_trans (self, name, arg_nu):
		asm = "@RET$" + self.prefix[-1] + "$" + name + "$." + str(self.ret_num[-1]) + "\nD=A\n" + D2push () # push return-addr
		asm = asm + pushCtx (name, arg_nu)
		asm = asm + "(RET$" + self.prefix[-1] + "$" + name + "$." + str(self.ret_num[-1]) + ")\n"
		self.ret_num [-1] += 1
		return asm
