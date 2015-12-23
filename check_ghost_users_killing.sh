#!/bin/bash
#
#This script is checking not active usres on the system 
#and killing ghost sessions, processes and unmount directories

#check if the server is nxserver master or standalone. optionally can use facter nx instead.
if [ -e /usr/NX/bin/nxserver ]; then

#get all sessions 
users=$( /usr/NX/bin/nxserver --list | awk '{print $2}' | sed "1,4 d" | head -n -2 )

for user in $users
do
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
      printf "$(hostname | cut -d"." -f1): $(date): "$user" is not active but still has an active nx session\n"
      #nxserver --terminate or --kill do not really work
      #/usr/NX/bin/nxserver --terminate "$user"
      #so far only this can terminate nx session
      ps auxww | grep "$user" | grep -v grep 
      printf "killing his processes and session..."
      nxproc=$(ps auxww | grep "$user" | grep -v grep | awk '{print $2}')
      printf "List of processes to be terminated: $nxproc"
      kill $nxproc
   fi
done
fi
 
# list all users that running processes. filter out users id less than 999. we see sometimes uids like 33 and 101 they belong to docker we ignore them
names_ps=$( ps -eo user:20,uid,pid,ppid,stime,%mem,%cpu,command | awk '{print $1}' | sed "1 d" | sort | uniq | awk '999<$1 {print $1}' )

for user in $names_ps
do
# check if there are processes running by not existing users
  id "$user" > /dev/null 2>&1
     if [ $? -ne 0 ]; then
        printf "\n"
        echo "$user is not active but running processes on his behalf. Here is a list of his processes:"
        ps auxww | egrep "^$user"
        echo "$user here is look up a username by id:"
        getent passwd "$user"
        if [ $? -ne 0 ]; then
           echo "Not found"
           echo "Killing his processeses..."
           pkill -u "$user"
           ###check if pkill couldn't kill then use kill -9. So far pkill was 99% successful.
           ps auxww | egrep "^$user"
           if [ $? == 0 ]; then
              kill -9 $(ps aux | egrep "^$user" | awk '{print $2}')
           fi    
        fi
     fi
done

# list all users that have mounted directories
names_mount=$(mount -l -t nfs | awk '{print $3}' | grep /home | cut -f3 -d/ | sort -u | cut -f1 -d-)

for user in $names_mount
do
#excluding all service users from check. i maintain these users in file service_users
if ! [[ $user =~ $(sed 's/[[:blank:]]//g' /proj/sysadmin/tmp/service_users | paste -sd '|' /dev/stdin) ]]; then
# check if users that have mounted directories exist 
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
        printf "$(hostname | cut -d"." -f1): $(date): $user is not active but still has mounted directory\n"
        ypcat -k auto.homehub | egrep "^$user"
        printf "unmounting $user home directory...\n"
        while mount | grep "$user"
        do
          printf "trying to unmount..."
          umount -fl /home/"$user"
        done
     fi
fi
done
