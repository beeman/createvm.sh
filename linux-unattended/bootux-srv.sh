#!/bin/bash
## wget -q http://createvm.googlecode.com/svn/linux-unattended/bootux-srv.sh -O bootux-srv.sh && sh bootux-srv.sh
#
# Check OS
# - distro
#
# Install Bootux
# - Add packages
# - Configure webserver
#
# Configure Bootux
# - Add settings (servername, paths)
# - Run php tests
# - Create Repo/Tree

distro=`lsb_release -is`; 
packages=(httpd php mysql-server mysql dnsmasq tftp-server subversion)

ip_address=`ifconfig eth0 | grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1`

if [ "$distro" == "CentOS" ] || [ "$distro" == "Fedora" ] ; 
then 
	echo " - $distro is supported!"; 
else 
	echo " - $distro is not supported! Exiting.";
	exit
fi

echo " - Fetchin config file"
wget -q http://createvm.googlecode.com/svn/linux-unattended/bootux.conf -O bootux.conf && source bootux.conf
echo $tftpdir
echo $httpdir

echo " - Installing ${packages[@]}"
yum -y install ${packages[@]}

echo " - Starting httpd"
service httpd start

echo " - Creating http and tftp dir"
mkdir -pv "$httptarget"
chown -Rc apache:apache "$httptarget"

echo " - Making symlink"
ln -sv "$httptarget" /var/www/html/bootux

echo " - Getting bootux from Subversion"
svn co http://createvm.googlecode.com/svn/linux-unattended/ "$httptarget"

echo " - Done..."
echo "Bootux is probably running on http://$ip_address/bootux/"
