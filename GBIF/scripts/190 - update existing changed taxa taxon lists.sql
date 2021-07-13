SET search_path=indicia, public;

-- Update existing taxa which have changed
UPDATE taxa_taxon_lists ttl
SET taxon_list_id = pttl.taxon_list_id,
  taxon_id = pttl.taxon_id,
  parent_id = pttl.parent_id,
  taxon_meaning_id = pttl.taxon_meaning_id,
  preferred = pttl.preferred,
  updated_on = now(),
  updated_by_id = (SELECT value FROM gbif.settings WHERE key = 'updated_by_id')
FROM gbif.prepared_taxa_taxon_lists pttl
WHERE pttl.id = ttl.id
AND pttl.changed = true
AND pttl.is_new = false;