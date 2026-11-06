SET search_path=indicia, public;

-- Ensure the designation kinds termlist is filled in.
SELECT insert_term (
  dk.kind,
  'eng',
  (SELECT id FROM termlists WHERE external_key='indicia:taxon_designation_categories'),
  null)
FROM uksi.all_designation_kinds dk
LEFT JOIN cache_termlists_terms ctt
  ON ctt.term=dk.kind
  AND ctt.termlist_id=(SELECT id FROM termlists WHERE external_key='indicia:taxon_designation_categories')
WHERE ctt.id IS NULL;

-- Insert any designations that are missing
INSERT INTO taxon_designations (title, code, abbreviation, description, category_id, created_on, created_by_id, updated_on, updated_by_id)
SELECT
  td.long_name,
  td.status_abbreviation,
  td.short_name,
  td.description,
  tlt.id,
  now(),
  (select updated_by_user_id from uksi.uksi_settings),
  now(),
  (select updated_by_user_id from uksi.uksi_settings)
FROM uksi.taxon_designations td
JOIN terms t ON t.term=td.kind
JOIN termlists_terms tlt on tlt.term_id=t.id and tlt.deleted=false
JOIN termlists tl on tl.id=tlt.termlist_id and tl.deleted=false and tl.external_key='indicia:taxon_designation_categories'
LEFT JOIN taxon_designations tdexist ON tdexist.abbreviation=td.short_name
WHERE tdexist.id IS NULL;

-- Build a unique list of the designations (since they can be duplicated in UKSI, e.g. if on
-- several lists).
DROP TABLE IF EXISTS uksi_taxa_taxon_designations;

SELECT DISTINCT ON (ttl.taxon_id, td.id)
	uttd.*,
	td.id as taxon_designation_id,
	ttl.taxon_id,
	SUBSTRING(uttd.detail FROM 'Source: (.+)') as processed_source
INTO TEMPORARY uksi_taxa_taxon_designations
FROM uksi.taxa_taxon_designations uttd
JOIN taxon_designations td ON td.abbreviation=uttd.short_name
-- Use raw tables here, as cache_taxa_taxon_lists may be stale.
JOIN taxa t ON t.external_key=uttd.recommended_taxon_version_key AND t.deleted=false
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id AND ttl.deleted=false AND ttl.preferred=true
  AND ttl.taxon_list_id=(select uksi_taxon_list_id from uksi.uksi_settings)
ORDER BY ttl.taxon_id, td.id, uttd.date_to IS NOT NULL,
  SUBSTRING(uttd.detail FROM 'Source: (.+)') IS NULL,
  uttd.status_geographic_area IS NULL,
  uttd.date_from DESC NULLS LAST,
  uttd.date_to DESC NULLS LAST,
  uttd.detail, uttd.status_geographic_area,
  uttd.recommended_taxon_version_key, uttd.short_name;

-- Update existing links with the latest source, constraints etc. Also remove links between designations and
-- taxa that are no longer required, if the date_to has kicked in.
UPDATE taxa_taxon_designations ttd
SET start_date=uttd.date_from,
  geographical_constraint=uttd.status_geographic_area,
  source=substring(uttd.detail FROM 'Source: (.+)'),
  deleted=CASE WHEN uttd.date_to IS NULL THEN false else true END,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM uksi_taxa_taxon_designations uttd
WHERE uttd.taxon_id=ttd.taxon_id AND uttd.taxon_designation_id=ttd.taxon_designation_id
AND NOT EXISTS (
  SELECT 1 FROM taxa_taxon_designations ttdkeep
  WHERE ttdkeep.taxon_id=ttd.taxon_id
  AND ttdkeep.taxon_designation_id=ttd.taxon_designation_id
  AND ttdkeep.id<ttd.id
);

-- Soft delete duplicate links, retaining the lowest ID even if it is deleted.
UPDATE taxa_taxon_designations ttd
SET deleted=true,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM uksi_taxa_taxon_designations uttd
WHERE uttd.taxon_id=ttd.taxon_id AND uttd.taxon_designation_id=ttd.taxon_designation_id
AND ttd.deleted=false
AND EXISTS (
  SELECT 1 FROM taxa_taxon_designations ttdkeep
  WHERE ttdkeep.taxon_id=ttd.taxon_id
  AND ttdkeep.taxon_designation_id=ttd.taxon_designation_id
  AND ttdkeep.id<ttd.id
);

-- Soft delete designations links which no longer exist.
UPDATE taxa_taxon_designations ttd
SET deleted=true,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
WHERE ttd.deleted=false
AND EXISTS (
  SELECT 1 FROM taxa_taxon_lists ttl
  WHERE ttl.taxon_id=ttd.taxon_id
  AND ttl.taxon_list_id=(select uksi_taxon_list_id from uksi.uksi_settings)
)
AND EXISTS (
  SELECT 1 FROM taxon_designations td
  JOIN uksi.taxon_designations utd ON utd.short_name=td.abbreviation
  WHERE td.id=ttd.taxon_designation_id
)
AND NOT EXISTS (
  SELECT 1 FROM uksi_taxa_taxon_designations uttd
  WHERE uttd.taxon_id=ttd.taxon_id
  AND uttd.taxon_designation_id=ttd.taxon_designation_id
);

-- Insert any missing links.
INSERT INTO taxa_taxon_designations (
	taxon_id, taxon_designation_id, created_on, created_by_id, updated_on, updated_by_id,
	start_date, source, geographical_constraint
)
SELECT uttd.taxon_id, uttd.taxon_designation_id,
	now(), (select updated_by_user_id from uksi.uksi_settings),
	now(), (select updated_by_user_id from uksi.uksi_settings),
	uttd.date_from, processed_source, uttd.status_geographic_area
FROM uksi_taxa_taxon_designations uttd
LEFT join taxa_taxon_designations ttd ON ttd.taxon_id=uttd.taxon_id AND ttd.taxon_designation_id=uttd.taxon_designation_id and ttd.deleted=false
WHERE ttd.id IS NULL
AND uttd.date_to IS NULL;