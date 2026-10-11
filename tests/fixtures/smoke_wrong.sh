#!/bin/sh
IFS= read -r input
test "$input" = 42 || exit 9
printf '43\n'
exit 0
