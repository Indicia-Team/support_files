UPDATE taxa_taxon_list_attribute_values av
SET taxa_taxon_list_id=ttlpref.id
FROM taxa_taxon_lists ttl
JOIN taxa_taxon_lists ttlpref
  ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
  AND ttlpref.preferred=true
WHERE ttl.id=av.taxa_taxon_list_id
AND ttl.preferred=false
AND ttl.deleted=false
AND av.deleted=false
AND av.taxa_taxon_list_id<>ttlpref.id;
SET search_path = indicia, public;

/*

------------------------------------------------------------
-- SCRIPT 32 — ALIGN INDICIA PREFERRED NAMES WITH UKSI
--
-- Authoritative rule:
--   What is preferred in UKSI is preferred in Indicia.
--   Nothing else is preferred.
------------------------------------------------------------



------------------------------------------------------------
-- 32.0 RESET PREFERENCE STATE (UKSI LIST ONLY)
--
-- We fully reset preference and entry flags for the target
-- list, then re‑apply UKSI truth deterministically.
------------------------------------------------------------
UPDATE indicia.taxa_taxon_lists
SET preferred = false,
    allow_data_entry = false,
    updated_on = now()
WHERE taxon_list_id = (
  SELECT uksi_taxon_list_id
  FROM uksi.uksi_settings
);


------------------------------------------------------------
-- 32.2 ENSURE UKSI PREFERRED TAXA EXIST IN THE LIST
--      (revive first)
------------------------------------------------------------
UPDATE indicia.taxa_taxon_lists ttl
SET deleted = false,
    updated_on = now(),
    updated_by_id = (SELECT updated_by_user_id FROM uksi.uksi_settings)
FROM indicia.taxa t
JOIN uksi.preferred_names pn
  ON pn.taxon_version_key = t.external_key
WHERE ttl.taxon_id = t.id
  AND ttl.taxon_list_id = (
    SELECT uksi_taxon_list_id FROM uksi.uksi_settings
  )
  AND ttl.deleted = true;


------------------------------------------------------------
-- 32.3 INSERT MISSING UKSI PREFERRED TAXA INTO THE LIST
------------------------------------------------------------
/* This is to avoid trying to set a preferred name where it is not in the taxa list
INSERT INTO indicia.taxa_taxon_lists (
  taxon_id,
  taxon_list_id,
  taxon_meaning_id,
  preferred,
  allow_data_entry,
  deleted,
  created_on,
  created_by_id,
  updated_on,
  updated_by_id
)
SELECT DISTINCT
  t.id,
  (SELECT uksi_taxon_list_id FROM uksi.uksi_settings),
  ttl_any.taxon_meaning_id,
  false,  -- set in next step
  false,
  false,
  now(),
  (SELECT updated_by_user_id FROM uksi.uksi_settings),
  now(),
  (SELECT updated_by_user_id FROM uksi.uksi_settings)
FROM uksi.preferred_names pn
JOIN indicia.taxa t
  ON t.external_key = pn.taxon_version_key
JOIN indicia.taxa_taxon_lists ttl_any
  ON ttl_any.taxon_id = t.id
LEFT JOIN indicia.taxa_taxon_lists ttl_target
  ON ttl_target.taxon_id = t.id
 AND ttl_target.taxon_list_id = (
   SELECT uksi_taxon_list_id FROM uksi.uksi_settings
 )
WHERE ttl_target.id IS NULL
  AND ttl_any.deleted = false;
*/


------------------------------------------------------------
-- 32.4 SET PREFERRED ACCORDING TO UKSI (LATIN ONLY)
------------------------------------------------------------
UPDATE indicia.taxa_taxon_lists ttl
SET preferred = true,
    allow_data_entry = true,
    deleted = false,
    updated_on = now()
FROM indicia.taxa t
JOIN uksi.preferred_names pn
  ON pn.taxon_version_key = t.external_key
WHERE ttl.taxon_id = t.id
  AND ttl.taxon_list_id IN  (
    SELECT uksi_taxon_list_id FROM uksi.uksi_settings
  )
  AND t.language_id = 2   
  AND ttl.deleted = false;



------------------------------------------------------------
-- 32.5 REPOINT ATTRIBUTE VALUES TO THE PREFERRED TTL
------------------------------------------------------------
UPDATE indicia.taxa_taxon_list_attribute_values av
SET taxa_taxon_list_id = ttlpref.id
FROM indicia.taxa_taxon_lists ttl
JOIN indicia.taxa_taxon_lists ttlpref
  ON ttlpref.taxon_meaning_id = ttl.taxon_meaning_id
 AND ttlpref.taxon_list_id   = ttl.taxon_list_id
 AND ttlpref.preferred       = true
WHERE av.taxa_taxon_list_id = ttl.id
  AND ttl.preferred = false
  AND ttl.deleted = false
  AND av.deleted = false
  AND av.taxa_taxon_list_id <> ttlpref.id;



------------------------------------------------------------
-- 32.6 HARD ASSERTION
------------------------------------------------------------
------------------------------------------------------------
-- 32.x HARD INVARIANT (UKSI ONLY)
--
-- For each UKSI preferred name, exactly one TTL must be
-- preferred in the UKSI taxon list.
------------------------------------------------------------
/* DO $$
DECLARE
  failing_records text;
BEGIN
  SELECT string_agg(
    format(
      'organism_key=%s, taxon_version_key=%s, preferred_count=%s',
      pn.organism_key,
      pn.taxon_version_key,
      COUNT(*) FILTER (WHERE ttl.preferred = true)
    ),
    E'\n'
  )
  INTO failing_records
  FROM uksi.preferred_names pn
  LEFT JOIN indicia.taxa t
    ON t.external_key = pn.taxon_version_key
  LEFT JOIN indicia.taxa_taxon_lists ttl
    ON ttl.taxon_id = t.id
   AND ttl.taxon_list_id = (
     SELECT uksi_taxon_list_id FROM uksi.uksi_settings
   )
   AND ttl.deleted = false
  GROUP BY pn.organism_key, pn.taxon_version_key
  HAVING COUNT(*) FILTER (WHERE ttl.preferred = true) <> 1;

  IF failing_records IS NOT NULL THEN
    RAISE EXCEPTION
      'SCRIPT 32 FAILED: each UKSI preferred name must have exactly one preferred TTL'
      USING DETAIL = failing_records;
  END IF;
END;
$$; */

-- END SCRIPT 32
*/