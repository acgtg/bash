#!/bin/bash

# check if autofs is able to mount NFS shares
# Nagios script

STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_ERROR=3
x=0

Path=("$@")
output=()

for i in "${Path[@]}"
do
  ls -d $i > /dev/null 2>&1
  if [ -e $i ]
   then
    output+=("OK: Path $i is accessible")
  else
    output+=("FAIL: Path $i is not accessible")
    let "x+=1"
  fi
done

printf '%s\n' "${output[@]}" | sort

if [ $x -ge 1 ]
   then
     exit $STATE_CRITICAL
   else
     exit $STATE_OK
fi
