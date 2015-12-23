#!/bin/bash
#this script checks if there is an output and sends it to your email
/proj/sysadmin/scripts/check_ghost_users.sh > /tmp/ghost.out
if [ -s /tmp/ghost.out ]; then 
   cat /tmp/ghost.out | mail -s "Ghost users report $(hostname | cut -d"." -f1)" YOUR_EMAIL_HERE
fi
