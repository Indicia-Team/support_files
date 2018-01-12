SET search_path=indicia, public;

DROP TABLE IF EXISTS to_process;

CREATE TEMPORARY TABLE to_process (
  id integer
);

-- Remove any taxa_taxon_lists where the item's TVK is not in the preferred
-- names list and the item is not in use anywhere.
INSERT INTO to_process
  SELECT ttl.id
  FROM taxa_taxon_lists ttl
  JOIN taxa t ON t.id=ttl.taxon_id
  LEFT JOIN uksi.all_names an ON an.input_taxon_version_key=t.search_code
  LEFT JOIN occurrences o on o.taxa_taxon_list_id=ttl.id
  LEFT JOIN determinations d ON d.taxa_taxon_list_id=ttl.id
  WHERE ttl.taxon_list_id in (select id from uksi.all_uksi_taxon_lists)
  AND an.recommended_taxon_version_key IS NULL
  AND o.id IS NULL
  AND d.id IS NULL
  -- Ensure any custom names are not deleted from child lists.
  AND t.search_code IS NOT NULL
  AND ttl.deleted=false;

DELETE FROM cache_taxa_taxon_lists WHERE id IN (SELECT id FROM to_process);
DELETE FROM cache_taxon_searchterms WHERE taxa_taxon_list_id IN (SELECT id FROM to_process);

UPDATE taxa_taxon_lists ttl
SET deleted=true,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM to_process d
WHERE d.id=ttl.id
AND deleted=false;
