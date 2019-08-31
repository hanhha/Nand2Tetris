#!/usr/bin/env python3

# Ha Minh Tran Hanh

import os
import sys
from datetime import datetime

from argparse import ArgumentParser
from vmt import (line_parser, code) 

parser = ArgumentParser ()
parser.add_argument ("-d", "--debug", action = 'store_true', default = False, help = "At VM commands as comments in ASM file") 
parser.add_argument ('-o', '--output', type=str, help = "Specify output filename")
parser.add_argument ("filename", metavar="Filename", type=str, help = "VM filename")

args = parser.parse_args ()

basename = os.path.splitext (args.filename)[0]
outname  = basename + '.' + "asm" if args.output == None else args.output

print ("Translating %s to %s ... "%(args.filename, outname))

sourcelines  = list ()
cmdlist      = list ()
symbol_table = dict ()

ofile = open (outname, 'w')

# Build symbol table first
with open (args.filename) as f:
	pc = 0
	lineno = 1
	for line in f:
		cmd_strt = line_parser.line_parser(line).type()
		sourcelines.append({"no" : lineno, "code": line, "struct": cmd_strt})
		lineno += 1

# Translates commands

code = code.code (basename)
for line in sourcelines:
	if line["struct"] is not None:
		if (line["struct"]["type"] != "E"):
			acode = code.translate (line["struct"])
			if acode is not None:
				if args.debug:
					debug_info = f'{line["code"]}'
					ofile.write ("// " + debug_info)
				ofile.write(acode) 
		else:
			sys.exit (f'Invalid syntax:\n Line {line["no"]} : {line["code"]}')

ofile.close ()

print ("Done.")
