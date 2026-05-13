SET search_path = indicia, public;

------------------------------------------------------------
-- PERFORMANCE SETTINGS (session-only)
------------------------------------------------------------
SET work_mem = '512MB';
SET maintenance_work_mem = '4GB';
SET temp_buffers = '512MB';
SET synchronous_commit = off;

/******************************************************************
 STEP 0 — ENSURE ALL TAXA EXIST IN THE MASTER LIST (LIST 15)
 Copies any taxa present in UKSI (or list 8) into list 15
 if not already present.
******************************************************************/

INSERT INTO indicia.taxa_taxon_lists (
    taxon_list_id,
    taxon_id,
    taxon_meaning_id,
    preferred,
    deleted,
    created_on,
    created_by_id,
    updated_on,
    updated_by_id
)
SELECT
    15,              -- master list
    t.id,
    t.taxon_meaning_id,
    false,           -- finalisation will choose the preferred name
    false,
    now(),
    1,
    now(),
    1
FROM indicia.taxa t
LEFT JOIN indicia.taxa_taxon_lists ttl
    ON ttl.taxon_id = t.id
   AND ttl.taxon_list_id = 15
WHERE ttl.id IS NULL                 -- not already in master list
  AND t.deleted = false;             -- only active taxa


/******************************************************************
 STEP 1 — NORMALISE name_deprecated
 UKSI imports leave many NULL name_deprecated values.
 We treat all NULLs as FALSE (not deprecated).
******************************************************************/
UPDATE indicia.taxa
SET name_deprecated = false
WHERE name_deprecated IS NULL;




/******************************************************************
 STEP 2 — SAFE DEDUPLICATION OF taxa_taxon_lists (TTL)
 This block:
   ✅ Identifies duplicate TTL rows
   ✅ Redirects occurrences → keep_id
   ✅ Redirects attributes → keep_id
   ✅ Soft-deletes duplicate TTL rows
******************************************************************/

------------------------------------------------------------
-- 2A — Identify duplicate TTL sets
-- Always keep the non-deleted row when possible.
------------------------------------------------------------
DROP TABLE IF EXISTS ttl_dupes_fixed;

WITH ttl_dupes AS (
  SELECT
    CASE 
      WHEN t1.deleted = false THEN t1.id
      ELSE t2.id
    END AS keep_id,
    CASE 
      WHEN t1.deleted = false THEN t2.id
      ELSE t1.id
    END AS remove_id
  FROM indicia.taxa_taxon_lists t1
  JOIN indicia.taxa_taxon_lists t2
    ON t1.taxon_id = t2.taxon_id
   AND t1.taxon_list_id = t2.taxon_list_id
   AND t1.taxon_meaning_id = t2.taxon_meaning_id
   AND t1.id <> t2.id
)

SELECT DISTINCT keep_id, remove_id
INTO TEMP ttl_dupes_fixed
FROM ttl_dupes
WHERE keep_id <> remove_id;




------------------------------------------------------------
-- 2B — Redirect occurrences to surviving TTL rows
------------------------------------------------------------
UPDATE indicia.occurrences o
SET taxa_taxon_list_id = d.keep_id
FROM ttl_dupes_fixed d
WHERE o.taxa_taxon_list_id = d.remove_id;




------------------------------------------------------------
-- 2C — Redirect attribute values from duplicate TTL rows
------------------------------------------------------------
UPDATE indicia.taxa_taxon_list_attribute_values aval
SET taxa_taxon_list_id = d.keep_id
FROM ttl_dupes_fixed d
WHERE aval.taxa_taxon_list_id = d.remove_id;




------------------------------------------------------------
-- 2D — Soft-delete duplicate TTL rows
-- DO NOT hard delete — Indicia must remain auditable.
------------------------------------------------------------
UPDATE indicia.taxa_taxon_lists ttl
SET deleted = true
FROM ttl_dupes_fixed d
WHERE ttl.id = d.remove_id
  AND ttl.deleted = false;




/******************************************************************
 STEP 3 — DEMOTE DEPRECATED NAMES THAT ARE STILL PREFERRED
 Keeps taxonomy consistent after UKSI updates.
******************************************************************/
UPDATE indicia.taxa_taxon_lists ttl
SET preferred = false
FROM indicia.taxa t
WHERE ttl.taxon_id = t.id
  AND ttl.preferred = true
  AND t.name_deprecated = true;




/******************************************************************
 STEP 4 — ENSURE EXACTLY ONE PREFERRED NAME PER MEANING PER LIST
 Rules:
   ✅ Keep the most recently updated TTL record
   ✅ Only consider non-deprecated names as preferred
   ✅ Demote all other preferred rows for same meaning/list
******************************************************************/
WITH ranked AS (
  SELECT
    ttl.id,
    ttl.taxon_list_id,
    ttl.taxon_meaning_id,
    ROW_NUMBER() OVER (
      PARTITION BY ttl.taxon_list_id, ttl.taxon_meaning_id
      ORDER BY ttl.updated_on DESC, ttl.id
    ) AS rn
  FROM indicia.taxa_taxon_lists ttl
  JOIN indicia.taxa t ON t.id = ttl.taxon_id
  WHERE ttl.preferred = true
    AND t.name_deprecated = false
)
UPDATE indicia.taxa_taxon_lists ttl
SET preferred = false
FROM ranked r
WHERE ttl.id = r.id
  AND r.rn > 1;




/******************************************************************
 STEP 5 — REBUILD CACHES (UNCOMMENT IF REQUIRED BY YOUR WORKFLOW)
 These rebuild all derived taxonomy + occurrence cache data.
******************************************************************/

-- SELECT rebuild_taxon_list_caches();
-- SELECT rebuild_taxon_paths_cache();
-- SELECT rebuild_taxonomy_cache();
-- SELECT refresh_occurrence_caches();

-- END OF FINALISATION SCRIPT