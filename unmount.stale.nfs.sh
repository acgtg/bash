#!/bin/bash

l=$( df -h 2>&1 | grep Stale | awk '{print $2}' | awk -F \` '{print $2}' | awk -F \' '{print $1}' )
 for m in $l
  do
  umount -fl $m
 done
