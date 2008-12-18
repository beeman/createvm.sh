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
LOGFILE=createvm.log
BINARIES=(gzip tar vmware-vdiskmanager zip)

# Default settings
DEFAULT_QUIET=no        # Don't ask for confirmations, only when critical
DEFAULT_YES=no          # Yes to al questions (warning: will overwrite existing files) 
DEFAULT_ZIPIT=no        # Create .zip archive
DEFAULT_TARGZIT=no      # Create .tar.gz archive 
DEFAULT_START_VM=no      # Start VM after creating it
DEFAULT_WRKPATH=.       # Location where output will be
BINARY_TESTS="FALSE"

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

# This is the list of supported OS'es
SUPPORT_OS=(winVista longhorn winNetBusiness winNetEnterprise winNetStandard \
winNetWeb winXPPro winXPHome win2000AdvServ win2000Serv win2000Pro winNT winMe \
win98 win95 win31 windows winVista-64 longhorn-64 winNetEnterprise-64 \
winNetStandard-64 winXPPro-64 ubuntu redhat rhel4 rhel3 rhel2 suse sles \
mandrake nld9 sjds turbolinux other26xlinux other24xlinux linux ubuntu-64 \
rhel4-64 rhel3-64 sles-64 suse-64 other26xlinux-64 other24xlinux-64 other-64 \
otherlinux-64 solaris10-64 solaris10 solaris9 solaris8 solaris7 solaris6 \
solaris netware6 netware5 netware4 netware freeBSD-64 freeBSD darwin other)


### Main functions ###

# Show version info
function print_version() {
    echo -e "\033[1m$PROGRAM - $PROGRAM_TITLE\033[0;00m"
    echo -e $PROGRAM_COPYRIGHT
}
# Print status message
function status_msg() {
    echo -ne "\033[1m    \033[0;00m$1 "
}
# Print if cmd returned oke or failed
function status_check() {
    if [[ $? -ne 0 ]] ; then
        echo -e "\033[1;31m[FAILED]\033[0;00m"
        exit 1;
    else
        echo -e "\033[1;32m[OK]\033[0;00m"
    fi
}
# Print normal message
function message() {
    echo -e "    $1 "
}
# Print highlighted message
function info() {
    echo -e "\033[1m    $1\033[0;00m "
}

function _alert() {
    local _type=$1
    shift;
    echo -e "\033[1m[$_type] \033[0;00m\033[1;31m$1\033[0;00m "
}

# Print alert message
function alert() {
    _alert '!' "$@"
}

# Print error message
function error() {
    _alert 'E' "$@"
}

# Ask if a user wants to continue, default to YES
function ask_oke(){
    if [ ! "$DEFAULT_QUIET" = "yes" ]; 
    then
        echo -ne "\033[1m[?] Is it oke to continue?     \033[1;32m[Yn]\033[0;00m "
        read YESNO
        if [ "$YESNO" = "n" ] ; then alert "Stopped..."; exit 0; fi
    fi
}
# Ask if a user wants to continue, default to NO
function ask_no_oke(){
    if [ ! "$DEFAULT_YES" = "yes" ]; 
    then
        echo -ne "\033[1m[?] Is it oke to continue?     \033[1;31m[yN]\033[0;00m "
        read YESNO
        if [ ! "$YESNO" = "y" ]; then alert "Stopped..."; exit 0; fi
    fi
}

### Specific funtions ###

# Print Help message
function print_usage() {
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
 -w, --working-dir [PATH]       Path to use as Working Dir    (default: current working dir)
 -o, --output-file [FILE]       File to write archive to      (default: <os-type>-vm.zip/.tar.gz)
 -z, --zip                      Create .zip from this VM
 -g, --tar-gz                   Create .tar.gz from this VM

 -l, --list                     Generate a list of VMware Guest OS'es
 -q, --quiet                    Runs without asking questions, accept the default values
 -y, --yes                      Say YES to all questions. This overwrites existing files!! 
 -x, -X                         Start the Virtual Machine in vmware, X for fullscreen

 -h, --help                     This help screen
 -v, --version                  Shows version information
 -ex, --sample                  Show some examples 

Dependencies:
This program needs the following binaries in its path: ${BINARIES[@]}"
}

# Show some examples
function print_examples(){
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
function print_summary(){
    info "I am about to create this Virtual Machine:"
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
    ask_oke
}

function add_config_param() {
    if [ -n "$1" ] ; then
        local item=$1
        shift;
        [ -n "$1" ] && CONFIG_PARAM="$CONFIG_PARAM\n$item = \"$@\""
    else
        CONFIG_PARAM=""
    fi
}

function print_config() {
    echo -e $CONFIG_PARAM > "$VM_VMX_FILE"
}

# Create the .vmx file
function create_conf(){
    status_msg "Creating config file...   "
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
    if [ ! $VM_USE_FDD = "FALSE" ]; then
        add_config_param floppy0.present TRUE
        add_config_param floppy0.startConnected FALSE
    else
        add_config_param floppy0.present FALSE
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
    status_check
}

# Create the working dir
function create_working_dir(){
    info "Creating Virtual Machine..."
    status_msg "Creating working dir...   "
    mkdir -p "$WRKDIR" &> /dev/null
    status_check
}
# Create the virtual disk
function create_virtual_disk(){
    status_msg "Creating virtual disk...  "

    local adapter=buslogic
    if [ "$VM_DISK_TYPE" = "IDE" ] ; then 
         adapter=ide
    fi
    vmware-vdiskmanager -qq -c -a $adapter -t 1 -s $VM_DISK_SIZE "$WRKDIR/$VM_DISK_NAME" &> $LOGFILE
    status_check
}
# Generate a zip file with the created VM (TODO: needs tar.gz too)
function create_archive(){
    if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then
        # Generate zipfile
        status_msg "Generate zip file...      "
        cd $DEFAULT_WRKPATH
        zip -q -r $VM_OUTP_FILE_ZIP $VM_NAME &> /dev/null
        status_check
    fi
    if [ "$DEFAULT_TARGZIT" = "yes" ]; 
    then
        # Generate tar.gz file
        status_msg "Generate tar.gz file...   "
        cd $DEFAULT_WRKPATH
        tar cvzf $VM_OUTP_FILE_TAR $VM_NAME &> /dev/null
        status_check
    fi
}
# Print OS list.
function print_os_list() {
    echo "List of Guest Operating Systems:"

    local max=${#SUPPORT_OS[@]}
    for ((i=0;i < max; i=i+3)) ; do
        printf "%-25s %-25s %-25s\n" ${SUPPORT_OS[$i]} ${SUPPORT_OS[$((i + 1))]} ${SUPPORT_OS[$((i + 2))]}
    done
}
# Check if selected OS is in the OS list
function run_os_test(){
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
        error "Guest OS \"$VM_OS_TYPE\" is unknown..."
        message "Run \"$PROGRAM_NAME -l\" for a list of Guest OS'es..."
        message "Run \"$PROGRAM_NAME -h\" for help..."
        message "Run \"$PROGRAM_NAME -ex\" for examples..."
        exit 1
    fi
}
# Check for binaries and existance of previously created VM's
function run_tests(){
    # Check for needed binaries
    info "Checking binaries..."
    local app
    for app in ${BINARIES[@]} ; do
        status_msg ""
        printf "    %-22s" "$app..."
        which $app 1> /dev/null
        status_check
    done
    # Check if working dir file exists
    info "Checking files and directories..."
    if [ -e "$WRKDIR" ]
    then 
        alert "Working dir already exists, i will trash it!"
        ask_no_oke
        status_msg "Trashing working dir...   "
        rm -rf "$WRKDIR" &>/dev/null
        status_check
    fi
    # Check if zip file exists
    if [ "$DEFAULT_ZIPIT" = "yes" ]; 
    then
        if [ -e $VM_OUTP_FILE_ZIP ]
        then 
            alert "Zipfile already exists, i will trash it!"
            ask_no_oke
            status_msg "Trashing zipfile...       "
            rm $VM_OUTP_FILE_ZIP &>/dev/null
            status_check
        fi
    fi
    # Check if tar.gz file exists
    if [ "$DEFAULT_TARGZIT" = "yes" ]; 
    then
        if [ -e $VM_OUTP_FILE_TAR ]
        then 
            alert "tar.gz file already exists, i will trash it!"
            ask_no_oke
            status_msg "Trashing tar.gz file...   "
            rm $VM_OUTP_FILE_TAR &>/dev/null
            status_check
        fi
    fi
}
# Clean up working dir and start VM (TODO: needs top be seperated)
function clean_up(){
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
        status_msg "Cleaning up workingdir... "
        rm -rf $WRKDIR
        status_check
    else
        VMLOCATION="$VM_VMX_FILE"
    fi
    info "Grab you VM here: $VMLOCATION"
}
# Start VM if asked for 
function start_vm(){
    if [ "$DEFAULT_START_VM" = "yes" ];
    then 
        info "Starting Virtual Machine..."
        vmware $VMW_OPT $VM_VMX_FILE
    fi
}

### The flow! ###

# Chatch some parameters if the first one is not the OS.
if [ "$1" = "" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then print_usage; exit; fi
if [ "$1" = "-v" ] || [ "$1" = "--version" ];     then print_version; exit; fi
if [ "$1" = "-l" ] || [ "$1" = "--list" ];     then print_os_list; exit 1; fi
if [ "$1" = "-ex" ] || [ "$1" = "--sample" ];     then print_examples; exit 1; fi

# The first parameter is the Guest OS Type
VM_OS_TYPE=$1

# Set default VM Name and output filename
VM_NAME=$VM_OS_TYPE-vm
VM_OUTP_FILE_ZIP=$VM_NAME.zip
VM_OUTP_FILE_TAR=$VM_NAME.tar.gz

# Run OS test
run_os_test

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
    -B | --binary )
        BINARY_TESTS="FALSE"
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
        print_version
    ;;
    -w | --working-dir )
        shift
        DEFAULT_WRKPATH=$1
    ;;
    -x  )
        DEFAULT_START_VM="yes"
        VMW_OPT="-x"
    ;;
    -X  )
        DEFAULT_START_VM="yes"
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
        error "Euhm... what did you mean by \"$*\"?"
        message "Run \"$PROGRAM_NAME -h\" for help"
        message "Run \"$PROGRAM_NAME -ex\" for examples..."
        
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
print_version
# Display summary
print_summary
# Do some tests
run_tests

# Create working environment
create_working_dir
# Write config file
create_conf
# Create virtual disk
create_virtual_disk
# Create archine
create_archive

# Clean up environment
clean_up
# Run the VM
start_vm

### The End! ###
