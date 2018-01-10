SET search_path=indicia, public;

-- Store the taxa taxon lists that are going to need to be updated in the cache
-- because of cache changes.
INSERT INTO uksi.changed_taxa_taxon_list_ids
SELECT DISTINCT ttl.id
FROM taxa_taxon_lists ttl
JOIN taxa t on t.id=ttl.taxon_id
JOIN uksi.update_taxon_ranks utr ON utr.id=t.taxon_rank_id
LEFT JOIN uksi.changed_taxa_taxon_list_ids ttldone ON ttldone.id=ttl.id
WHERE ttldone.id IS NULL;

DROP TABLE IF EXISTS uksi.update_taxon_ranks;