#!/bin/bash
SSC_DESC="Reboot after configuration"
SSC_DEFAULT=0

# Warn on unset variables!
set -o nounset

# Read the configuration
source config.sh

# Read the main functions
source functions.sh

# Read personal settings
read_config

log_echo "You are about to reboot this system!!!"

#echo -n "Press Enter to continue or Ctrl-C to abort..."
#read p

log_echo "Rebooting System..."
# sleep 60 && reboot &
