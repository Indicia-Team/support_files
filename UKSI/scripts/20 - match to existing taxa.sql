SET search_path=indicia, public;

-- Match up all the existing taxa to the updated copies using the search_code|input_taxon_version_key.
-- Also work out which ones have changed.
UPDATE uksi.prepared_taxa pt
SET id=t.id,
  changed=(
    pt.taxon<>t.taxon
    OR pt.taxon_group_id<>t.taxon_group_id
    OR pt.language_id<>t.language_id
    OR pt.external_key<>t.external_key
    OR COALESCE(pt.authority, '')<>COALESCE(t.authority, '')
    OR pt.search_code<>t.search_code
    OR pt.scientific<>t.scientific
    OR COALESCE(pt.taxon_rank_id, 0)<>COALESCE(t.taxon_rank_id, 0)
    OR COALESCE(pt.attribute, '')<>COALESCE(t.attribute, '')
    OR pt.marine_flag<>t.marine_flag
  ) OR {{ force_cache_rebuild }} 
FROM taxa t
JOIN taxa_taxon_lists ttl on ttl.taxon_id=t.id
  AND ttl.taxon_list_id = (SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  AND ttl.deleted=false
WHERE t.search_code=pt.search_code
AND t.deleted=false;

-- Remember the taxon changes so we can update the cache tables.
INSERT INTO uksi.changed_taxa_taxon_list_ids
SELECT DISTINCT ttl.id
FROM taxa_taxon_lists ttl
JOIN uksi.prepared_taxa pt ON pt.id=ttl.taxon_id
  AND (pt.changed=true OR pt.is_new=true)
LEFT JOIN uksi.changed_taxa_taxon_list_ids ttldone ON ttldone.id=ttl.id
WHERE ttldone.id IS NULL;