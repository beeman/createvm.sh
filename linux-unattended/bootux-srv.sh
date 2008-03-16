#!/bin/bash
## wget -q http://boreel.ath.cx/b/bootux/scripts/bootux-srv.sh -O bootux-srv.sh && sh bootux-srv.sh
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
bootuxuser='bootux'
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
mkdir -pv "/home/$bootuxuser/public_html/"

echo " - Making symlink"
ln -sv /home/$bootuxuser/public_html/ /var/www/html/bootux

echo " - Creating info.php"
echo '<?php echo $_SERVER['"'SERVER_SIGNATURE'"']; ?>' > "/home/$bootuxuser/public_html/info.php"
wget -q http://createvm.googlecode.com/svn/linux-unattended/check.php -O "/home/$bootuxuser/public_html/check.php"

echo " - Done..."
echo "Bootux is probably running on http://$ip_address/bootux/"
