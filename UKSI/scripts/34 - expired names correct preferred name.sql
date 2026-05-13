SET search_path=indicia, public;

-- Expired names (redundant or deleted) are either deleted if not in use, or
-- flagged as not for data entry. Since the rest of this script does not handle
-- expired names, we still need to ensure they point to the correct
-- recommended taxon version key.
INSERT INTO uksi.changed_taxa_taxon_list_ids
SELECT DISTINCT ttl.id
FROM taxa t
JOIN uksi.all_taxon_version_keys atvk ON atvk.input_taxon_version_key=t.search_code
AND atvk.recommended_taxon_version_key<>t.external_key
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id
  AND ttl.allow_data_entry=false
  AND ttl.deleted=false
WHERE t.deleted=false;

UPDATE taxa t
SET external_key=atvk.recommended_taxon_version_key,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM
  uksi.all_taxon_version_keys atvk,
  taxa_taxon_lists ttl
WHERE atvk.input_taxon_version_key=t.search_code
AND t.deleted=false
AND ttl.taxon_id=t.id
AND ttl.allow_data_entry=false
AND ttl.deleted=false
AND t.external_key<>atvk.recommended_taxon_version_key;

-- Some dodgy common names for families in UKSI are sometimes marked as species rank.
UPDATE taxa SET taxon_rank_id=25, updated_on=now()
WHERE id IN (
	SELECT ttl.taxon_id
	FROM cache_taxa_taxon_lists cttl
	JOIN taxa_taxon_lists ttl ON ttl.id=cttl.id AND ttl.deleted=false
	JOIN cache_taxa_taxon_lists cttlpref ON cttlpref.taxon_meaning_id=cttl.taxon_meaning_id AND cttlpref.preferred=true
	WHERE cttl.taxon_list_id=15 AND cttlpref.taxon_list_id=15
	AND cttl.preferred=false
	AND cttl.taxon_rank_id<>cttlpref.taxon_rank_id
	AND cttl.taxon_rank='Species' AND cttlpref.taxon_rank='Family'
	AND cttl.language_iso<>'lat'
);


/* SET search_path = indicia, public;   New script 

------------------------------------------------------------
-- SCRIPT 34 — EXPIRED NAMES AND UKSI CLEANUP
------------------------------------------------------------



/************************************************************
 34.1 FLAG EXPIRED / NON-DATA-ENTRY NAMES THAT WILL CHANGE
 ************************************************************/
INSERT INTO uksi.changed_taxa_taxon_list_ids (id)
SELECT DISTINCT ttl.id
FROM indicia.taxa t
JOIN uksi.all_taxon_version_keys atvk
  ON atvk.input_taxon_version_key = t.search_code
 AND atvk.recommended_taxon_version_key <> t.external_key
JOIN indicia.taxa_taxon_lists ttl
  ON ttl.taxon_id = t.id
WHERE
  t.deleted = false
  AND ttl.deleted = false
  AND ttl.allow_data_entry = false
  AND ttl.preferred = false;



/************************************************************
 34.2 UPDATE EXTERNAL_KEY FOR EXPIRED / NON-DATA-ENTRY NAMES
 ************************************************************/
UPDATE indicia.taxa t
SET
  external_key = atvk.recommended_taxon_version_key,
  updated_on = now(),
  updated_by_id = (
    SELECT updated_by_user_id
    FROM uksi.uksi_settings
  )
FROM uksi.all_taxon_version_keys atvk,
     indicia.taxa_taxon_lists ttl
WHERE
  ttl.taxon_id = t.id                 -- ✅ moved here
  AND atvk.input_taxon_version_key = t.search_code
  AND t.deleted = false
  AND ttl.deleted = false
  AND ttl.allow_data_entry = false
  AND ttl.preferred = false
  AND t.external_key <> atvk.recommended_taxon_version_key;



/************************************************************
 34.3 FIX KNOWN UKSI DATA ANOMALY:
      FAMILY COMMON NAMES MIS-TYPED AS SPECIES
 ************************************************************/
UPDATE indicia.taxa t
SET
  taxon_rank_id = 25,
  updated_on = now(),
  updated_by_id = (
    SELECT updated_by_user_id
    FROM uksi.uksi_settings
  )
WHERE t.id IN (
  SELECT ttl.taxon_id
  FROM indicia.cache_taxa_taxon_lists cttl
  JOIN indicia.taxa_taxon_lists ttl
    ON ttl.id = cttl.id
   AND ttl.deleted = false
  JOIN indicia.cache_taxa_taxon_lists cttlpref
    ON cttlpref.taxon_meaning_id = cttl.taxon_meaning_id
   AND cttlpref.preferred = true
  WHERE
    cttl.taxon_list_id = 15
    AND cttlpref.taxon_list_id = 15
    AND cttl.taxon_rank <> cttlpref.taxon_rank
    AND cttl.taxon_rank = 'Species'
    AND cttlpref.taxon_rank = 'Family'
    AND cttl.language_iso <> 'lat'
    AND ttl.allow_data_entry = false
    AND ttl.preferred = false   
);

*/