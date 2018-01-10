DROP TABLE IF EXISTS uksi.changed_occurrence_ids;
DROP TABLE IF EXISTS uksi.changed_taxa_taxon_list_ids;

-- Create tables to capture changed records that we can apply cache table updates to at the end.
SELECT id
INTO uksi.changed_occurrence_ids
FROM occurrences
LIMIT 0;

SELECT id
INTO uksi.changed_taxa_taxon_list_ids
FROM taxa_taxon_lists
LIMIT 0;