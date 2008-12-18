#!/bin/bash
# Author: Bram Borggreve ( borggreve @ gmail dot com )
# Homepage: http://code.google.com/p/createvm/
# License: GPL, see: http://www.gnu.org/copyleft/gpl.txt

### Todo ###
# - Start VM with parameter, vmplayer and vmware
# - Automatically register the VM with vmware server
# - Add ESX support
# - Named color codes

### Some default variables ###

# Program info
PROGRAM_NAME=`basename $0`
PROGRAM_TITLE="Create VMware Virtual Machines in bash"
PROGRAM_VER="0.5"
PROGRAM_COPYRIGHT="Copyright 2007-2008. \
Distributed under GPL license. No warranty whatsoever, express or implied."
PROGRAM="$PROGRAM_NAME $PROGRAM_VER"

# Default settings
DEFAULT_QUIET=no        # Don't ask for confirmations, only when critical
DEFAULT_YES=no          # Yes to al questions (warning: will overwrite existing files) 
DEFAULT_ZIPIT=no        # Zip it after creation
DEFAULT_TARGZIT=no      # Tar+GZ it afger creation
DEFAULT_STARTVM=no      # Start it after creation
DEFAULT_WRKPATH=.       # Location where output will be

# Default VM parameters
VM_CONF_VER=8           # VM Config version
VM_VMHW_VER=4           # VM Hardware version
VM_RAM=256              # Default RAM
VM_NVRAM=nvram          # Default bios file
VM_ETH_TYPE=bridged     # Default network type
VM_MAC_ADDR=default     # Default MAC address
VM_DISK_SIZE=8          # Default DISK size (GB's)
VM_DISK_TYPE=SCSI       # Default DISK type
VM_USE_USB=FALSE        # Enable USB
VM_USE_SND=FALSE        # Enable sound
VM_USE_CDD=FALSE        # Enable CD drive
VM_USE_ISO=FALSE        # Enable and load ISO 
VM_USE_FDD=FALSE        # Enable and load FDD

# This is the list of supported OS's
SUPPORT_OS=(winVista longhorn winNetBusiness winNetEnterprise winNetStandard \
winNetWeb winXPPro winXPHome win2000AdvServ win2000Serv win2000Pro winNT winMe \
win98 win95 win31 windows winVista-64 longhorn-64 winNetEnterprise-64 \
winNetStandard-64 winXPPro-64 ubuntu redhat rhel4 rhel3 rhel2 suse sles \
mandrake nld9 sjds turbolinux other26xlinux\ other24xlinux linux ubuntu-64 \
rhel4-64 rhel3-64 sles-64 suse-64 other26xlinux-64 other24xlinux-64 other-64 \
otherlinux-64 solaris10-64 solaris10 solaris9 solaris8 solaris7 solaris6 \
solaris netware6 netware5 netware4 netware freeBSD-64 freeBSD darwin other)


### Main functions ###

# Show version info
function PrintVersion() {
    echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0;00m"
    echo -e $PROGRAM_COPYRIGHT
}
# Print status message
function StatusMsg() {
    echo -ne "\033[1m    \033[0;00m$1 "
}
# Print if cmd returned oke or failed
function StatusCheck() {
    if [[ $? -ne 0 ]] ; then
        echo -e "\033[1;31m[FAILED]\033[0;00m"
        exit 1;
    else
        echo -e "\033[1;32m[OK]\033[0;00m"
    fi
}
# Print normal message
function Message() {
    echo -e "    $1 "
}
# Print highlighted message
function Info() {
    echo -e "\033[1m    $1\033[0;00m "
}

function _alert() {
    local _type=$1
    shift;
    echo -e "\033[1m[$_type] \033[0;00m\033[1;31m$1\033[0;00m "
}

# Print alert message
function Alert() {
    _alert '!' "$@"
}

# Print error message
function Error() {
    _alert 'E' "$@"
}

# Ask if a user wants to continue, default to YES
function AskOke(){
    if [ ! "$DEFAULT_QUIET" = "yes" ]; 
    then
        echo -ne "\033[1m[?] Is it oke to continue?     \033[1;32m[Yn]\033[0;00m "
        read YESNO
        if [ "$YESNO" = "n" ] ; then Alert "Stopped..."; exit 0; fi
    fi
}
# Ask if a user wants to continue, default to NO
function AskNoOke(){
    if [ ! "$DEFAULT_YES" = "yes" ]; 
    then
        echo -ne "\033[1m[?] Is it oke to continue?     \033[1;31m[yN]\033[0;00m "
        read YESNO
        if [ ! "$YESNO" = "y" ]; then Alert "Stopped..."; exit 0; fi
    fi
}

### Specific funtions ###

# Print Help message
function PrintUsage() {
    echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0;00m.
Usage: $PROGRAM_NAME GuestOS OPTIONS

VM Options:
 -n, --name [NAME]              Friendly name of the VM       (default: <os-type>-vm)
 -r, --ram [SIZE]               RAM size in MB                (default: $VM_RAM)
 -d, --disk-size [SIZE]         HDD size in GB                (default: $VM_DISK_SIZE)
 -t, --disk-type [TYPE]         HDD Interface, SCSI or IDE    (default: $VM_DISK_TYPE)
 -e, --eth-type [TYPE]          Network Type (bridge/nat/etc) (default: $VM_ETH_TYPE)
 -m, --mac-addr [ADDR]          Use static mac address        (address: 00:50:56:xx:xx:xx)

 -c, --cdrom                    Enable CDROM Drive            (default: $VM_USE_CDD)
 -i, --iso [FILE]               Enable CDROM Iso              (default: $VM_USE_ISO)
 -f, --floppy                   Enable Floppy Drive           (default: $VM_USE_FDD)
 -a, --audio                    Enable sound card             (default: $VM_USE_SND)
 -u, --usb                      Enable USB                    (default: $VM_USE_USB)
 -b, --bios [PATH]              Path to custom bios file      (default: $VM_NVRAM)

Program Options:
 -o, --output-file [FILE]       Zip file to write output to   (default: <os-type>-vm.zip)
 -w, --working-dir [PATH]       Path to use as Working Dir    (default: current working dir)
 -z, --zip                      Create .zip from this VM
 -g, --tar-gz                   Create .tar.gz from this VM

 -l, --list                     Generate a list of VMware Guest OSes
 -q, --quiet                    Runs without asking questions, take the default values
 -y, --yes                      Say YES to all questions. This overwrites existing files!! 
 -x, -X                         Start the Virtual Machine in vmware, X for fullscreen

 -h, --help                     This help screen
 -v, --version                  Shows version information
 -ex, --sample                  Show some examples 

Dependencies:
This program needs the 'zip' and 'vmware-vdiskmanager' binaries in its path..."
}

# Show some examples
function PrintExamples(){
    echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0;00m.
Here are some examples:

 Create an Ubuntu Linux machine with a 20GB hard disk and a different name
   $ $PROGRAM_NAME ubuntu -d 20 -n \My Ubuntu VM\ -o my-ubuntu-vm.zip 

 Silently create a SUSE Linux machine with 512MB ram, a fixed MAC address and zip it
   $ $PROGRAM_NAME suse -r 512 -q -m 00:50:56:01:25:00 -z 

 Create a Windows XP machine with 512MB and audio, USB and CD enabled
   $ $PROGRAM_NAME winXPPro -r 512 -a -u -c 

 Create an Ubuntu VM with 512MB and run it in vmware
   $ $PROGRAM_NAME ubuntu -r 512 -q -x"    
}
    
function _print_summary_item() {
    local item=$1
    shift;
    printf "    %-26s" "$item"
    echo -e "\033[1m $* \033[0;00m"
}

# Print a summary with some of the options on the screen
function PrintSummary(){
    Info "I am about to create this Virtual Machine:"
    _print_summary_item "Guest OS" $VM_OS_TYPE
    _print_summary_item "Display name" $VM_NAME
    _print_summary_item "RAM (MB)" $VM_RAM
    _print_summary_item "HDD (Gb)" $VM_DISK_SIZE
    _print_summary_item "HDD interface" $VM_DISK_TYPE
    _print_summary_item "BIOS file" $VM_NVRAM
    _print_summary_item "Ethernet type" $VM_ETH_TYPE
    _print_summary_item "Mac address" $VM_MAC_ADDR
    _print_summary_item "Floppy disk" $VM_USE_FDD
    _print_summary_item "CD/DVD drive" $VM_USE_CDD
    _print_summary_item "CD/DVD image" $VM_USE_ISO
    _print_summary_item "USB device" $VM_USE_USB
    _print_summary_item "Sound Card" $VM_USE_SND
    AskOke
}

function add_config_param() {
    if [ -n "$1" ] ; then
        local item=$1
        shift;
        [ -n "$1" ] && CONFIG_PARAM="$CONFIG_PARAM\n$item = '$@'"
    else
        CONFIG_PARAM=""
    fi
}

function print_config() {
    echo -e $CONFIG_PARAM > "$VM_VMX_FILE"
}

# Create the .vmx file
function CreateConf(){

    StatusMsg "Creating config file...   "
    # echo '#!/usr/bin/vmware' >> $VM_VMX_FILE
    add_config_param config.version $VM_CONF_VER
    add_config_param virtualHW.version $VM_VMHW_VER
    add_config_param displayName $VM_NAME
    add_config_param guestOS $VM_OS_TYPE
    add_config_param memsize $VM_RAM
    if [ ! $VM_NVRAM = "nvram" ]; then
        FILENAME=`basename $VM_NVRAM`
        cp $VM_NVRAM "$WRKDIR/$FILENAME"
        add_config_param nvram $FILENAME
    else
    add_config_param nvram $VM_NVRAM
    fi
    add_config_param ethernet0.present TRUE
    add_config_param ethernet0.connectionType $VM_ETH_TYPE
    if [ ! $VM_MAC_ADDR = "default" ]; then
        add_config_param ethernet0.addressType static
        add_config_param ethernet0.address $VM_MAC_ADDR
    else
        add_config_param ethernet0.addressType generated
    fi
    if [ ! $VM_DISK_TYPE = "IDE" ]; then
        add_config_param scsi0:0.present TRUE
        add_config_param scsi0:0.fileName $VM_DISK_NAME
    else 
        add_config_param ide0:0.present TRUE
        add_config_param ide0:0.fileName $VM_DISK_NAME
    fi
    if [ ! $VM_USE_USB = "FALSE" ]; then
        add_config_param usb.present TRUE
        add_config_param usb.generic.autoconnect FALSE
    fi
    if [ ! $VM_USE_SND = "FALSE" ]; then
        add_config_param sound.present TRUE
        add_config_param sound.fileName -1
        add_config_param sound.autodetect TRUE
        add_config_param sound.startConnected FALSE
    fi
    if [ $VM_USE_FDD = "FALSE" ]; then
        add_config_param floppy0.present FALSE
    else
        add_config_param floppy0.present TRUE
        add_config_param floppy0.startConnected FALSE
    fi
    if [ ! $VM_USE_CDD = "FALSE" ]; then
        add_config_param ide0:1.present TRUE
        add_config_param ide0:1.fileName auto detect
        add_config_param ide0:1.autodetect TRUE
        add_config_param ide0:1.deviceType cdrom-raw
        add_config_param ide0:1.startConnected FALSE
    fi

    if [ ! $VM_USE_ISO = "FALSE" ]; then
        add_config_param ide1:0.present TRUE
        add_config_param ide1:0.fileName $VM_USE_ISO
        add_config_param ide1:0.deviceType cdrom-image
        add_config_param ide1:0.startConnected TRUE
        add_config_param ide1:0.mode persistent
    fi
    add_config_param annotation "This VM is created by $PROGRAM"
    print_config
    StatusCheck
}

# Create the working dir
function CreateWorkingDir(){
    StatusMsg "Creating working dir...   "
    mkdir -p "$WRKDIR" &> /dev/null
    StatusCheck
}
# Create the virtual disk
function CreateVirtualDisk(){
    StatusMsg "Creating virtual disk...  "

    local adapter=buslogic
    if [ "$VM_DISK_TYPE" = "IDE" ] ; then 
         adapter=ide
    fi
    vmware-vdiskmanager -c -a $adapter -t 1 -s $VM_DISK_SIZE "$WRKDIR/$VM_DISK_NAME"  &> /dev/null
    StatusCheck
}
# Generate a zip file with the created VM (TODO: needs tar.gz too)
function CreateArchive(){
    if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then
        # Generate zipfile
        StatusMsg "Generate zip file...      "
        cd $DEFAULT_WRKPATH
        zip -q -r $VM_OUTP_FILE_ZIP $VM_NAME &> /dev/null
        StatusCheck
    fi
    if [ "$DEFAULT_TARGZIT" = "yes" ]; 
    then
        # Generate tar.gz file
        StatusMsg "Generate tar.gz file...   "
        cd $DEFAULT_WRKPATH
        tar cvzf $VM_OUTP_FILE_TAR $VM_NAME &> /dev/null
        StatusCheck
    fi
}
# Print OS list.
function PrintOsList() {
    echo "List of Guest Operating Systems:"

    local max=${#SUPPORT_OS[@]}
    for ((i=0;i < max; i=i+3)) ; do
        printf "%-25s %-25s %-25s\n" ${SUPPORT_OS[$i]} ${SUPPORT_OS[$((i + 1))]} ${SUPPORT_OS[$((i + 2))]}
    done
}
# Check if selected OS is in the OS list
function RunOsTest(){
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
        Error "Guest OS \"$VM_OS_TYPE\" is unknown..."
        
        Message "Run \"$PROGRAM_NAME -l\" for a list of Guest OS's..."

        Message "Run \"$PROGRAM_NAME -h\" for help..."
        Message "Run \"$PROGRAM_NAME -ex\" for examples..."
        exit 1
    fi
}
# Check for binaries and existance of previously created VM's
function RunTests(){
    # Check for needed binaries
    Info "Creating Virtual Machine..."
    local app
    for app in vmware-vdiskmanager zip ; do
        StatusMsg ""
        printf "    %-22s" "$app..."
        which $app &> /dev/null
        StatusCheck
    done
    # Check if working dir file exists
    if [ -e "$WRKDIR" ]
    then 
        Alert "Working dir already exists, i will trash it!"
        AskNoOke
        StatusMsg "Trashing working dir...   "
        rm -rf "$WRKDIR" &>/dev/null
        StatusCheck
    fi
    # Check if zip file exists
    if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then
        if [ -e $VM_OUTP_FILE_ZIP ]
        then 
            Alert "Zipfile already exists, i will trash it!"
            AskNoOke
            StatusMsg "Trashing zipfile...       "
            rm $VM_OUTP_FILE_ZIP &>/dev/null
            StatusCheck
        fi
    fi
    # Check if tar.gz file exists
    if [ "$DEFAULT_TARGZIT" = "yes" ]; 
    then
        if [ -e $VM_OUTP_FILE_TAR ]
        then 
            Alert "tar.gz file already exists, i will trash it!"
            AskNoOke
            StatusMsg "Trashing tar.gz file...   "
            rm $VM_OUTP_FILE_TAR &>/dev/null
            StatusCheck
        fi
    fi
}
# Clean up working dir and start VM (TODO: needs top be seperated)
function CleanUp(){
    # Back to base dir...
    cd - &> /dev/null
    # Clean up if zipped or tar-gzipped, and announce file location
    if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then 
        CLEANUP='yes'
        VMLOCATION="$VM_OUTP_FILE_ZIP $VMLOCATION"
    fi
    if [ "$DEFAULT_TARGZIT" = "yes" ]; 
    then 
        CLEANUP='yes'
        VMLOCATION="$VM_OUTP_FILE_TAR $VMLOCATION"
    fi
    if [ "$CLEANUP" = "yes" ];
    then
        StatusMsg "Cleaning up workingdir... "
        rm -rf $WRKDIR
        StatusCheck
    else
        VMLOCATION="$VM_VMX_FILE"
    fi
    Info "Grab you VM here: $VMLOCATION"
}
# Start VM if asked for 
function StartVM(){
    if [ "$DEFAULT_STARTVM" = "yes" ];
    then 
        Info "Starting Virtual Machine..."
        vmware $VMW_OPT $VM_VMX_FILE
    fi
}

### The flow! ###

# Chatch some parameters if the first one is not the OS.
if [ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then PrintUsage; exit; fi
if [ "$1" = "-v" ] || [ "$1" = "--version" ];     then PrintVersion; exit; fi
if [ "$1" = "-l" ] || [ "$1" = "--list" ];     then PrintOsList; exit 1; fi
if [ "$1" = "-ex" ] || [ "$1" = "--sample" ];     then PrintExamples; exit 1; fi

# The first parameter is the Guest OS Type
VM_OS_TYPE=$1

# Set default VM Name and output filename
VM_NAME=$VM_OS_TYPE-vm
VM_OUTP_FILE_ZIP=$VM_NAME.zip
VM_OUTP_FILE_TAR=$VM_NAME.tar.gz

# Run OS test
RunOsTest

# Shift through all parameters to search for options
shift
while [ "$1" != "" ]; do
    case $1 in
    -a | --audio )
        VM_USE_SND="TRUE"
    ;;
    -b | --bios )
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
    -g | --tar-gz )
        DEFAULT_TARGZIT="yes"
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
        VM_OUTP_FILE_ZIP=$1
        VM_OUTP_FILE_TAR=$1
    ;;
    -r | --ram )
        shift
        VM_RAM=$1
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
    -w | --working-dir )
        shift
        DEFAULT_WRKPATH=$1
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
        Error "Euhm... what did you mean by \"$*\"?"
        Message "Run \"$PROGRAM_NAME -h\" for help"
        Message "Run \"$PROGRAM_NAME -ex\" for examples..."
        
        exit 1
    esac
    shift
done

# The last parameters are set
VM_DISK_SIZE=$VM_DISK_SIZE'Gb'
WRKDIR="$DEFAULT_WRKPATH/$VM_NAME"
VM_DISK_NAME=$VM_DISK_TYPE-$VM_OS_TYPE.vmdk
VM_VMX_FILE="$WRKDIR/$VM_OS_TYPE.vmx"

# Print banner
PrintVersion
# Display summary
PrintSummary
# Do some tests
RunTests

# Create working environment
CreateWorkingDir
# Write config file
CreateConf
# Create virtual disk
CreateVirtualDisk
# Create archine
CreateArchive

# Clean up environment
CleanUp
# Run the VM
StartVM

### The End! ###
