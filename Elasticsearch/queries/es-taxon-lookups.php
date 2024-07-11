<?php
  if (count($argv) != 7) {
    echo("Six arguments must be supplied to the script:\n");
    echo("1) host - the hostname or IP address of the postgres host\n");
    echo("2) database - the name of the indicia warehouse database\n");
    echo("3) user - database user with sufficient access, e.g. indicia_user\n");
    echo("4) password\n");
    echo("5) taxon list ids - a comma separated list of taxon_list ids. If more than one, separate with commas - but no spaces\n");
    echo("6) output folder - the location where the output files will be generated (no trailing slash)\n\n");
    echo("Example call:\n");
    echo("php -d memory_limit=512M es-taxon-lookups.php 123.123.123.123 warehouselive indicia_user pasword 15,251,258,260,261,265,277,282 .\n");
    exit;
  } else {
    // $argv[0] is the script name
    $host = $argv[1];
    $dbname = $argv[2];
    $user = $argv[3];
    $password = $argv[4];
    $taxon_lists = $argv[5];
    $folder = $argv[6];
  }

  $db_connection = pg_connect("host=$host dbname=$dbname user=$user password=$password");
  if ($db_connection) {
    echo "Connected to " . pg_dbname($db_connection) . "\n";
    echo "Generating data...\n";
  } else {
    echo "Connection failed for host $host, dbname $dbname, user $user and password $password\n";
    exit;
  }

  $taxa_sql = file_get_contents("./prepare-taxa-lookup.sql");
  $taxa_sql_mod = "SET search_path to indicia;\n" . str_replace("=<taxon_list_id>", " IN ($taxon_lists)", $taxa_sql);
  $taxon_paths_sql = file_get_contents("./prepare-taxon-paths.sql");
  $taxon_paths_sql_mod = "SET search_path to indicia;\n" . str_replace("=<taxon_list_id>", " IN ($taxon_lists)", $taxon_paths_sql);

  $taxa = pg_query($db_connection, $taxa_sql_mod);
  $taxon_paths = pg_query($db_connection, $taxon_paths_sql_mod);

  $rows = pg_fetch_all($taxa);
  $file = fopen("$folder/taxa.yml", "w");
  foreach ($rows as $row) {
    fwrite($file, array_shift($row) . "\n");
  }
  fclose($file);

  $rows = pg_fetch_all($taxon_paths);
  $file = fopen("$folder/taxon-paths.yml", "w");
  foreach ($rows as $row) {
    fwrite($file, array_shift($row) . "\n");
  }
  fclose($file);

  pg_close($db_connection);
  echo "Finished\n";
?>