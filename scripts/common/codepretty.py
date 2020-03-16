#!/usr/bin/env python

# /***************************************************************************
#  *   Copyright (C) 2007 by Gavin Beatty                                    *
#  *   public@gavinbeatty.com                                                 *
#  *                                                                         *
#  *   This program is free software; you can redistribute it and/or modify  *
#  *   it under the terms of the GNU General Public License as published by  *
#  *   the Free Software Foundation; either version 2 of the License, or     *
#  *   (at your option) any later version.                                   *
#  *                                                                         *
#  *   This program is distributed in the hope that it will be useful,       *
#  *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
#  *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
#  *   GNU General Public License for more details.                          *
#  *                                                                         *
#  *   You should have received a copy of the GNU General Public License     *
#  *   along with this program; if not, write to the                         *
#  *   Free Software Foundation, Inc.,                                       *
#  *   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             *
#  ***************************************************************************/

# Author: Gavin Beatty <public@gavinbeatty.com>

# Modified by: 

# Requires: getopt
#           astyle

# Usage: codepretty.py FILE1 [ FILE2 ... ]

"""Reformat code according to certain pretty styles

Uses astyle to turn ugly code into pretty code according to certain preset
standards
"""
import sys, os, os.path, optparse, re, string
import subprocess as sp

def main(argv=None):
    if argv is None:
        argv = sys.argv

    default="[DEFAULT=%default]"
    defaultquote="[DEFAULT=\"%default\"]"

    def flag(option, opt_str, value, parser):
        setattr(parser.values, option.dest, value)
        setattr(parser.values, option.dest+"flag", True)
    ## added callback

    prog=os.path.basename(argv[0])
    usage="%prog [ OPTIONS ] FILES ..."
    version="%prog 1.0"
    description="Python script to easily make code pretty according to certain standards - using astyle"
    parser = optparse.OptionParser(usage=usage, version=version, description=description)

    styles = {"kde":"--indent=spaces=4 --brackets=linux --indent-labels --pad=oper "#--unpad=paren "
                    "--one-line=keep-statements --convert-tabs --indent-preprocessor",
              "java":"--mode=java --indent=spaces=4 --brackets=linux --indent-labels --pad=oper "#--unpad=paren "
                    "--one-line=keep-statements --convert-tabs --indent-preprocessor"
             }
    globalopts = "--suffix=.astyleorig"

    parser.set_defaults(style="kde", astyle="astyle", teach=False)

    parser.add_option("-s", "--style", dest="style", metavar="STYLE", type="string",
        help="Set the style to prettify the code with ; "+default)

    pathgroup = optparse.OptionGroup(parser, "Executable Locations Options", "These options"
                    "deal with finding executables needed by %s in order to work" % prog)
    pathgroup.add_option("-a", "--astyle", metavar="EXE", dest="astyle",
        type="string", help="Specifies the astyle executable name to use ; "+default)

    parser.add_option_group(pathgroup)

    parser.add_option("-t", "--teaching", dest="teach", action="store_true", help="Print the generated astyle command"
                    " ; "+default)

    (opts, args) = parser.parse_args(argv[1:])

# main code goes here
    if len(args) < 1:
        parser.error("Must supply a file argument")

    if opts.style not in styles.keys():
        parser.error("Must supply one of %s as a style" % styles.keys())

    basecommand="%s %s %s" % (opts.astyle, styles[opts.style], globalopts)
    regex = re.compile(r"(formatted (.*))%s$"% (os.linesep*2))
    for file in args:
        if string.find(file, "java", -4) != -1 and opts.style != "java":
            basecommand += " --mode=java"
        command = "%s %s" % (basecommand, file)
        if opts.teach: print command
        proc = sp.Popen(command, shell=True
          , stdout=sp.PIPE, stderr=sp.PIPE, close_fds=True)

        for output in proc.stdout:
            matches = regex.search(output)
            if matches:
                print matches.group(1)

if __name__ == "__main__":
    sys.exit(main())

# done here - look at main()

