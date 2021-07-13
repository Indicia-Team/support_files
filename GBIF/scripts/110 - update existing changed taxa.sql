SET search_path=indicia, public;

-- Update existing taxa which have changed
UPDATE taxa t
SET taxon = pt.taxon,
  taxon_group_id = pt.taxon_group_id,
  language_id = pt.language_id,
  external_key = pt.external_key,
  authority = pt.authority,
  search_code = pt.search_code,
  scientific = pt.scientific,
  taxon_rank_id = pt.taxon_rank_id,
  updated_on = now(),
  updated_by_id = (SELECT value FROM gbif.settings WHERE key = 'updated_by_id')
FROM gbif.prepared_taxa pt
WHERE pt.id = t.id
AND pt.changed = true;