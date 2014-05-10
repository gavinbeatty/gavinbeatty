#!/usr/bin/env python
# vi: set ft=python et sw=2 ts=2:
from __future__ import with_statement
from __future__ import print_function
from __future__ import unicode_literals
from __future__ import absolute_import
from __future__ import division
import sys
import csv
import logging
from collections import OrderedDict
debug = logging.debug

class NoKeyType:
  def __str__(self):
    return '<NoKey>'
NoKey = NoKeyType()

class NoDefaultType:
  def __str__(self):
    raise KeyError("No default for missing key")
NoDefault = NoDefaultType()

def selfstrip(x, *args, **kwargs):
  return x.strip(*args, **kwargs)

def kv(e, sep, ktrim=selfstrip, vtrim=selfstrip):
  es = e.split(sep)
  assert es
  if es[1:2]:
    return ktrim(es[0]), vtrim(sep.join(es[1:]))
  return NoKey, vtrim(e)

class NoKeyError(Exception):
  pass

def add_key_value(keys, x, sep):
  k, v = kv(x, sep)
  if k is NoKey:
    raise NoKeyError("No key-value pair found in '%s' using sep='%s'" % (x, sep))
  if k in keys:
    raise KeyError("Can't add %s=%s: already have %s=%s" % (k, v, k, keys[k]))
  keys[k] = v

class NoDefaultError(Exception):
  pass

def read_header_list(rows):
  allkeys = list()
  for rowkv in rows:
    for k in rowkv.keys():
      if k not in allkeys:
        allkeys.append(k)
  return allkeys

def write_rows(rows, hdrs, out):
  hdrset = set(hdrs)
  for rown, rowkv in enumerate(rows):
    diffkeys = hdrset - set(rowkv.keys())
    allkv = rowkv.copy()
    for k in diffkeys:
      raise NoDefaultError("No default set for %s in row %d" % (k, rown))
    assert len(set(allkv.keys()).difference(hdrset)) == 0
    out.writerow([allkv[k] for k in hdrs])

def read_rows(reader, sep):
  rows = []
  for row in reader:
    rowkvs = OrderedDict()
    for elem in row:
      add_key_value(rowkvs, elem, sep)
    rows.append(rowkvs)
  return rows

def cli_open(name, mode, *args, **kwargs):
  if name == '-':
    if mode.find('r') >= 0:
      return sys.stdin
    else:
      return sys.stdout
  return open(name, mode, *args, **kwargs)

def idx(xs, i, default):
  return (xs[i:i+1] or [default])[0]

def main(argv):
  pathin = argv[1]
  pathout = idx(argv, 2, '-')
  sep = idx(argv, 3, ':')
  dialect = csv.excel
  skip_header = False
  logging.basicConfig(format='%(asctime)s [%(levelname)s] %(message)s', level=logging.DEBUG)
  with cli_open(pathin, 'rb') as fin:
    if fin != sys.stdin:
      sample = fin.read(4098)
      fin.seek(0)
      dialect = csv.Sniffer().sniff(sample)
      skip_header = csv.Sniffer().has_header(sample)
    debug('dialect=%s' % dialect)
    reader = csv.reader(fin, dialect)
    if skip_header:
      next(reader)
    rows = read_rows(reader, sep)
    debug('row count=%d' % len(rows))
  hdrs = read_header_list(rows)
  debug('hdrs=%s' % hdrs)
  with cli_open(pathout, 'wb') as fout:
    writer = csv.DictWriter(fout, hdrs, restval=NoDefault, dialect=dialect)
    writer.writeheader()
    writer.writerows(rows)

if __name__ == '__main__':
  sys.exit(main(sys.argv))
