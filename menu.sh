#!/bin/bash

thefile=filelisting.dat
tempfile=`mktemp`
select task in count recreate
do
  case $REPLY in
   1) wc -l $thefile ;;
   2) echo "Recreating the index. It will be ready in a few minutes."
     (nohup find /home/user/scripts_practice -print > $tempfile 2>&1 ; mv $tempfile $thefile) & ;;
  esac
done
