

SELECT d1.taxa_taxon_list_id AS from_taxa_taxon_list_id, d2.taxa_taxon_list_id AS to_taxa_taxon_list_id
INTO TEMPORARY ttl_changes
FROM uksi.duplicates d1
JOIN uksi.duplicates d2 ON d2.search_code=d1.search_code
  AND d1.taxa_taxon_list_id < d2.taxa_taxon_list_id;

-- Find all the occurrence IDs that we are changing the taxa_taxon_list_id for so we can update the cache later.
INSERT INTO uksi.changed_occurrence_ids (
  SELECT DISTINCT o.id
  FROM occurrences o
  JOIN ttl_changes tc ON tc.from_taxa_taxon_list_id=o.taxa_taxon_list_id
);

UPDATE occurrences o
SET taxa_taxon_list_id=tc.to_taxa_taxon_list_id,
	updated_on=now(),
	updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM ttl_changes tc
WHERE tc.from_taxa_taxon_list_id = o.taxa_taxon_list_id;

UPDATE determinations d
SET taxa_taxon_list_id=tc.to_taxa_taxon_list_id,
	updated_on=now(),
	updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM ttl_changes tc
WHERE tc.from_taxa_taxon_list_id = d.taxa_taxon_list_id;

DROP TABLE uksi.duplicates;
DROP TABLE ttl_changes;