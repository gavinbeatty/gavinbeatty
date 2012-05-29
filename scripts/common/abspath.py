#!/usr/bin/env python
# vi: set ft=python expandtab shiftwidth=4 tabstop=4:
"""Print the absolute path of the given path."""

import sys
import os.path

if __name__ == "__main__":
    if len(sys.argv) == 3 and sys.argv[1] == "--":
        sys.argv.pop(1)
    if len(sys.argv) != 2:
        sys.exit("usage: %s <path>" % (os.path.split(sys.argv[0])[1]))
    print os.path.abspath(sys.argv[1])
