#!/usr/bin/env python3

import re

A_pattern  = re.compile (r"@((\d+)|([A-Za-z_.\$:][A-Za-z_.\$:0-9]*))$")
C1_pattern = re.compile (r"([^=^;]+)=([^=^;]+)$")
C2_pattern = re.compile (r"([^=^;]+);([^=^;]+)$")
C3_pattern = re.compile (r"([^=^;]+)=([^=^;]+);([^=^;]+)$")
L_pattern  = re.compile (r"\(([A-Za-z_.\$:][A-Za-z_.\$:0-9]*)\)$")

class line_parser (object):
	def __init__ (self, line):
		self.line = "".join(line.split()) 
		self.line = re.sub (r'\/\/.*\n?', '', self.line)

	def type (self):
		if self.line == "":
			return None
		else:
			if A_pattern.match (self.line):
				match = A_pattern.search (self.line)
				ret = {"type": "A", "symbol" : match.group(1) }
			elif C1_pattern.match (self.line):
				match = C1_pattern.search (self.line)
				ret = {"type": "C", "dest" : match.group(1), "comp" : match.group(2), "jump" : "null"}
			elif C2_pattern.match (self.line):
				match = C2_pattern.search (self.line)
				ret = {"type": "C", "jump" : match.group(2), "comp" : match.group(1), "dest" : "null"}
			elif C3_pattern.match (self.line):
				match = C3_pattern.search (self.line)
				ret = {"type": "C", "jump" : match.group(3), "comp" : match.group(2), "dest" : match.group(1)}
			elif L_pattern.match (self.line):
				match = L_pattern.search (self.line)
				ret = {"type": "L", "symbol" : match.group(1) }
			else:
				ret = {"type": "E"}
			return ret
