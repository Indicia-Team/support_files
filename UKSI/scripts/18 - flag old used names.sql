SET search_path=indicia, public;

DROP TABLE IF EXISTS to_process;

CREATE TEMPORARY TABLE to_process (
  id integer
);

-- Mark any remaining taxa_taxon_lists as not for data entry where the item's TVK is not in the preferred names list but the item is in use
INSERT INTO to_process
  SELECT ttl.id
  FROM taxa_taxon_lists ttl
  JOIN taxa t ON t.id=ttl.taxon_id and t.deleted=false
  LEFT JOIN uksi.all_names an ON an.input_taxon_version_key=t.search_code
  WHERE ttl.taxon_list_id in (select id from uksi.all_uksi_taxon_lists)
  AND an.recommended_taxon_version_key IS NULL
  AND ttl.deleted=false
  AND ttl.allow_data_entry=true
  -- Ensure any custom names are not deleted from child lists.
  AND t.search_code IS NOT NULL;

UPDATE cache_taxa_taxon_lists SET allow_data_entry=false WHERE id IN (SELECT id FROM to_process);
DELETE FROM cache_taxon_searchterms WHERE taxa_taxon_list_id IN (SELECT id FROM to_process);

UPDATE taxa_taxon_lists ttl
SET allow_data_entry=false,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM to_process d
WHERE d.id=ttl.id;