<?php

/**
 * @file
 * List of scripts that will be run in order.
 *
 * Each script has the following keys:
 * * file - name of the file in the scripts subfolder.
 * * description - Description of hte script. Optional.
 * * result - if the rows affected by the query is informative, describe what
 *   it means here. Optional.
 * * output - if the result of the script is best described by testing it with
 *   another query, then specify the query here. The output of this query will
 *   be displayed. Optional.
 */

$scripts = [
  [
    'file' => '1 - settings.sql',
    'description' => 'Prepare for script access to settings',
  ],
  [
    'file' => '2 - change tracker tables.sql',
    'description' => 'Create tables for tracking changes to existing records',
  ],
  [
    'file' => '3 - get duplicate tvks.sql',
    'description' => 'Find any duplicated input_taxon_version_keys in the existing warehouse data',
    'result' => 'Count of duplicated taxon version keys in existing warehouse data',
  ],
  [
    'file' => '4 - process_duplicate_tvks.sql',
    'description' => 'Tidy any duplicated taxon version keys in existing warehouse data',
  ],
  [
    'file' => '5 - cleanup unused taxa.sql',
    'description' => 'Remove any orphaned taxa records in the existing warehouse data',
    'result' => 'Existing orphaned taxa records removed',
  ],
  [
    'file' => '6 - create tables in uksi schema.sql',
    'description' => 'Create interim tables for UKSI data',
  ],
  [
    'file' => '7 - import CSV data.sql',
    'description' => 'Import the CSV data into the database',
    'output' =>
      "SELECT 'all names' as type, count(*) FROM uksi.all_names " .
      'UNION ' .
      "SELECT 'preferred names' as type, count(*) FROM uksi.preferred_names ",
    // Run as superuser, because of COPY command.
    'connection' => 'su',
  ],
  [
    'file' => '8 - remove not wellformed similar synonyms.sql',
    'description' => 'Remove synonyms that are not wellformed if similar to others',
    'result' => 'Similar not wellformed synonyms removed',
  ],
  [
    'file' => '9 - remove names that differ only in rank.sql',
    'description' => 'Remove synonyms that differ from the preferred name only in rank',
    'result' => 'Synonyms removed which differ only in rank',
  ],
  [
    'file' => '10 - populate parent tvk.sql',
    'description' => 'Use organism_master hierarchy to find incorrect parent taxon version keys',
    'result' => 'Parent keys updated',
  ],
  [
    'file' => '11 - update taxon ranks.sql',
    'description' => 'Update the existing warehouse taxon ranks to match UKSI data',
    'result' => 'Taxon ranks updated',
  ],
  [
    'file' => '12 - update taxon ranks cleanup.sql',
    'description' => 'Cleanup after taxon ranks update',
  ],
  [
    'file' => '13 - insert taxon ranks.sql',
    'description' => 'Insert new taxon ranks',
    'result' => 'Taxon ranks inserted',
  ],
  [
    'file' => '14 - insert taxon groups.sql',
    'description' => 'Insert new taxon groups',
    'result' => 'Taxon groups inserted',
  ],
  [
    'file' => '15 - update taxon groups.sql',
    'description' => 'Update the existing taxon groups to match UKSI data',
    'result' => 'Taxon groups update',
  ],
  [
    'file' => '16 - update taxon groups cleanup.sql',
    'description' => 'Cleanup after taxon groups update',
  ],
  [
    'file' => '17 - delete old unused names.sql',
    'description' => 'Remove any old names which are not used in warehouse and now deleted in UKSI',
    'result' => 'Unused names removed',
  ],
  [
    'file' => '18 - flag old used names.sql',
    'description' => 'Flag as not for data entry any old names which are used in warehouse but now deleted in UKSI',
    'result' => 'Old names flagged as not for data entry',
  ],
  [
    'file' => '19 - prepare taxa.sql',
    'description' => 'Prepare the taxa table UKSI version',
    'result' => 'Number of records in taxa',
  ],
  [
    'file' => '20 - match to existing taxa.sql',
    'description' => 'Link UKSI taxa to existing warehouse taxa',
    'result' => 'Number of pre-existing taxa found',
  ],
  [
    'file' => '21 - update existing changed taxa.sql',
    'description' => 'Update values for existing taxa which have changed',
    'result' => 'Number of pre-existing taxa updated',
  ],
  [
    'file' => '22 - insert new taxa.sql',
    'description' => 'Insert new taxon records',
    'result' => 'Number of new taxon records',
  ],
  [
    'file' => '23 - prepare taxa taxon lists.sql',
    'description' => 'Prepare the taxa taxon lists table UKSI version',
    'output' => "SELECT 'total taxa_taxon_lists' as type, count(*) FROM uksi.prepared_taxa_taxon_lists " .
      "UNION " .
      "SELECT 'child list taxa_taxon_lists' as type, count(*) FROM uksi.prepared_taxa_taxon_lists " .
      "WHERE taxon_list_id<>(select uksi_taxon_list_id from uksi.uksi_settings)",
  ],
  [
    'file' => '24 - match to existing taxa taxon lists.sql',
    'description' => 'Link UKSI taxa to existing warehouse taxa taxon lists',
    'output' => "SELECT 'existing taxa_taxon_lists linked', count(*) FROM uksi.prepared_taxa_taxon_lists WHERE id IS NOT NULL",
  ],
  [
    'file' => '25 - populate preferred name taxon meanings.sql',
    'description' => 'Create new taxon meanings and populate them into the preferred names',
    'output' => "SELECT 'new meanings' as type, count(*) FROM new_taxon_meanings " .
      "UNION " .
      "SELECT 'meanings attached to preferred names' as type, count(*) FROM uksi.prepared_taxa_taxon_lists WHERE taxon_meaning_id IS NOT NULL;",
  ],
  [
    'file' => '26 - populate synonym taxon meanings.sql',
    'description' => 'Populate taxon meanings into the synonyms',
    'result' => 'Meanings attached to synonyms',
  ],
  [
    'file' => '27 - populate parent links.sql',
    'description' => 'Fill in the parent to child links',
    'output' => "SELECT 'children linked to parents' as type, count(*) FROM uksi.prepared_taxa_taxon_lists WHERE parent_id IS NOT NULL " .
      "UNION " .
      "SELECT 'changes or new parent links' as type, count(*) FROM uksi.prepared_taxa_taxon_lists WHERE COALESCE(parent_id, 0)<>COALESCE(orig_parent_id, 0);",
  ],
  [
    'file' => '28 - prepare common names.sql',
    'description' => 'Prepare common name mappings',
    'result' => 'Names mapped to common names',
  ],
  [
    'file' => '29 - apply common names.sql',
    'description' => 'Apply common name mappings',
    'output' => "select 'Names which had a common name change' as type, count(*) from uksi.prepared_taxa_taxon_lists " .
      'where changed=true and coalesce(common_taxon_id, 0)<>coalesce(orig_common_taxon_id, 0)'
  ],
  [
    'file' => '30 - insert new taxa taxon lists.sql',
    'description' => 'Insert new taxa taxon list records',
    'result' => 'Number of new taxa taxon list record',
  ],
  [
    'file' => '31 - update existing changed taxa taxon lists.sql',
    'description' => 'Update values for existing taxa taxon lists which have changed',
    'result' => 'Number of pre-existing taxa taxon lists updated',
  ],
  [
    'file' => '32 - fixup attribute values.sql',
    'description' => 'Ensure taxa taxon list attribute values point to the preferred name',
    'result' => 'Number of attribute values relinked to preferred names',
  ],
  [
    'file' => '33 - designations.sql',
    'description' => 'Update the taxon designations data',
  ],
  [
    'file' => '34 - expired names correct preferred name.sql',
    'description' => 'Correct preferred name for expired names',
  ],
  [
    'file' => '35 - cleanup.sql',
    'description' => 'Tidy up orphaned records',
  ],
  [
    'file' => '36 - ensure cache update is thorough.sql',
    'description' => 'Ensure updated common and preferred names are applied to all names in concept',
  ],
];
