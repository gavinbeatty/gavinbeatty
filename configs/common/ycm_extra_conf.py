# vi: set et ts=2 sw=2:
import sys
from os import listdir, getcwd
from os.path import abspath, normpath, split, join, isfile, isdir, isabs, splitdrive
import ycm_core

dirname = lambda x: split(x)[0]
basename = lambda x: split(x)[1]

def is_root_dir(d):
  for f in (basename(x) for x in listdir(d) if isfile(join(d, x))):
    if f == '.ycm_extra_conf.py':
      return True
  return False

def get_root_dir(cwd=None):
  if cwd is None: cwd = getcwd()
  while (normpath(splitdrive(cwd)[1]) not in ('/', '')):
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

def DefaultFlags():
  paths = (absp for absp in abslistdir(root) if isdir(absp) and not basename(absp).startswith('.'))
  fs = []
  for path in paths:
    fs.extend(['-I', path])
  fs.extend(['-x', 'c++', '-std=gnu++98'])
  return fs

def MakeRelativePathsInFlagsAbsolute(fs, working_directory):
  if not working_directory:
    return list(fs)
  new_flags = []
  make_next_absolute = False
  path_flags = [ '-isystem', '-I', '-iquote', '--sysroot=' ]
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
      return {'flags': DefaultFlags(), 'do_cache': True}
  # GetCompilationInfoForFile returns a "list-like" StringVec object.
  compilation_info = database.GetCompilationInfoForFile(abspath(filename))
  final_flags = MakeRelativePathsInFlagsAbsolute(
    compilation_info.compiler_flags_,
    compilation_info.compiler_working_dir_ )
  return {'flags': final_flags, 'do_cache': True}
