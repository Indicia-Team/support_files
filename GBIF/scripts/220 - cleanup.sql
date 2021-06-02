SET search_path=indicia, public;

DROP TABLE IF EXISTS gbif.preferred_name_changes;

-- Tidy up where there have been preferred name changes.

-- Grab a table of the changes.
SELECT ttl1.id AS old_taxa_taxon_list_id,
  ttl1.orig_taxon_meaning_id AS old_taxon_meaning_id,
  ttl2.id AS new_taxa_taxon_list_id,
  ttl2.taxon_meaning_id AS new_taxon_meaning_id
INTO gbif.preferred_name_changes
FROM gbif.prepared_taxa_taxon_lists ttl1
JOIN gbif.prepared_taxa_taxon_lists ttl2
  ON ttl2.taxon_meaning_id = ttl1.taxon_meaning_id
  AND ttl2.preferred = true
WHERE ttl1.orig_preferred = true
AND (ttl1.id <> ttl2.id OR ttl1.orig_taxon_meaning_id <> ttl2.taxon_meaning_id);

-- Where there are related tables that link by taxon meaning ID, we need to
-- map them to the new preferred names.
UPDATE taxon_codes tc
SET taxon_meaning_id = nc.new_taxon_meaning_id
FROM gbif.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id = tc.taxon_meaning_id
AND tc.taxon_meaning_id <> nc.new_taxon_meaning_id;

UPDATE species_alerts sa
SET taxon_meaning_id = nc.new_taxon_meaning_id
FROM gbif.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id = sa.taxon_meaning_id
AND sa.taxon_meaning_id <> nc.new_taxon_meaning_id;

DELETE FROM taxon_associations WHERE from_taxon_meaning_id IN (
  SELECT tm.id FROM taxon_meanings tm
  LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id = tm.id
  WHERE ttl.id IS NULL
);
DELETE FROM taxon_associations WHERE to_taxon_meaning_id IN (
  SELECT tm.id FROM taxon_meanings tm
  LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
  WHERE ttl.id IS NULL
);

UPDATE taxon_associations ta
SET from_taxon_meaning_id = nc.new_taxon_meaning_id
FROM gbif.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id = ta.from_taxon_meaning_id
AND ta.from_taxon_meaning_id <> nc.new_taxon_meaning_id;

UPDATE taxon_associations ta
SET to_taxon_meaning_id=nc.new_taxon_meaning_id
FROM gbif.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id = ta.to_taxon_meaning_id
AND ta.to_taxon_meaning_id <> nc.new_taxon_meaning_id;

-- Reference https://github.com/BiologicalRecordsCentre/iRecord/issues/636#issuecomment-520751086 
DELETE FROM cache_taxon_paths WHERE taxon_meaning_id IN (
  SELECT old_taxon_meaning_id FROM gbif.preferred_name_changes
);

-- For tables that are linked to a taxa taxon list ID we can use that to get
-- the updated taxon meaning ID.
UPDATE cache_taxa_taxon_lists cttl
SET taxon_meaning_id = ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id = cttl.id
AND cttl.taxon_meaning_id <> ttl.taxon_meaning_id;

UPDATE cache_taxon_searchterms cts
SET taxon_meaning_id = ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id = cts.taxa_taxon_list_id
AND cts.taxon_meaning_id <> ttl.taxon_meaning_id;

-- Verification rules may also link by TVKs which are no-longer preferred.
UPDATE verification_rule_metadata vrm
SET value = t.external_key
FROM taxa t
JOIN taxa_taxon_lists ttl ON ttl.taxon_id = t.id
  AND ttl.taxon_list_id = (SELECT value FROM gbif.settings WHERE key = 'taxon_list_id')
  AND ttl.deleted = false 
  AND ttl.allow_data_entry = true
WHERE (vrm.key ilike 'Tvk' OR vrm.key ilike 'DataRecordId')
AND t.search_code = vrm.value
AND t.external_key <> vrm.value
AND t.deleted = false;

UPDATE verification_rule_data vrd
SET key = t.external_key
FROM taxa t
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id 
  AND ttl.taxon_list_id = (SELECT value FROM gbif.settings WHERE key = 'taxon_list_id') 
  AND ttl.deleted = false
WHERE vrd.header_name ilike 'Data'
AND t.search_code = vrd.key
AND t.external_key <> t.search_code
AND t.deleted = false;

-- Verification rule cache tables will then need a refresh.

SELECT DISTINCT vr.id AS verification_rule_id,
  vr.reverse_rule,
  vrmkey.value AS taxa_taxon_list_external_key,
  vrd.value_geom AS geom,
  vr.error_message
INTO temporary cache_verification_rules_without_polygon2
FROM verification_rules vr
JOIN verification_rule_metadata vrmkey 
  ON vrmkey.verification_rule_id = vr.id 
  AND vrmkey.key = 'DataRecordId' 
  AND vrmkey.deleted = false
JOIN verification_rule_metadata isSpecies 
  ON isSpecies.verification_rule_id = vr.id 
  AND isSpecies.value = 'Species' 
  AND isSpecies.deleted = false
JOIN verification_rule_data vrd 
  ON vrd.verification_rule_id = vr.id 
  AND vrd.header_name = 'geom' 
  AND vrd.deleted = false
WHERE vr.test_type = 'WithoutPolygon'
  AND vr.deleted = false;

TRUNCATE cache_verification_rules_without_polygon;

INSERT INTO cache_verification_rules_without_polygon
  SELECT * FROM cache_verification_rules_without_polygon2;

DROP TABLE cache_verification_rules_without_polygon2;

SELECT vr.id AS verification_rule_id,
  vr.reverse_rule,
  coalesce(vrmkey.value, cttltaxon.external_key, cttlmeaning.external_key) AS taxa_taxon_list_external_key,
  extract(doy FROM cast('2012' || vrmstart.value AS date)) AS start_date,
  extract(doy FROM cast('2012' || vrmend.value AS date)) AS end_date,
  vrmsurvey.value::integer AS survey_id,
  null::text[] AS stages,
  vr.error_message
INTO temporary cache_verification_rules_period_within_year2
FROM verification_rules vr
LEFT JOIN verification_rule_metadata vrmkey 
  ON vrmkey.verification_rule_id = vr.id
  AND vrmkey.key ilike 'Tvk' 
  AND vrmkey.deleted = false
LEFT JOIN verification_rule_metadata vrmtaxon 
  ON vrmtaxon.verification_rule_id = vr.id
  AND vrmtaxon.key = 'Taxon' 
  AND vrmtaxon.deleted = false
LEFT JOIN cache_taxa_taxon_lists cttltaxon 
  ON cttltaxon.preferred_taxon = vrmtaxon.value 
  AND cttltaxon.preferred = true
LEFT JOIN verification_rule_metadata vrmmeaning 
  ON vrmmeaning.verification_rule_id = vr.id
  AND vrmmeaning.key = 'TaxonMeaningId' 
  AND vrmmeaning.deleted = false
LEFT JOIN cache_taxa_taxon_lists cttlmeaning 
  ON cttltaxon.taxon_meaning_id=vrmmeaning.value::integer 
  AND cttlmeaning.preferred=true
LEFT JOIN verification_rule_metadata vrmstart 
  ON vrmstart.verification_rule_id = vr.id 
  AND vrmstart.key ilike 'StartDate' 
  AND length(vrmstart.value) = 4
  AND vrmstart.deleted = false
LEFT JOIN verification_rule_metadata vrmend 
  ON vrmend.verification_rule_id = vr.id 
  AND vrmend.key ilike 'EndDate' 
  AND length(vrmend.value) = 4
  AND vrmend.deleted = false
LEFT JOIN verification_rule_metadata vrmsurvey 
  ON vrmsurvey.verification_rule_id = vr.id 
  AND vrmsurvey.key = 'SurveyId' 
  AND vrmsurvey.deleted = false
WHERE vr.test_type = 'PeriodWithinYear'
  AND vr.deleted = false
  AND (vrmstart.id IS NOT NULL OR vrmend.id IS NOT NULL)

UNION

select vr.id AS verification_rule_id,
  vr.reverse_rule,
  coalesce(vrmkey.value, cttltaxon.external_key, cttlmeaning.external_key) AS taxa_taxon_list_external_key,
  extract(doy FROM cast('2012' || vrstart.value AS date)) AS start_date,
  extract(doy FROM cast('2012' || vrend.value AS date)) AS end_date,
  vrmsurvey.value::integer AS survey_id,
  string_to_array(lower(vrdstage.value), ',') AS stages,
  vr.error_message
FROM verification_rules vr
LEFT JOIN verification_rule_metadata vrmkey 
  ON vrmkey.verification_rule_id = vr.id
  AND vrmkey.key ilike 'Tvk' 
  AND vrmkey.deleted = false
LEFT JOIN verification_rule_metadata vrmtaxon 
  ON vrmtaxon.verification_rule_id = vr.id
  AND vrmtaxon.key = 'Taxon' 
  AND vrmtaxon.deleted = false
LEFT JOIN cache_taxa_taxon_lists cttltaxon 
  ON cttltaxon.taxon = vrmtaxon.value 
  AND cttltaxon.preferred = true
LEFT JOIN verification_rule_metadata vrmmeaning 
  ON vrmmeaning.verification_rule_id = vr.id
  AND vrmmeaning.key = 'TaxonMeaningId' 
  AND vrmmeaning.deleted = false
LEFT JOIN cache_taxa_taxon_lists cttlmeaning 
  ON cttltaxon.taxon_meaning_id = vrmmeaning.value::integer 
  AND cttlmeaning.preferred = true
join verification_rule_data vrdstage 
  ON vrdstage.verification_rule_id = vr.id 
  AND vrdstage.key ilike 'Stage'
LEFT JOIN verification_rule_data vrstart 
  ON vrstart.verification_rule_id = vr.id 
  AND vrstart.key ilike 'StartDate' 
  AND length(vrstart.value) = 4
  AND vrstart.deleted = false
LEFT JOIN verification_rule_data vrend 
  ON vrend.verification_rule_id = vr.id 
  AND vrend.key ilike 'EndDate' 
  AND length(vrend.value) = 4
  AND vrend.deleted = false
LEFT JOIN verification_rule_data vrmsurvey 
  ON vrmsurvey.verification_rule_id = vr.id 
  AND vrmsurvey.key = 'SurveyId' 
  AND vrmsurvey.deleted = false
WHERE vr.test_type = 'PeriodWithinYear'
  AND vr.deleted = false
  AND (vrstart.id IS NOT NULL OR vrend.id IS NOT NULL);

TRUNCATE cache_verification_rules_period_within_year;

INSERT INTO cache_verification_rules_period_within_year
  SELECT * FROM cache_verification_rules_period_within_year2;

DROP TABLE cache_verification_rules_period_within_year2;
