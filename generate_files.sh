#! /bin/bash
for n in {1..100}; do
#    dd if=/dev/urandom of=file$( printf %03d "$n" ).bin bs=1 count=$(( RANDOM + 1024 ))
     echo "File number $n $(date)" >  file.$n."$(date)"
     sleep 10
     echo "keep running..."
done
