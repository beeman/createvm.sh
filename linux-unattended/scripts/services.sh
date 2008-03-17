#!/bin/bash
## wget http://createvm.googlecode.com/svn/linux-unattended/scripts/services.sh -O services.sh && sh services.sh

services=(bluetooth cups portmap irqbalance nfslock sendmail smartd apmd anacron atd rpcidmapd cpuspeed haldaemon gpm iptables ip6tables autofs messagebus rpcgssd acpid kudzu netfs mdmonitor pcscd restorecond lvm2-monitor mcstrans hidd auditd)

for service in ${services[@]}
do
   echo "-- Disabling $service --"
   chkconfig $service off
done

echo "-- Services enabled in Runlevel 3 --"
chkconfig --list | grep 3:on

