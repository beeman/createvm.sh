#!/bin/bash

## Program: Linux Server Control
## File:    Preferences editor
## Author:  Bram Borggreve (borggreve@gmail.com)

generate_config(){
    
    log_echo "Creating empty config"
#    touch "$PATH_CONFIG"
}

edit_config(){
    # Spit out some debug info
    log_debug "Config file: $PATH_CONFIG"
    log_debug "Temp config: $PATH_CONFIG_TEMP"

    # Here we define the questions    
    Q1="DO_DEBUG     :"
    Q2="LOGGER_DATE) :"
    Q3="LOGGER_LEVEL :"
    Q4="D_SIZE_W     :"
    Q5="D_SIZE_H     :"
    
    # Here we show the questions and read the answers
    echo -n "$Q1 "; read A1
    echo -n "$Q2 "; read A2
    echo -n "$Q3 "; read A3
    echo -n "$Q4 "; read A4
    echo -n "$Q5 "; read A5
    
    # Here the answers get parsed
    if [ "$A1" != '' ]; then echo "DO_DEBUG=$A1"     >>  "$PATH_CONFIG_TEMP"; CHANGED=1; fi
    if [ "$A2" != '' ]; then echo "LOGGER_DATE=$A2"  >>  "$PATH_CONFIG_TEMP"; CHANGED=1; fi
    if [ "$A3" != '' ]; then echo "LOGGER_LEVEL=$A3" >>  "$PATH_CONFIG_TEMP"; CHANGED=1; fi
    if [ "$A4" != '' ]; then echo "D_SIZE_W=$A4"     >>  "$PATH_CONFIG_TEMP"; CHANGED=1; fi
    if [ "$A5" != '' ]; then echo "D_SIZE_H=$A5"     >>  "$PATH_CONFIG_TEMP"; CHANGED=1; fi
    
    # Aks to save, if the temp config file is created
    if [ -f "$PATH_CONFIG_TEMP" ]; then   
        log_echo "File changed!";
        echo "==============="
        cat "$PATH_CONFIG_TEMP"
        echo "==============="
        
        echo -n "Do you want to save this? (y/n) " 
        read SAVETHIS
        if [ "$SAVETHIS" == 'y' ]; 
        then 
            log_debug "Moving temp config file to permanent"
            mv -v "$PATH_CONFIG_TEMP" "$PATH_CONFIG"
            log_echo "Configuration saved."
        else
            log_debug "Cleanup temp config file"
            rm -v "$PATH_CONFIG_TEMP"
            log_echo "Not saved."
        fi
    else
        log_echo "File not changed!";         
    fi
}

# Delete the config file
delete_config(){
    log_debug "Delete config file $PATH_CONFIG"
    rm -v  "$PATH_CONFIG"
}

# Warn on unset variables!
set -o nounset

# Read the configuration
source config.sh

# Read the main functions
source functions.sh

# Print a banner
print_version


if [ -f "$PATH_CONFIG" ];
then
    log_echo "Config file found."
    log_echo "Press (e) to reconfigure"
    log_echo "Press (v) to edit with $EDITOR"
    log_echo "Press (d) to delete the config"
    log_echo "Press (q) to quit"
    echo 
    echo -n  "Make a choice and press enter to continue: "
    read choice
    if [ "$choice" == "e" ]; 
    then 
        edit_config 
    fi
    if [ "$choice" == "d" ]; 
    then 
        delete_config 
    fi
    if [ "$choice" == "v" ]; 
    then 
        $EDITOR "$PATH_CONFIG" 
    fi
    
else
    log_echo 'No config found.'
    generate_config
    edit_config
fi
