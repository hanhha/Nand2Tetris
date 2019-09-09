#!/usr/bin/env python3

# Ha Minh Tran Hanh

import os
import sys
from datetime import datetime

from argparse import ArgumentParser
from vmt import (line_parser, code) 

def translate (filename, ofile):
	sourcelines  = list ()
	if os.path.isfile (filename):
		# Build symbol table first
		with open (filename) as f:
			pc = 0
			lineno = 1
			for line in f:
				cmd_strt = line_parser.line_parser(line).type()
				sourcelines.append({"no" : lineno, "code": line, "struct": cmd_strt})
				lineno += 1

		# Translates commands
		engine = code.code (os.path.splitext(os.path.basename(filename))[0])
		for line in sourcelines:
			if line["struct"] is not None:
				if (line["struct"]["type"] != "E"):
					acode = engine.translate (line["struct"])
					if acode is not None:
						if args.debug:
							debug_info = f'{line["code"]}'
							ofile.write ("// " + debug_info)
						ofile.write(acode) 
				else:
					raise ValueError (f'Invalid syntax:\n Line {line["no"]} : {line["code"]}')
	else:
		print ("No " + filename + "file.")

parser = ArgumentParser ()
parser.add_argument ("-d", "--debug", action = 'store_true', default = False, help = "Add VM commands as comments in ASM file") 
parser.add_argument ('-o', '--output', type=str, help = "Specify output filename")
parser.add_argument ("input", metavar="Filename(s) or folder", type=str, help = "VM filename")

args = parser.parse_args ()
filenames = []

if os.path.isdir(args.input):
	basename = args.input
	for r, d, f in os.walk (args.input):
		for file in f:
			if '.vm' in file:
				filenames.append (os.path.join (r, file))
else:
	basename = os.path.splitext (args.input)[0]
	filenames = [args.input]

outname  = basename + '.' + "asm" if args.output == None else args.output

print ("Translating %s to %s ... "%(args.input, outname))

ofile = open (outname, 'w')

if len(filenames) > 1:
	ofile.write ("//Init code\n" + code.code.init_gen () + "\n")

for filename in filenames:
	try:
		translate (filename, ofile)
	except ValueError:
		print (ValueError)

ofile.close ()

print ("Done.")
