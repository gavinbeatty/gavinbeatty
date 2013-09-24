# vi: set et ts=2 sw=2:
import sys
from os import listdir, getcwd, environ, devnull
from os.path import abspath, normpath, split, join, isfile, isdir, isabs, splitdrive
import subprocess as sp
import ycm_core

cc = 'g++'
dirname = lambda x: split(x)[0]
basename = lambda x: split(x)[1]
database = None

def is_root_dir(d):
  for f in (basename(x) for x in listdir(d) if isfile(join(d, x))):
    if f == '.ycm_extra_conf.py':
      return True
  return False

def get_root_dir(cwd=None):
  if cwd is None: cwd = getcwd()
  while (normpath(splitdrive(cwd)[1]) not in ('/', '\\', '')):
    if is_root_dir(cwd):
      return cwd
    cwd = join(cwd, '..')
  return None

def abslistdir(p):
  absp = abspath(p)
  return (join(absp, x) for x in listdir(absp))

here = dirname(abspath(__file__))
root = get_root_dir(here)
if not root:
  root = here[:]
database = ycm_core.CompilationDatabase(root)
if not database.DatabaseSuccessfullyLoaded():
  database = None

path_flags = ['-isystem', '-I', '-iquote', '--sysroot=']
def StripPathFlags(f):
  for p in path_flags:
    if f.startswith(p):
      if len(f) > len(p): return f[len(p):]
      else: return ''
  return f

def SplitPathFlags(fs):
  new_fs = []
  for f in fs:
    new_f = [f]
    for p in path_flags:
      lenp = len(p)
      if f.startswith(p) and len(f) > lenp:
        new_f = [f[:lenp], f[lenp:]]
        continue
    new_fs.extend(new_f)
  return new_fs

def SystemIncludeFlags():
  flags = []
  try:
    with open(devnull, 'rb+') as null:
      env = environ.copy()
      env['LC_ALL'] = 'C'
      stdout = sp.check_output(
        [cc, '-v', '-x', 'c++', '-c', '-'], env=env, universal_newlines=True
        , stderr=sp.STDOUT, stdin=null.fileno()
      )
  except:
    pass
  else:
    in_includes = False
    for line in stdout.splitlines():
      l = line.strip()
      if l == 'End of search list.':
        in_includes = False
      elif in_includes and line.startswith(' '):
        flags.extend(['-isystem', l])
      elif l.endswith('search starts here:'):
        in_includes = True
  return flags

def DefaultFlags():
  paths = (absp for absp in abslistdir(root) if isdir(absp) and not basename(absp).startswith('.'))
  fs = ['-I', root]
  for path in paths:
    fs.extend(['-I', path])
    includes = (p for p in abslistdir(path) if isdir(p) and basename(p) in ('include', 'inc'))
    for inc in includes:
      fs.extend(['-I', inc])
  fs.extend(['-x', 'c++', '-std=c++11'])
  return fs

def MakeRelativePathsInFlagsAbsolute(fs, working_directory):
  if not working_directory:
    return list(fs)
  new_flags = []
  make_next_absolute = False
  for flag in fs:
    new_flag = flag
    if make_next_absolute:
      make_next_absolute = False
      if not flag.startswith('/'):
        new_flag = join(working_directory, flag)
    for path_flag in path_flags:
      if flag == path_flag:
        make_next_absolute = True
        break
      if flag.startswith(path_flag):
        path = flag[len(path_flag):]
        new_flag = path_flag + join(working_directory, path)
        break
    if new_flag:
      new_flags.append(new_flag)
  return new_flags

def FlagsForFile(filename):
  if not database:
    flags = DefaultFlags()
  else:
    # GetCompilationInfoForFile returns a "list-like" StringVec object.
    compilation_info = database.GetCompilationInfoForFile(abspath(filename))
    flags = MakeRelativePathsInFlagsAbsolute(
      compilation_info.compiler_flags_,
      compilation_info.compiler_working_dir_ )
  return {'flags': SplitPathFlags(flags) + SystemIncludeFlags(), 'do_cache': True}
