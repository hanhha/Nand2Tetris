#!/usr/bin/env python3

import re

AR_pattern  = re.compile (r"(add|sub|neg|eq|gt|lt|and|or|not)$")
PU_pattern  = re.compile (r"push[\s\t]+([^\s\t]+)[\s\t]+([^\s\t]+)$")
PO_pattern  = re.compile (r"pop[\s\t]+([^\s\t]+)[\s\t]+([^\s\t]+)$")
FU_pattern  = re.compile (r"function[\s\t]+([^\s\t]+)[\s\t]+([^\s\t]+)$")
CA_pattern  = re.compile (r"call[\s\t]+([^\s\t]+)[\s\t]+([^\s\t]+)$")
LB_pattern  = re.compile (r"label[\s\t]+([^\s\t]+)$")
GO_pattern  = re.compile (r"goto[\s\t]+([^\s\t]+)$")
IF_pattern  = re.compile (r"if-goto[\s\t]+([^\s\t]+)$")
RT_pattern  = re.compile (r"return$")

class line_parser (object):
	def __init__ (self, line):
		self.line = re.sub (r'\/\/.*\n?', '', line)
		self.line = self.line.strip() 

	def type (self):
		if self.line == "":
			return None
		else:
			if AR_pattern.match (self.line):
				match = AR_pattern.search (self.line)
				ret = {"type": "AR", "arg1" : match.group(1) }
			elif PU_pattern.match (self.line):
				match = PU_pattern.search (self.line)
				ret = {"type": "PU", "arg1" : match.group(1), "arg2" : int(match.group(2)) }
			elif PO_pattern.match (self.line):
				match = PO_pattern.search (self.line)
				ret = {"type": "PO", "arg1" : match.group(1), "arg2" : int(match.group(2)) }
			elif FU_pattern.match (self.line):
				match = FU_pattern.search (self.line)
				ret = {"type": "FU", "arg1" : match.group(1), "arg2" : int(match.group(2)) }
			elif CA_pattern.match (self.line):
				match = CA_pattern.search (self.line)
				ret = {"type": "CA", "arg1" : match.group(1), "arg2" : int(match.group(2)) }
			elif LB_pattern.match (self.line):
				match = LB_pattern.search (self.line)
				ret = {"type": "LB", "arg1" : match.group(1) }
			elif GO_pattern.match (self.line):
				match = GO_pattern.search (self.line)
				ret = {"type": "GO", "arg1" : match.group(1) }
			elif IF_pattern.match (self.line):
				match = IF_pattern.search (self.line)
				ret = {"type": "IF", "arg1" : match.group(1) }
			elif RT_pattern.match (self.line):
				match = RT_pattern.search (self.line)
				ret = {"type": "RT" }
			else:
				ret = {"type": "E"}
			return ret
