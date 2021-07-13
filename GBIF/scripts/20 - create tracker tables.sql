DROP TABLE IF EXISTS gbif.changed_taxa_taxon_list_ids;

-- Create table to capture changed records that we can apply cache table 
-- updates to at the end.
SELECT id
INTO gbif.changed_taxa_taxon_list_ids
FROM taxa_taxon_lists
LIMIT 0;