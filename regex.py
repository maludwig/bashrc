#!/usr/bin/python
import re
import sys

r1 = re.compile(sys.argv[1])
for line in sys.stdin.readlines():
	sys.stdout.write("-- %s --" % r1.sub(sys.argv[2],line))
