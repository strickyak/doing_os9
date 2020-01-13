# Find memory leaks, and other memory errors,
# based on `#define AUDIT_MALLOC_FREE` in malloc.c

# (F=014C)({=FFF1)(U=7FF3)(P=8049)(}=FFF2)

import sys
import re

Match = re.compile('[(]([FM])[=](....)[)]').match

d = {}
for line in sys.stdin:
    line = line.rstrip()
    m = Match(line)
    if m:
        fm, addr = m.groups()

        if fm == 'M':
            if d.get(addr) is not None:
                print "DOUBLE MALLOC", line, d[addr]

            d[addr] = line
        elif fm == 'F':
            if d.get(addr) is None:
                print "DOUBLE FREE", line

            d[addr] = None

for a in d:
    if d.get(a) is not None:
        print 'LEAK', a, d[a]
