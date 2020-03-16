#!/usr/bin/env python
# vi: set ft=python et sw=2 ts=2:
from __future__ import division
from __future__ import print_function
from stat import S_ISFIFO
from errno import EPIPE
import codecs
import locale
import os
import shlex
import subprocess as sp
import sys

u"""Allows use of `git diff --no-index` with svn.

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

ENCODING = locale.getpreferredencoding(do_setlocale=False)

def FromLocale(s):
  return s.decode(ENCODING)

def ExtractL(args):
  u"""A simple attempt to extract -L "label" and -L"label".
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
    elif arg == u'--':
      new_args.append(arg)
      isPass = True
    elif isL:
      ells.append(arg)
      isL = False
    else:
      if arg == u'-L':
        isL = True
      elif arg.startswith(u'-L'):
        ells.append(arg[2:])
      else:
        new_args.append(arg)
  return (new_args, ells)

def DiffIndex(lines):
  u"""Returns the index of the first line after the '---' and '+++' lines.

  There may be no such lines because:
  - the patterns were not found within a few lines
  - `len(lines)` is too small

  In which case, -1 (negative one) is returned.
  """
  size = len(lines)
  # Inspect a decent number of prefix lines, so that we can skip over any `--stat` lines.
  for i, line in enumerate(lines[:50]):
    if i + 2 < size and line.find(u'---') >= 0 and lines[i + 1].find(u'+++') >= 0:
      return i + 2
  return -1

def FDIsPipe(fd):
  return S_ISFIFO(os.fstat(fd).st_mode)

def Write(p, fobj, *args, **kwargs):
  u"""Write to `fobj`, and if we get `EPIPE`, `sys.exit(p.returncode)`.

  This means we handle writing to unix-like `head`, etc., in the unix-like way:
  - don't write "broken pipe" messages to `stderr`
  - exit with the appropriate exit value (in our case, the diff output's exit value)
  """
  try:
    return fobj.write(*args, **kwargs)
  except IOError as e:
    if e.errno == EPIPE:
      sys.exit(p.returncode)
    raise

def GetLinesep(line, fallback=os.linesep):
  u"""Go a little overboard trying to reproduce the original line separator."""
  for separator in (u'\r\n', u'\n', u'\r'):
    idx = line.rfind(separator)
    if idx >= 0:
      return line[idx:]
  return fallback


def Main(argv, git, gitoptsstr, stdinreader, stdoutwriter, stderrwriter):
  gitopts = shlex.split(gitoptsstr) if gitoptsstr else []
  try:
    args, ells = ExtractL(argv[1:])
    # Use --no-ext-diff: if you want to use a different diff tool,
    # then configure it with svn yourself.
    # No sense in "proxying" many times to the underlying diff tool.
    cmd = [git, u'diff', u'--no-index', u'--no-ext-diff'] + gitopts + args
    p = sp.Popen(cmd, stdout=sp.PIPE, stderr=sp.PIPE)
    stdin = None
    if FDIsPipe(sys.stdin.fileno()):
      stdin = stdinreader.read()
    stdout, stderr = p.communicate(input=stdin)
    stdout, stderr = FromLocale(stdout), FromLocale(stderr)
  except OSError as e:
    sys.exit(str(e))
  # Print all of stdout, then all of stderr.
  # Lines 0 and 1 are diff and sha1 noise.
  # Lines 2 and 3 are where the labels go.
  # This way takes care of --color=always.
  # Don't try to colorize new '---' lines.
  lines = stdout.splitlines(True)
  idx = DiffIndex(lines)
  try:
    if idx >= 2 and len(ells) >= 2:
      Write(p, stdoutwriter, u'--- ' + ells[0] + GetLinesep(lines[idx - 2]))
      Write(p, stdoutwriter, u'+++ ' + ells[1] + GetLinesep(lines[idx - 1]))
      for line in lines[idx:]:
        Write(p, stdoutwriter, line)
    else:
      Write(p, stdoutwriter, stdout)
  finally:
    if stderr.rstrip(u'\r\n'):
      Write(p, stderrwriter, stderr)
  sys.exit(p.returncode)

if __name__ == '__main__':
  ENCODING = locale.getpreferredencoding(do_setlocale=True)
  argv = sys.argv
  if sys.version_info[0] < 3:
    argv = [FromLocale(s) for s in sys.argv]
    git = FromLocale(os.environ.get('GIT_EXE', 'git'))
    gitoptsstr = FromLocale(os.environ.get('GIT_OPTS', ''))
    textreader = codecs.getreader(ENCODING)
    textwriter = codecs.getwriter(ENCODING)
    stdinreader = textreader(sys.stdin)
    stdoutwriter = textwriter(sys.stdout)
    stderrwriter = textwriter(sys.stderr)
  else:
    git = os.environ.get(u'GIT_EXE', u'git')
    gitoptsstr = os.environ.get(u'GIT_OPTS', u'')
    stdinreader = sys.stdin
    stdoutwriter = sys.stdout
    stderrwriter = sys.stderr
  sys.exit(Main(argv, git, gitoptsstr, stdinreader, stdoutwriter, stderrwriter))
