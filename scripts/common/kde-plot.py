#!/usr/bin/env python
import sys
import numpy as np
from scipy.stats import kde
import matplotlib.pyplot as plt
if len(sys.argv) < 2:
    sys.exit("usage: kde-plot.py <data-file> [<xlabel>] [<ylabel>] [<title>] [<bins>] [<normed>]")
def to_bool(x):
    x = x.lower()
    if x in ('0', 'false', 'no'):
        return False
    if x in ('1', 'true', 'yes'):
        return True
    raise Exception('Unrecognized value for <normed>: ' + x)
xlabel = None
ylabel = None
title = None
histkws = {'normed': True, 'bins': 100}
plotkws = {'antialiased': True}
path = sys.argv[1]
if path != '-':
    title = path
if len(sys.argv) > 2 and sys.argv[2]:
    xlabel = sys.argv[2]
if len(sys.argv) > 3 and sys.argv[3]:
    ylabel = sys.argv[3]
if len(sys.argv) > 4 and sys.argv[4]:
    title = sys.argv[4]
if len(sys.argv) > 5:
    histkws['bins'] = int(sys.argv[5])
if len(sys.argv) > 6:
    histkws['normed'] = to_bool(sys.argv[6])
if not ylabel:
    if histkws['normed']:
        ylabel = 'normalized samples'
    else:
        ylabel = 'samples'
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
with cli_open(path, 'r') as f:
    x = np.asarray([float(line) for line in f])
density = kde.gaussian_kde(x)
xgrid = np.linspace(x.min(), x.max(), 100)
plt.hist(x, **histkws)
if xlabel: plt.xlabel(xlabel)
if ylabel: plt.ylabel(ylabel)
if title: plt.title(title)
plt.plot(xgrid, density(xgrid), 'r-', **plotkws)
plt.show()
