#!/bin/sh
# Controlled external process for output-location tests, not algorithm tests.
test "$#" -eq 1 && test -x "$1" || exit 9
IFS= read -r input
case "$input" in
    0|1) printf '1\n' ;;
    5) printf '120\n' ;;
    10) printf '3628800\n' ;;
    12) printf '479001600\n' ;;
    42) printf '42\n' ;;
    *) exit 9 ;;
esac
