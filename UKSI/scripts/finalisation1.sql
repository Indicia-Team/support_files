SET search_path = indicia, public;
SET synchronous_commit = off;

------------------------------------------------------------
-- FINALISATION: VERIFY + CLEAN + CACHE
-- All taxonomy decisions happen in scripts 32–36
------------------------------------------------------------

/************************************************************
 1. VERIFY CORE INVARIANTS (FAIL FAST)
************************************************************/

-- One preferred TTL per meaning per list
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM taxa_taxon_lists
    WHERE deleted = false
    GROUP BY taxon_list_id, taxon_meaning_id
    HAVING SUM(preferred::int) <> 1
  ) THEN
    RAISE EXCEPTION
      'Finalisation invariant failed: each meaning must have exactly one preferred TTL';
  END IF;
END $$;

-- Preferred must allow data entry
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM taxa_taxon_lists
    WHERE preferred = true
      AND allow_data_entry = false
      AND deleted = false
  ) THEN
    RAISE EXCEPTION
      'Finalisation invariant failed: preferred TTL does not allow data entry';
  END IF;
END $$;

-- No live occurrence points to deleted TTL
DO $$
BEGIN
  IF EXISTS (
    SELECT 1
    FROM occurrences o
    JOIN taxa_taxon_lists ttl
      ON ttl.id = o.taxa_taxon_list_id
    WHERE o.deleted = false
      AND ttl.deleted = true
  ) THEN
    RAISE EXCEPTION
      'Finalisation invariant failed: live occurrence references deleted TTL';
  END IF;
END $$;



/************************************************************
 2. SAFE STRUCTURAL CLEANUP (OPTIONAL BUT RECOMMENDED)
************************************************************/

-- Remove duplicate TTL rows per (taxon, list),
-- keeping preferred or most recently updated
WITH ranked AS (
  SELECT
    id,
    ROW_NUMBER() OVER (
      PARTITION BY taxon_id, taxon_list_id
      ORDER BY preferred DESC, updated_on DESC, id
    ) AS rn
  FROM taxa_taxon_lists
  WHERE deleted = false
)
UPDATE taxa_taxon_lists ttl
SET deleted = true,
    updated_on = now()
FROM ranked r
WHERE ttl.id = r.id
  AND r.rn > 1;



/************************************************************
 FINALISATION COMPLETE
************************************************************/
``