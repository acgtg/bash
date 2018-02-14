#!/bin/bash

function get_groupname
{
 [ ! -z "$1" ] && getent group $@ | cut -d: -f1
}
function get_groupid
{
 [ ! -z "$1" ] && getent group $@ | cut -d: -f3
}
function get_username
{
 [ ! -z "$1" ] && getent passwd $1 | cut -d: -f1
}
function get_userid
{
 [ ! -z "$1" ] && getent passwd $1 | cut -d: -f3
}
function get_user_group_names
{
 [ ! -z "$1" ] && groups $@ | cut -d: -f2
}
function get_user_group_ids
{
 get_user_group_names $@ | while read groups
 do
 get_groupid $groups
 done
}
function get_primary_group_id
{
 [ ! -z "$1" ] && getent passwd $1 | cut -d: -f4
}
function get_primary_group_name
{
 [ ! -z "$1" ] && get_groupname `get_primary_group_id $@`
}
function show_user
{
 [ $# -gt 0 ] && getent passwd $@ | cut -d: -f1,5
}
function show_groups
{
 for uid in $@
 do
 echo "User $uid : Primary group is `get_primary_group_name $uid`"
 printf "Additional groups: "
 for gid in `id -G $uid | cut -d" " -f2-`
 do
 printf "%s " `get_groupname $gid`
 done
 echo
 done
}
function show_group_members
{
 for sgid in `get_groupid $@`
 do
 echo
 echo "Primary members of the group `get_groupname $sgid`"
 show_user `getent passwd | cut -d: -f1,4 | grep ":${sgid}$" | cut -d: -f1`
 echo "Secondary members of the group `get_groupname $sgid`"
 show_user `getent group $sgid | cut -d: -f4 | tr ',' ' '`
 done
}
USERNAME=${1:-$LOGNAME}
echo "User $USERNAME is in these groups: `id -Gn $USERNAME`"
show_groups $USERNAME
show_group_members `id -G $USERNAME`
