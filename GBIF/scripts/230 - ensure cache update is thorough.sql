SET search_path=indicia, public;

-- Ensure that any name whose preferred name has been updated is also updated.
INSERT INTO gbif.changed_taxa_taxon_list_ids(
  SELECT ttl.id
  FROM taxa_taxon_lists ttl
  JOIN taxa_taxon_lists ttlpref 
    ON ttlpref.taxon_meaning_id = ttl.taxon_meaning_id
    AND ttlpref.taxon_list_id = ttl.taxon_list_id
    AND ttlpref.preferred = true
  JOIN gbif.changed_taxa_taxon_list_ids ttlchanged ON ttlchanged.id = ttlpref.id
  LEFT JOIN gbif.changed_taxa_taxon_list_ids done ON done.id = ttl.id
  WHERE ttl.preferred = false
  AND done.id IS NULL
);