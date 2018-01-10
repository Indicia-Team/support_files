SET search_path=indicia, public;

-- Track changes for updating the cache tables later
INSERT INTO uksi.changed_taxa_taxon_list_ids
SELECT DISTINCT ttl.id
FROM taxa_taxon_lists ttl
JOIN taxa t on t.id=ttl.taxon_id
JOIN uksi.update_taxon_groups utg ON utg.id=t.taxon_group_id
LEFT JOIN uksi.changed_taxa_taxon_list_ids ttldone ON ttldone.id=ttl.id
WHERE ttldone.id IS NULL;

DROP TABLE uksi.update_taxon_groups;