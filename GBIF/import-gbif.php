<?php

require_once "import-gbif-helper.php";
require_once "import-gbif-scripts.php";
require_once "final-gbif-scripts.php";

echo "\n";
$settings = ImportGbifHelper::getSettings($argv, $argc);
$connections = ImportGbifHelper::getConnections($settings);

$startAll = microtime(TRUE);
foreach ($scripts as $idx => $script) {
  // Scripts connect as normal user unless otherwise specified.
  $script['connection'] = empty($script['connection']) ? 
    'default' : $script['connection'];
  // Allow skip to start at certain script.
  if (!empty($settings['start']) && ($idx + 1) < $settings['start']) {
    continue;
  }
  // Allow abort at certain script.
  if (!empty($settings['stop']) && ($idx + 1) > $settings['stop']) {
    break;
  }
  echo ($idx + 1) . ' - ' . (empty($script['description']) ? 
    $script['file'] : $script['description']);
  $sql = file_get_contents("scripts/$script[file]");
  // Apply settings as replacements Twig style.
  foreach ($settings as $key => $value) {
    $sql = str_replace("{{ $key }}", $value, $sql);
  }
  $startScript = microtime(TRUE);
  // Some scripts need to run as superuser.
  $conn = $connections[$script['connection']];
  // Run the script.
  $result = @pg_query($conn, $sql);
  if ($result === FALSE) {
    die("\nError in script: " . pg_last_error($conn) . "\n");
  }
  else {
    $time = round(microtime(TRUE) - $startScript, 1);
    echo " - OK ({$time}s)\n";
    ImportGbifHelper::echoScriptOutputs($conn, $script, $result);
  }
}
if (empty($settings['stop'])) {
  // Update the cache_* tables, unless doing an incomplete run.
  importGbifHelper::updateCaches($connections['default'], $settings);

  // Run final scripts
  foreach ($final_scripts as $idx => $script) {
     echo ($idx + 1) . ' - ' . (empty($script['description']) ? 
      $script['file'] : $script['description']);
    $sql = file_get_contents("scripts/$script[file]");
    $startScript = microtime(TRUE);
    $conn = $connections['default'];
    // Run the script.
    $result = @pg_query($conn, $sql);
    if ($result === FALSE) {
      die("\nError in script: " . pg_last_error($conn) . "\n");
    }
    else {
      $time = round(microtime(TRUE) - $startScript, 1);
      echo " - OK ({$time}s)\n";
      ImportGbifHelper::echoScriptOutputs($conn, $script, $result);
    }
  }
}

echo 'Total time: ' . round(microtime(TRUE) - $startAll, 1) . "s\n";
