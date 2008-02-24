#!/bin/bash

# Read the settings
source bootux.conf

# Some strings we might need later on
name=`basename $0`
error="Try: '$name -h' for help"
usage='Usage: addrepo.sh -d <distro> -v <version> -a <arch> -m <mirror>'

# Read which parameters are given
while getopts ":d:v:a:m:" options; do
  case $options in
    d ) distro=$OPTARG;;
    v ) version=$OPTARG;;
    a ) arch=$OPTARG;;
    m ) mirror=$OPTARG;;
    h ) echo $usage;;
    \? ) echo $usage
        exit 1;;
    * ) echo $usage
		exit 1;;
  esac
done

# Check if we got al needed info
if [ "$distro" == '' ];  then echo $error; exit; fi
if [ "$version" == '' ]; then echo $error; exit; fi
if [ "$arch" == '' ];    then echo $error; exit; fi
if [ "$mirror" == '' ];	 then echo $error; exit; fi

# Print a summary of what we are going to do
echo 
echo "[$distro-$version-$arch]"
echo "distro=$distro"
echo "version=$version"
echo "arch=$arch"
echo "mirror=$mirror"

echo 
ttarget=$tftpdir/$distro/$version/$arch/
wtarget=$httpdir/$distro/$version/$arch/
echo "TFTP dir: $ttarget"
echo "WWW dir:  $wtarget"
echo
echo -n "Press return to continue or Ctrl-C to quit"
read continue

echo
tftpcmd="mkdir -pv $ttarget"
echo "Creating TFTP dir ($tftpcmd)"
$tftpcmd

wwwcmd="mkdir -pv $wtarget"
echo "Creating HTTP dir ($wwwcmd)"
$wwwcmd

echo
kgetcommand="wget -c -nv $mirror/images/pxeboot/vmlinuz -O $ttarget/vmlinuz"
igetcommand="wget -c -nv $mirror/images/pxeboot/initrd.img -O $ttarget/initrd.img"
echo "Fetching Kernel and Initial Ramdisk"

$kgetcommand
$igetcommand

echo
echo Writing initial config files...
for cfg in ${cfgfiles[@]}
do
    echo $cfg
    touch $wtarget/$cfg
done

echo
echo TFTP Dir: 
ls -l $ttarget

echo
echo WWW Dir: 
ls -l $wtarget

