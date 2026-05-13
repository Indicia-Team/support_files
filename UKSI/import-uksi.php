<?php

require_once "import-uksi-helper.php";
require_once "import-uksi-scripts.php";

echo "\n";
$settings = ImportUksiHelper::getSettings($argv, $argc);
$settings['warehouse_db_user'] = ImportUksiHelper::getWarehouseDbUser($settings);

$connections = ImportUksiHelper::getConnections($settings);



/**
 * Execute a substituted SQL script via psql (needed for \copy and other psql meta-commands).
 * - Uses superuser creds for script['connection'] === 'su', else default DB creds.
 * - Assumes all {{ ... }} template variables are already replaced in $sqlText.
 * - Returns [exitCode, command, outputLines[]].
 */
  function run_via_psql(string $sqlText, array $settings, array $script): array {
    // 0) Normalize line endings – CRLF/CR -> LF (prevents \copy parse errors)
    $sqlText = str_replace(["\r\n", "\r"], "\n", $sqlText);

    // 1) Write SQL to a temp file
    $tmpFile = tempnam(sys_get_temp_dir(), 'uksi_sql_');
    file_put_contents($tmpFile, $sqlText);

    // 2) Load warehouse DB connection (Kohana config) correctly
    $dbConfigFilePath = $settings['warehouse-path'] . 'application' . DIRECTORY_SEPARATOR . 'config' . DIRECTORY_SEPARATOR . 'database.php';
    if (!file_exists($dbConfigFilePath)) {
      @unlink($tmpFile);
      throw new RuntimeException('Database config file not found at ' . $dbConfigFilePath);
    }
    if (!defined('SYSPATH')) {
      define('SYSPATH', 0); // Kohana guard
    }
    // IMPORTANT: use global $config; database.php writes into it.
    global $config;
    $config = [];
    require $dbConfigFilePath;
    if (empty($config['default']['connection'])) {
      @unlink($tmpFile);
      throw new RuntimeException('Could not load default connection from Kohana DB config.');
    }
    $dbConf = $config['default']['connection'];

    $host = $dbConf['host'];
    $port = $dbConf['port'];
    $db   = $dbConf['database'];

    // 3) Choose user/password (su vs default)
    $useSu = !empty($script['connection']) && $script['connection'] === 'su';
    if ($useSu) {
      $user = $settings['su'];
      $pass = $settings['supass'];
    } else {
      $user = $dbConf['user'];
      $pass = $dbConf['pass'];
    }

    // 4) Resolve psql absolute path
    $psqlPath = trim(shell_exec('command -v psql 2>/dev/null') ?? '');
    if ($psqlPath === '' && is_executable('/usr/pgsql-17/bin/psql')) {
      $psqlPath = '/usr/pgsql-17/bin/psql'; // PGDG 17 typical path
    }
    if ($psqlPath === '') {
      @unlink($tmpFile);
      throw new RuntimeException(
        "psql not found on this server.\n" .
        "On Rocky 9 with PGDG 17 ask sysops to run:\n" .
        "  dnf module reset postgresql -y && dnf module disable postgresql -y\n" .
        "  dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm\n" .
        "  dnf install -y postgresql17\n" .
        "Or add /usr/pgsql-17/bin to PATH."
      );
    }

    // 5) Use .pgpass if available; otherwise pass PGPASSWORD via env (not command line)
    $envPrefix = '';
    if (!empty($pass)) {
      $envPrefix = 'PGPASSWORD=' . escapeshellarg($pass) . ' ';
    }

    // 6) Sanity check: ensure no leftover templating tokens (prevents psql parse errors)
    if (strpos($sqlText, '{{') !== false || strpos($sqlText, '}}') !== false) {
      @unlink($tmpFile);
      throw new RuntimeException("Unreplaced {{ }} template token remains in SQL fed to psql. Check data-path / warehouse_db_user variables.");
    }

    // 7) Build and run command
    $cmd = sprintf(
      $envPrefix . '%s -h %s -p %s -U %s -d %s --set=ON_ERROR_STOP=1 -f %s 2>&1',
      escapeshellarg($psqlPath),
      escapeshellarg($host),
      escapeshellarg($port),
      escapeshellarg($user),
      escapeshellarg($db),
      escapeshellarg($tmpFile)
    );

    exec($cmd, $output, $code);

    // Helpful diagnostics if psql fails: show first few lines of the temp file
    if ($code !== 0) {
      $head = @file($tmpFile, FILE_IGNORE_NEW_LINES);
      $preview = '';
      if (is_array($head)) {
        $max = min(count($head), 20);
        for ($i = 0; $i < $max; $i++) {
          $preview .= sprintf("%03d: %s\n", $i + 1, $head[$i]);
        }
      }
      @unlink($tmpFile);
      // Append a preview of the temp SQL to the error so we can spot CRLF/smart quotes/leftover tokens
      $output[] = "\n--- Preview of SQL file fed to psql ---\n" . $preview;
      return [$code, $cmd, $output];
    }

    @unlink($tmpFile);
    return [$code, $cmd, $output];
  }


$startAll = microtime(TRUE);
foreach ($scripts as $idx => $script) {
  // Scripts connect as normal user unless otherwise specified.
  $script['connection'] = empty($script['connection']) ? 'default' : $script['connection'];

  // Allow skip to start at certain script.
  if (!empty($settings['start']) && ($idx + 1) < $settings['start']) {
    continue;
  }
  // Allow abort at certain script.
  if (!empty($settings['stop']) && ($idx + 1) > $settings['stop']) {
    break;
  }

  echo ($idx + 1) . ' - ' . (empty($script['description']) ? $script['file'] : $script['description']);

  $sql = file_get_contents("scripts/$script[file]");
  // Apply settings as replacements Twig style.
  foreach ($settings as $key => $value) {
    $sql = str_replace("{{ $key }}", $value, $sql);
  }

  $startScript = microtime(TRUE);

  if (!empty($script['psql'])) {
    // Run via psql (supports \copy, \echo, etc.)
    [$exit, $cmd, $output] = run_via_psql($sql, $settings, $script);
    if ($exit !== 0) {
      die("\nError in script (psql exit $exit):\n$cmd\n" . implode("\n", $output) . "\n");
    }
    $time = round(microtime(TRUE) - $startScript, 1);
    echo " - OK ({$time}s)\n";

    // If this script defines an 'output' query, run it via pg_query to preserve your summaries
    if (!empty($script['output'])) {
      $conn = $connections[$script['connection']];
      $result = @pg_query($conn, $script['output']);
      if ($result === FALSE) {
        die("Output check script failed\n");
      }
      ImportUksiHelper::echoScriptOutputs($conn, $script, $result);
    }
  } else {
    // Run normally with libpq
    $conn = $connections[$script['connection']];
    $result = @pg_query($conn, $sql);
    if ($result === FALSE) {
      die("\nError in script: " . pg_last_error($conn) . "\n");
    } else {
      $time = round(microtime(TRUE) - $startScript, 1);
      echo " - OK ({$time}s)\n";
      ImportUksiHelper::echoScriptOutputs($conn, $script, $result);
    }
  }
}

if (empty($settings['stop'])) {
  // Update the cache_* tables, unless doing an incomplete run.
  importUksiHelper::updateCaches($connections['default'], $settings);
}

echo 'Total time: ' . round(microtime(TRUE) - $startAll, 1) . "s\n";
echo "Once back online, please run the script scripts/finalisation.sql to tidy the occurrences " .
  "cache table. Using the BETWEEN filter to update in batches of a million records. Also note " .
  "that the end of this script has several queries to help identify any taxon restricted " .
  "attributes where the concept they were restricted to no longer exists. These will need to be " .
  "manually fixed.\n";
echo "* For the BRC warehouse1 instance, please ensure that the scripts/Naturespot update.sql \n" .
  "script is run on the warehouse, taking note that this script contains a query to download a " .
  "set of changes that need to be passed to the naturespot.org.uk admin team.\n";