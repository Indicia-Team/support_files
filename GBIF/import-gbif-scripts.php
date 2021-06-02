<?php

/**
 * @file
 * List of scripts that will be run in order.
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

$scripts = [
  [
    'file' => '10 - save settings.sql',
    'description' => 'Store settings for use in queries.',
  ],
  [
    'file' => '20 - create tracker tables.sql',
    'description' => 'Create tables for tracking changes to existing records.',
  ],
  [
    'file' => '30 - create backbone table.sql',
    'description' => 'Create backbone table for GBIF data.',
  ],
  [
    'file' => '40 - import gbif data.sql',
    'description' => 'Import the CSV data into the database.',
    'result' => 'GBIF records imported',
    'connection' => 'su',
  ],
  [
    'file' => '50 - insert taxon ranks.sql',
    'description' => 'Insert missing taxon ranks compatible with UKSI data.',
    'result' => 'Taxon ranks inserted',
  ],
  [
    'file' => '60 - insert taxon groups.sql',
    'description' => 'Insert new taxon groups',
    'result' => 'Taxon groups inserted',
  ],
  [
    'file' => '70 - delete old unused names.sql',
    'description' => 'Remove any old names which are not used in warehouse ' .
      'and now deleted in GBIF.',
    'result' => 'Unused names removed',
  ],
  [
    'file' => '80 - flag old used names.sql',
    'description' => 'Flag as not for data entry any old names which are ' .
      'used in warehouse but now deleted in GBIF.',
    'result' => 'Old names flagged as not for data entry',
  ],
  [
    'file' => '90 - prepare taxa.sql',
    'description' => 'Prepare the taxa table GBIF version.',
    'result' => 'Number of records in taxa',
  ],
  [
    'file' => '100 - match to existing taxa.sql',
    'description' => 'Link GBIF taxa to existing warehouse taxa.',
    'result' => 'Number of pre-existing taxa found',
  ],
  [
    'file' => '110 - update existing changed taxa.sql',
    'description' => 'Update values for existing taxa which have changed.',
    'result' => 'Number of pre-existing taxa updated',
  ],
  [
    'file' => '120 - insert new taxa.sql',
    'description' => 'Insert new taxon records',
    'result' => 'Number of new taxon records',
  ],
  [
    'file' => '130 - prepare taxa taxon lists.sql',
    'description' => 'Prepare the taxa taxon lists table GBIF version',
    'output' => "SELECT 'total taxa_taxon_lists' as type, count(*) " .
      "FROM gbif.prepared_taxa_taxon_lists " .
      "UNION " .
      "SELECT 'child list taxa_taxon_lists' as type, count(*) " .
      "FROM gbif.prepared_taxa_taxon_lists " .
      "WHERE taxon_list_id <> " .
        "(SELECT value FROM gbif.settings WHERE key = 'taxon_list_id')",
  ],
  [
    'file' => '140 - match to existing taxa taxon lists.sql',
    'description' => 'Link GBIF taxa to existing warehouse taxa taxon lists',
    'output' => "SELECT 'existing taxa_taxon_lists linked', count(*) " .
      "FROM gbif.prepared_taxa_taxon_lists WHERE id IS NOT NULL",
  ],
  [
    'file' => '150 - populate preferred name taxon meanings.sql',
    'description' => 'Create new taxon meanings and populate them into the ' .
      'preferred names',
    'output' => "SELECT 'new meanings' as type, count(*) FROM new_taxon_meanings " .
      "UNION " .
      "SELECT 'meanings attached to preferred names' as type, count(*) " .
      "FROM gbif.prepared_taxa_taxon_lists WHERE taxon_meaning_id IS NOT NULL;",
  ],
  [
    'file' => '160 - populate synonym taxon meanings.sql',
    'description' => 'Populate taxon meanings into the synonyms',
    'result' => 'Meanings attached to synonyms',
  ],
  [
    'file' => '170 - populate parent links.sql',
    'description' => 'Fill in the parent to child links',
    'output' => "SELECT 'children linked to parents' as type, count(*) " .
      "FROM gbif.prepared_taxa_taxon_lists WHERE parent_id IS NOT NULL " .
      "UNION " .
      "SELECT 'changes or new parent links' as type, count(*) " .
      "FROM gbif.prepared_taxa_taxon_lists " .
      "WHERE COALESCE(parent_id, 0) <> COALESCE(orig_parent_id, 0);",
  ],
  [
    'file' => '180 - insert new taxa taxon lists.sql',
    'description' => 'Insert new taxa taxon list records',
    'result' => 'Number of new taxa taxon list record',
  ],
  [
    'file' => '190 - update existing changed taxa taxon lists.sql',
    'description' => 'Update values for existing taxa taxon lists which have changed',
    'result' => 'Number of pre-existing taxa taxon lists updated',
  ],
  [
    'file' => '200 - fixup attribute values.sql',
    'description' => 'Ensure taxa taxon list attribute values point to the preferred name',
    'result' => 'Number of attribute values relinked to preferred names',
  ],
  [
    'file' => '210 - expired names correct preferred name.sql',
    'description' => 'Correct preferred name for expired names',
  ],
  [
    'file' => '220 - cleanup.sql',
    'description' => 'Tidy up orphaned records',
  ],
  [
    'file' => '230 - ensure cache update is thorough.sql',
    'description' => 'Ensure updated common and preferred names are applied to all names in concept',
  ],
];
