#!/bin/bash

## Program: Linux Server Control
## File:    Configuration File
## Author:  Bram Borggreve (borggreve@gmail.com)

# Banners and stuff
export PROGRAM_NAME="Linux Server Control"
export PROGRAM_VER="1.0"
export PROGRAM_COPYLEFT="Bram Borggreve (c) 2008."
export PROGRAM_LICENSE="Distributed under the GPL license."
export PROGRAM="$PROGRAM_NAME $PROGRAM_VER"

# Define where dialog is (could be Xdialog for example)
export DIALOG=${DIALOG=/usr/bin/dialog}

# Define Dialog box format, Height, Width
export D_SIZE_H=20
export D_SIZE_W=78

# These programs are needed in the path
export DEP_BINARIES=($DIALOG lsb_release uname)

# Set debugging (0/1/2/3)
export DO_DEBUG=2

# Enable or disable logger date
export LOGGER_DATE=0
# Enable or disable logger level
export LOGGER_LEVEL=1

# Define some paths
export PATH_PROGRAM=`pwd`
export PATH_TMP='/tmp'
export PATH_SCRIPTS="$PATH_PROGRAM/scripts"
export PATH_DATA="$PATH_PROGRAM/data"
export PATH_CONFIG="$HOME/.server-control"
export PATH_CONFIG_TEMP="$PATH_TMP/server-control-$$"

# Show copyright message
export SHOW_BANNERS=1
export SHOW_COPYLEFT=1

## Fin ##

##TODO LIST:
##TODO: Show the output of the scripts in dialog window
##TODO: Create 'runonce' like system
##TODO: Define OS families (rhel/sles/debian/unkown) and reflect in update methods
##TODO: Command Line Parameters (run-all-options, list-all-options, run-single-option, enable debug, show usage, etc)
##TODO: Generate Color codes
##TODO: Default 'press return to......' functions
##TODO: Script/Template Generator
##TODO: Action scripts updaten via SVN
##TODO: Main script updaten via SVN 
##TODO: 


