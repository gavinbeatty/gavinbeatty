#!/usr/bin/env python
#-*- coding: utf-8 -*-

import sys
import os
import io

def appendConfiguration(path, args):
  """On "good" platforms, `io.open`'s appends will be atomic.
  `buffering=0` requires binary/non-text mode, so join with `os.linesep`.
  """
  with io.open(path, 'ab', buffering=0) as f:
    f.write(os.linesep.join(args) + os.linesep)

def parseArguments(arguments):
  nextPrefix = ''
  result = []
  for arg in arguments:
    if nextPrefix:
      result.append(nextPrefix + arg)
      nextPrefix = ''
    elif arg in ('-I', '-D'):
      nextPrefix = arg
    elif arg == '-include':
      nextPrefix = arg + ' '
    elif arg[:2] in ('-I', '-D'):
      result.append(arg)
    elif arg[:2] == '-W' and ',' not in arg:
      result.append(arg)
    elif arg.startswith('-std='):
      result.append(arg)
  return result

CONFIG_NAME = ".clang_complete"
args = parseArguments(sys.argv[1:])
appendConfiguration(CONFIG_NAME, args)
os.execvp(sys.argv[1], sys.argv[1:])

# vim: set ts=2 sts=2 sw=2 expandtab :
