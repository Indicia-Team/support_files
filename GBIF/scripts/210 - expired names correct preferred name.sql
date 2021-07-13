SET search_path=indicia, public;

-- Names which are no longer accepted have been flagged as not for data entry.
-- We need to ensure they point to the correct accepted name.
INSERT INTO gbif.changed_taxa_taxon_list_ids
SELECT DISTINCT ttl.id
FROM taxa t
JOIN gbif.backbone gb 
  ON gb.id::varchar(20) = t.search_code
  AND gb.status != 'ACCEPTED'
  AND gb.parent_key::varchar(50) <> t.external_key
JOIN taxa_taxon_lists ttl 
  ON ttl.taxon_id = t.id
  AND ttl.allow_data_entry = false
  AND ttl.deleted = false
WHERE t.deleted = false;

UPDATE taxa t
SET 
  external_key = gb.parent_key::varchar(50),
  updated_on = now(),
  updated_by_id = (SELECT value FROM gbif.settings WHERE key = 'updated_by_id')
FROM
  gbif.backbone gb,
  taxa_taxon_lists ttl
WHERE 
  gb.id::varchar(20) = t.search_code
  AND gb.status != 'ACCEPTED'
  AND gb.parent_key::varchar(50) <> t.external_key
  AND ttl.taxon_id = t.id
  AND ttl.allow_data_entry = false
  AND ttl.deleted = false
  AND t.deleted = false

