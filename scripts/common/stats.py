#!/usr/bin/env python
from __future__ import print_function
from __future__ import unicode_literals
import codecs
import collections
import datetime
import locale
import math
import sys


DEFAULT_ENCODING = locale.getdefaultlocale()[1]


def from_locale(s):
    return codecs.decode(s, DEFAULT_ENCODING, 'strict')


if sys.version_info[0] < 3:
    unistr = from_locale
    from_stdin = from_locale
    def viewitems(d, **kwargs):
        return d.viewitems(**kwargs)
    def get_argv():
        return [from_locale(s) for s in sys.argv]
else:
    unistr = str
    long = int
    def from_stdin(s):
        return s
    def viewitems(d, **kwargs):
        return d.items(**kwargs)
    def get_argv():
        return sys.argv[:]


def number(s):
    f = float(s)
    l = long(f)
    if f == l:
        return l
    return f


def timestamp(s):
    # If we get 7 post-second digits, trunc to 6 digits.
    if len(s) == 16:
        s = s[:15]
    try:
        dt = datetime.datetime.strptime(s, '%H:%M:%S.%f')
    except ValueError:
        dt = datetime.datetime.strptime(s, '%H:%M:%S')
    return dt.time()


def categorize(s, cats):
    for cat, convfmt in viewitems(cats):
        conv, fmt = convfmt
        try:
            return (cat, conv(s))
        except:
            pass
    raise RuntimeError('no cat for {!r}: tried {!r}'.format(s, list(viewitems(cats))))


def main(argv):
    cats = collections.OrderedDict()
    cats['timestamp'] = (timestamp, datetime.time.isoformat)
    cats['number'] = (number, unistr)
    cats['identity'] = (lambda s: s, unistr)
    values = []
    count = 0
    stdiniter = iter(sys.stdin)
    first = next(stdiniter, None)
    if first is None:
        return
    first = from_stdin(first).rstrip()
    cat, value = categorize(first, cats)
    conv, fmt = cats[cat]
    values.append(value)
    count += 1
    for line in stdiniter:
        line = from_stdin(line).rstrip()
        value = conv(line)
        values.append(value)
        count += 1
    values = sorted(values)
    print('cat:', cat)
    print('count:', count)
    percentiles = (.0, .25, .5, .75, .95, .99, 1.0)
    indices = [max(0, min(count - 1, int(count * p))) for p in percentiles]
    for p, i in zip(percentiles, indices):
        print('{:.02f}ile:'.format(p), fmt(values[i]))
    if cat in {'number'}:
        total = math.fsum(values)
        print('mean:', fmt(total / count))


if __name__ == '__main__':
    main(get_argv())
