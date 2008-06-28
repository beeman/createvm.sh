#!/bin/bash
SSC_DESC="Register System with RedHat"
SSC_DEFAULT=0

# Warn on unset variables!
set -o nounset

# Read the configuration
source config.sh

# Read the main functions
source functions.sh

# Read personal settings
read_config

log_echo "This script registers the machine at Red Hat Network..."
do_sleep 1
