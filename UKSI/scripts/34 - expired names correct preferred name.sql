SET search_path=indicia, public;

-- Expired names (redundant or deleted) are either deleted if not in use, or
-- flagged as not for data entry. Since the rest of this script does not handle
-- expired names, we still need to ensure they point to the correct
-- recommended taxon version key.
INSERT INTO uksi.changed_taxa_taxon_list_ids
SELECT DISTINCT ttl.id
FROM taxa t
JOIN uksi.all_taxon_version_keys atvk ON atvk.input_taxon_version_key=t.search_code
AND atvk.recommended_taxon_version_key<>t.external_key
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id
  AND ttl.allow_data_entry=false
  AND ttl.deleted=false
WHERE t.deleted=false;

UPDATE taxa t
SET external_key=atvk.recommended_taxon_version_key,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM
  uksi.all_taxon_version_keys atvk,
  taxa_taxon_lists ttl
WHERE atvk.input_taxon_version_key=t.search_code
AND t.deleted=false
AND ttl.taxon_id=t.id
AND ttl.allow_data_entry=false
AND ttl.deleted=false
AND t.external_key<>atvk.recommended_taxon_version_key;