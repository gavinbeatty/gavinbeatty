#!/bin/sh
find "${1:-.}" -iname '*.mkv' -o -iname '*.mp4' -o -iname '*.avi' \
    -o -iname '*.mov' -o -iname '*.mpeg' -o -iname '*.mpg' -o -iname '*.m4v' \
    | xargs -I'{}' bash -c \
    "ffprobe \"\$1\" 2>&1 | perl -e 'while(<STDIN>){if(/.*Duration: ([^,]*).*/){print \"\$ARGV[0]: \$1\\n\";}}' \"\$1\"" bash '{}'
