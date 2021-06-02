-- Ensure occurrence cache taxonomy info is correct.
-- If there are millions of occurrences then maybe do this like for
-- UKSI, a million at a time manually.
UPDATE cache_occurrences_functional o
SET
  preferred_taxa_taxon_list_id = cttl.preferred_taxa_taxon_list_id,
  taxa_taxon_list_external_key = cttl.external_key,
  taxon_meaning_id = cttl.taxon_meaning_id
FROM cache_taxa_taxon_lists cttl
WHERE cttl.id = o.taxa_taxon_list_id
AND (o.preferred_taxa_taxon_list_id <> cttl.preferred_taxa_taxon_list_id 
  OR o.taxa_taxon_list_external_key <> cttl.external_key
  OR o.taxon_meaning_id <> cttl.taxon_meaning_id);