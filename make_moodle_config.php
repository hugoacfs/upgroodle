<?php
$template = './config-dist.php';
$config_arr = [
    'MOODLE_CFG_DB_TYPE' => $argv[1],
    'MOODLE_CFG_DB_HOST'=> $argv[2],
    'MOODLE_CFG_DB_NAME'=> $argv[3],
    'MOODLE_CFG_DB_USER'=> $argv[4],
    'MOODLE_CFG_DB_PASS'=> $argv[5],
    'MOODLE_CFG_DB_PREF'=> $argv[6],
    'MOODLE_CFG_WWWROOT'=> $argv[7],
    'MOODLE_CFG_DATAROOT' => $argv[8]
];
echo 'Getting template files for config.php...';
if (!file_exists($template)) {
    echo '! File does not exist'. "\n";
    exit;
}
$config_template = file_get_contents($template);
foreach ($config_arr as $key => $setting) {
    $config_template = str_replace($key, $setting, $config_template);
} 
$success = file_put_contents('./config.php', $config_template) ? 'success!' : 'failed!';
echo 'Moodle-> config.php created from template status -> ' . $success . "\n";
