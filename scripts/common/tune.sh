#!/bin/sh
# vi: set ft=sh expandtab shiftwidth=4 tabstop=4:
set -e
set -u
tune_env() {
    exec env \
        CFLAGS="${TUNE_PRE_CFLAGS+$TUNE_PRE_CFLAGS } ${CFLAGS+$CFLAGS } ${TUNE_POST_CFLAGS+$TUNE_POST_CFLAGS }" \
        CXXFLAGS="${TUNE_PRE_CXXFLAGS+$TUNE_PRE_CXXFLAGS } ${CXXFLAGS+$CXXFLAGS } ${TUNE_POST_CXXFLAGS+$TUNE_POST_CXXFLAGS }" \
        "$@"
}
if test $# -eq 0 ; then
    tune_env env
else
    tune_env "$@"
fi
