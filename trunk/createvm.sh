#!/bin/bash
# 2007 copyright by Bram Borggreve. Distributed under GPL license. No warranty whatsoever, express or implied.
# Todo:
# - Start VM with parameter, vmplayer and vmware
# - Automatically register the VM with vmware server
# - Create Virtual Disks with vmware-vdiskmanager by default
# - Remove complaints about upgrading your VM
# - Don't zip by default (-z), and add tar.gz support.
# - Beautify the way of creating the config file, first write it to a variable, then to file
#
PROGRAM_NAME=`basename $0`
PROGRAM_TITLE="Create VMware Virtual Machines in bash"
PROGRAM_VER="0.3"
PROGRAM="$PROGRAM_NAME $PROGRAM_VER"
DEFAULT_YES=no
DEFAULT_QUIET=no
DEFAULT_ZIPIT=no
DEFAULT_STARTVM=no
SUPPORT_OS=(winVista longhorn winNetBusiness winNetEnterprise winNetStandard winNetWeb winXPPro winXPHome win2000AdvServ win2000Serv win2000Pro winNT winMe win98 win95 win31 windows winVista-64 longhorn-64 winNetEnterprise-64 winNetStandard-64 winXPPro-64 ubuntu redhat rhel4 rhel3 rhel2 suse sles mandrake nld9 sjds turbolinux other26xlinux other24xlinux linux ubuntu-64 rhel4-64 rhel3-64 sles-64 suse-64 other26xlinux-64 other24xlinux-64 otherlinux-64 solaris10-64 solaris10 solaris9 solaris8 solaris7 solaris6 solaris netware6 netware5 netware4 netware freeBSD-64 freeBSD darwin other other-64)
WRKPATH=.

function DoVersion() {
	echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0m."
	echo -e "2007 copyright by Bram Borggreve. Distributed under GPL license. No warranty whatsoever, express or implied."
}

function DoUsage() {
	echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0m."
	echo "Usage: $PROGRAM_NAME GuestOS OPTIONS"
	echo
 	echo "Options:"
 	echo " -b, --bios [PATH]              Path to bios file             (default: nvram)"
 	echo " -c, --cdrom                    Enable CDROM Drive            (default: FALSE)"
 	echo " -d, --disk-size [SIZE]         HDD size in GB                (default: 8)"
 	echo " -e, --eth-type [TYPE]          Ethernet Type                 (default: bridged)"
 	echo " -f, --floppy                   Enable Floppy Drive           (default: FALSE)"
 	echo " -m, --mac-addr [ADDR]          Use static mac address        (address: 00:50:56:xx:xx:xx)"
 	echo " -n, --name [NAME]              Display name of your VM       (default: <os-type>-vm)"
 	echo " -o, --output-file [FILE]       Zip file to write output to   (default: <os-type>-vm.zip)"
 	echo " -r, --ram [SIZE]               RAM size in MB                (default: 256)"
 	echo " -s, --sound                    Enable sound card             (default: FALSE)"
 	echo " -t, --disk-type [TYPE]         HDD Interface, SCSI or IDE    (default: IDE)"
 	echo " -u, --usb                      Enable USB                    (default: FALSE)"
 	echo
 	echo " -q, --quiet                    Run without asking questions, takes the default values."
 	echo " -y, --yes                      Say YES to all questions. This overwrites existing files!!" 
    echo " -z, --zip                      Zip the Virtual Machine"
    echo " -g, --go                       Start the Virtual Machine in vmware" 
	echo
 	echo " -h, --help                     This help screen"
 	echo " -l, --list                     Generate a list of VMware Guest OSes"
 	echo " -v, --version                  Shows version information"
 	echo
	echo "Dependencies:"
 	echo "This program needs the 'zip' and 'qemu-img' binaries in its path..."
	echo
	echo "Examples:"
	echo " Create an Ubuntu Linux machine with a 20GB hard disk and a different name"
	echo "   $ $PROGRAM_NAME ubuntu -d 20 -n \"My Ubuntu VM\" -o my-ubuntu-vm.zip" 
	echo
	echo " Silently create a SUSE Linux machine with 512MB ram, a fixed MAC address and zip it"
	echo "   $ $PROGRAM_NAME suse -r 512 -q -m 00:50:56:01:25:00 -z" 
	echo
	echo " Create a Windows XP machine with 512MB and sound, USB and CD enabled"
	echo "   $ $PROGRAM_NAME winXPPro -r 512 -s -u -c" 
	echo
    echo " Create an Ubuntu VM with 512MB and run it in vmware"
    echo "   $ $PROGRAM_NAME ubuntu -r 512 -q -x"
    echo

}
function DoCreateConf(){
DoStatus "Creating working dir...	"
    mkdir -p $WRKDIR &> /dev/null
DoOke
DoStatus "Creating virtual disk...	"
    qemu-img create -f vmdk $WRKDIR/$VM_DISK_NAME $VM_DISK_SIZE &> /dev/null
DoOke
DoStatus "Creating config file...	"
    echo '#!/usr/bin/vmware						'	>> $VM_VMX_FILE
	echo 'config.version                    = "'$VM_CONF_VER'"	'	>> $VM_VMX_FILE	
 	echo 'virtualHW.version                 = "'$VM_VMHW_VER'"	'	>> $VM_VMX_FILE
	echo 'displayName                       = "'$VM_NAME'"		'	>> $VM_VMX_FILE
	echo 'guestOS                           = "'$VM_OS_TYPE'"	'	>> $VM_VMX_FILE
	echo 'memsize                           = "'$VM_RAM'"		'	>> $VM_VMX_FILE
	echo 'nvram                             = "'$VM_NVRAM'"		'	>> $VM_VMX_FILE
	echo 'ethernet0.present                 = "TRUE"		'	>> $VM_VMX_FILE
	echo 'ethernet0.connectionType          = "'$VM_ETH_TYPE'"	'	>> $VM_VMX_FILE
	if [ ! $VM_MAC_ADDR = "default" ]; then
		echo 'ethernet0.addressType             = "static"		'	>> $VM_VMX_FILE
		echo 'ethernet0.address                 = "'$VM_MAC_ADDR'"	'	>> $VM_VMX_FILE
	else
		echo 'ethernet0.addressType             = "generated"		'	>> $VM_VMX_FILE
	fi
	if [ ! $VM_DISK_TYPE = "IDE" ]; then
		echo 'scsi0:0.present                   = "TRUE"		'	>> $VM_VMX_FILE
		echo 'scsi0:0.fileName                  = "'$VM_DISK_NAME'"	'	>> $VM_VMX_FILE
	else 
	 	echo 'ide0:0.present                    = "TRUE"		'	>> $VM_VMX_FILE
		echo 'ide0:0.fileName                   = "'$VM_DISK_NAME'"	'	>> $VM_VMX_FILE
	fi
	if [ $VM_USE_USB = "FALSE" ]; then
		echo 'usb.present                       = "FALSE"		'	>> $VM_VMX_FILE
	else
		echo 'usb.present                       = "TRUE"		'	>> $VM_VMX_FILE
		echo 'usb.generic.autoconnect           = "FALSE"		'	>> $VM_VMX_FILE
	fi
	if [ $VM_USE_SND = "FALSE" ]; then
		echo 'sound.present                     = "FALSE"		'	>> $VM_VMX_FILE
	else
		echo 'sound.present                     = "TRUE"		'	>> $VM_VMX_FILE
		echo 'sound.fileName                    = "-1"			'	>> $VM_VMX_FILE
		echo 'sound.autodetect                  = "TRUE"		'	>> $VM_VMX_FILE
		echo 'sound.startConnected              = "FALSE"		'	>> $VM_VMX_FILE
	fi
	if [ $VM_USE_FDD = "FALSE" ]; then
		echo 'floppy0.present                   = "FALSE"		'	>> $VM_VMX_FILE
	else
		echo 'floppy0.present                   = "TRUE"		'	>> $VM_VMX_FILE
		echo 'floppy0.startConnected            = "FALSE"		'	>> $VM_VMX_FILE
	fi
	if [ $VM_USE_CDD = "FALSE" ]; then
		echo 'ide1:0.present                    = "FALSE"		'	>> $VM_VMX_FILE
		echo 'ide1:0.autodetect                 = "TRUE"		'	>> $VM_VMX_FILE
	else
		echo 'ide0:1.present                    = "TRUE"		'	>> $VM_VMX_FILE
		echo 'ide0:1.fileName                   = "auto detect"		'	>> $VM_VMX_FILE
		echo 'ide0:1.autodetect                 = "TRUE"		'	>> $VM_VMX_FILE
		echo 'ide0:1.deviceType                 = "cdrom-raw"		'	>> $VM_VMX_FILE
		echo 'ide0:1.startConnected             = "FALSE"		'	>> $VM_VMX_FILE
	fi
	echo 'annotation                        = "This VM is created by '$PROGRAM'..."'	>> $VM_VMX_FILE
    DoOke
}
function DoSummary(){
    DoEcho "I am about to create this Virtual Machine:"
	    echo -e "      Virtual OS                \033[1m $VM_OS_TYPE \033[0m"
	    echo -e "      Display name              \033[1m $VM_NAME \033[0m"
	    echo -e "      RAM (MB)                  \033[1m $VM_RAM \033[0m"
	    echo -e "      HDD (GB)                  \033[1m $VM_DISK_SIZE\033[0m"
	    echo -e "      HDD Interface             \033[1m $VM_DISK_TYPE\033[0m"
	    echo -e "      Outputfile                \033[1m $VM_OUTP_FILE\033[0m"
	    echo -e "      BIOS file                 \033[1m $VM_NVRAM\033[0m"
	    echo -e "      Ethernet Type             \033[1m $VM_ETH_TYPE\033[0m"
    	echo -e "      Mac Address               \033[1m $VM_MAC_ADDR\033[0m"
    	echo -e "      DISK type                 \033[1m $VM_DISK_TYPE\033[0m"
    	echo -e "      Floppy Disk               \033[1m $VM_USE_FDD\033[0m"
    	echo -e "      CD/DVD                    \033[1m $VM_USE_CDD\033[0m"
    	echo -e "      USB                       \033[1m $VM_USE_USB\033[0m"
    	echo -e "      Sound Card                \033[1m $VM_USE_SND\033[0m"
    askOke
}
function DoChecks(){
    # Check for needed binaries
    DoEcho "Creating Virtual Machine..."
    DoStatus "Checking for qemu-img...	"
	    which qemu-img &> /dev/null
    DoOke
    DoStatus "Checking for zip...       "
	    which zip &> /dev/null
    DoOke
    # Check if working dir file exists
    if [ -e $WRKDIR ]
    then 
	    DoAlert "Working dir already exists, i will trash it!"
	    askNoOke
	    DoStatus "Trashing working dir...   "
		    rm -rf $WRKDIR &>/dev/null
	    DoOke
    fi
    # Check if zipfile exists
	if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then
        if [ -e $VM_OUTP_FILE ]
        then 
	        DoAlert "Zipfile already exists, i will trash it!"
	        askNoOke
	        DoStatus "Trashing zipfile...	"
		        rm $VM_OUTP_FILE &>/dev/null
	        DoOke
        fi
    fi
}
function DoCreateOutput(){
	if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then
        # Generate zipfile
        DoStatus "Generate zipfile... 	"
        cd $WRKPATH
	    zip -q -r $VM_OUTP_FILE $WRKDIR/ &> /dev/null
        DoOke
    fi
}
function DoCleanUp(){
    # Back to base dir...
    cd - &> /dev/null
    # Clean up if zipped, and announce file location
    if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then 
	    DoStatus "Cleaning up workingdir...	"
		    rm -rf $WRKDIR
	    DoOke
	    DoEcho "Grab you VM here: $VM_OUTP_FILE"
    else
	    DoEcho "Created VM here: $VM_VMX_FILE"
    fi
    # Start VM if asked for 
    if [ "$DEFAULT_STARTVM" = "yes" ];
    then 
	    DoEcho "Starting Virtual Machine..."
        vmware -x $VM_VMX_FILE
    fi 
}
function askOke(){
	if [ ! "$DEFAULT_QUIET" = "yes" ]; 
	then
		echo -ne "\033[1m[ ? ] Is it oke to continue?     \033[1;32m[Yn]\033[0m "
		read YESNO
		if [ "$YESNO" = "n" ] ; then DoAlert "Stopped..."; exit 0; fi
	fi
}
function askNoOke(){
	if [ ! "$DEFAULT_YES" = "yes" ]; 
	then
		echo -ne "\033[1m[ ? ] Is it oke to continue?     \033[1;31m[yN]\033[0m "
		read YESNO
		if [ ! "$YESNO" = "y" ]; then DoAlert "Stopped..."; exit 0; fi
	fi
}
function DoStatus() {
	echo -ne "\033[1m      \033[0m$1 "
}
function DoEcho() {
	echo -e "\033[1m[ * ] \033[0m\033[1;33m$1\033[0m "
}
function DoAlert() {
	echo -e "\033[1m[ ! ] \033[0m\033[1;31m$1\033[0m "
}
function DoError() {
	echo -e "\033[1m[ * ] \033[0m\033[1;31m$1\033[0m "
}
function DoOke() {
    if [[ $? -ne 0 ]] ; then
        echo -e "\033[1;31m[FAILED]\033[0;00m"
        exit 1;
    else
        echo -e "\033[1;32m[OK]\033[0;00m"
    fi
}
function DoOsList() {
    echo "List of Guest Operating Systems:"
    for OS in ${SUPPORT_OS[@]}
    do 
    	echo " - " $OS;
    done
}
function DoSuppOsTest(){
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
		echo "Guest OS \"$VM_OS_TYPE\" is unknown..."
		echo "use \"$PROGRAM_NAME -h\" for help and examples..."
		echo "and \"$PROGRAM_NAME -l\" for a list of Guest OS's..."
		exit 1
	fi
}
##########	The flow!	##########
if [ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then DoUsage; exit; fi
if [ "$1" = "-v" ] || [ "$1" = "--version" ]; then DoVersion; exit; fi
if [ "$1" = "--list" ] || [ "$1" = "-l" ]; then DoOsList; exit 1; fi
VM_OS_TYPE=$1
DoSuppOsTest
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
	-g | --go )
		DEFAULT_STARTVM="yes"
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
	-y | --yes )
		DEFAULT_QUIET="yes"
		DEFAULT_YES="yes"
		    ;;
	-v | --version )
		DoVersion
		    ;;
	-z | --zip )
		DEFAULT_ZIPIT="yes"
		    ;;
	* )
		shift
		DoEcho "Euhm... what did you mean by \"$*\"?"
		DoEcho "Please run \"$PROGRAM_NAME -h\" for help and examples..."
		exit 1
	esac
	shift
done

# Fill in some default entries when left empty
if [ "$VM_RAM" = "" ]; 		then VM_RAM=256; fi 
if [ "$VM_NAME" = "" ]; 	then VM_NAME=$VM_OS_TYPE-vm; fi 
if [ "$VM_NVRAM" = "" ]; 	then VM_NVRAM=nvram; fi 
if [ "$VM_ETH_TYPE" = "" ]; 	then VM_ETH_TYPE=Bridged; fi
if [ "$VM_MAC_ADDR" = "" ]; 	then VM_MAC_ADDR=default; fi
if [ "$VM_DISK_SIZE" = "" ];	then VM_DISK_SIZE=8; fi 
if [ "$VM_DISK_TYPE" = "" ]; 	then VM_DISK_TYPE=IDE; fi
if [ "$VM_OUTP_FILE" = "" ]; 	then VM_OUTP_FILE=`pwd`/$VM_OS_TYPE-vm.zip; fi 
if [ "$VM_USE_USB" = "" ]; 	then VM_USE_USB=FALSE; fi
if [ "$VM_USE_SND" = "" ]; 	then VM_USE_SND=FALSE; fi
if [ "$VM_USE_CDD" = "" ]; 	then VM_USE_CDD=FALSE; fi
if [ "$VM_USE_FDD" = "" ]; 	then VM_USE_FDD=FALSE; fi

VM_CONF_VER=8
VM_VMHW_VER=3
VM_DISK_SIZE=$VM_DISK_SIZE'G'
WRKDIR=$WRKPATH/$VM_OS_TYPE
VM_DISK_NAME=$VM_DISK_TYPE-$VM_OS_TYPE.vmdk
VM_VMX_FILE=$WRKDIR/$VM_OS_TYPE.vmx

DoSummary
DoChecks
DoCreateConf
DoCreateOutput
DoCleanUp

##########	The End!	##########
