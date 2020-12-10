#!/bin/bash
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
    -> Renames the current htdocs and keeps its config.php file,
        only useful for upgrading a current Moodle installation.
    uses:
        MOODLE_HTDOCS -> path to current htdocs folder
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system

enable_maintenance()
    -> Switches Moodle maintenance on my running a php file within Moodle,
        it also changes user ownership from www user to user.
    uses: 
        MOODLE_HTDOCS -> path to current htdocs folder
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system

disable_maintenance()
    -> Opposite of enable_maintenance, but does not change ownership.
    uses:
        MOODLE_HTDOCS -> path to current htdocs folder
        USER -> linux user of the system

sync_plugins()
    -> This function will sync the files from migration folder (community plugins),
        and Moodle htdocs. It changes ownership to make this possible. 
        It will attempt to run patches, if any are present. Changes back 
        ownership at the end.
    uses:
        MIGRATION_DIR -> path to folder with custom plugins
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system
        MOODLE_HTDOCS -> path to current htdocs folder
        MOODLE_DATA -> path to current moodledata folder

sync_release() 
    -> This function syncs the latest Moodle version from the versions folder,
        to the current htdocs folder.
    uses:
        MOODLE_HTDOCS -> path to current htdocs folder
        MOODLE_VERSIONS -> path to moodle versions folder
        MOODLE_LATEST -> name of latest moodle folder in versions folder

fix_moodle_perms() 
    -> Fixes the permissions of htdocs so that Moodle works as it should.
    uses:
        USER -> linux user of the system
        WWW_USER -> apache www-data user of the system
        MOODLE_HTDOCS -> path to current htdocs folder

moodle_upgrade() 
    -> Upgrades moodle by running the upgrade php script.
    uses:
        WWW_USER -> apache www-data user of the system
        MOODLE_HTDOCS -> path to current htdocs folder

make_moodle_config()
    -> Uses the configuration provided to create a basic Moodle config.php file
        and then moves it to the current htdocs. Should be used for
        DEVELOPMENT ONLY, during new installations, to speed up the process.
    uses:
        MOODLE_HTDOCS -> path to current htdocs folder
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

help_me()
{
   echo "Usage:"
   echo "$ upgroodle -t 'install|upgrade' -v '34-39' -m 'vanilla|hosted' [optional: -c 'yes|no']"
   echo -e "\t-d Run function: 'get_moodle' etc "
   echo -e "\t-t Available tasks: 'upgrade', 'install'"
   echo -e "\t-v Version should correspond to Moodle version. e.g. '38' for lastest version of Moodle 3.8.+"
   echo -e "\t-m Available modes: 'vanilla' (default), 'hosted' (hosted plugins)"
   echo -e "\t-c (optional) Enable creation of config.php file for Moodle from config.cfg file: Takes 'yes' if want to enable." #TODO: Make this optional
   exit 1 # Exit script after printing help
}

while getopts "d:t:v:r:m:c:" opt
do
   case "$opt" in
      d ) DO="$OPTARG" ;;
      t ) TASK="$OPTARG" ;;
      v ) VERSION="$OPTARG" ;;
      r ) RELEASE="$OPTARG" ;;
      m ) MODE="$OPTARG" ;;
      c ) CONFIG="$OPTARG" ;;
      ? ) help_me ;; # Print help_me in case parameter is non-existent
   esac
done

# Print help_me in case parameters are empty
if [ ! -z "$DO" ] 
then
   echo "Running function $DO";
   $DO
   exit 1 
fi

# Print help_me in case parameters are empty
if [ -z "$TASK" ] || [ -z "$VERSION" ]
then
   echo "Required parameters are empty, cannot continue.";
   help_me
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

if [[ $(($VERSION)) > 39 ]] || [[ $(($VERSION)) < 34 ] && [ $(($VERSION)) > 311 ]] || [[ $(($VERSION)) < 310 ]] 
then 
   echo "Cannot support versions of Moodle after 3.9 or before 3.4 yet, try overriding this manually, aborting.";
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
                fix_moodle_perms
                if [[ $CONFIG == 'yes' ]]
                then
                    make_moodle_config
                fi
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
