#!/bin/bash

## Program: Linux Server Control
## File:    Functions library
## Author:  Bram Borggreve (borggreve@gmail.com)

### Local functions ###

# Get start time
TIME_START=`date +"%s"`

# The main functions that runs dialog, catches the options and responds to the selected options
run_dialog(){
    list_options

    # Define backtitle
    D_BACKTITLE="$SYS_STRING"

    # Define title
    D_TITLE="[ $PROGRAM_NAME $PROGRAM_VER ]"

    # Define header text
    D_HEADER="Please select the components you want to install.\n\n\
     Select items by pressing <space>\n
    Run the scripts by pressing <enter>\n"

    D_SIZE_L=${#OPTIONS[@]}

    # Run dialog and put the result in variable CHOICE
    CHOICE=$(eval $DIALOG --stdout                          \
                         --title     \"$D_TITLE\"           \
                         --backtitle \"$D_BACKTITLE\"       \
                         --checklist \"$D_HEADER\"          \
                                     \"$D_SIZE_H\"          \
                                     \"$D_SIZE_W\"          \
                                     \"$D_SIZE_L\"          \
                                       $D_OPTIONS           \
            ); ## This was the dialog box

    # Get the return code
    retval=$?

    # React on the return code
    case $retval in
      0)
        if [ -n "$CHOICE" ]
        then
        
            dialog  --title     "$D_TITLE"           \
                    --backtitle "$D_BACKTITLE"       \
                    --yesno "\nDo you want to run the following scripts?\n\n$CHOICE" 11 $D_SIZE_W 
            sel=$?
            case $sel in
               0) 
                    TIME_START_SCRIPTS=`date +"%s"`
                    run_as_root; 
                    run_scripts "$CHOICE"
                    ;;
               1) 
                    log_echo "Not running scripts..."
                    ;;
               255) 
                    log_echo "Canceled by user by pressing [ESC] key"
                    ;;
            esac
        else
            log_echo "Er zijn geen opties gekozen..."
        fi;; 
      1)
        log_echo "Cancel pressed.";;
      255)
        log_echo "ESC pressed.";;
    esac
}


# Run the selected scripts
run_scripts(){
    PARAMS="$@"
    log_echo "Your choices: $PARAMS"
    for SCRIPT in $PARAMS
    do
        SCRIPT=`echo "$SCRIPT" | cut -d "\"" -f 2`
        SCRIPT="$PATH_SCRIPTS/$SCRIPT"
		log_debug "Running $SCRIPT" 
        if [ -e "$SCRIPT" ]
        then 
            "$SCRIPT"
        else
            log_error "$SCRIPT : no such file or directory..."
			log_echo "Press return to continue..."
            read p
        fi
    done
}

# Check if we are root
run_as_root() {
    if [ "$(whoami)" != 'root' ]; 
    then 
        log_error 'You are *NOT* running as root...';
	    #log_echo "Press return to continue..."
        # read p
    else 
        log_echo 'You are running as root :)'; 
    fi
}

# List the files in the script dir and build the list
list_options() {
    # Get a list of files
    FILE_LIST=`ls "$PATH_SCRIPTS"/*.sh`
    
    # loop through them 
    i=0
    for SCRIPT_PATH in $FILE_LIST
    do 
        # Fetch script name and description
        NAME="$(basename $SCRIPT_PATH)"
        DESC="$(head -n 3 $SCRIPT_PATH | grep SSC_DESC    | cut -d "=" -f 2  )"
        
        # Check if we have to enable it
        DEFAULT="$(head -n 3 $SCRIPT_PATH | grep SSC_DEFAULT | cut -d "=" -f 2  )"
        
        log_debug "Enabled by default : $DEFAULT "
        
        if [ "$DEFAULT" == '1' ]; 
        then
            RUN_SCRIPT='ON'
        else 
            RUN_SCRIPT='OFF'
        fi
        
        if [ "$DESC" == '' ]; 
        then
            DESC='" *** No Description *** "'
        fi
        
        # Build the string with options
        OPT_STRING="\"$NAME\" $DESC $RUN_SCRIPT "
        
        log_debug "String with options: $OPT_STRING"
        
        # Build the array with options
        OPTIONS[$i]=$OPT_STRING
        
        # Add 1 to i. 
        i=$((i+1))
    done
    
    # Generate and export an array for the information gathered above
    D_OPTIONS=''
    for CHOICE in ${OPTIONS[@]}
    do
        D_OPTIONS="$D_OPTIONS $CHOICE"
    done
    # export $D_OPTIONS
}

# Parse (or: source) the config file
read_config(){
    # Read personal variables
    if [ -f "$PATH_CONFIG" ]; then
        source "$PATH_CONFIG"; 
        log_debug "Found and Parsed config file: $PATH_CONFIG" 
    fi
}
### Generic Functions ###

# Show version info
print_version() { 
    echo "$PROGRAM by $PROGRAM_COPYLEFT $PROGRAM_LICENSE";
}

# Sleep for a given time
do_sleep() {
	log_info "Sleeping for $1 second(s)..."
	sleep "$1"
}

# Main logger function
_logger() {
    local LEVEL=$1 ; shift
    local MSG=$@
    local PREFIX=''
    
    # Add date an level
    if [ "$LOGGER_DATE" == "1" ];
    then
        local NOW=`date +"%Y/%m/%d %H:%M:%S"`
        PREFIX="$PREFIX[$NOW] "
    fi
    if [ "$LOGGER_LEVEL" == "1" ];
    then
        PREFIX="$PREFIX$LEVEL "
    fi
    
    # Concat message with prefix
    echo -e "$PREFIX""$MSG"
}
# Log echo message
log_echo() {
	_logger "[echo]" "\033[1;37m"$@"\033[0;00m"
}
# Log error message
log_error() {
	_logger "[eror]" "\033[1;31m"$@"\033[0;00m"
}
# Log informational message
log_info() {
	if [ "$DO_DEBUG" -gt "0" ];  then 
        _logger "[info]" "$@" ; 
    fi
}
# Log debug message
log_debug() {
	if [ "$DO_DEBUG" -gt "2" ];  then 
        _logger "[dbug]" "$@" ; 
    fi
}

# Get system info
get_sysinfo(){
	# Get System info
	export SYS_SYSTEM=`uname -o`
	export SYS_DISTRO=`lsb_release -si`
	export SYS_VERSION="`lsb_release -sr` (`lsb_release -sc`)"
	export SYS_KERNEL=`uname -r`
	export SYS_ARCH=`uname -m`
	export SYS_STRING="$SYS_DISTRO $SYS_VERSION - $SYS_SYSTEM $SYS_KERNEL $SYS_ARCH"
}

# Check for needed binaries
check_requirements() {
	log_debug "$FUNCNAME: checking binaries"
    COMPLY=true
	for BIN in ${DEP_BINARIES[@]}
	do
		which $BIN &> /dev/null
		if [[ $? -ne 0 ]] ; then
			log_error "$FUNCNAME: This script needs the \"$BIN\" program, but i cannot find it... :( "
            COMPLY=false
		else
			log_debug "$FUNCNAME: found $BIN"
		fi
	done
    if [ "$COMPLY" == false ]; then exit 1; fi
}
# Show some info when the script is ended. Can be used for cleanup of temp files 
run_cleanup(){
    log_echo "Clean exit... :)"

    TIME_END=`date +"%s"`
    TIME_RAN_TOTAL=`expr $TIME_END - $TIME_START`
    TIME_RAN_SCRIPTS=`expr $TIME_END - $TIME_START_SCRIPTS`
    TIME_RAN_MENU=`expr $TIME_RAN_TOTAL - $TIME_RAN_SCRIPTS`
    
    log_debug "Started: `date -d @$TIME_START`  - Stopped: `date -d @$TIME_END` "
    log_debug "Menu   runtime: $TIME_RAN_MENU seconds..."
    log_debug "Script runtime: $TIME_RAN_SCRIPTS seconds..."
    log_debug "Total  runtime: $TIME_RAN_TOTAL seconds..."
}

## Fin. ##
