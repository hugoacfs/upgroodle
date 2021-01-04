# Upgroodle

When doing an update/upgrade etc this directory has some useful scripts for automating the process.

They still need some configuration to work. Copy the config.cfg.defaults over to a file called config.cfg and make sure to remove any comments.

## Configuration
The configuration file contains two types of variables, upgroodle variables, used to navigate the file system and Moodle configuration variables, used to create a Moodle configuration file.

### Upgroodle Variables [**required**]
- MOODLE_HTDOCS -> directory path where moodle will be installed
- MOODLE_DATA -> directory path where moodledata is
- MOODLE_VERSIONS -> moodle versions directory where core moodle is downloaded to
- MOODLE_LATEST -> desired moodle directory to be used in the install (moodle-38 for example) can be left as **'latest'** for latest download
- USER -> ubuntu user or root if no other user exists
- WWW_USER -> www-data user
- MIGRATION_DIR -> migration directory that should contain htdocs and moodledata sub directories

### Moodle Auto Configuration Variables
- MOODLE_CFG_DB_TYPE
- MOODLE_CFG_DB_HOST
- MOODLE_CFG_DB_NAME
- MOODLE_CFG_DB_USER
- MOODLE_CFG_DB_PASS
- MOODLE_CFG_DB_PREF
- MOODLE_CFG_WWWROOT
- MOODLE_CFG_DATAROOT
- MOODLE_CFG_SITENAME
- MOODLE_CFG_SHORTNAME
- MOODLE_CFG_ADMINPASSWORD
- MOODLE_CFG_ADMINEMAIL

## Usage

To use the scripts, focus on the upgroodle.sh file.

There are two main ways to use this script, the simple method and the advanced method.

### Simple Method
This method is used for letting the script handle most of the upgrade. Simple method is documented, simply run `./upgroodle.sh` to get help.

### Advanced Method
This method allows the user to call individual functions from the script library to do things. Useful for debugging and other tasks rather than upgrade/install. 
Usage: `./upgroodle.sh -d 'function_name' (+ other parameters needed by function)`
Example: `./upgroodle.sh -d get_moodle -v 38 -r 3.8.4`

## Folder Structure

```console
.
├── moodle_versions             -> Automatically generated, holds the Moodle downloads
│   └── latest                  -> Automaitcally generated, holds the most recent Moodle download
├── config.cfg                  -> Not included, you must create it from config.cfg
├── config.cfg.defaults         -> The dist version of config.cfg
├── config-dist.php             -> Moodle's config.php distribution
├── config.shlib                -> Script's library
├── make_moodle_config.php      -> Generator for Moodle's config.php
├── README.md                   -> This file
└── upgroodle.sh                -> The upgrade/install script
```
