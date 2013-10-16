#!/usr/bin/env python
# vi: set ft=python et sw=2 ts=2:
from os import environ, fstat
from stat import S_ISFIFO
import subprocess as sp
import sys

"""Allows use of `git diff --no-index` with svn.

There are many motivating `git diff` features to warrant this:

  - easy colorize diff (`--color=always, `--color=auto`)
  - automatic color-warning for trailing whitespace
  - patience diff (`--patience`)
  - color word diff (`--color-words`, `--word-diff=color`)
  - full function context (`--function-context`, `-W`)

To use with svn:

  - add svngitdiff.py to your PATH
  - configure `~/.subversion/config` (on Unix-alikes) like so:

      [helpers]
      diff-cmd = svngitdiff.py
"""

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

def DiffIndex(lines):
  """Returns the index of the first line after the '---' and '+++' lines.

  There may be no such lines because:
  - the patterns were not found within a few lines
  - `len(lines)` is too small

  In which case, -1 (negative one) is returned.
  """
  size = len(lines)
  # Inspect a decent number of prefix lines, so that we can skip over any `--stat` lines.
  for i, line in enumerate(lines[:50]):
    if i + 2 < size and line.find('---') >= 0 and lines[i + 1].find('+++') >= 0:
      return i + 2
  return -1

def FDIsPipe(fd):
  return S_ISFIFO(fstat(fd).st_mode)

try:
  args, ells = ExtractL(sys.argv[1:])
  git = environ.get('GIT_EXE', 'git')
  # Use --no-ext-diff: if you want to use a different diff tool,
  # then configure it with svn yourself.
  # No sense in "proxying" many times to the underlying diff tool.
  cmd = [git, 'diff', '--no-index', '--no-ext-diff'] + args
  p = sp.Popen(cmd, stdout=sp.PIPE, stderr=sp.PIPE)
  stdin = None
  if FDIsPipe(sys.stdin.fileno()):
    stdin = sys.stdin.read()
  stdout, stderr = p.communicate(input=stdin)
except OSError, e:
  sys.exit(str(e))
# Print all of stdout, then all of stderr.
# Lines 0 and 1 are diff and sha1 noise.
# Lines 2 and 3 are where the labels go.
# This way takes care of --color=always.
# Don't try to colorize new '---' lines.
lines = stdout.splitlines()
idx = DiffIndex(lines)
if idx >= 0 and len(ells) >= 2:
  print('--- ' + ells[0])
  print('+++ ' + ells[1])
  for line in lines[idx:]:
    print(line)
else:
  sys.stdout.write(stdout)
if stderr.rstrip('\r\n'):
  sys.stderr.write(stderr)
sys.exit(p.returncode)
