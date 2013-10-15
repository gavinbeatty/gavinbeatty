#!/usr/bin/env python
# vi: set ft=python et sw=2 ts=2:
from os import environ
import sys
import subprocess as sp

def ExtractL(args):
  """A simple attempt to extract -L "label" and -L"label".
  Does not support options with argument as next element, except -L.
  e.g., -U10  # Good!
        -U 10 # Bad!
        --context=10 # Good!
        --context 10 # Bad!
        -La/file.txt  # Good!
        -L a/file.txt # Still good!
  """
  ells = []
  new_args = []
  isL = False # is an argument to -L
  isPass = False # always pass through to new_args
  for arg in args:
    if isPass:
      new_args.append(arg)
    elif arg == '--':
      new_args.append(arg)
      isPass = True
    elif isL:
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
  git = environ.get('GIT_EXE', 'git')
  cmd = [git, 'diff', '--no-index'] + args
  p = sp.Popen(cmd, stdout=sp.PIPE, stderr=sp.PIPE)
  stdout, stderr = p.communicate()
except OSError, e:
  sys.exit(str(e))
# Print all of stdout, then all of stderr.
if len(ells) < 2:
  sys.stdout.write(stdout)
else:
  for i, line in enumerate(stdout.splitlines()):
    # Lines 0 and 1 are diff and sha1 noise.
    # Lines 2 and 3 are where the labels go.
    # This way takes care of --color=always.
    # Don't try to colorize the '---' lines.
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
