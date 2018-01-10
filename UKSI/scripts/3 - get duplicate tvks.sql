SET search_path=indicia, public;

DROP TABLE IF EXISTS uksi.duplicates;

-- Gets a list of all taxa/taxa_taxon_list details where the search_code is duplicated because of errors in previous imports.
SELECT t.search_code, t.external_key, t.id AS taxon_id, ttl.id AS taxa_taxon_list_id, t.taxon, t.attribute
INTO uksi.duplicates
FROM taxa t
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id AND ttl.deleted=false AND ttl.taxon_list_id=15 AND ttl.deleted=false AND ttl.allow_data_entry=true
WHERE t.search_code IN (
	SELECT t.search_code
	FROM taxa t
	JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id AND ttl.deleted=false AND ttl.taxon_list_id=15 AND ttl.deleted=false AND ttl.allow_data_entry=true
	WHERE t.deleted=false
	GROUP BY search_code
	HAVING count(t.id)>1
)
AND t.deleted=false;
