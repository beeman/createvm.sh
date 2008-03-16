#!/bin/bash
## wget -q http://createvm.googlecode.com/svn/linux-unattended/bootux-srv.sh -O bootux-srv.sh && sh bootux-srv.sh
# Check OS
# - distro/type
#
# Install Bootux
# - Add User bootux
# - Add packages
# - Configure webserver
#
# Configure Bootux
# - Add settings (servername, paths)
# - Run php tests
# - Create Repo/Tree

distro=`lsb_release -is`; 
packages=(httpd php mysql-server mysql dnsmasq tftp-server subversion)
bootuxuser="bootux"
bootuxtarget="/home/$bootuxuser/public_html/";

ip_address=`ifconfig eth0 | grep "inet addr" | cut -d ":" -f 2 | cut -d " " -f 1`

if [ "$distro" == "CentOS" ] || [ "$distro" == "Fedora" ] ; 
then 
	echo " - $distro is supported!"; 
else 
	echo " - $distro is not supported! Exiting.";
	exit
fi

echo " - Installing ${packages[@]}"
yum -y install ${packages[@]}

echo " - Starting httpd"
service httpd start

echo " - Creating user $bootuxuser"
adduser -m "$bootuxuser"

echo " - Setting rights"
chmod -Rc 755 /home/"$bootuxuser"

echo " - Creating webdir"
mkdir -pv ""
chown -Rc apache:apache "$bootuxtarget"

echo " - Making symlink"
ln -sv "$bootuxtarget" /var/www/html/bootux

echo " - Getting bootux from Subversion"
svn co http://createvm.googlecode.com/svn/linux-unattended/ "$bootuxtarget"

echo " - Done..."
echo "Bootux is probably running on http://$ip_address/bootux/"
