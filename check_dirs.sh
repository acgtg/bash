#!/bin/bash
# This script will output directories that belong to ghost users
# checking swbuild
dirs=/project/swbuild*
for dir in $dirs
 do
  cd $dir
  users=$(ls -l | awk '{print $9}' | sed "1 d")
   for user in $users
    do
# normally signum is 7 characters long so we eliminate non-standard directories names
    if [ ${#user} -eq 7 ]; then
      id "$user" > /dev/null 2>&1
      inNIS=$?
# check if script is running by root
      if [ "$EUID" -eq 0 ]; then
       /opt/quest/bin/vastool -u host/ attrs "$user" > /dev/null 2>&1
       inVAS=$?
      else
       /opt/quest/bin/vastool attrs "$user" > /dev/null 2>&1
       inVAS=$?
      fi
      if [ $inNIS -ne 0 -o $inVAS -ne 0 ]; then
       printf "\n"
       #printf "$(hostname | cut -d"." -f1): $(date): $user is not active but has a directory $dir/$user"
       size=$( du -sk $dir/$user | awk '{print $1}' )
       printf "$(hostname | cut -d"." -f1): $(date): $user is not active but has a directory $dir/$user. Size in kilobytes : $size"
       total=$(($total + $size))
      fi
    fi
   done
 done
printf "Total disk usage in kilobytes : $total"
# checking scratch
dirs=/scratch/[0-9]*
for dir in $dirs
 do
  cd $dir
  users=$(ls -l | awk '{print $9}' | sed "1 d")
   for user in $users
    do
     if [ ${#user} -eq 7 ]; then
      id "$user" > /dev/null 2>&1
      inNIS=$?
# check if script is running by root
      if [ "$EUID" -eq 0 ]; then
       /opt/quest/bin/vastool -u host/ attrs "$user" > /dev/null 2>&1
       inVAS=$?
      else
       /opt/quest/bin/vastool attrs "$user" > /dev/null 2>&1
       inVAS=$?
      fi
      if [ $inNIS -ne 0 -o $inVAS -ne 0 ]; then
       printf "\n"
       #printf "$(hostname | cut -d"." -f1): $(date): $user is not active but has a directory $dir/$user"
       sizesc=$( du -sk $dir/$user | awk '{print $1}' )
       printf "$(hostname | cut -d"." -f1): $(date): $user is not active but has a directory $dir/$user. Size in kilobytes : $sizesc"
       totalsc=$(($totalsc + $sizesc))
      fi
     fi
    done
 done
printf "Total disk usage in kilobytes : $totalsc"
