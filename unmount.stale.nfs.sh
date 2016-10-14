#!/bin/bash

l=$( df -h 2>&1 | grep Stale | awk '{print $2}' | awk -F \` '{print $2}' | awk -F \' '{print $1}' )
 for m in $l
  do
  umount -fl $m
 done


# another way to unmount stale file systems
# it will print stale file systems
mount | sed -n "s/^.* on \(.*\) type nfs .*$/\1/p" | 
while read mount_point ; do 
  timeout 10 ls $mount_point >& /dev/null || echo "stale $mount_point" ; 
done



# put it in array

arr=(`mount | sed -n "s/^.* on \(.*\) type nfs .*$/\1/p" |  while read mount_point ; do timeout 10 ls $mount_point >& /dev/null || echo "$mount_point" ;  done`)

# and unmount it

for var in "${arr[@]}"; do umount -fl $var; done
