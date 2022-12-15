/**
 * @file
 * Data cleaning operations.
 *
 * This script runs cleanup operations that would not be required if the
 * former state of the UKSI data on the warehouse was absolutely clean - i.e.
 * these queries fix fomer UKSI import bugs which can get in the way later.
 */
SET search_path=indicia, public;

-- Find all the cache table entries which have not got an up to date taxon
-- meaning ID due to previous failures to update the cache. As the cache table
-- is often looked up against when entering or importing data, we need to use
-- this info to undo mistakes in foreign keys.
DROP TABLE IF EXISTS broke_meanings_by_id;
SELECT ttl.id, ttl.preferred, cttl.taxon_meaning_id AS old_taxon_meaning_id, ttl.taxon_meaning_id AS new_taxon_meaning_id
INTO TEMPORARY broke_meanings_by_id
FROM cache_taxa_taxon_lists cttl
JOIN taxa_taxon_lists ttl on ttl.id=cttl.id AND ttl.taxon_meaning_id<>cttl.taxon_meaning_id;

-- Repair the tables which cache the meaning ID along with the taxa_taxon_list_id.
UPDATE cache_occurrences_functional u
SET taxon_meaning_id=bm.new_taxon_meaning_id
FROM broke_meanings_by_id bm
WHERE bm.id=u.id
AND u.taxon_meaning_id<>bm.new_taxon_meaning_id;

UPDATE cache_taxon_searchterms u
SET taxon_meaning_id=bm.new_taxon_meaning_id
FROM broke_meanings_by_id bm
WHERE bm.id=u.taxa_taxon_list_id
AND u.taxon_meaning_id<>bm.new_taxon_meaning_id;

UPDATE cache_taxa_taxon_lists u
SET taxon_meaning_id=bm.new_taxon_meaning_id
FROM broke_meanings_by_id bm
WHERE bm.id=u.id
AND u.taxon_meaning_id<>bm.new_taxon_meaning_id;

DELETE FROM cache_taxon_paths WHERE taxon_meaning_id IN (SELECT old_taxon_meaning_id FROM broke_meanings_by_id);

-- Now get meanings which definitely don't exist any more, so we can fix FKs in
-- tables which don't have the benefit of being able to use taxa_taxon_list_id
-- to find the correct taxon_meaning_id.
DROP TABLE IF EXISTS broke_meanings;
SELECT DISTINCT ON (old_taxon_meaning_id) old_taxon_meaning_id, new_taxon_meaning_id
INTO temporary broke_meanings
FROM broke_meanings_by_id bm
LEFT JOIN taxa_taxon_lists ttl
  ON ttl.taxon_meaning_id=bm.old_taxon_meaning_id
  AND ttl.deleted=false
WHERE ttl.id IS NULL
ORDER BY old_taxon_meaning_id, bm.preferred DESC;

UPDATE taxon_codes u
SET taxon_meaning_id=bm.new_taxon_meaning_id
FROM broke_meanings bm
WHERE bm.old_taxon_meaning_id=u.taxon_meaning_id;

UPDATE taxon_associations u
SET from_taxon_meaning_id=bm.new_taxon_meaning_id
FROM broke_meanings bm
WHERE bm.old_taxon_meaning_id=u.from_taxon_meaning_id;

UPDATE taxon_associations u
SET to_taxon_meaning_id=bm.new_taxon_meaning_id
FROM broke_meanings bm
WHERE bm.old_taxon_meaning_id=u.to_taxon_meaning_id;

UPDATE species_alerts u
SET taxon_meaning_id=bm.new_taxon_meaning_id
FROM broke_meanings bm
WHERE bm.old_taxon_meaning_id=u.taxon_meaning_id;

-- Now clean up any redundant unused taxon meanings.
DROP TABLE IF EXISTS to_delete;
SELECT DISTINCT tm.id
INTO TEMPORARY to_delete
FROM taxon_meanings tm
LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
WHERE ttl.id IS NULL;
-- Before removing the taxon meanings, remove related dead records.
-- Hopefully there won't be any by this point.
DELETE FROM taxon_codes WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM taxon_media WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM species_alerts WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM taxon_associations WHERE from_taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM taxon_associations WHERE to_taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM cache_taxon_searchterms WHERE taxon_meaning_id IN (SELECT id FROM to_delete);

-- Remove the taxon meanings.
DELETE FROM taxon_meanings WHERE id IN (SELECT id FROM to_delete);
DROP TABLE to_delete;

-- Remove any orphaned taxa which don't have a taxa_taxon_list record. There
-- hopefully won't be any.
DELETE FROM taxa tdel
USING taxa t
LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id
LEFT JOIN taxa_taxon_designations ttd ON ttd.taxon_id=t.id
WHERE t.id=tdel.id
AND ttl.id IS NULL
AND ttd.id IS NULL;