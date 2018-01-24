SET search_path=indicia, public;

/* Find and delete taxon ranks where
 * * they are no longer in UKSI
 * * they used to be used in a UKSI species which has been deleted
 * * they are not still used in any taxon
 * This script is unlikely to actuall remove anything unless there have been
 * significant changes to the ranks.
 */
DELETE FROM taxon_ranks WHERE id IN (
  SELECT tr.id
  FROM taxon_ranks tr
  JOIN taxa t ON t.taxon_rank_id=tr.id
  JOIN taxa_taxon_lists ttl on ttl.taxon_id=t.id AND ttl.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  LEFT JOIN taxa t2 ON t2.taxon_rank_id=tr.id AND t2.deleted=false
  WHERE tr.deleted=false
  AND (t.deleted=true OR ttl.deleted=true)
  AND t2.id IS NULL
  AND tr.short_name NOT IN (SELECT short_name FROM uksi.taxon_ranks)
);

-- As above, but for taxon groups.
DELETE FROM taxon_groups WHERE id IN (
  SELECT tg.id
  FROM taxon_groups tg
  JOIN taxa t on t.taxon_group_id=tg.id
  JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id AND ttl.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  LEFT join taxa t2 ON t2.taxon_group_id=tg.id AND t2.deleted=false
  WHERE tg.deleted=false
  AND (t.deleted=true OR ttl.deleted=true)
  AND t2.id IS NULL
  AND tg.title NOT IN (SELECT taxon_group_name FROM uksi.taxon_groups)
);

DROP TABLE IF EXISTS uksi.preferred_name_changes;

-- Tidy up where there have been preferred name changes.
-- Grab a table of the changes.
SELECT ttl1.id AS old_taxa_taxon_list_id,
  ttl1.orig_taxon_meaning_id AS old_taxon_meaning_id,
  ttl2.id AS new_taxa_taxon_list_id,
  ttl2.taxon_meaning_id AS new_taxon_meaning_id
INTO uksi.preferred_name_changes
FROM uksi.prepared_taxa_taxon_lists ttl1
JOIN uksi.prepared_taxa_taxon_lists ttl2
  ON ttl2.taxon_meaning_id=ttl1.taxon_meaning_id
  AND ttl2.preferred=true
WHERE ttl1.orig_preferred=true
AND (ttl1.id<>ttl2.id OR ttl1.orig_taxon_meaning_id<>ttl2.taxon_meaning_id);

-- Where there are related tables that link by taxon meaning ID, we need to
-- map them to the new preferred names.
UPDATE taxon_codes tc
SET taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=tc.taxon_meaning_id
AND tc.taxon_meaning_id<>nc.new_taxon_meaning_id;

UPDATE species_alerts sa
SET taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=sa.taxon_meaning_id
AND sa.taxon_meaning_id<>nc.new_taxon_meaning_id;

UPDATE taxon_associations ta
SET from_taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=ta.from_taxon_meaning_id
AND ta.from_taxon_meaning_id<>nc.new_taxon_meaning_id;

UPDATE taxon_associations ta
SET to_taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=ta.to_taxon_meaning_id
AND ta.to_taxon_meaning_id<>nc.new_taxon_meaning_id;

-- For tables that are linked to a taxa taxon list ID we can use that to get
-- the updated taxon meaning ID.
UPDATE cache_taxa_taxon_lists cttl
SET taxon_meaning_id=ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id=cttl.id
AND cttl.taxon_meaning_id<>ttl.taxon_meaning_id;

UPDATE cache_taxon_searchterms cts
SET taxon_meaning_id=ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id=cts.taxa_taxon_list_id
AND cts.taxon_meaning_id<>ttl.taxon_meaning_id;

-- Temporary indexes will help
CREATE INDEX ix_temp ON cache_occurrences_functional(taxon_meaning_id);
CREATE INDEX ix_temp2 ON cache_occurrences_functional(taxa_taxon_list_id);
UPDATE cache_occurrences_functional co
SET taxon_meaning_id=ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id=co.taxa_taxon_list_id
AND co.taxon_meaning_id<>ttl.taxon_meaning_id;
DROP INDEX ix_temp;
DROP INDEX ix_temp2;

-- Now, it should hopefully be safe to clean up old meanings.
DELETE FROM taxon_meanings WHERE id IN (
  SELECT tm.id FROM taxon_meanings tm
  LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
  WHERE ttl.id IS NULL
);


