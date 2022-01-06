#!/bin/bash
SUDO=(`command -v sudo`)
source config.shlib; # load the config & library functions
<<COMMENT1
Available functions:

get_moodle()
    -> Fetches the specified version of Moodle,
        and extracts it to the versions folder.
    uses:
        MOODLE_VERSIONS -> path to moodle versions folder
        INPUT{1} -> Version (required)
        INPUT{2} -> Realease (optional)

prepare_upgrade()
    -> Renames the current apache html and keeps its config.php file,
        only useful for upgrading a current Moodle installation.
    uses:
        MOODLE_WWWHTML -> path to current apache html folder
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system

enable_maintenance()
    -> Switches Moodle maintenance on my running a php file within Moodle,
        it also changes user ownership from www user to user.
    uses:
        MOODLE_WWWHTML -> path to current apache html folder
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system

disable_maintenance()
    -> Opposite of enable_maintenance, but does not change ownership.
    uses:
        MOODLE_WWWHTML -> path to current apache html folder
        USER -> linux user of the system

sync_plugins()
    -> This function will sync the files from migration folder (community plugins),
        and Moodle apache html. It changes ownership to make this possible.
        It will attempt to run patches, if any are present. Changes back
        ownership at the end.
    uses:
        MIGRATION_DIR -> path to folder with custom plugins
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system
        MOODLE_WWWHTML -> path to current apache html folder
        MOODLE_DATA -> path to current moodledata folder

sync_release()
    -> This function syncs the latest Moodle version from the versions folder,
        to the current apache html folder.
    uses:
        MOODLE_WWWHTML -> path to current apache html folder
        MOODLE_VERSIONS -> path to moodle versions folder
        MOODLE_LATEST -> name of latest moodle folder in versions folder

fix_moodle_perms()
    -> Fixes the permissions of apache html so that Moodle works as it should.
    uses:
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system
        MOODLE_WWWHTML -> path to current apache html folder

moodle_upgrade()
    -> Upgrades moodle by running the upgrade php script.
    uses:
        WWW_USER -> apache www-data user of the system
        MOODLE_WWWHTML -> path to current apache html folder

make_moodle_config()
    -> Uses the configuration provided to create a basic Moodle config.php file
        and then moves it to the current apache html. Should be used for
        DEVELOPMENT ONLY, during new installations, to speed up the process.
    uses:
        MOODLE_WWWHTML -> path to current apache html folder
    uses special config:
        MOODLE_CFG_DB_TYPE -> Moodle database type field
        MOODLE_CFG_DB_HOST -> Moodle database hostname
        MOODLE_CFG_DB_NAME -> Moodle db name
        MOODLE_CFG_DB_USER -> Moodle db username
        MOODLE_CFG_DB_PASS -> Moodle db password
        MOODLE_CFG_DB_PREF -> Moodle database prefix
        MOODLE_CFG_WWWROOT -> Moodle wwwroot path (http...)
        MOODLE_CFG_DATAROOT -> Moodle dataroot path (moodledata)

moodle_install()
    -> It creates a new config.php file and then runs the moodle install script.
    uses:
        MOODLE_CFG_DB_TYPE -> Moodle database type field
        MOODLE_CFG_DB_HOST -> Moodle database hostname
        MOODLE_CFG_DB_NAME -> Moodle db name
        MOODLE_CFG_DB_USER -> Moodle db username
        MOODLE_CFG_DB_PASS -> Moodle db password
        MOODLE_CFG_DB_PREF -> Moodle database prefix
        MOODLE_CFG_WWWROOT -> Moodle wwwroot path (http...)
        MOODLE_CFG_DATAROOT -> Moodle dataroot path (moodledata)
    extra config:
        MOODLE_CFG_SITENAME -> Moodle site name
        MOODLE_CFG_SHORTNAME -> Moodle site shortname
        MOODLE_CFG_ADMINPASSWORD -> Moodle admin password
        MOODLE_CFG_ADMINEMAIL -> Moodle admin email

COMMENT1

# COLOURS
CL_BLACK='\033[0;30m'
CL_DGREY='\033[1;30m'
CL_RED='\033[0;31m'
CL_LRED='\033[1;31m'
CL_GREEN='\033[0;32m'
CL_LGREEN='\033[1;32m'
CL_ORANGE='\033[0;33m'
CL_YELLOW='\033[1;33m'
CL_BLUE='\033[0;34m'
CL_LBLUE='\033[1;34m'
CL_PURPLE='\033[0;35m'
CL_LPURPLE='\033[1;35m'
CL_CYAN='\033[0;36m'
CL_LCYAN='\033[1;36m'
CL_LGREY='\033[0;37m'
CL_WHITE='\033[1;37m'
CL_RESET='\e[0m'
# Resetting colors
echo -e "$CL_RESET"

help_me()
{
   echo "Usage:"
   echo -e "$CL_RED""$""$CL_RESET upgroodle $CL_RED""-t""$CL_RESET 'install|upgrade' $CL_RED""-v""$CL_RESET '3x' $CL_RED""-m""$CL_RESET 'vanilla|hosted' [optional: $CL_RED""-r""$CL_RESET '3.x.x'] [optional: $CL_RED""-c""$CL_RESET, $CL_RED""-i""$CL_RESET ]"
   echo -e "\t$CL_RED""-d""$CL_RESET Run function: 'get_moodle' etc "
   echo -e "\t$CL_RED""-t""$CL_RESET Available tasks: 'upgrade', 'install'"
   echo -e "\t$CL_RED""-v""$CL_RESET Version should correspond to Moodle version. e.g. '38' for lastest version of Moodle 3.8.+"
   echo -e "\t$CL_RED""-r""$CL_RESET Release that corresponds to Moodle version. e.g. '3.8.4' for the specific release for version 3.8"
   echo -e "\t$CL_RED""-m""$CL_RESET Available modes: 'vanilla' (default), 'hosted' (hosted plugins)"
   echo -e "\t$CL_RED""-c""$CL_RESET (optional) Enable creation of config.php file for Moodle from config.cfg file."
   echo -e "\t$CL_RED""-i""$CL_RESET (optional) Enable interactive mode (feature preview)." #TODO improve description
   exit 1 # Exit script after printing help
}

while getopts "d:t:v:r:m:cih" opt
do
   case "$opt" in
      d ) DO="$OPTARG" ;;
      t ) TASK="$OPTARG" ;;
      v ) VERSION="$OPTARG" ;;
      r ) RELEASE="$OPTARG" ;;
      m ) MODE="$OPTARG" ;;
      c ) CONFIG="1" ;;
      i ) INTERACTIVE="1" ;;
      h ) help_me ;;
      ? ) echo "Error: Unexpected option used." ;; # Runs when parameter is not in the list
   esac
done

if [[ $INTERACTIVE == "1" ]]
    then
        echo -e "$CL_RED[Interactive Mode]$CL_RESET Enabled."
fi

if [ ! -z "$DO" ]
then
   echo "Running function $DO";
   $DO
   exit 1
fi

# Print help_me in case parameters are empty
if [ -z "$TASK" ] || [ -z "$VERSION" ]
then
   echo -e "Incorrect usage, run $CL_LBLUE""'./upgroodle.sh -h'""$CL_RESET for help, or $CL_LBLUE""'./upgroodle.sh -d show_functions'""$CL_RESET for advanced usage.";
   exit 1
fi

if [[ $TASK != 'upgrade' ]] && [[ $TASK != 'install' ]]
then
   echo "Cannot run requested task ($TASK), aborting.";
   exit 1
fi

if [[ $MODE != 'vanilla' ]] && [[ $MODE != 'hosted' ]]
then
   echo "Cannot run requested mode ($MODE), aborting.";
   exit 1
fi

if (( $VERSION <= 39 && $VERSION >= 34 )) || (( $VERSION <= 311 && $VERSION >= 310 ))
then
   echo "Installing supported version: $VERSION ...";
else
   echo "Cannot support versions of Moodle newer than 3.11 or older than 3.4 yet, aborting.";
   exit 1
fi

case "$TASK" in
    "install" ) echo "Are you sure you want to install Moodle $VERSION? "
                read -p "(Enter 'y' for yes, 'n' for no) : " confirminstall
                if [[ $confirminstall != 'y' ]]
                then
                    echo "Aborting install... "
                    exit 1
                fi
                get_moodle $VERSION
                sync_release
                if [[ $MODE == 'hosted' ]]
                then
                    sync_plugins
                fi
                read -p "Fix Moodle perms? (y, n)? " confirmfix
                if [[ $confirmfix == 'y' ]]
                then
                    fix_moodle_perms
                fi
                if [[ $CONFIG == '1' ]]
                then
                    make_moodle_config
                fi
                interactive_check
                moodle_install
                ;;

    "upgrade" ) echo "Are you sure you want to install Moodle $VERSION? "
                read -p "(Enter 'y' for yes, 'n' for no) : " confirmupgrade
                if [[ $confirmupgrade != 'y' ]]
                then
                    echo "Aborting upgrade... "
                    exit 1
                fi
                get_moodle $VERSION
                prepare_upgrade
                sync_release
                if [[ $MODE == 'hosted' ]]
                then
                    sync_plugins
                fi
                fix_moodle_perms
                moodle_upgrade
                ;;
esac
