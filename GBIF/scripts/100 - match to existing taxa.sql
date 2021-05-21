SET search_path=indicia, public;

-- Match up all the existing taxa to the updated copies using the 
-- search_code (GBIF id).
-- Also work out which ones have changed.
UPDATE gbif.prepared_taxa pt
SET id = t.id,
  changed = (
    pt.taxon <> t.taxon
    OR pt.taxon_group_id <> t.taxon_group_id
    OR pt.external_key::varchar(50) <> t.external_key
    OR COALESCE(pt.authority, '') <> COALESCE(t.authority, '')
    OR pt.search_code::varchar(20) <> t.search_code
    OR COALESCE(pt.taxon_rank_id, 0) <> COALESCE(t.taxon_rank_id, 0)
  ) OR {{ force-cache-rebuild }}
FROM taxa t
JOIN taxa_taxon_lists ttl on ttl.taxon_id = t.id
  AND ttl.taxon_list_id = (SELECT value FROM gbif.settings WHERE key = 'taxon_list_id')
  AND ttl.deleted=false
WHERE t.search_code = pt.search_code::varchar(20)
AND t.deleted = false;

-- Remember the taxon changes so we can update the cache tables.
INSERT INTO gbif.changed_taxa_taxon_list_ids
SELECT DISTINCT ttl.id
FROM taxa_taxon_lists ttl
JOIN gbif.prepared_taxa pt ON pt.id = ttl.taxon_id AND pt.changed = true
LEFT JOIN gbif.changed_taxa_taxon_list_ids ttldone ON ttldone.id = ttl.id
WHERE ttldone.id IS NULL;