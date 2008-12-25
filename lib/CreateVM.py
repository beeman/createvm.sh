#!/usr/bin/env python

import os,sys

class CreateVM:

    def __init__(self):
        """Default constructor of CreateVM"""
        self.defaults = { 
                'quiet': False,
                'accept': False,
                'zip': False,
                'tarball': False,
                'start_vm': False,
                'wrk_path': '.',
        }

        self.conf = {
                'vm_conf_ver': "8",
                'vm_vmhw_ver' : "4",
                'vm_name' : "ubuntu-vm",
                'vm_os_type' : "ubuntu",
                'vm_ram' : "256",
                'vm_nvram' : "nvram",
                'vm_eth_type' : "bridged",
                'vm_mac' : "default",
                'vm_disk_type' : "buslogic",
                'vm_disk_size' : "8GB",
                'vm_use_usb' : "FALSE",
                'vm_use_snd' : "FALSE",
                'vm_use_iso' : "FALSE",
                'vm_use_fdd' : "FALSE",
                'vm_use_cdd' : "FALSE",
                'vm_vnc_pass' : "FALSE",
                'vm_vnc_port' : "5901",
        }

        self.conf_item = {
                'vm_name' : "Display name",
                'vm_os_type' : "OS type",
                'vm_ram' : "RAM (Mb)",
                'vm_nvram' : "BIOS",
                'vm_eth_type' : "Ethernet type",
                'vm_mac' : "Mac address",
                'vm_disk_type' : "Disk type",
                'vm_disk_size' : "Disk size (Gb)",
                'vm_use_usb' : "USB",
                'vm_use_snd' : "Audio",
                'vm_use_iso' : "Image file",
                'vm_use_fdd' : "Floppy drive",
                'vm_use_cdd' : "CD/DVD drive",
                'vm_vnc_pass' : "VNC password",
                'vm_vnc_port' : "VNC port",
        }

        self.os = ('winVista','longhorn','winNetBusiness','winNetEnterprise','winNetStandard',
            'winNetWeb','winXPPro','winXPHome','win2000AdvServ','win2000Serv','win2000Pro',
            'winNT','winMe','win98','win95','win31','windows','winVista-64','longhorn-64',
            'winNetEnterprise-64','winNetStandard-64','winXPPro-64','ubuntu','redhat',
            'rhel4','rhel3','rhel2','suse','sles','mandrake','nld9','sjds','turbolinux',
            'other26xlinux','other24xlinux','linux','ubuntu-64','rhel4-64','rhel3-64',
            'sles-64','suse-64','other26xlinux-64','other24xlinux-64','other-64',
            'otherlinux-64','solaris10-64','solaris10','solaris9','solaris8','solaris7',
            'solaris6','solaris','netware6','netware5','netware4','netware','freeBSD-64',
            'freeBSD','darwin','other')

        self.vmx_summary = list()

    def show_conf_summary(self):
        ''' Show summary of configuration '''
        for index, item in self.conf_item.items():
            line = "    " + item.ljust(26)  + self.conf[index]
            print line

    def change_conf(self, conf, val):
        key = "vm_" + conf
        self.conf[key] = val

    def create_conf(self):
        pass

    def _add_conf_param(self):
        pass

