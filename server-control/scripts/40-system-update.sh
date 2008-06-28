#!/bin/bash
SSC_DESC="Update this System"
SSC_DEFAULT=0

# Warn on unset variables!
set -o nounset

# Read the configuration
source config.sh

# Read the main functions
source functions.sh

# Read personal settings
read_config

log_echo "Performing System Update..."
#sudo apt-get update > /dev/null
log_echo "Performing System Upgrade..."
#sudo apt-get -y upgrade 
# do_sleep 3
