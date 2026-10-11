#!/bin/sh
IFS= read -r input
test "$input" = 42 || exit 9
printf '42\n'
exit 7
