SET search_path=indicia, public;

-- Ensure that any name whose preferred name has been updated is also updated.
INSERT INTO uksi.changed_taxa_taxon_list_ids(
  SELECT ttl.id
  FROM taxa_taxon_lists ttl
  JOIN taxa_taxon_lists ttlpref ON ttlpref.gitttl.taxon_meaning_id
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

-- Ensure that the hierarchical data is fully populated. Easier just to redo the
-- whole lot rather than scan up and down the hierarchy to ensure changes are
-- properly applied.
WITH RECURSIVE q AS (
  SELECT distinct ttl.id AS child_id, t.taxon AS child_taxon, ttlpref.parent_id,
      ttlpref.id AS rank_ttl_id, tpref.taxon AS rank_taxon,
      tr.rank, tr.id AS taxon_rank_id, tr.sort_order AS taxon_rank_sort_order
  FROM taxa_taxon_lists ttl
  JOIN taxa t ON t.id=ttl.taxon_id AND t.deleted=false
  JOIN taxa tpref ON tpref.search_code=t.external_key AND tpref.deleted=false
  JOIN taxa_taxon_lists ttlpref ON ttlpref.taxon_id=tpref.id AND ttlpref.deleted=false
    AND ttlpref.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
    AND ttlpref.preferred=true AND ttlpref.allow_data_entry=true
  JOIN taxon_ranks tr ON tr.id=tpref.taxon_rank_id AND tr.deleted=false AND tr.deleted=false
  UNION ALL
  SELECT q.child_id, q.child_taxon, ttl.parent_id,
      ttl.id AS rank_ttl_id, t.taxon AS rank_taxon, tr.rank, tr.id AS taxon_rank_id, tr.sort_order AS taxon_rank_sort_order
  FROM q
  JOIN taxa_taxon_lists ttl ON ttl.id=q.parent_id AND ttl.deleted=false
  JOIN taxa t ON t.id=ttl.taxon_id AND t.deleted=false AND t.deleted=false
  JOIN taxon_ranks tr ON tr.id=t.taxon_rank_id AND tr.deleted=false AND tr.deleted=false
) SELECT DISTINCT * INTO temporary rankupdate FROM q;

UPDATE cache_taxa_taxon_lists cttl
SET kingdom_taxa_taxon_list_id=ru.rank_ttl_id, kingdom_taxon=ru.rank_taxon
FROM rankupdate ru
WHERE ru.child_id=cttl.id AND ru.rank='Kingdom'
AND (
  COALESCE(cttl.kingdom_taxa_taxon_list_id, 0)<>COALESCE(ru.rank_ttl_id, 0)
  OR COALESCE(cttl.kingdom_taxon, '')<>COALESCE(rank_taxon, '')
);

UPDATE cache_taxa_taxon_lists cttl
SET order_taxa_taxon_list_id=ru.rank_ttl_id, order_taxon=ru.rank_taxon
FROM rankupdate ru
WHERE ru.child_id=cttl.id AND ru.rank='Order'
AND (
  COALESCE(cttl.order_taxa_taxon_list_id, 0)<>COALESCE(ru.rank_ttl_id, 0)
  OR COALESCE(cttl.order_taxon, '')<>COALESCE(rank_taxon, '')
);

UPDATE cache_taxa_taxon_lists cttl
SET family_taxa_taxon_list_id=ru.rank_ttl_id, family_taxon=ru.rank_taxon
FROM rankupdate ru
WHERE ru.child_id=cttl.id AND ru.rank='Family'
AND (
  COALESCE(cttl.family_taxa_taxon_list_id, 0)<>COALESCE(ru.rank_ttl_id, 0)
  OR COALESCE(cttl.family_taxon, '')<>COALESCE(rank_taxon, '')
);

UPDATE cache_taxa_taxon_lists cttl
SET taxon_rank_id=ru.taxon_rank_id, taxon_rank=ru.rank, taxon_rank_sort_order=ru.taxon_rank_sort_order
FROM rankupdate ru
WHERE ru.child_id=cttl.id
AND ru.child_id=ru.rank_ttl_id
AND (
  COALESCE(cttl.taxon_rank_id, 0)<>COALESCE(ru.taxon_rank_id, 0)
  OR COALESCE(cttl.taxon_rank, '')<>COALESCE(ru.rank, '')
  OR COALESCE(cttl.taxon_rank_sort_order, 0)<>COALESCE(ru.taxon_rank_sort_order, 0)
);

UPDATE cache_taxon_searchterms u
SET taxon_rank_sort_order=cttl.taxon_rank_sort_order
FROM cache_taxa_taxon_lists cttl
WHERE cttl.id=u.taxa_taxon_list_id
AND COALESCE(u.taxon_rank_sort_order, 0)<>COALESCE(cttl.taxon_rank_sort_order, 0);

UPDATE cache_occurrences_functional u
SET taxon_rank_sort_order=cttl.taxon_rank_sort_order,
  family_taxa_taxon_list_id=cttl.family_taxa_taxon_list_id
FROM cache_taxa_taxon_lists cttl
WHERE cttl.id=u.taxa_taxon_list_id
AND (
  COALESCE(u.taxon_rank_sort_order, 0)<>COALESCE(cttl.taxon_rank_sort_order, 0)
  OR COALESCE(u.family_taxa_taxon_list_id, 0)=COALESCE(cttl.family_taxa_taxon_list_id, 0)
);

DROP TABLE rankupdate;