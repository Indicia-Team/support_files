SET search_path=indicia, public;

DROP TABLE IF EXISTS to_process;

CREATE TEMPORARY TABLE to_process (
  id integer
);

-- Remove any taxa_taxon_lists where the item's name is not accepted
-- and the item is not in use anywhere.
INSERT INTO to_process
  SELECT ttl.id
  FROM taxa_taxon_lists ttl
  JOIN taxa t ON t.id = ttl.taxon_id
  LEFT JOIN gbif.backbone gb ON gb.id::varchar(20) = t.search_code
  LEFT JOIN occurrences o on o.taxa_taxon_list_id = ttl.id
  LEFT JOIN determinations d ON d.taxa_taxon_list_id = ttl.id
  WHERE ttl.taxon_list_id in (SELECT id FROM gbif.all_taxon_lists)
  AND gb.status != 'ACCEPTED'
  AND o.id IS NULL
  AND d.id IS NULL
  -- Ensure any custom names are not deleted from child lists.
  AND t.search_code IS NOT NULL
  AND ttl.deleted = false;

DELETE FROM cache_taxa_taxon_lists 
WHERE id IN (SELECT id FROM to_process);

DELETE FROM cache_taxon_searchterms 
WHERE taxa_taxon_list_id IN (SELECT id FROM to_process);

UPDATE taxa_taxon_lists ttl
SET deleted = true,
  updated_on = now(),
  updated_by_id = (SELECT value FROM gbif.settings WHERE key = 'updated_by_id')
FROM to_process d
WHERE d.id = ttl.id
AND deleted = false;

DROP TABLE to_process;
