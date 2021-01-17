SET search_path=indicia, public;

/* Find and delete taxon ranks where
 * * they are no longer in UKSI
 * * they used to be used in a UKSI species which has been deleted
 * * they are not still used in any taxon
 * This script is unlikely to actuall remove anything unless there have been
 * significant changes to the ranks.
 */
DELETE FROM taxon_ranks WHERE id IN (
  SELECT tr.id
  FROM taxon_ranks tr
  JOIN taxa t ON t.taxon_rank_id=tr.id
  JOIN taxa_taxon_lists ttl on ttl.taxon_id=t.id AND ttl.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  LEFT JOIN taxa t2 ON t2.taxon_rank_id=tr.id AND t2.deleted=false
  WHERE tr.deleted=false
  AND (t.deleted=true OR ttl.deleted=true)
  AND t2.id IS NULL
  AND tr.short_name NOT IN (SELECT short_name FROM uksi.taxon_ranks)
);

-- As above, but for taxon groups.
DELETE FROM taxon_groups WHERE id IN (
  SELECT tg.id
  FROM taxon_groups tg
  JOIN taxa t on t.taxon_group_id=tg.id
  JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id AND ttl.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  LEFT join taxa t2 ON t2.taxon_group_id=tg.id AND t2.deleted=false
  WHERE tg.deleted=false
  AND (t.deleted=true OR ttl.deleted=true)
  AND t2.id IS NULL
  AND tg.title NOT IN (SELECT taxon_group_name FROM uksi.taxon_groups)
);

DROP TABLE IF EXISTS uksi.preferred_name_changes;

-- Tidy up where there have been preferred name changes.
-- Grab a table of the changes.
SELECT ttl1.id AS old_taxa_taxon_list_id,
  ttl1.orig_taxon_meaning_id AS old_taxon_meaning_id,
  ttl2.id AS new_taxa_taxon_list_id,
  ttl2.taxon_meaning_id AS new_taxon_meaning_id
INTO uksi.preferred_name_changes
FROM uksi.prepared_taxa_taxon_lists ttl1
JOIN uksi.prepared_taxa_taxon_lists ttl2
  ON ttl2.taxon_meaning_id=ttl1.taxon_meaning_id
  AND ttl2.preferred=true
WHERE ttl1.orig_preferred=true
AND (ttl1.id<>ttl2.id OR ttl1.orig_taxon_meaning_id<>ttl2.taxon_meaning_id);

-- Where there are related tables that link by taxon meaning ID, we need to
-- map them to the new preferred names.
UPDATE taxon_codes tc
SET taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=tc.taxon_meaning_id
AND tc.taxon_meaning_id<>nc.new_taxon_meaning_id;

UPDATE species_alerts sa
SET taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=sa.taxon_meaning_id
AND sa.taxon_meaning_id<>nc.new_taxon_meaning_id;

DELETE FROM taxon_associations WHERE from_taxon_meaning_id IN (
  SELECT tm.id FROM taxon_meanings tm
  LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
  WHERE ttl.id IS NULL
);
DELETE FROM taxon_associations WHERE to_taxon_meaning_id IN (
  SELECT tm.id FROM taxon_meanings tm
  LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
  WHERE ttl.id IS NULL
);

UPDATE taxon_associations ta
SET from_taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=ta.from_taxon_meaning_id
AND ta.from_taxon_meaning_id<>nc.new_taxon_meaning_id;

UPDATE taxon_associations ta
SET to_taxon_meaning_id=nc.new_taxon_meaning_id
FROM uksi.preferred_name_changes nc
WHERE nc.old_taxon_meaning_id=ta.to_taxon_meaning_id
AND ta.to_taxon_meaning_id<>nc.new_taxon_meaning_id;

-- Reference https://github.com/BiologicalRecordsCentre/iRecord/issues/636#issuecomment-520751086 
DELETE FROM cache_taxon_paths WHERE taxon_meaning_id IN (
  SELECT old_taxon_meaning_id FROM uksi.preferred_name_changes
);

-- For tables that are linked to a taxa taxon list ID we can use that to get
-- the updated taxon meaning ID.
UPDATE cache_taxa_taxon_lists cttl
SET taxon_meaning_id=ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id=cttl.id
AND cttl.taxon_meaning_id<>ttl.taxon_meaning_id;

UPDATE cache_taxon_searchterms cts
SET taxon_meaning_id=ttl.taxon_meaning_id
FROM taxa_taxon_lists ttl
WHERE ttl.id=cts.taxa_taxon_list_id
AND cts.taxon_meaning_id<>ttl.taxon_meaning_id;

-- Verification rules may also link by TVKs which are no-longer preferred.
UPDATE verification_rule_metadata vrm
SET value=t.external_key
FROM taxa t
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id
  AND ttl.taxon_list_id=(select uksi_taxon_list_id from uksi.uksi_settings)
  AND ttl.deleted=false AND ttl.allow_data_entry=true
WHERE (vrm.key ilike 'Tvk' OR vrm.key ilike 'DataRecordId')
AND t.search_code=vrm.value
AND t.external_key<>vrm.value
AND t.deleted=false;

UPDATE verification_rule_data vrd
SET key=t.external_key
FROM taxa t
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id AND ttl.taxon_list_id=15 AND ttl.deleted=false
WHERE vrd.header_name ilike 'Data'
AND t.search_code=vrd.key
AND t.external_key<>t.search_code
AND t.deleted=false;

-- Verification rule cache tables will then need a refresh.

select distinct vr.id as verification_rule_id,
  vr.reverse_rule,
  vrmkey.value as taxa_taxon_list_external_key,
  vrd.value_geom as geom,
  vr.error_message
into temporary cache_verification_rules_without_polygon2
from verification_rules vr
join verification_rule_metadata vrmkey on vrmkey.verification_rule_id=vr.id and vrmkey.key='DataRecordId' and vrmkey.deleted=false
join verification_rule_metadata isSpecies on isSpecies.verification_rule_id=vr.id and isSpecies.value='Species' and isSpecies.deleted=false
join verification_rule_data vrd on vrd.verification_rule_id=vr.id and vrd.header_name='geom' and vrd.deleted=false
where vr.test_type='WithoutPolygon'
and vr.deleted=false;

truncate cache_verification_rules_without_polygon;
insert into cache_verification_rules_without_polygon
  select * from cache_verification_rules_without_polygon2;
drop table cache_verification_rules_without_polygon2;

select vr.id as verification_rule_id,
  vr.reverse_rule,
  coalesce(vrmkey.value, cttltaxon.external_key, cttlmeaning.external_key) as taxa_taxon_list_external_key,
  extract(doy from cast('2012' || vrmstart.value as date)) as start_date,
  extract(doy from cast('2012' || vrmend.value as date)) as end_date,
  vrmsurvey.value::integer as survey_id,
  null::text[] as stages,
  vr.error_message
into temporary cache_verification_rules_period_within_year2
from verification_rules vr
left join verification_rule_metadata vrmkey on vrmkey.verification_rule_id=vr.id
  and vrmkey.key ilike 'Tvk' and vrmkey.deleted=false
left join verification_rule_metadata vrmtaxon on vrmtaxon.verification_rule_id=vr.id
  and vrmtaxon.key='Taxon' and vrmtaxon.deleted=false
left join cache_taxa_taxon_lists cttltaxon on cttltaxon.preferred_taxon=vrmtaxon.value and cttltaxon.preferred=true
left join verification_rule_metadata vrmmeaning on vrmmeaning.verification_rule_id=vr.id
  and vrmmeaning.key='TaxonMeaningId' and vrmmeaning.deleted=false
left join cache_taxa_taxon_lists cttlmeaning on cttltaxon.taxon_meaning_id=vrmmeaning.value::integer and cttlmeaning.preferred=true
left join verification_rule_metadata vrmstart on vrmstart.verification_rule_id=vr.id and vrmstart.key ilike 'StartDate' and length(vrmstart.value)=4
  and vrmstart.deleted=false
left join verification_rule_metadata vrmend on vrmend.verification_rule_id=vr.id and vrmend.key ilike 'EndDate' and length(vrmend.value)=4
  and vrmend.deleted=false
left join verification_rule_metadata vrmsurvey on vrmsurvey.verification_rule_id=vr.id and vrmsurvey.key='SurveyId' and vrmsurvey.deleted=false
where vr.test_type='PeriodWithinYear'
  and vr.deleted=false
  and (vrmstart.id is not null or vrmend.id is not null)
union
select vr.id as verification_rule_id,
  vr.reverse_rule,
  coalesce(vrmkey.value, cttltaxon.external_key, cttlmeaning.external_key) as taxa_taxon_list_external_key,
  extract(doy from cast('2012' || vrstart.value as date)) as start_date,
  extract(doy from cast('2012' || vrend.value as date)) as end_date,
  vrmsurvey.value::integer as survey_id,
  string_to_array(lower(vrdstage.value), ',') as stages,
  vr.error_message
from verification_rules vr
left join verification_rule_metadata vrmkey on vrmkey.verification_rule_id=vr.id
  and vrmkey.key ilike 'Tvk' and vrmkey.deleted=false
left join verification_rule_metadata vrmtaxon on vrmtaxon.verification_rule_id=vr.id
  and vrmtaxon.key='Taxon' and vrmtaxon.deleted=false
left join cache_taxa_taxon_lists cttltaxon on cttltaxon.taxon=vrmtaxon.value and cttltaxon.preferred=true
left join verification_rule_metadata vrmmeaning on vrmmeaning.verification_rule_id=vr.id
  and vrmmeaning.key='TaxonMeaningId' and vrmmeaning.deleted=false
left join cache_taxa_taxon_lists cttlmeaning on cttltaxon.taxon_meaning_id=vrmmeaning.value::integer and cttlmeaning.preferred=true
join verification_rule_data vrdstage on vrdstage.verification_rule_id=vr.id and vrdstage.key ilike 'Stage'
left join verification_rule_data vrstart on vrstart.verification_rule_id=vr.id and vrstart.key ilike 'StartDate' and length(vrstart.value)=4
  and vrstart.deleted=false
left join verification_rule_data vrend on vrend.verification_rule_id=vr.id and vrend.key ilike 'EndDate' and length(vrend.value)=4
  and vrend.deleted=false
left join verification_rule_data vrmsurvey on vrmsurvey.verification_rule_id=vr.id and vrmsurvey.key='SurveyId' and vrmsurvey.deleted=false
where vr.test_type='PeriodWithinYear'
  and vr.deleted=false
  and (vrstart.id is not null or vrend.id is not null);

truncate cache_verification_rules_period_within_year;
insert into cache_verification_rules_period_within_year
  select * from cache_verification_rules_period_within_year2;
drop table cache_verification_rules_period_within_year2;
