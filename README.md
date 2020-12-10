# Scripts

When doing an update/upgrade etc this directory has some useful scripts for automating the process.

They still need some configuration to work. Copy the config.cfg.defaults over to a file called config.cfg and make sure to remove any comments.

## Usage

To use the scripts, focus on the upgroodle.sh file.

There are two main ways to use this script, the simple method and the advanced method.

### Simple Method
This method is used for letting the script handle most of the upgrade.

### Advanced Method
This method allows the user to call individual functions from the script library to do things. Useful for debugging and other tasks rather than upgrade/install.

## Folder Structure

```
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