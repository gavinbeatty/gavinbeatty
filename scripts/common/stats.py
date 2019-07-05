#!/usr/bin/env python
from __future__ import print_function
from __future__ import unicode_literals
import codecs
import collections
import datetime
import io
import itertools
import locale
import math
import sys


def identity(x):
    return x


if sys.version_info[0] < 3:
    unistr = unicode
    def unifile(fobj, encoding='utf_8'):
        return io.open(sys.stdin.fileno(), 'rt', encoding=encoding)
    def viewitems(d, **kwargs):
        return d.viewitems(**kwargs)
else:
    unistr = str
    long = int
    def unifile(fobj, encoding='utf_8'):
        return io.TextIOWrapper(sys.stdin.buffer, encoding=encoding)
    def viewitems(d, **kwargs):
        return d.items(**kwargs)


def number(s):
    f = float(s)
    l = long(f)
    if f == l:
        return l
    return f


def timestamp(s):
    # If we get 7 post-second digits, round to 6 digits.
    if len(s) == 16:
        seconds = s[6:]
        if seconds:
            s = s[:6] + '{:02.6f}'.format(round(float(seconds), 6))
    try:
        dt = datetime.datetime.strptime(s, '%H:%M:%S.%f')
    except ValueError:
        dt = datetime.datetime.strptime(s, '%H:%M:%S')
    return dt.time()


def categorize_kind(s, kinds):
    for kind, convfmt in viewitems(kinds):
        conv, fmt = convfmt
        try:
            return (kind, conv(s))
        except:
            pass
    raise RuntimeError('no kind for {!r}: tried {!r}'.format(s, list(viewitems(kinds))))


def main():
    kinds = collections.OrderedDict()
    kinds['timestamp'] = (timestamp, datetime.time.isoformat)
    kinds['number'] = (number, unistr)
    kinds['identity'] = (identity, unistr)
    values = []
    count = 0
    stdiniter = iter(unifile(sys.stdin))
    line = next(stdiniter, None)
    if line is None:
        return
    line = line.rstrip()
    split = line.split(',')
    head, tail = split[0], split[1:]
    kind, value = categorize_kind(head, kinds)
    conv, fmt = kinds[kind]
    values.append((value, tail))
    count += 1
    print('kind:', kind)
    for line in stdiniter:
        line = line.rstrip()
        split = line.split(',')
        head, tail = split[0], split[1:]
        value = conv(head)
        values.append((value, tail))
        count += 1
    values = sorted(values)
    print('count:', count)
    percentiles = (0.00, 0.01, 0.05, 0.25, 0.50, 0.75, 0.95, 0.99, 1.00)
    indices = [max(0, min(count - 1, int(count * p))) for p in percentiles]
    for p, i in zip(percentiles, indices):
        value, tail = values[i]
        print('{:.02f}ile: {}'.format(p, ','.join(itertools.chain((fmt(value),), tail))))
    if kind in {'number'}:
        total = math.fsum(x[0] for x in values)
        mean = total / count
        print('mean:', fmt(mean))
        if count > 1:
            stddev = math.sqrt(math.fsum((xi - mean) ** 2 for xi, tail in values) / (count - 1))
            print('stddev:', fmt(stddev))


if __name__ == '__main__':
    main()
