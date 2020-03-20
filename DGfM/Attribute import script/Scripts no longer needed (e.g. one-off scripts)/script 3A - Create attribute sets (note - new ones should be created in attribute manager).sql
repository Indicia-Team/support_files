--Replace the following tag before running script
--<dgfm_survey_id>
--<dgfm_taxon_list_id>
--<dgfm_website_id>
set search_path TO indicia, public;

DO
$do$
DECLARE rows_to_import RECORD;
DECLARE attribute_set_list_array text[];
DECLARE attribute_set text;
BEGIN

select string_to_array(tas.attribute_sets, ':') into attribute_set_list_array
from dgfm.tbl_attribute_sets tas;

FOREACH attribute_set IN ARRAY attribute_set_list_array LOOP
  IF (NOT EXISTS (
    select ias.id
    from indicia.attribute_sets ias
    join attribute_sets_surveys ass on ass.attribute_set_id=ias.id AND ass.survey_id=<dgfm_survey_id> AND ass.deleted=false
    where ias.title = trim(attribute_set) AND ias.deleted=false))
  THEN
    insert into indicia.attribute_sets (
      title,
      description,
      website_id,
      taxon_list_id,
      created_by_id,
      created_on,
      updated_by_id,
      updated_on
    )
    values (
      trim(attribute_set),
      'DGFM attribute set ' || trim(attribute_set),
      <dgfm_website_id>,
      <dgfm_taxon_list_id>,
      1,
      now(),
      1,
      now()
    );

    insert into indicia.attribute_sets_surveys (
      attribute_set_id,
      survey_id,
      created_by_id,
      created_on,
      updated_by_id,
      updated_on
    )
    values (
      (select id from indicia.attribute_sets where title = trim(attribute_set) order by id desc LIMIT 1),
      <dgfm_survey_id>,
      1,
      now(),
      1,
      now()
    );
  ELSE 
  END IF;
END LOOP;
END
$do$;
