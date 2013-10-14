#!/usr/bin/env python
# vi: set ft=python et sw=2 ts=2:
import os
import sys
import subprocess as sp

def ExtractL(args):
  """A simple attempt to extract -L "label" and -L"label"."""
  isL = False
  new_args = []
  ells = []
  for arg in args:
    if isL:
      ells.append(arg)
      isL = False
    else:
      if arg == '-L':
        isL = True
      elif arg.startswith('-L'):
        ells.append(arg[2:])
      else:
        new_args.append(arg)
  return (new_args, ells)

try:
  args, ells = ExtractL(sys.argv[1:])
  cmd = ['git', 'diff', '--no-index'] + args
  p = sp.Popen(cmd, stdout=sp.PIPE, stderr=sp.PIPE)
  stdout, stderr = p.communicate()
except OSError, e:
  sys.exit(str(e))
if len(ells) < 2:
  sys.stdout.write(stdout)
else:
  for i, line in enumerate(stdout.splitlines()):
    # Lines 0 and 1 are diff and sha noise.
    # Lines 2 and 3 are where the labels go.
    # This way takes care of --color=always.
    if i == 2:
      assert line.find('---') >= 0, 'Line: ' + line
      print('--- ' + ells[0])
    elif i == 3:
      assert line.find('+++') >= 0, 'Line: ' + line
      print('+++ ' + ells[1])
    elif i >= 4:
      print line
if stderr.rstrip('\n'):
  sys.stderr.write(stderr)
sys.exit(p.returncode)
