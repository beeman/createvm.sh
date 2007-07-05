#!/bin/bash
# Author: Bram Borggreve ( borggreve @ gmail dot com )
# Homepage: http://code.google.com/p/createvm/
# License: GPL, see: http://www.gnu.org/copyleft/gpl.txt

### Todo ###
# - Start VM with parameter, vmplayer and vmware
# - Automatically register the VM with vmware server
# - Create Virtual Disks with vmware-vdiskmanager by default
# - Remove complaints about upgrading your VM
# - Don't zip by default (-z), and add tar.gz support.
# - Beautify the way of creating the config file, first write it to a variable, then to file

### Some default variables ###

# Program info
PROGRAM_NAME=`basename $0`
PROGRAM_TITLE="Create VMware Virtual Machines in bash"
PROGRAM_VER="0.3"
PROGRAM_COPYRIGHT="2007 copyright by Bram Borggreve. Distributed under GPL license. No warranty whatsoever, express or implied."
PROGRAM="$PROGRAM_NAME $PROGRAM_VER"

# Default settings
DEFAULT_YES=no
DEFAULT_QUIET=no
DEFAULT_ZIPIT=no
DEFAULT_STARTVM=no
DEFAULT_WRKPATH=.

# Default VM parameters
VM_CONF_VER=8
VM_VMHW_VER=3
VM_RAM=256
VM_NVRAM=nvram
VM_ETH_TYPE=Bridged
VM_MAC_ADDR=default
VM_DISK_SIZE=8
VM_DISK_TYPE=IDE
VM_USE_USB=FALSE
VM_USE_SND=FALSE
VM_USE_CDD=FALSE
VM_USE_ISO=FALSE
VM_USE_FDD=FALSE

# List of supported OS's
SUPPORT_OS=(winVista longhorn winNetBusiness winNetEnterprise winNetStandard winNetWeb winXPPro winXPHome win2000AdvServ win2000Serv win2000Pro winNT winMe win98 win95 win31 windows winVista-64 longhorn-64 winNetEnterprise-64 winNetStandard-64 winXPPro-64 ubuntu redhat rhel4 rhel3 rhel2 suse sles mandrake nld9 sjds turbolinux other26xlinux other24xlinux linux ubuntu-64 rhel4-64 rhel3-64 sles-64 suse-64 other26xlinux-64 other24xlinux-64 otherlinux-64 solaris10-64 solaris10 solaris9 solaris8 solaris7 solaris6 solaris netware6 netware5 netware4 netware freeBSD-64 freeBSD darwin other other-64)

### Main functions ###

# Show version info
function PrintVersion() {
	echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0;00m."
	echo -e $PROGRAM_COPYRIGHT
}
# Print status message
function DoStatus() {
	echo -ne "\033[1m    \033[0;00m$1 "
}
# Print if cmd returned oke or failed
function DoStatusCheck() {
	if [[ $? -ne 0 ]] ; then
		echo -e "\033[1;31m[FAILED]\033[0;00m"
		exit 1;
	else
		echo -e "\033[1;32m[OK]\033[0;00m"
	fi
}
# Print informational message
function DoInfo() {
	echo -e "\033[1m    $1\033[0;00m "
}
# Print alert message
function DoAlert() {
	echo -e "\033[1m[!] \033[0;00m\033[1;31m$1\033[0;00m "
}
# Print error message
function DoError() {
	echo -e "\033[1m[e] \033[0;00m\033[1;31m$1\033[0;00m "
}
# Ask if a user wants to continue, default to YES
function AskOke(){
	if [ ! "$DEFAULT_QUIET" = "yes" ]; 
	then
		echo -ne "\033[1m[?] Is it oke to continue?     \033[1;32m[Yn]\033[0;00m "
		read YESNO
		if [ "$YESNO" = "n" ] ; then DoAlert "Stopped..."; exit 0; fi
	fi
}
# Ask if a user wants to continue, default to NO
function AskNoOke(){
	if [ ! "$DEFAULT_YES" = "yes" ]; 
	then
		echo -ne "\033[1m[?] Is it oke to continue?     \033[1;31m[yN]\033[0;00m "
		read YESNO
		if [ ! "$YESNO" = "y" ]; then DoAlert "Stopped..."; exit 0; fi
	fi
}

### Specific funtions ###

# Print Help message
function PrintUsage() {
	echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0;00m.
Usage: $PROGRAM_NAME GuestOS OPTIONS

Options:
 -b, --bios [PATH]              Path to bios file             (default: nvram)
 -c, --cdrom                    Enable CDROM Drive            (default: FALSE)
 -d, --disk-size [SIZE]         HDD size in GB                (default: 8)
 -e, --eth-type [TYPE]          Ethernet Type                 (default: bridged)
 -f, --floppy                   Enable Floppy Drive           (default: FALSE)
 -i, --iso [FILE]               Enable CDROM Iso              (default: FALSE)
 -m, --mac-addr [ADDR]          Use static mac address        (address: 00:50:56:xx:xx:xx)
 -n, --name [NAME]              Display name of your VM       (default: <os-type>-vm)
 -o, --output-file [FILE]       Zip file to write output to   (default: <os-type>-vm.zip)
 -r, --ram [SIZE]               RAM size in MB                (default: 256)
 -s, --sound                    Enable sound card             (default: FALSE)
 -t, --disk-type [TYPE]         HDD Interface, SCSI or IDE    (default: IDE)
 -u, --usb                      Enable USB                    (default: FALSE)

 -q, --quiet                    Run without asking questions, takes the default values.
 -y, --yes                      Say YES to all questions. This overwrites existing files!! 
 -z, --zip                      Zip the Virtual Machine
 -x, -X                         Start the Virtual Machine in vmware, X for fullscreen 

 -h, --help                     This help screen
 -l, --list                     Generate a list of VMware Guest OSes
 -v, --version                  Shows version information

Dependencies:
This program needs the 'zip' and 'qemu-img' binaries in its path...

Examples:
 Create an Ubuntu Linux machine with a 20GB hard disk and a different name
   $ $PROGRAM_NAME ubuntu -d 20 -n \My Ubuntu VM\ -o my-ubuntu-vm.zip 
	echo
 Silently create a SUSE Linux machine with 512MB ram, a fixed MAC address and zip it
   $ $PROGRAM_NAME suse -r 512 -q -m 00:50:56:01:25:00 -z 
	echo
 Create a Windows XP machine with 512MB and sound, USB and CD enabled
   $ $PROGRAM_NAME winXPPro -r 512 -s -u -c 
	echo
 Create an Ubuntu VM with 512MB and run it in vmware
   $ $PROGRAM_NAME ubuntu -r 512 -q -x"
}
# Print a summary with some of the options on the screen
function PrintSummary(){
	DoInfo "I am about to create this Virtual Machine:"
		echo -e "    Virtual OS                \033[1m $VM_OS_TYPE \033[0;00m"
		echo -e "    Display name              \033[1m $VM_NAME \033[0;00m"
		echo -e "    RAM (MB)                  \033[1m $VM_RAM \033[0;00m"
		echo -e "    HDD (GB)                  \033[1m $VM_DISK_SIZE\033[0;00m"
		echo -e "    HDD Interface             \033[1m $VM_DISK_TYPE\033[0;00m"
		echo -e "    BIOS file                 \033[1m $VM_NVRAM\033[0;00m"
		echo -e "    Ethernet Type             \033[1m $VM_ETH_TYPE\033[0;00m"
		echo -e "    Mac Address               \033[1m $VM_MAC_ADDR\033[0;00m"
		echo -e "    DISK type                 \033[1m $VM_DISK_TYPE\033[0;00m"
		echo -e "    Floppy Disk               \033[1m $VM_USE_FDD\033[0;00m"
		echo -e "    CD/DVD Drive              \033[1m $VM_USE_CDD\033[0;00m"
		echo -e "    CD/DVD Iso                \033[1m $VM_USE_ISO\033[0;00m"
		echo -e "    USB                       \033[1m $VM_USE_USB\033[0;00m"
		echo -e "    Sound Card                \033[1m $VM_USE_SND\033[0;00m"
	AskOke
}
# Create the .vmx file
function CreateConf(){
	DoStatus "Creating config file...   "
		echo '#!/usr/bin/vmware'	>> $VM_VMX_FILE
		echo 'config.version                = "'$VM_CONF_VER'"	'	>> $VM_VMX_FILE	
		echo 'virtualHW.version             = "'$VM_VMHW_VER'"	'	>> $VM_VMX_FILE
		echo 'displayName                   = "'$VM_NAME'"		'	>> $VM_VMX_FILE
		echo 'guestOS                       = "'$VM_OS_TYPE'"	'	>> $VM_VMX_FILE
		echo 'memsize                       = "'$VM_RAM'"		'	>> $VM_VMX_FILE
		echo 'nvram                         = "'$VM_NVRAM'"		'	>> $VM_VMX_FILE
		echo 'ethernet0.present             = "TRUE"		'	>> $VM_VMX_FILE
		echo 'ethernet0.connectionType      = "'$VM_ETH_TYPE'"	'	>> $VM_VMX_FILE
		if [ ! $VM_MAC_ADDR = "default" ]; then
			echo 'ethernet0.addressType         = "static"		'	>> $VM_VMX_FILE
			echo 'ethernet0.address             = "'$VM_MAC_ADDR'"	'	>> $VM_VMX_FILE
		else
			echo 'ethernet0.addressType         = "generated"		'	>> $VM_VMX_FILE
		fi
		if [ ! $VM_DISK_TYPE = "IDE" ]; then
			echo 'scsi0:0.present               = "TRUE"		'	>> $VM_VMX_FILE
			echo 'scsi0:0.fileName              = "'$VM_DISK_NAME'"	'	>> $VM_VMX_FILE
		else 
			echo 'ide0:0.present                = "TRUE"		'	>> $VM_VMX_FILE
			echo 'ide0:0.fileName               = "'$VM_DISK_NAME'"	'	>> $VM_VMX_FILE
		fi
		if [ $VM_USE_USB = "FALSE" ]; then
			echo 'usb.present                   = "FALSE"		'	>> $VM_VMX_FILE
		else
			echo 'usb.present                   = "TRUE"		'	>> $VM_VMX_FILE
			echo 'usb.generic.autoconnect       = "FALSE"		'	>> $VM_VMX_FILE
		fi
		if [ $VM_USE_SND = "FALSE" ]; then
			echo 'sound.present                 = "FALSE"		'	>> $VM_VMX_FILE
		else
			echo 'sound.present                 = "TRUE"		'	>> $VM_VMX_FILE
			echo 'sound.fileName                = "-1"			'	>> $VM_VMX_FILE
			echo 'sound.autodetect              = "TRUE"		'	>> $VM_VMX_FILE
			echo 'sound.startConnected          = "FALSE"		'	>> $VM_VMX_FILE
		fi
		if [ $VM_USE_FDD = "FALSE" ]; then
			echo 'floppy0.present               = "FALSE"		'	>> $VM_VMX_FILE
		else
			echo 'floppy0.present               = "TRUE"		'	>> $VM_VMX_FILE
			echo 'floppy0.startConnected        = "FALSE"		'	>> $VM_VMX_FILE
		fi
		if [ $VM_USE_CDD = "FALSE" ]; then
			echo 'ide0:1.present                = "FALSE"		'	>> $VM_VMX_FILE
			echo 'ide0:1.autodetect             = "TRUE"		'	>> $VM_VMX_FILE
		else
			echo 'ide0:1.present                = "TRUE"		'	>> $VM_VMX_FILE
			echo 'ide0:1.fileName               = "auto detect"		'	>> $VM_VMX_FILE
			echo 'ide0:1.autodetect             = "TRUE"		'	>> $VM_VMX_FILE
			echo 'ide0:1.deviceType             = "cdrom-raw"		'	>> $VM_VMX_FILE
			echo 'ide0:1.startConnected         = "FALSE"		'	>> $VM_VMX_FILE
		fi
		if [ $VM_USE_ISO = "FALSE" ]; then
			echo 'ide1:0.present                = "FALSE"		'	>> $VM_VMX_FILE
			echo 'ide1:0.autodetect             = "TRUE"		'	>> $VM_VMX_FILE
		else
			echo 'ide1:0.present                = "TRUE"		'	>> $VM_VMX_FILE
			echo 'ide1:0.fileName               = "'$VM_USE_ISO'"	'	>> $VM_VMX_FILE
			echo 'ide1:0.deviceType             = "cdrom-image"		'	>> $VM_VMX_FILE
			echo 'ide1:0.startConnected         = "TRUE"		'	>> $VM_VMX_FILE
			echo 'ide1:0.mode                   = "persistent"		'	>> $VM_VMX_FILE
		fi
		echo 'annotation                    = "This VM is created by '$PROGRAM'..."'	>> $VM_VMX_FILE
	DoStatusCheck
}
# Create the working dir
function CreateWorkingDir(){
	DoStatus "Creating working dir...   "
		mkdir -p $WRKDIR &> /dev/null
	DoStatusCheck
}
# Create the virtual disk
function CreateVirtualDisk(){
	DoStatus "Creating virtual disk...  "
		qemu-img create -f vmdk $WRKDIR/$VM_DISK_NAME $VM_DISK_SIZE &> /dev/null
	DoStatusCheck
}
# Generate a zip file with the created VM (TODO: needs tar.gz too)
function CreateArchive(){
	if [ "$DEFAULT_ZIPIT" = "yes" ]; 
	then
		# Generate zipfile
		DoStatus "Generate zipfile...       "
		cd $DEFAULT_WRKPATH
		zip -q -r $VM_OUTP_FILE $WRKDIR/ &> /dev/null
		DoStatusCheck
	fi
}
# Print OS list.
function PrintOsList() {
	echo "List of Guest Operating Systems:"
	for OS in ${SUPPORT_OS[@]}
	do 
		echo " - " $OS;
	done
}
# Check if selected OS is in the OS list
function DoOsTest(){
	OS_SUPPORTED="no";
	for OS in ${SUPPORT_OS[@]}
	do 
		if [ $OS = "$VM_OS_TYPE" ];
		then
			OS_SUPPORTED="yes";
		fi
	done
	if [ ! $OS_SUPPORTED = "yes" ]; 
	then
		DoError "Guest OS \"$VM_OS_TYPE\" is unknown..."
		DoInfo "use \"$PROGRAM_NAME -h\" for help and examples..."
		DoInfo "and \"$PROGRAM_NAME -l\" for a list of Guest OS's..."
		exit 1
	fi
}
# Check for binaries and existance of previously created VM's
function DoChecks(){
	# Check for needed binaries
	DoInfo "Creating Virtual Machine..."
	DoStatus "Checking for qemu-img...  "
		which qemu-img &> /dev/null
	DoStatusCheck
	DoStatus "Checking for zip...       "
		which zip &> /dev/null
	DoStatusCheck
	# Check if working dir file exists
	if [ -e $WRKDIR ]
	then 
		DoAlert "Working dir already exists, i will trash it!"
		AskNoOke
		DoStatus "Trashing working dir...   "
			rm -rf $WRKDIR &>/dev/null
		DoStatusCheck
	fi
	# Check if zipfile exists
	if [ "$DEFAULT_ZIPIT" = "yes" ]; 
	then
		if [ -e $VM_OUTP_FILE ]
		then 
			DoAlert "Zipfile already exists, i will trash it!"
			AskNoOke
			DoStatus "Trashing zipfile...       "
				rm $VM_OUTP_FILE &>/dev/null
			DoStatusCheck
		fi
	fi
}
# Clean up working dir and start VM (TODO: needs top be seperated)
function DoCleanUp(){
	# Back to base dir...
	cd - &> /dev/null
	# Clean up if zipped, and announce file location
	if [ "$DEFAULT_ZIPIT" = "yes" ]; 
	then 
		DoStatus "Cleaning up workingdir... "
			rm -rf $WRKDIR
		DoStatusCheck
		DoInfo "Grab you VM here: $VM_OUTP_FILE"
	else
		DoInfo "Created VM here: $VM_VMX_FILE"
	fi
}
# Start VM if asked for 
function DoStartVM(){
	if [ "$DEFAULT_STARTVM" = "yes" ];
	then 
		DoInfo "Starting Virtual Machine..."
		vmware $VMW_OPT $VM_VMX_FILE
	fi
}

### The flow! ###

# Chatch some parameters if the first one is not the OS.
if [ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then PrintUsage; exit; fi
if [ "$1" = "-v" ] || [ "$1" = "--version" ]; then PrintVersion; exit; fi
if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then PrintOsList; exit 1; fi

# The first parameter is the Guest OS Type
VM_OS_TYPE=$1

# Set default VM Name and output filename
VM_NAME=$VM_OS_TYPE-vm
VM_OUTP_FILE=`pwd`/$VM_OS_TYPE-vm.zip

# Do OS test
DoOsTest

# Shift through all parameters to search for options
shift
while [ "$1" != "" ]; do
	case $1 in
	-b | --bios )#
		shift
		VM_NVRAM=$1
	;;
	-c | --cdrom )
		VM_USE_CDD="TRUE"
	;;
	-d | --disk-size )
		shift
		VM_DISK_SIZE=$1
	;;
	-e | --eth-type )
		shift
		VM_ETH_TYPE=$1
	;;
	-f | --floppy )
		VM_USE_FDD="TRUE"
	;;
	-i | --iso )
		shift
		VM_USE_ISO=$1
	;;
	-m | --mac-addr )
		shift
		VM_MAC_ADDR=$1
	;;
	-n | --name )
		shift
		VM_NAME=$1
	;;
	-o | --output-file )
		shift
		VM_OUTP_FILE=`pwd`/$1
	;;
	-r | --ram )
		shift
		VM_RAM=$1
	;;
	-s | --sound )
		VM_USE_SND="TRUE"
	;;
	-t | --disk-type )
		shift
		VM_DISK_TYPE=$1
	;;
	-u | --usb )
		VM_USE_USB="TRUE"
	;;
	-q | --quiet )
		DEFAULT_QUIET="yes"
	;;
	-v | --version )
		PrintVersion
	;;
	-x  )
		DEFAULT_STARTVM="yes"
		VMW_OPT="-x"
	;;
	-X  )
		DEFAULT_STARTVM="yes"
		VMW_OPT="-X"	
	;;
	-y | --yes )
		DEFAULT_QUIET="yes"
		DEFAULT_YES="yes"
	;;
	-z | --zip )
		DEFAULT_ZIPIT="yes"
	;;
	* )
		DoError "Euhm... what did you mean by \"$*\"?"
		DoInfo "Please run \"$PROGRAM_NAME -h\" for help and examples..."
		exit 1
	esac
	shift
done

# The last parameters are set
VM_DISK_SIZE=$VM_DISK_SIZE'G'
WRKDIR=$DEFAULT_WRKPATH/$VM_OS_TYPE
VM_DISK_NAME=$VM_DISK_TYPE-$VM_OS_TYPE.vmdk
VM_VMX_FILE=$WRKDIR/$VM_OS_TYPE.vmx

# Print banner
PrintVersion
# Display summary
PrintSummary
# Do some tests
DoChecks

# Create working environment
CreateWorkingDir
# Create virtual disk
CreateVirtualDisk
# Write config file
CreateConf
# Create archine
CreateArchive

# Clean up environment
DoCleanUp
# Run the VM
DoStartVM

##########	The End!	##########
