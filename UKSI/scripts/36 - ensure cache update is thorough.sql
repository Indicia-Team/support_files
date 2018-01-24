SET search_path=indicia, public;

-- Ensure that any name whose preferred name has been updated is also updated.
INSERT INTO uksi.changed_taxa_taxon_list_ids(
  SELECT ttl.id
  FROM taxa_taxon_lists ttl
  JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
    AND ttlpref.taxon_list_id=ttl.taxon_list_id
    AND ttlpref.preferred=true
  JOIN uksi.changed_taxa_taxon_list_ids ttlchanged ON ttlchanged.id=ttlpref.id
  LEFT JOIN uksi.changed_taxa_taxon_list_ids done ON done.id=ttl.id
  WHERE ttl.preferred=false
  AND done.id IS NULL
);

-- Ensure that any name whose common name has been updated is also updated.
INSERT INTO uksi.changed_taxa_taxon_list_ids(
  SELECT ttl.id
  FROM taxa_taxon_lists ttl
  JOIN taxa_taxon_lists ttlc ON ttlc.taxon_id=ttl.common_taxon_id
  JOIN uksi.changed_taxa_taxon_list_ids ttlchanged ON ttlchanged.id=ttlc.id
  LEFT JOIN uksi.changed_taxa_taxon_list_ids done ON done.id=ttl.id
  WHERE ttl.preferred=false
  AND done.id IS NULL
);

-- Build a complete hierarchy so we can spot changes required in the cache tables
WITH RECURSIVE q AS (
  SELECT distinct ttl1.id AS child_id, t1.taxon AS child_taxon, ttlpref.parent_id,
      ttlpref.id AS rank_ttl_id, t.taxon AS rank_taxon, tr.rank, tr.id AS taxon_rank_id, tr.sort_order AS taxon_rank_sort_order
  FROM taxa_taxon_lists ttl1
  JOIN taxa t1 ON t1.id=ttl1.taxon_id AND t1.deleted=false
  JOIN taxa t1pref ON t1pref.search_code=t1.external_key and t1pref.deleted=false
  JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_id=t1.id AND ttlpref.deleted=false
    AND ttlpref.taxon_list_id=ttl1.taxon_list_id AND ttlpref.preferred=true AND ttlpref.allow_data_entry=true
  JOIN taxa_taxon_lists ttlprefraw ON ttlprefraw.id=ttlpref.id AND ttlprefraw.deleted=false
  JOIN taxa t ON t.id=ttlprefraw.taxon_id AND t.deleted=false AND t.deleted=false
  JOIN taxon_ranks tr ON tr.id=t.taxon_rank_id AND tr.deleted=false AND tr.deleted=false
  WHERE ttl1.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  UNION ALL
  SELECT q.child_id, q.child_taxon, ttl.parent_id,
      ttl.id AS rank_ttl_id, t.taxon AS rank_taxon, tr.rank, tr.id AS taxon_rank_id, tr.sort_order AS taxon_rank_sort_order
  FROM q
  JOIN taxa_taxon_lists ttl ON ttl.id=q.parent_id AND ttl.deleted=false AND ttl.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  JOIN taxa t ON t.id=ttl.taxon_id AND t.deleted=false AND t.deleted=false
  JOIN taxon_ranks tr ON tr.id=t.taxon_rank_id AND tr.deleted=false AND tr.deleted=false
) SELECT DISTINCT * INTO temporary rankupdate FROM q;

-- Apply hierarchical changes as required otherwise these could be missed by the simplistic
-- approach to identifying changed rows.

-- Update data for the higher taxa kingdom, order and family.
UPDATE cache_taxa_taxon_lists u
SET kingdom_taxa_taxon_list_id=ru.rank_ttl_id, kingdom_taxon=ru.rank_taxon
FROM taxa_taxon_lists ttl
JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.preferred=true
  AND ttlpref.deleted=false
  AND ttlpref.allow_data_entry=true
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
LEFT JOIN rankupdate ru ON ru.child_id=ttlpref.id AND ru.rank='Kingdom'
where ttl.id=u.id
AND (
  coalesce(u.kingdom_taxa_taxon_list_id, 0)<>coalesce(ru.rank_ttl_id, 0)
  OR coalesce(u.kingdom_taxon, '')<>coalesce(ru.rank_taxon, '')
);

UPDATE cache_taxa_taxon_lists u
SET order_taxa_taxon_list_id=ru.rank_ttl_id, order_taxon=ru.rank_taxon
FROM taxa_taxon_lists ttl
JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.preferred=true
  AND ttlpref.deleted=false
  AND ttlpref.allow_data_entry=true
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
LEFT JOIN rankupdate ru ON ru.child_id=ttlpref.id AND ru.rank='Order'
where ttl.id=u.id
AND (
  coalesce(u.order_taxa_taxon_list_id, 0)<>coalesce(ru.rank_ttl_id, 0)
  OR coalesce(u.order_taxon, '')<>coalesce(ru.rank_taxon, '')
);

UPDATE cache_taxa_taxon_lists u
SET family_taxa_taxon_list_id=ru.rank_ttl_id, family_taxon=ru.rank_taxon
FROM taxa_taxon_lists ttl
JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.preferred=true
  AND ttlpref.deleted=false
  AND ttlpref.allow_data_entry=true
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
LEFT JOIN rankupdate ru ON ru.child_id=ttlpref.id AND ru.rank='Family'
where ttl.id=u.id
AND (
  coalesce(u.family_taxa_taxon_list_id, 0)<>coalesce(ru.rank_ttl_id, 0)
  OR coalesce(u.family_taxon, '')<>coalesce(ru.rank_taxon, '')
);

UPDATE cache_occurrences_functional u
SET family_taxa_taxon_list_id=ru.rank_ttl_id
FROM occurrences o
JOIN taxa_taxon_lists ttl ON ttl.id=o.taxa_taxon_list_id
  AND ttl.deleted=false
JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.preferred=true
  AND ttlpref.deleted=false
  AND ttlpref.allow_data_entry=true
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
LEFT JOIN rankupdate ru ON ru.child_id=ttlpref.id AND ru.rank='Family'
WHERE o.id=u.id
AND coalesce(u.family_taxa_taxon_list_id, 0)<>coalesce(ru.rank_ttl_id, 0);

-- Update rank data for the same level.
UPDATE cache_taxa_taxon_lists u
SET taxon_rank_id=ru.taxon_rank_id, taxon_rank=ru.rank, taxon_rank_sort_order=ru.taxon_rank_sort_order
FROM taxa_taxon_lists ttl
JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.preferred=true
  AND ttlpref.deleted=false
  AND ttlpref.allow_data_entry=true
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
LEFT JOIN rankupdate ru ON ru.child_id=ttlpref.id
  -- doing the current level
  AND ru.child_id=ru.rank_ttl_id
WHERE ttl.id=u.id
AND (coalesce(u.taxon_rank_id, 0) <> ru.taxon_rank_id
  OR coalesce(u.taxon_rank, '')<>ru.rank
  OR coalesce(u.taxon_rank_sort_order, 0)<>ru.taxon_rank_sort_order
);

UPDATE cache_taxon_searchterms u
SET taxon_rank_sort_order=ru.taxon_rank_sort_order
FROM rankupdate ru
FROM taxa_taxon_lists ttl
JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.preferred=true
  AND ttlpref.deleted=false
  AND ttlpref.allow_data_entry=true
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
LEFT JOIN rankupdate ru ON ru.child_id=ttlpref.id
  -- doing the current level
  AND ru.child_id=ru.rank_ttl_id
WHERE ttl.id=u.taxa_taxon_list_id
AND coalesce(u.taxon_rank_sort_order, 0)<>COALESCE(ru.taxon_rank_sort_order, 0);

UPDATE cache_occurrences_nonfunctional u
SET taxon_rank_sort_order=ru.taxon_rank_sort_order
FROM occurrences o
JOIN taxa_taxon_lists ttl ON ttl.id=o.taxa_taxon_list_id
  AND ttl.deleted=false
JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.preferred=true
  AND ttlpref.deleted=false
  AND ttlpref.allow_data_entry=true
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
LEFT JOIN rankupdate ru ON ru.child_id=ttlpref.id
  -- doing the current level
  AND ru.child_id=ru.rank_ttl_id
WHERE o.id=u.id
AND COALESCE(u.taxon_rank_sort_order, 0)<>COALESCE(ru.taxon_rank_sort_order, 0);

DROP TABLE rankupdate;