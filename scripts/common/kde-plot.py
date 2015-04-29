#!/usr/bin/env python
import sys
import numpy as np
from scipy.stats import kde
import matplotlib.pyplot as plt
if not sys.argv[1:]:
    sys.exit("usage: kde-plot.py <data-file> <bins>")
try:
    bins = int(sys.argv[2])
except IndexError:
    bins = 100
def cli_open(path, *args, **kwargs):
    if path == '-':
        return sys.stdin
    elif path.endswith('.gz'):
        import gzip
        return gzip.open(path, *args, **kwargs)
    elif path.endswith('bz2'):
        import bz2
        return bz2.BZ2File(path, *args, **kwargs)
    elif path.endswith('.xz') or path.endswith('.lzma'):
        import lzma
        return lzma.open(path, *args, **kwargs)
    else:
        return open(path, *args, **kwargs)
with cli_open(sys.argv[1], 'r') as f:
    x = np.asarray([float(line) for line in f])
density = kde.gaussian_kde(x)
xgrid = np.linspace(x.min(), x.max(), 100)
plt.hist(x, bins=bins, normed=True)
plt.plot(xgrid, density(xgrid), 'r-')
plt.show()
