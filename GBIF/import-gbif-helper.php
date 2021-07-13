<?php

/**
 * @file
 * Declares a helper class for functions required during UKSI import.
 */

/**
 * Helper class for functions required during UKSI import.
 */
class ImportGbifHelper {

  /**
   * Text displayed when command line help shown.
   *
   * @var string
   */
  private static $help = <<<HELP
Usage: php import-gbif.php [options]

 --warehouse-path  The path to the warehouse installation folder.
 --su              PostgreSQL superuser username required for some scripts.
 --supass          PostgreSQL superuser password required for some scripts.
 --taxon_list_id   The ID of the existing list in the warehouse which will be 
                   updated with UKSI data.
 --user_id         The ID of the existing user in the warehouse which will be 
                   used in the record metadata for changes and new records.
Optional
 --data-path       The path to the folder containing he GBIF file, 
                   backbone-current-simple.txt, downloaded from 
                   https://hosted-datasets.gbif.org/datasets/backbone.
                   When not supplied, the files must be in the same folder as 
                   this PHP script.
 --start=n         Start at script numbered n.
 --stop=n          Stop after script numbered n.

HELP;

  /**
   * List of parameters we will validate as mandatory.
   *
   * @var array
   */
  private static $requiredParams = [
    'warehouse-path',
    'su', 'supass',
    'taxon_list_id',
    'user_id',
  ];

  /**
   * Retrieves the settings from the command line parameters.
   *
   * @param array $argv
   *   Command line arguments.
   * @param int $argc
   *   Count of arguments.
   *
   * @return array
   *   Settings as an associative array.
   */
  public static function getSettings(array $argv, $argc) {
    // Grab the settings from the command line parameters.
    $settings = [];
    if ($argc > 1) {
      for ($i = 1; $i < $argc; $i++) {
        $tokens = explode('=', $argv[$i]);
        if (count($tokens) === 2) {
          if (substr($tokens[0], 0, 2) == '--') {
            $settings[substr($tokens[0], 2)] = trim($tokens[1], '"');
          }
        }
        elseif ($tokens[0] === '--help') {
          $settings['help'] === TRUE;
        }
      }
    }
    // Validate parameters and display help if required.
    if (empty($settings['help'])) {
      foreach (self::$requiredParams as $param) {
        if (empty($settings[$param])) {
          echo "Missing parameter $param\n";
          $settings['help'] = TRUE;
        }
      }
    }
    if (!empty($settings['help'])) {
      exit(self::$help);
    }
    // Apply defaults.
    $settings = array_merge([
      'data-path' => dirname(__FILE__),
      'force-cache-rebuild' => 'false',
    ], $settings);
    // Ensure valid value for force-cache-rebuild.
    if (strtolower($settings['force-cache-rebuild']) !== 'true') {
      $settings['force-cache-rebuild'] = 'false';
    }
    // Ensure paths have slash at end.
    if (substr($settings['data-path'], -1) !== DIRECTORY_SEPARATOR) {
      $settings['data-path'] .= DIRECTORY_SEPARATOR;
    }
    if (substr($settings['warehouse-path'], -1) !== DIRECTORY_SEPARATOR) {
      $settings['warehouse-path'] .= DIRECTORY_SEPARATOR;
    }
    return $settings;
  }

  /**
   * Retrieves a default and su (superuser) connections to the database.
   *
   * @param array $settings
   *   Settings for the script.
   *
   * @return array
   *   Array containing default and su connections objects.
   */
  public static function getConnections(array $settings) {
    // Fake define so we can load kohana config.
    define('SYSPATH', 0);
    $config = [];
    $dbConfigFilePath = $settings['warehouse-path'] . 'application' . 
      DIRECTORY_SEPARATOR . 'config' . DIRECTORY_SEPARATOR . 'database.php';
    if (!file_exists($dbConfigFilePath)) {
      die ('Database config file not found at ' . $dbConfigFilePath);
    }
    require_once $dbConfigFilePath;

    // Connect to PostgreSQL.
    $dbConf = $config['default']['connection'];
    $conn = pg_connect(
      "host=$dbConf[host] port=$dbConf[port] dbname=$dbConf[database] " .
      "user=$dbConf[user] password=$dbConf[pass]"
    );
    $conn or die("Unable to connect to PostgreSQL\n");
    echo "Database connection OK\n";
    $connSu = pg_connect(
      "host=$dbConf[host] port=$dbConf[port] dbname=$dbConf[database] " .
      "user=$settings[su] password=$settings[supass]"
    );
    $connSu or die("Unable to connect to PostgreSQL as superuser\n");
    echo "Superuser database connection OK\n";
    return [
      'default' => $conn,
      'su' => $connSu
    ];
  }

  /**
   * Outputs any script results or output data.
   *
   * A script can declare a result (a definition of what the affected rows
   * mean), or an output (a query that summarises the results of the query).
   * Outputs these bits of information when available.
   *
   * @param object $conn
   *   Database connection.
   * @param array $script
   *   Script configuration.
   * @param object $result
   *   Database resource returned from the script.
   */
  public static function echoScriptOutputs($conn, array $script, $result) {
    if (!empty($script['result'])) {
      echo "    - $script[result]: " . pg_affected_rows($result) . "\n";
    }
    if (!empty($script['output'])) {
      $result = pg_query($conn, $script['output']);
      if ($result === FALSE) {
        die("Output check script failed\n");
      }
      $resultArr = pg_fetch_all($result);
      $fields = [];
      for ($i = 0; $i < pg_num_fields($result); $i++) {
        $fields[] = pg_field_name($result, $i);
      }
      echo '    - ' . implode(' || ', $fields) . "\n";
      foreach ($resultArr as $record) {
        $row = [];
        foreach ($fields as $field) {
          $row[] = $record[$field];
        }
        echo '    - ' . implode(' || ', $row) . "\n";
      }
    }
  }

  /**
   * Update the cache_* tables.
   *
   * Rather than run dedicated scripts, which could get out of step with the
   * code in the cache_builder module, we load the scripts from the module's
   * config file and run those. There is no need to process deletions as these
   * are done as the sync scripts go along.
   *
   * @param object $conn
   *   Database connection.
   * @param array $settings
   *   Script settings.
   */
  public static function updateCaches($conn, array $settings) {
    require_once $settings['warehouse-path'] . 
      'modules/cache_builder/config/cache_builder.php';
    $tables = [
      'termlists_terms',
      'taxa_taxon_lists',
      'taxon_searchterms',
    ];
    $needsUpdateJoins = [
      'termlists_terms' => "join termlists_terms nu " .
                           "on nu.id = tlt.id ".
                           "and nu.updated_on > ".
                             "(select last_scheduled_task_check from system " .
                             "where name = 'cache_builder')",
      'taxa_taxon_lists' => 'join gbif.changed_taxa_taxon_list_ids nu ' .
                            'on nu.id = ttl.id',
      'taxon_searchterms' => 'join gbif.changed_taxa_taxon_list_ids nu ' .
                             'on nu.id = cttl.id',
    ];
    foreach ($tables as $table) {
      echo "Processing cache for $table\n";

      // Updates.
      $updates = $config[$table]['update'];
      if (!is_array($updates)) {
        $updates = ['default' => $updates];
      }
      foreach ($updates as $queryName => $qry) {
        echo "  - $queryName (UPDATE)";
        $startScript = microtime(TRUE);
        $qry = str_replace(
          ['#join_needs_update#', '#master_list_id#'],
          [$needsUpdateJoins[$table], $settings['taxon_list_id']],
          $qry
        );
        pg_query($conn, $qry);
        $time = round(microtime(TRUE) - $startScript, 1);
        echo " - OK ({$time}s)\n";
      }
      
      // Inserts.
      $inserts = $config[$table]['insert'];
      if (!is_array($inserts)) {
        $inserts = ['default' => $inserts];
      }
      foreach ($inserts as $queryName => $qry) {
        echo "  - $queryName (INSERT)";
        $startScript = microtime(TRUE);
        $qry = str_replace(
          ['#join_needs_update#', '#master_list_id#'],
          [$needsUpdateJoins[$table], $settings['taxon_list_id']],
          $qry
        );
        $result = @pg_query($conn, $qry);
        if ($result === FALSE) {
          echo "\nQuery failed:\n";
          echo "$qry\n";
          die("\nError in script: " . pg_last_error($conn) . "\n");
        }
        $time = round(microtime(TRUE) - $startScript, 1);
        echo " - OK ({$time}s)\n";
      }

      // Extras.
      if (!empty($config[$table]['extra_multi_record_updates'])) {
        foreach ($config[$table]['extra_multi_record_updates'] as $queryName => $qry) {
          echo "  - $queryName (EXTRAS)";
          $startScript = microtime(TRUE);
          $singularTable = preg_replace('/s$/', '', $table);
          // Ensure that the hierarchical data is fully populated. Easier just
          // to redo the whole lot rather than scan up and down the hierarchy
          // to ensure changes are properly applied. So for the ranks query,
          // remove the needs update join.
          if ($table === 'taxa_taxon_lists' && $queryName === 'ranks') {
            $qry = str_replace('JOIN needs_update_taxa_taxon_lists nu ON nu.id=ttl1.id', '', $qry);
          }
          $qry = str_replace(
            ["needs_update_$table", '#master_list_id#'],
            ["gbif.changed_{$singularTable}_ids", $settings['taxon_list_id']],
            $qry
          );
          $result = @pg_query($conn, $qry);
          if ($result === FALSE) {
            echo "\nQuery failed:\n";
            echo "$qry\n";
            die("\nError in script: " . pg_last_error($conn) . "\n");
          }
          $time = round(microtime(TRUE) - $startScript, 1);
          echo " - OK ({$time}s)\n";
        }
      }
    }
    pg_query($conn, "UPDATE system SET last_scheduled_task_check=now() WHERE name='cache_builder'");
    // @todo Consider if the following is best way to prevent data cleaner firing a load of messages
    pg_query($conn, "UPDATE system SET last_scheduled_task_check=now() WHERE name='data_cleaner'");
  }

}
