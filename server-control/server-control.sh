#!/bin/bash

## Program: Linux Server Control
## File:    Main program
## Author:  Bram Borggreve (borggreve@gmail.com)

# Warn on unset variables!
set -o nounset

# Read the configuration
source config.sh

# Read the main functions
source functions.sh

# Print a banner
print_version

# Read personal settings
read_config

# Check for needed binaries
check_requirements

# Get system info    
get_sysinfo

# Run the main window
run_dialog

# Clean exit 
run_cleanup

## Fin ##
