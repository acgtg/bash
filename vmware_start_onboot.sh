#!/bin/bash
# For RHEL 6 to make it start on boot

cp /etc/vmware-tools/services.sh /etc/init.d/vmware-tools
sed -i '/##VMWARE_INIT_INFO##/a # chkconfig: 235 03 99' /etc/init.d/vmware-tools
chkconfig --add vmware-tools
chkconfig vmware-tools on
service vmware-tools start
