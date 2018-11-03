#!/bin/bash

# get only /opt eliminate /opt/XXXXXXXX. To make sure it's working on rhel6 put use df -HP
space=$(df -HP | grep opt$ | awk '{print $5}')

#stripping %
space=${space::-1}
echo "$space percent used"

# get /dev/mapper/rootvg-optlv
lv=$(df -HP | grep opt$ | awk '{print $1}')


if (( $space > 10 )); then
echo "############ Must grow $lv file system ##############"

lvextend -L+10M $lv
# check if ext4 or xfs
fs=$(grep rootvg-optlv /etc/fstab | awk '{print $3}')

case $fs in
ext4)
 echo "##### $fs file system #####"
 resize2fs $lv
 ;;
xfs)
 echo "#### $fs file system ####"
 xfs_growfs $lv
 ;;
esac


else
echo "####### there is enough disk space on $lv #########"
fi
