#!/bin/bash
#
## FILE: check_stale_nfs.sh
##
## DESCRIPTION: This is a nagios compatible script to checks NFS mounts against what
##              should be mounted in /etc/fstab and if there is a stale mount.
##
## AUTHOR: Dennis Ruzeski (denniruz@gmail.com)
##
## Creation Date: 1/23/2013
##
##--------------------------------------------------------------------------
## Last Modified: 2015-06-19 (real.melancon@ericsson.com)
##    - Added (0x187) error handling since its a bug in statfs not reporting
##      0x187 as autofs - even if it is. Normal code for autofs is 0x0187
##
## VERSION: 1.1
##--------------------------------------------------------------------------
## USAGE: ./check_stale_nfs.sh
##        This version takes no arguments
##
EXCLUDE_LIST='/var/lib/puppet'
declare -a nfs_mounts=( $(mount -t nfs | egrep -vi "$EXCLUDE_LIST" | grep -v home | awk '{print $3}') )
declare -a MNT_STATUS
declare -a SFH_STATUS
declare -a OUTPUT_STATUS
for mount_type in ${nfs_mounts[@]} ; do
  if [ "$(stat -f -c '%T' ${mount_type})" == "nfs" ] || [ "$(stat -f -c '%T' ${mount_type})" == "autofs" ] || [ "$(stat -f -c '%T' ${mount_type})" == "UNKNOWN (0x187)" ]; then
    read -t3 < <(stat -t ${mount_type})
    if [ $? -ne 0 ]; then
      OUTPUT_STATUS=("${OUTPUT_STATUS[@]}" "ERROR: ${mount_type} might be stale.")
      SFH_STATUS=("${SFH_STATUS[@]}" "ERROR: ${mount_type} might be stale.")
    else
      MNT_STATUS=("${MNT_STATUS[@]}" "OK: ${mount_type} is ok.")
    fi
  else
    OUTPUT_STATUS=("${OUTPUT_STATUS[@]}" "ERROR: ${mount_type} is not properly mounted.")
    MNT_STATUS=("${MNT_STATUS[@]}" "ERROR: ${mount_type} is not properly mounted.")
fi
done
echo ${MNT_STATUS[@]} ${SFH_STATUS[@]} |grep -q ERROR
  if [ $? -eq 0 ]; then
    echo ${OUTPUT_STATUS[@]}
    RETVAL=2
    echo "CRITICAL - NFS mounts may be stale or unavailable"
  else
    RETVAL=0
    echo "OK - NFS mounts are functioning within normal operating parameters"
  fi
unset -v MNT_STATUS
unset -v SFH_STATUS
exit ${RETVAL}
