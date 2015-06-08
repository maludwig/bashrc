#!/usr/bin/python
import re
import sys
import argparse

parser = argparse.ArgumentParser(description='Search with Python regular expressions')
parser.add_argument('-I', '--insensitive', action='store_true', help="Case insensitive search")
parser.add_argument('-n', '--noisy', action='store_true', help="Print only matching input")
parser.add_argument('-f', '--file', default=sys.stdin, type=argparse.FileType('r'), help="Input file")
parser.add_argument('-o', '--output', default=sys.stdout, type=argparse.FileType('w'), help="Output file")
parser.add_argument('needle',help="Regex to find")
parser.add_argument('replace',nargs='?',default="",help="(Optional) replacement regex, supports \\1 notation")

args = parser.parse_args()

sys.stderr.write("Needle: /%s/\n" % args.needle)
sys.stderr.write("Replace: /%s/\n" % args.replace)
sys.stderr.write("Insensitive: /%s/\n" % args.insensitive)
sys.stderr.write("Noisy: /%s/\n" % args.noisy)

if args.insensitive:
	rneedle = re.compile(args.needle,re.IGNORECASE)
else:
	rneedle = re.compile(args.needle)

instream = args.file
outstream = args.output;

print "Replace: |%s|" % args.replace
if args.replace:
	# REPLACERS
	for line in instream.readlines():
		if rneedle.search(line):
			outstream.write("%s" % rneedle.sub(args.replace,line))
		else:
			if args.noisy:
				outstream.write(line)
				
else:
	# FINDERS
	for line in instream.readlines():
		if rneedle.search(line):
			outstream.write(line)
