<?php

/**
 * @file
 * List of scripts that will be run in order following import
 * of GBIF data and update to cache tables.
 *
 * Each script has the following keys:
 * * file - name of the file in the scripts subfolder.
 * * description - Description of the script. Optional.
 * * result - if the rows affected by the query is informative, describe what
 *   it means here. Optional.
 * * output - if the result of the script is best described by testing it with
 *   another query, then specify the query here. The output of this query will
 *   be displayed. Optional.
 */

$final_scripts = [
  [
    'file' => 'final 10 - update cache occurrences.sql',
    'description' => 'Ensure occurrence cache taxonomy info is correct.',
  ],
  [
    'file' => 'final 20 - remove old meanings.sql',
    'description' => 'Clean up old meanings.',
  ],
];