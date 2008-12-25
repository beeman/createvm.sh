#!/usr/bin/env python

""" Todo
- command line options need to be handled!
- fix ask_oke / aks_no_oke . They now only accept the default value. Meta function
- create zip and tar.gz archives
- fetch errorlevels from os.system() calls and handle them
- recreate log_status/check_status system
- 
- 
"""

import os,sys
from optparse import OptionParser

# Program info
program_name='createvm.py'
program_title="Create VMware virtual machines from the command line"
program_ver="0.6"
program_copyright="Copyright 2007-2008. \
Distributed under GPL V2 license. No warranty whatsoever, express or implied."
program=program_name+' '+program_ver

binaries=('gzip','tar','vmware-vdiskmanager','zip')
binary_tests=True

# Default settings
default_quiet=False        # Don't ask for confirmations, only when critical
default_accep=False        # Yes to al questions (warning: will overwrite existing files) 
default_zip=False          # Create .zip archive
default_targz=False        # Create .tar.gz archive 
default_start_vm=False     # Start VM after creating it
default_wrkpath='.'        # Location where output will be

# Default VM parameters
vm_conf_ver = "8"
vm_vmhw_ver = "4"
vm_name = "ubuntu-vm"
vm_os_type = "ubuntu"
vm_ram = "256"
vm_nvram = "nvram"
vm_eth_type = "bridged"
vm_mac = "default"
vm_disk_type = "buslogic"
vm_disk_size = "8GB"
vm_disk_name = vm_disk_type+'-'+vm_os_type+'.vmdk'
vm_use_usb = "FALSE"
vm_use_snd = "FALSE"
vm_use_iso = "FALSE"
vm_use_fdd = "FALSE"
vm_use_cdd = "FALSE"
vm_vnc_pass = "FALSE"
vm_vnc_port = "5901"

# These wil hold the configuration and summary
vmx_config=''
vmx_summary=''

# This is the list of supported OS'es
support_os=('winVista','longhorn','winNetBusiness','winNetEnterprise','winNetStandard',
            'winNetWeb','winXPPro','winXPHome','win2000AdvServ','win2000Serv','win2000Pro',
            'winNT','winMe','win98','win95','win31','windows','winVista-64','longhorn-64',
            'winNetEnterprise-64','winNetStandard-64','winXPPro-64','ubuntu','redhat',
            'rhel4','rhel3','rhel2','suse','sles','mandrake','nld9','sjds','turbolinux',
            'other26xlinux','other24xlinux','linux','ubuntu-64','rhel4-64','rhel3-64',
            'sles-64','suse-64','other26xlinux-64','other24xlinux-64','other-64',
            'otherlinux-64','solaris10-64','solaris10','solaris9','solaris8','solaris7',
            'solaris6','solaris','netware6','netware5','netware4','netware','freeBSD-64',
            'freeBSD','darwin','other')

# Some color codes
col_emr="\033[1;31m"    # Bold red
col_emg="\033[1;32m"    # Bold green
col_emy="\033[1;33m"    # Bold yellow
col_emw="\033[1;37m"    # Bold white
col_reset="\033[0;00m"  # Default colors

# Disable colors for IDLE for now
#col_emr=""    # Bold red
#col_emg=""    # Bold green
#col_emy=""    # Bold yellow
#col_emw=""    # Bold white
#col_reset=""  # Default colors

### Main functions ###

def version():
    ''' Show version info '''
    print col_emw+program+" - "+program_title+col_reset
    print program_copyright

def log_status(msg):
    ''' Print status message '''
    print "    "+msg

def check_status():
    ''' Print if cmd returned oke or failed'''
    pass

def log_message(msg):
    ''' Print normal message '''
    print "    "+msg

def log_info(msg):
    ''' Print highlighted message'''
    print col_emw+"    "+msg+col_reset

def log_alert(msg):
    ''' Print log_alert log_message '''
    print col_emw+"[!] "+col_emy+msg+col_reset

def log_error(msg):
    ''' Print log_error log_message '''
    print col_emw+"[E] "+col_emr+msg+col_reset

def ask_oke():
    ''' Ask if a user wants to continue, default to YES '''
    question = col_emw+"[?] Is it oke to continue?     "+col_emg+" [Yn] "+col_reset
    answer = raw_input(question)
    default = 'y'
    if not answer is '':
        sys.exit()
    else:
        return True

def ask_no_oke():
    ''' Ask if a user wants to continue, default to NO '''
    default = ''
    question = col_emw+"[?] Is it oke to continue?     "+col_emr+" [Ny] "+col_reset
    answer = raw_input(question)
    if answer is default:
        sys.exit()
    else:
        return True

### Specific funtions ###

def usage():
    ''' Print Help message'''
    print col_emw+program+" - "+program_title+col_reset
    print "Usage:"+program_name+" GuestOS OPTIONS"
    print """
VM Options:
 -n, --name [NAME]              Friendly name of the VM       (default: <os-type>-vm)
 -r, --ram [SIZE]               RAM size in MB                (default: """+vm_ram+""")
 -d, --disk-size [SIZE]         HDD size in GB                (default: """+vm_disk_size+""")
 -t, --disk-type [TYPE]         HDD Interface, SCSI or IDE    (default: """+vm_disk_type+""")
 -e, --eth-type [TYPE]          Network Type (bridge/nat/etc) (default: """+vm_eth_type+""")
 -m, --mac-addr [ADDR]          Use static mac address        (address: 00:50:56:xx:xx:xx)

 -c, --cdrom                    Enable CDROM Drive
 -i, --iso [FILE]               Enable CDROM Iso
 -f, --floppy                   Enable Floppy Drive
 -a, --audio                    Enable sound card
 -u, --usb                      Enable USB
 -b, --bios [PATH]              Path to custom bios file
 
 -vnc [PASSWD]:[PORT]           Enable vnc support for this VM
 
Program Options:
 -x [COMMAND]                   Start the VM with this command 

 -w, --working-dir [PATH]       Path to use as Working Dir    (default: current working dir)
 -z, --zip                      Create .zip from this VM
 -g, --tar-gz                   Create .tar.gz from this VM

 -l, --list                     Generate a list of VMware Guest OS'es
 -q, --quiet                    Runs without asking questions, accept the default values
 -y, --yes                      Say YES to all questions. This overwrites existing files!! 
 -B, --binary                   Disable the check on binaries
 -M, --monochrome               Don't use colors
 
 -h, --help                     This help screen
 -v, --version                  Shows version information
 -ex, --sample                  Show some examples 
"""
    print "Dependencies:"
    print "This program needs the following binaries in its path: ${BINARIES[@]}"

def print_examples():
    ''' Show some examples '''
    print col_emw+program+" - "+program_title+col_reset
    print '''
Here are some examples:

 Create an Ubuntu Linux machine with a 20GB hard disk and a different name
   $ $PROGRAM_NAME ubuntu -d 20 -n \"My Ubuntu VM\" 

 Silently create a SUSE Linux machine with 512MB ram, a fixed MAC address and zip it
   $ $PROGRAM_NAME suse -r 512 -q -m 00:50:56:01:25:00 -z 

 Create a Windows XP machine with 512MB and audio, USB and CD enabled
   $ $PROGRAM_NAME winXPPro -r 512 -a -u -c 

 Create an Ubuntu VM with 512MB and open and run it in vmware
   $ $PROGRAM_NAME ubuntu -r 512 -x \"vmware -x\""
   '''

def summary_item(attr,value):
    global vmx_summary
    line = "    "+attr.ljust(26)+"  "+col_emw+value+col_reset
    if not vmx_summary is '':
        vmx_summary=vmx_summary+"\n"+line
    else:
        vmx_summary=line
    
def show_summary():
    ''' Show summary of configuration '''
    global vmx_summary
    log_info("I am about to create this Virtual Machine:")
    summary_item("Guest OS",vm_os_type)
    summary_item("Display name",vm_name)
    summary_item("RAM (MB)",vm_ram)
    summary_item("HDD (Gb)",vm_disk_size)
    summary_item("HDD interface",vm_disk_type)
    summary_item("BIOS file",vm_nvram)
    summary_item("Ethernet type",vm_eth_type)
    print vmx_summary
    ask_oke()

def add_config_param(attr,value):
    ''' Add configuration items to the list'''
    global vmx_config
    #print '   ',attr.ljust(26),' ',value
    vmx_config = vmx_config+''+str(attr)+' = "'+str(value)+'"\n'

def print_config():
    ''' Dump the configuration to file '''
    global vmx_config
    f = file(vm_vmx_file,'w')
    f.write(vmx_config)
    f.close()

def create_conf():
    ''' Create the configuration file '''
    log_status("Creating config file...   ")
    
    add_config_param('config.version',vm_conf_ver)
    add_config_param('virtualHW.version',vm_vmhw_ver)
    add_config_param('displayName',vm_name)
    add_config_param('guestOS',vm_os_type)
    add_config_param('memsize',vm_ram)
    
    if not vm_nvram is "nvram":
        # File-copy action goes here
        add_config_param('nvram',vm_nvram)
    else:
        add_config_param('nvram',vm_nvram)
    
    add_config_param('ethernet0.present','TRUE')
    add_config_param('ethernet0.connectionType',vm_eth_type)
    
    if not vm_mac is "default":
        summary_item("Mac address",vm_mac)
        add_config_param('ethernet0.addressType','static')
        add_config_param('ethernet0.address',vm_mac)
    else:
        add_config_param('ethernet0.addressType','generated')
        
    if not vm_disk_type is "IDE":
        add_config_param('scsi0:0.present','TRUE')
        add_config_param('scsi0:0.fileName',vm_disk_name)
    else: 
        add_config_param('ide0:0.present',' TRUE')
        add_config_param('ide0:0.fileName',vm_disk_name)
    
    if not vm_use_usb is "FALSE":
        summary_item("USB device",vm_use_usb)
        add_config_param('usb.present',' TRUE')
        add_config_param('usb.generic.autoconnect FALSE')
    
    if not vm_use_snd is "FALSE":
        summary_item("Sound Card",vm_use_snd)
        add_config_param('sound.present','TRUE')
        add_config_param('sound.fileName','-1')
        add_config_param('sound.autodetect','TRUE')
        add_config_param('sound.startConnected','FALSE')
    
    if not vm_use_fdd is "FALSE":
        summary_item("Floppy disk", vm_use_fdd)
        add_config_param('floppy0.present','TRUE')
        add_config_param('floppy0.startConnected','FALSE')
    else:
        add_config_param('floppy0.present','FALSE')
    
    if not vm_use_cdd is "FALSE":
        summary_item("CD/DVD drive",vm_use_cdd)
        add_config_param('ide0:1.present','TRUE')
        add_config_param('ide0:1.fileName','auto detect')
        add_config_param('ide0:1.autodetect','TRUE')
        add_config_param('ide0:1.deviceType','cdrom-raw')
        add_config_param('ide0:1.startConnected','FALSE')
    
    if not vm_use_iso is "FALSE":
        summary_item("CD/DVD image",vm_use_iso)
        add_config_param('ide1:0.present','TRUE')
        add_config_param('ide1:0.fileName','VM_USE_ISO')
        add_config_param('ide1:0.deviceType','cdrom-image')
        add_config_param('ide1:0.startConnected','TRUE')
        add_config_param('ide1:0.mode','persistent')
    
    if not vm_vnc_pass is "FALSE":
        summary_item("VNC Port",vm_vnc_port)
        summary_item("VNC Password",vm_vnc_pass)
        add_config_param('remotedisplay.vnc.enabled','TRUE')
        add_config_param('remotedisplay.vnc.port',vm_vnc_port)
        add_config_param('remotedisplay.vnc.password',vm_vnc_pass)
    
    add_config_param('annotation', 'This VM is created by '+program_name+' '+program_ver)
    print_config()

def create_working_dir():
    log_status("Creating working dir...   ")
    if not os.path.exists(wrk_path):
        os.mkdir(wrk_path)
        return True
    else:
        return False

def create_virtual_disk(size='8gb',adapter='buslogic',type='1'):
    log_status("Creating virtual disk...  ")
    command = 'vmware-vdiskmanager -c -a '+ vm_disk_type +' -t '+ type +' -s '+ vm_disk_size +' '+ vmdk_path +' &> createvm.log'
    os.system(command)
    return True

def create_archive():
    ''' Create zip or tar.gz archive from the VM'''
    if default_zip:
        log_message('Cannot create zip archives yet')
    if default_targz:
        log_message('Cannot create tar.gz archives yet')
    pass

def list_guest_os():
    """ List the available guest operating systems """
    l = len(support_os)
    while(l>0):
        l-=1
        print support_os[l]

def run_os_test(os):
    """ Check if the OS is in the list of supported guest OS'es

        Accepts one parameter, the guest OS to search"""
    for i in support_os:
        if i == os:
            return True
    log_error('Guest OS "'+os+'" is unknown...')
    small_help()
    return False

def run_tests():
    ''' Test environment before creating the VM

    Check on binaries, existing working dir or archives'''
    tests_oke = True
    
    # Binary check
    log_info("Checking binaries...")
    for binary in binaries:
        error_level = os.system('which '+binary+" &>/dev/null") 
        if error_level == 0:
            log_message(binary.ljust(28)+col_emg+'[OK]'+col_reset)
        else:
            log_error(binary.ljust(28)+col_emr+'[FAILED]'+col_reset)
            tests_oke = False

    # Check if target dir exists
    log_info("Checking files and directories...")
    if os.path.exists(vm_target):
        log_alert("Working dir already exists, i will trash it!")
        if ask_oke():
            log_info("Trashing working dir...   ")
            os.system('rm -r '+vm_target)
        else:
            print 'Leaving directory...'
            tests_oke = False

    if tests_oke:
        return True
    else:
        return False

def clean_up():
    ''' Clean up working dir'''
    log_info("Grab you VM here: "+vm_vmx_file)

def start_vm():
    ''' Start the Virtual Machine on request '''
    if default_start_vm:
        log_info("Starting Virtual Machine...")
        os.system('vmware -x '+vm_vmx_file+' &')
    pass

def small_help():
    """ Display a small help """
    log_message('Run "'+program_name+' -l" for a list of supported OS\'es')
    log_message('Run "'+program_name+' -h"  for help...')
    log_message('Run "'+program_name+' --ex" for examples...')

parser = OptionParser(prog='program', usage='usage', version='0.1')

parser.add_option('-n', dest='vm_name',    type='string',  default='My VM',    action='store', help='Friendly name of the virtual machine')
parser.add_option('-r', dest='vm_ram',     type='int',     default='256',      action='store', help='RAM size in MB (default %default)')
parser.add_option('-d', dest='vm_disk_size',type='int',     default='8',        action='store', help='HDD size in GB (default %default)')
parser.add_option('-t', dest='vm_disk_type',type='string',  default='buslogic', action='store', help='HDD interface (default %default)')
parser.add_option('-e', dest='vm_eth_type',type='string',  default='Bridged',  action='store', help='Network Type (default %default)')
parser.add_option('-m', dest='vm_mac',type='string',  default='',         action='store', help='Use static mac address')
parser.add_option('-b', dest='vm_nvram',   type='string',  default='',         action='store', help='Path to BIOS file')
parser.add_option('-i', dest='vm_use_iso',     type='string',  default='',         action='store', help='Path to ISO file')

parser.add_option('-a','--audio',       dest='vm_use_snd',   default=False,      action='store_false', help='Enable audio')
parser.add_option('-u','--usb',         dest='vm_use_usb',     default=False,      action='store_false', help='Enable USB')
parser.add_option('-c','--cdd',         dest='vm_use_cdd',     default=False,      action='store_false', help='Enable CD Drive')
parser.add_option('-f','--fdd',         dest='vm_use_fdd',     default=False,      action='store_false', help='Enable Floppy Drive')
parser.add_option('--vnc-pass',         type='string',  dest='vm_use_vnc_pass',    default=None,   action='store', help='VNC Password')
parser.add_option('--vnc-port',         type='string',  dest='vm_use_vnc_port',    default=None,   action='store', help='VNC Port')

parser.add_option('-l','--list', dest='oslist', default=False, action='store_true', help='List Guest Operating Systems')
parser.add_option('--ex', dest='examples', default=False, action='store_true', help='Show Examples')
parser.add_option('--debug', dest='debug', default=False, action='store_true', help='Enable Debugging')

parser.set_defaults(true=False )
options, args = parser.parse_args()

working_dir = '.'
vm_target = working_dir+'/'+vm_name
vm_vmx_file = vm_target+"/"+vm_os_type+".vmx"
vmdk_path=vm_target+'/'+vm_disk_name
wrk_path = vm_target

if options.oslist==True:
    list_guest_os()
    exit
elif options.examples==True:
    list_examples()
    exit
else:
    # Print banner
    version()

    # This can probably be handled better by the optionparser
    if len(args)<1:
        vm_os_type = raw_input('Enter guest OS: ')
    elif len(args)>1:
        vm_os_type ('Please enter Guest OS as an argument!')
        small_help()
        exit
    else:
        # Our one and only argument is the guest OS
        vm_os_type=args[0]

    if run_os_test(vm_os_type):
        # Display summary
        show_summary()
        # Do some tests
        if run_tests():
            log_info("Creating Virtual Machine...")
            # Create working environment
            create_working_dir()
            # Write config file
            create_conf()
            # Create virtual disk
            create_virtual_disk()
            # Create archine
            create_archive()
            
            # Clean up environment
            clean_up()
            # Run the VM
            start_vm()
        else:
            log_error('Some tests failed :(')
### The End! ###

if options.debug==True:
    print 72*'-'
    print type(options)
    print 'OPTIONS::', options
    print type(args)
    print 'ARGS::', args
