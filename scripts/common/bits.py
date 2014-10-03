#!/usr/bin/python
import sys
bases = {'hex': 16, '16': 16, 'dec': 10, '10': 10, 'bin': 2, '2': 2, 'oct': 8, '8': 8}
try:
    base = bases[sys.argv[1]]
except IndexError:
    sys.exit('usage: bits.py <base> <int>...')
except KeyError:
    sys.exit('usage: bits.py <base> <int>...\ne.g., <base> "hex" or "16"')
for i in sys.argv[2:]:
    bs = bin(int(i, base))
    if bs.startswith('0b') or bs.startswith('0B'):
        bs = bs[2:]
    nstrs = []
    for n, b in enumerate(reversed(bs)):
        if b == '1':
            nstrs.append(str(n))
        elif b != '0':
            sys.exit('Binary string %s of base %d int %s has character that is not 0 or 1' % (bs, base, i))
    print(' '.join(nstrs))

