#!/usr/bin/env python3

import sys
from .spec import *

class code (object):
	def __init__ (self, symbol_tbl, start_mem_addr):
		self.symbol_tbl = symbol_tbl
		self.variable_tbl = dict ()
		self.avail_mem_addr = start_mem_addr

	def translate (self, line):
		cmd_strt = line ["struct"]
		lineno   = line ["no"]
		code     = line ["code"]

		if cmd_strt ["type"] == "A":
			try:
				imm = int (cmd_strt["symbol"]) 
			except:
				if cmd_strt["symbol"] in preSymbols:
					imm = preSymbols [cmd_strt["symbol"]]
				elif cmd_strt["symbol"] in self.symbol_tbl:
					imm = self.symbol_tbl [cmd_strt["symbol"]]
				elif cmd_strt["symbol"] in self.variable_tbl:
					imm = self.variable_tbl [cmd_strt["symbol"]]
				else:
					imm = self.avail_mem_addr
					self.variable_tbl [cmd_strt["symbol"]] = imm
					self.avail_mem_addr += 1
			return "0" + f'{imm:015b}'
		elif cmd_strt ["type"] == "C":
			if (cmd_strt["dest"] not in dstCmds) or (cmd_strt["comp"] not in compCmds) or (cmd_strt["jump"] not in jmpCmds):
				sys.exit ("Invalid syntax at line " + str(lineno) + ":\n" + code) 
			dest = dstCmds  [cmd_strt["dest"]]
			comp = compCmds [cmd_strt["comp"]]
			jump = jmpCmds  [cmd_strt["jump"]]
			return "111" + comp + dest + jump
		else:
			return None

