SET search_path=indicia, public;

-- Just in case, remove any taxon meanings that are not in use.
SELECT DISTINCT tm.id
INTO TEMPORARY to_delete
FROM taxon_meanings tm
LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
WHERE ttl.id IS NULL;
-- Before removing the taxon meanings, remove related dead records.
DELETE FROM taxon_codes WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM taxon_media WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM species_alerts WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
-- Correct mistakes in cache table which would otherwise block us from tidying.
UPDATE cache_taxon_searchterms cts
SET taxon_meaning_id=ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id=cts.taxa_taxon_list_id
AND ttl.taxom_meaning_id<>cts.taxon_meaning_id;
-- Remove the taxon meanings.
DELETE FROM taxon_meanings WHERE id IN (SELECT id FROM to_delete);
DROP TABLE to_delete;

-- Just in case, remove any taxa which don't have a taxa_taxon_list record.
DELETE FROM taxa tdel
USING taxa t
LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id
LEFT JOIN taxa_taxon_designations ttd ON ttd.taxon_id=t.id
WHERE t.id=tdel.id
AND ttl.id IS NULL
AND ttd.id IS NULL;