SET search_path=indicia, public;

DROP TABLE IF EXISTS to_process;

CREATE TEMPORARY TABLE to_process (
  id integer
);

-- Mark any remaining taxa_taxon_lists as not for data entry where the item's TVK is not in the preferred names list but the item is in use
INSERT INTO to_process
SELECT DISTINCT ttl.id
FROM taxa_taxon_lists ttl
JOIN taxa t
  ON t.id = ttl.taxon_id
 AND t.deleted = false
LEFT JOIN uksi.all_names an
  ON an.input_taxon_version_key = t.search_code
 AND an.organism_key = t.organism_key
LEFT JOIN occurrences o
  ON o.taxa_taxon_list_id = ttl.id
LEFT JOIN determinations d
  ON d.taxa_taxon_list_id = ttl.id
WHERE ttl.taxon_list_id IN (
    SELECT id FROM uksi.all_uksi_taxon_lists
)
AND an.recommended_taxon_version_key IS NULL
AND ttl.deleted = false
AND ttl.allow_data_entry = true
-- ✅ must be in use
AND (o.id IS NOT NULL OR d.id IS NOT NULL)
-- Ensure any custom names are not affected
AND t.search_code IS NOT NULL;

UPDATE cache_taxa_taxon_lists SET allow_data_entry=false WHERE id IN (SELECT id FROM to_process);
DELETE FROM cache_taxon_searchterms WHERE taxa_taxon_list_id IN (SELECT id FROM to_process);

UPDATE taxa_taxon_lists ttl
SET allow_data_entry=false,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM to_process d
WHERE d.id=ttl.id;