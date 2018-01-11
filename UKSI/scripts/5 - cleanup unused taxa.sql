SET search_path=indicia, public;

-- Just in case, remove any taxa which don't have a taxa_taxon_list record.
DELETE FROM taxa tdel
USING taxa t
LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id
LEFT JOIN taxa_taxon_designations ttd ON ttd.taxon_id=t.id
WHERE t.id=tdel.id
AND ttl.id IS NULL
AND ttd.id IS NULL;