#! /bin/sh

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


# Application Variables
TMPFILE=esxsrv_tempfile.$$

# Menu

MENUOPTION_ONE="server-control"
MENUOPTION_TWO="preferences.sh"
MENUCOMMENT_ONE="Start Server Control"
MENUCOMMENT_TWO="User Preferences"

# Define backtitle
D_BACKTITLE="$SYS_STRING"

# Define title
D_TITLE="[ $PROGRAM_NAME $PROGRAM_VER ]"

# Define header text
D_HEADER="Please select the components you want to install.\n\n\
 Select items by pressing <space>\n
Run the scripts by pressing <enter>\n"


# Start choosen interface.
# Application
$DIALOG                          \
         --title     "$D_TITLE"           \
         --backtitle "$D_BACKTITLE"       \
         --menu "Wat wilt u uitvoeren?" 23 82 10 \
     "1. $MENUOPTION_ONE"   "$MENUCOMMENT_ONE" \
     "2. $MENUOPTION_TWO"   "$MENUCOMMENT_TWO" 2> $PATH_TMP/$TMPFILE
  
  RETVAL=$?
  CHOICE=`cat $PATH_TMP/$TMPFILE`
  
  case "$RETVAL" in
   0)  
      case "$CHOICE" in  
# Menu Option 1
         "1. $MENUOPTION_ONE")
          ./server-control.sh
          ;;
# Menu Option 2
         "2. $MENUOPTION_TWO")
         ./preferences.sh
         ;;
      esac
      ./main.sh
    ;;
  1)
     rm -f $PATH_TMP/$TMPFILE
     rm -f $PATH_TMP/$TMPFILE.*
     exit
     ;;
255)
     rm -f $PATH_TMP/$TMPFILE
     rm -f $PATH_TMP/$TMPFILE.*
     exit
     ;;
   esac

