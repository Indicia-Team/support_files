<?php

require_once "import-uksi-helper.php";
require_once "import-uksi-scripts.php";

echo "\n";
$settings = ImportUksiHelper::getSettings($argv, $argc);
$connections = ImportUksiHelper::getConnections($settings);

$startAll = microtime(TRUE);
foreach ($scripts as $idx => $script) {
  // Scripts connect as normal user unless otherwise specified.
  $script['connection'] = empty($script['connection']) ? 'default' : $script['connection'];
  // Allow skip to start at certain script.
  if (!empty($settings['start']) && ($idx + 1) < $settings['start']) {
    continue;
  }
  echo ($idx + 1) . ' - ' . (empty($script['description']) ? $script['file'] : $script['description']);
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
    ImportUksiHelper::echoScriptOutputs($conn, $script, $result);
  }
}
importUksiHelper::updateCaches($connections['default'], $settings);
echo 'Total time: ' . round(microtime(TRUE) - $startAll, 1) . "s\n";
