#!/bin/bash
# this script calculating total cpu usage by process

process="$1"

addnums () {
  local total=0
  val=$(ps aux | grep -i $process | grep -v grep |  awk '{print $3}')
  for t in $val
    do total=$(echo $total + $t | bc)
  done
  date >> cpu_imperva
  echo "Total CPU usage by $process $total%" >> cpu_imperva

}

while :
do
addnums
sleep 180
done
