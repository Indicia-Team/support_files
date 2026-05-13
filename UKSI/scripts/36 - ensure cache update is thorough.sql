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

/* NEW SCRIPT
SET search_path = indicia, public;

------------------------------------------------------------
-- SCRIPT 36 — PROPAGATE TTL CHANGE FLAGS
--
-- Purpose:
--   Ensure all dependent TTL rows are marked as changed
--   when their canonical or linked TTL changes.
--
-- This script does NOT:
--   * decide preferred names
--   * update taxa or TTL data
--   * touch occurrences
--
-- It ONLY expands the set of TTL IDs that downstream
-- cache rebuilds must refresh.
------------------------------------------------------------



/************************************************************
 36.1 — PROPAGATE CHANGES FROM PREFERRED NAME
 ------------------------------------------------------------
 If the preferred TTL for a (list, meaning) has changed,
 then all non-preferred TTLs for that meaning in the same
 list must also be refreshed.
************************************************************/
INSERT INTO uksi.changed_taxa_taxon_list_ids (id)
SELECT ttl.id
FROM indicia.taxa_taxon_lists ttl
JOIN indicia.taxa_taxon_lists ttlpref
  ON ttlpref.taxon_meaning_id = ttl.taxon_meaning_id
 AND ttlpref.taxon_list_id   = ttl.taxon_list_id
 AND ttlpref.preferred       = true
 AND ttlpref.deleted         = false
JOIN uksi.changed_taxa_taxon_list_ids changed
  ON changed.id = ttlpref.id
LEFT JOIN uksi.changed_taxa_taxon_list_ids already_done
  ON already_done.id = ttl.id
WHERE
  ttl.deleted   = false
  AND ttl.preferred = false   -- synonyms / vernaculars only
  AND already_done.id IS NULL;



/************************************************************
 36.2 — PROPAGATE CHANGES FROM COMMON NAME TTLs
 ------------------------------------------------------------
 If a common-name TTL has changed, then all scientific TTLs
 that reference it via common_taxon_id must also be refreshed.
************************************************************/
INSERT INTO uksi.changed_taxa_taxon_list_ids (id)
SELECT ttl.id
FROM indicia.taxa_taxon_lists ttl
JOIN indicia.taxa_taxon_lists ttl_common
  ON ttl_common.taxon_id = ttl.common_taxon_id
 AND ttl_common.deleted  = false
JOIN uksi.changed_taxa_taxon_list_ids changed
  ON changed.id = ttl_common.id
LEFT JOIN uksi.changed_taxa_taxon_list_ids already_done
  ON already_done.id = ttl.id
WHERE
  ttl.deleted = false
  AND ttl.preferred = false
  AND already_done.id IS NULL;

  */
