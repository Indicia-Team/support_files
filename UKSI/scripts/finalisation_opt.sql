------------------------------------------------------------
-- finalisation.optimised.sql
-- Ultra-optimised version for 40M+ occurrence warehouses
-- Requires psql -v start_id -v end_id
------------------------------------------------------------

-- 1) Improve planner decisions
SET work_mem = '512MB';
SET maintenance_work_mem = '4GB';
SET temp_buffers = '512MB';
SET enable_bitmapscan = on;
SET enable_seqscan = on;
SET enable_indexscan = on;
SET synchronous_commit = off;

------------------------------------------------------------
-- 2) TEMP TABLE: Build a small mapping table of TTL → Meaning
-- This avoids repeatedly joining large TTL tables
------------------------------------------------------------
DROP TABLE IF EXISTS tmp_ttl_meaning_map;
CREATE TEMP TABLE tmp_ttl_meaning_map AS
SELECT ttl.id AS taxa_taxon_list_id,
       ttl.taxon_meaning_id,
       ttl.parent_id
FROM taxa_taxon_lists ttl
JOIN uksi.changed_taxa_taxon_list_ids c
     ON c.id = ttl.id;

CREATE INDEX ON tmp_ttl_meaning_map(taxa_taxon_list_id);
CREATE INDEX ON tmp_ttl_meaning_map(taxon_meaning_id);

------------------------------------------------------------
-- 3) TEMP TABLE: Build occurrence batch based on BETWEEN filter
------------------------------------------------------------
DROP TABLE IF EXISTS tmp_occ_batch;
CREATE TEMP TABLE tmp_occ_batch AS
SELECT o.id,
       o.taxa_taxon_list_id
FROM occurrences o
WHERE o.id BETWEEN :start_id AND :end_id;

CREATE INDEX ON tmp_occ_batch(id);

------------------------------------------------------------
-- 4) UPDATE cache_occurrences_functional meaning IDs
------------------------------------------------------------
WITH mapped AS (
  SELECT b.id,
         m.taxon_meaning_id
  FROM tmp_occ_batch b
  JOIN tmp_ttl_meaning_map m
       ON m.taxa_taxon_list_id = b.taxa_taxon_list_id
)
UPDATE cache_occurrences_functional cf
SET taxon_meaning_id = mapped.taxon_meaning_id
FROM mapped
WHERE cf.id = mapped.id
AND cf.taxon_meaning_id IS DISTINCT FROM mapped.taxon_meaning_id;

------------------------------------------------------------
-- 5) UPDATE cache_occurrences_functional classification paths
-- (uses precomputed TTL parent/meaning relationships)
------------------------------------------------------------
WITH p AS (
   SELECT b.id,
          t.parent_id,
          t.taxon_meaning_id
   FROM tmp_occ_batch b
   JOIN tmp_ttl_meaning_map t
        ON t.taxa_taxon_list_id = b.taxa_taxon_list_id
)
UPDATE cache_occurrences_functional cf
SET parent_meaning_id = p.parent_id
FROM p
WHERE cf.id = p.id
AND cf.parent_meaning_id IS DISTINCT FROM p.parent_id;

------------------------------------------------------------
-- 6) Refresh simple non-functional caches (fast)
------------------------------------------------------------
UPDATE cache_occurrences_nonfunctional cn
SET taxa_taxon_list_id = b.taxa_taxon_list_id
FROM tmp_occ_batch b
WHERE cn.id = b.id
AND cn.taxa_taxon_list_id IS DISTINCT FROM b.taxa_taxon_list_id;

UPDATE cache_occurrences_functional_sensitive cs
SET taxa_taxon_list_id = b.taxa_taxon_list_id
FROM tmp_occ_batch b
WHERE cs.id = b.id
AND cs.taxa_taxon_list_id IS DISTINCT FROM b.taxa_taxon_list_id;

------------------------------------------------------------
-- 7) Cleanup taxon meanings no longer referenced
------------------------------------------------------------
DELETE FROM taxon_meanings tm
WHERE tm.id NOT IN (
    SELECT DISTINCT taxon_meaning_id
    FROM taxa_taxon_lists
)
AND tm.id NOT IN (
    SELECT DISTINCT taxon_meaning_id
    FROM cache_occurrences_functional
);

------------------------------------------------------------
-- 8) Provide useful diagnostics
------------------------------------------------------------
SELECT 
  :start_id::bigint AS batch_start,
  :end_id::bigint   AS batch_end,
  (SELECT COUNT(*) FROM tmp_occ_batch) AS batch_rows,
  now() AS completed_at;