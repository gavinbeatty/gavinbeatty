#!/usr/bin/env python

"""Test: mini test description

Big long test description that lasts many
lines
"""

from distutils.core import setup


# A list of classifiers can be found here:
#   http://pypi.python.org/pypi?%3Aaction=list_classifiers
classifiers = """\
Natural Language :: English
Development Status :: 5 - Production/Stable
Environment :: Console
Topic :: Software Development :: Libraries :: Python Modules
Topic :: Utilities
Intended Audience :: Developers
License :: OSI Approved :: GNU General Public License (GPL)
Programming Language :: Python
Operating System :: Microsoft :: Windows
Operating System :: Unix
Operating System :: Apple :: OS X
Operating System :: OS Independent
"""

from sys import version_info

if version_info < (2, 3):
    _setup = setup
    def setup(**kwargs):
        if kwargs.has_key("classifiers"):
            del kwargs["classifiers"]
        _setup(**kwargs)

doclines = __doc__.split("\n")

setup(name='foo',
      description=doclines[0],
      long_description="\n".join(doclines[2:]),
      author='Gavin Beatty',
      author_email='gavinbeatty@gmail.com',
      maintainer='Gavin Beatty',
      maintainer_email='gavinbeatty@gmail.com',
      license = "http://www.gnu.org/licenses/gpl.txt",
      platforms=["any"],
      classifiers=filter(None, classifiers.split("\n")),
      url='',
      version='0.1b',
      py_modules=['foo'],
      )
