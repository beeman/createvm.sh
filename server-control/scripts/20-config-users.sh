#!/bin/bash
SSC_DESC="Configure local Admins"
SSC_DEFAULT=0

# Warn on unset variables!
set -o nounset

# Read the configuration
source config.sh

# Read the main functions
source functions.sh

# Read personal settings
read_config

log_echo "Installing Local Sysadmin group and Accounts..."
do_sleep 1

