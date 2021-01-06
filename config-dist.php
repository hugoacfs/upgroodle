<?php
///////////////////////////////////////////////////////////////////////////
//                                                                       //
// Moodle configuration file                                             //
//                                                                       //
// This file should be renamed "config.php" in the top-level directory   //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
//                                                                       //
// NOTICE OF COPYRIGHT                                                   //
//                                                                       //
// Moodle - Modular Object-Oriented Dynamic Learning Environment         //
//          http://moodle.org                                            //
//                                                                       //
// Copyright (C) 1999 onwards  Martin Dougiamas  http://moodle.com       //
//                                                                       //
// This program is free software; you can redistribute it and/or modify  //
// it under the terms of the GNU General Public License as published by  //
// the Free Software Foundation; either version 3 of the License, or     //
// (at your option) any later version.                                   //
//                                                                       //
// This program is distributed in the hope that it will be useful,       //
// but WITHOUT ANY WARRANTY; without even the implied warranty of        //
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         //
// GNU General Public License for more details:                          //
//                                                                       //
//          http://www.gnu.org/copyleft/gpl.html                         //
//                                                                       //
///////////////////////////////////////////////////////////////////////////
unset($CFG);  // Ignore this line
global $CFG;  // This is necessary here for PHPUnit execution
$CFG = new stdClass();

//=========================================================================
// 1. DATABASE SETUP
//=========================================================================
// First, you need to configure the database where all Moodle data       //
// will be stored.  This database must already have been created         //
// and a username/password created to access it.                         //

$CFG->dbtype    = 'MOODLE_CFG_DB_TYPE';      // 'pgsql', 'mariadb', 'mysqli', 'mssql', 'sqlsrv' or 'oci'
$CFG->dblibrary = 'native';     // 'native' only at the moment
$CFG->dbhost    = 'MOODLE_CFG_DB_HOST';  // eg 'localhost' or 'db.isp.com' or IP
$CFG->dbname    = 'MOODLE_CFG_DB_NAME';     // database name, eg moodle
$CFG->dbuser    = 'MOODLE_CFG_DB_USER';   // your database username
$CFG->dbpass    = 'MOODLE_CFG_DB_PASS';   // your database password
$CFG->prefix    = 'MOODLE_CFG_DB_PREF';       // prefix to use for all table names
$CFG->dboptions = array(
    'dbpersist' => false,
    'dbsocket'  => false,
    'dbport'    => '',
    'dbhandlesoptions' => false,
    'dbcollation' => 'utf8mb4_unicode_ci', 
);

$CFG->wwwroot   = 'MOODLE_CFG_WWWROOT';
$CFG->dataroot  = 'MOODLE_CFG_DATAROOT';
$CFG->directorypermissions = 02777;
$CFG->admin = 'admin';

require_once(__DIR__ . '/lib/setup.php'); // Do not edit

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
