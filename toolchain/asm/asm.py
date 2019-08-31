#!/usr/bin/env python3

# Ha Minh Tran Hanh

import os
import sys
from datetime import datetime

from argparse import ArgumentParser
from asm import (line_parser, code) 

parser = ArgumentParser ()
parser.add_argument ("-d", "--debug", action = 'store_true', default = False, help = "Print list file that help to debug") 
parser.add_argument ('-o', '--output', type=str, help = "Specify output filename")
parser.add_argument ("filename", metavar="Filename", type=str, help = "Assembly source filename")

args = parser.parse_args ()

basename = os.path.splitext (args.filename)[0]
listname = basename + '.' + "lst"
outname  = basename + '.' + "hack" if args.output == None else args.output

print ("Assembling %s to %s ... "%(args.filename, outname))

sourcelines  = list ()
cmdlist      = list ()
symbol_table = dict ()

ofile = open (outname, 'w')

lfile = open (listname, 'w') if args.debug else None
if lfile is not None:
	lfile.write ("Symbol table:\n")

# Build symbol table first
with open (args.filename) as f:
	pc = 0
	lineno = 1
	for line in f:
		cmd_strt = line_parser.line_parser(line).type()
		sourcelines.append({"pc" : pc, "no" : lineno, "code": line, "struct": cmd_strt})
		if cmd_strt is not None:
			if cmd_strt ["type"] == "L":
				if cmd_strt["symbol"] not in symbol_table:
					symbol_table [cmd_strt["symbol"]] = pc 
					if lfile is not None:
						lfile.write (f'{pc:15} : {cmd_strt["symbol"]}\n')
				else:
					sys.exit (f'This symbol {cmd_strt["symbol"]} was declared multiple time:\n Line {lineno} : {line}')
			elif cmd_strt ["type"] == "A" or cmd_strt ["type"]  == "C":
				pc += 1
		lineno += 1

# Translates commands
if lfile is not None:
	lfile.write ("\nCommand translation: \n")

code = code.code (symbol_table, 16)
for line in sourcelines:
	if line["struct"] is not None:
		if (line["struct"]["type"] != "E"):
			mcode = code.translate (line)
			if mcode is not None:
				ofile.write(mcode + "\n") 
				debug_info = f'{line["pc"]:015}  :  {mcode}  :  {line["code"]}'
			else:
				debug_info = f'{line["pc"]:015}  :  {" ":16}  :  {line["code"]}'
			if lfile is not None:
				lfile.write (debug_info + "\n")
		else:
			sys.exit (f'Invalid syntax:\n Line {line["no"]} : {line["code"]}')

if lfile is not None:
	lfile.write ("\nVariable allocation table:\n")
	for k,v in code.variable_tbl.items():
		lfile.write (k + " : " + str(v) + "\n")
	lfile.write ("\nCreated at " + datetime.now().strftime ("%d/%m%Y %H:%M:%S") + "\nEOF.\n") 
	lfile.close ()
ofile.close ()

print ("Done.")
