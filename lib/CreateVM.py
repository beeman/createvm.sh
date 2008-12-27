#!/usr/bin/env python

import os,sys

class CreateVM:

    def __init__(self):
        """Default constructor of CreateVM"""
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

        self.conf = {}

    def print_conf(self, filename):
        ''' Show summary of configuration '''
        for cat, item in self.conf.items():
            if 'comment' in item:
                print "\n## %s" % item['comment']
                del item['comment']
            for param, val in item.items():
                print '%s.%s = "%s"' % (cat, param, val)

                

    def _add_conf_param(self, index, val):
        split_arr = index.split('.')
        cat = split_arr[0]
        index = split_arr[1]
        if cat in self.conf:
            config = self.conf[cat]
        else:
            config = dict();
        config[index] = val
        self.conf[cat] = config
        print self.conf

    def add_sound(self, val):
        if val is True:
            bool = 'TRUE'
        else:
            bool = 'FALSE'

        self._add_conf_param('sound.comment', 
        """This add the sound properties to the VM""");
        self._add_conf_param('sound.present', bool)
        self._add_conf_param('sound.fileName', '-1')
        self._add_conf_param('sound.autodetect', bool)
        self._add_conf_param('sound.startConnected', bool)

