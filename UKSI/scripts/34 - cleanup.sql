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

-- Just in case, remove any taxon meanings that are not in use.
-- This could occur if a taxon is flagged as redundant/deleted in
-- UKSI.
SELECT DISTINCT tm.id
INTO TEMPORARY to_delete
FROM taxon_meanings tm
LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
WHERE ttl.id IS NULL;
-- Before removing the taxon meanings, remove related dead records.
DELETE FROM taxon_codes WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM taxon_media WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
DELETE FROM species_alerts WHERE taxon_meaning_id IN (SELECT id FROM to_delete);
-- Remove the taxon meanings.
DELETE FROM taxon_meanings WHERE id IN (SELECT id FROM to_delete);
DROP TABLE to_delete;
