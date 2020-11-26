-- Note: Ranged attributes need names updated manually
-- Import extra attributes to hold freetext for the freetext option in termlists
--<dgfm_taxon_list_id>
--<dgfm_website_id>
--<dgfm_survey_id>

--Note: Import file can contain all characters, the importer will ignore rows which do not require freetext.

-- Allocate the new attributes to sets
set search_path TO indicia, public;

--Create the attributes

-- Next: need to insert the attributes themselves
DO
$do$
declare attribute_to_import RECORD;
declare other_language_caption text;
declare deu_freetext_attribute_name text;
declare gb_freetext_attribute_name text;
declare cz_freetext_attribute_name text;
declare attribute_description_to_use text;
declare reporting_category_id_to_use integer;
declare allow_ranges_to_use boolean;
BEGIN 

-- Cycle through each row again
FOR attribute_to_import IN (
  select
    dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area,
    dta.gb_area as gb_attribute_area, dta.gb_sub_area as gb_attribute_sub_area,
    dta.deu_area as cz_attribute_area, dta.cz_sub_area as cz_attribute_sub_area,
    dta.deu_attribute as deu_attribute_main_attr_name,
    dta.deu_type,
    dta.deu_type as attribute_data_type, 
    dta.colour_attribute_description as colour_attribute_description,
    row_num
  from dgfm.tbl_attributes dta) 
loop
  deu_freetext_attribute_name := 'Kommentar';
  gb_freetext_attribute_name := 'Comment';
  cz_freetext_attribute_name := 'Komentář';
  attribute_description_to_use = 'Kommentar für ' || attribute_to_import.deu_attribute_area || '/' || attribute_to_import.deu_attribute_sub_area || '/' || attribute_to_import.deu_attribute_main_attr_name;
  
  other_language_caption='{';
  IF (gb_freetext_attribute_name != 'null') THEN
    other_language_caption=other_language_caption || '"eng":"' || gb_freetext_attribute_name || '"';
  ELSE
  END IF;
  IF (cz_freetext_attribute_name != 'null') THEN
    IF (other_language_caption != '{') THEN
      other_language_caption=other_language_caption || ',';
    ELSE
    END IF;
    other_language_caption = other_language_caption || '"cze":"' || cz_freetext_attribute_name || '"';
  ELSE
  END IF;
  other_language_caption=other_language_caption || '}';  -- Collect the sub-area termlist_term id for this row

  reporting_category_id_to_use := 
      (select tt.id
      from termlists_terms tt 
      join terms t on t.id = tt.term_id AND term = attribute_to_import.deu_attribute_sub_area AND t.deleted=false
      join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
      join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = LEFT(TRIM(BOTH from attribute_to_import.deu_attribute_area),200) AND t_parent_area.deleted=false
      where tt.deleted=false
      ORDER BY tt.id desc LIMIT 1);  
  -- Fistly check if attributes already exists (only need to check German as other names are synonyms)
  IF (NOT EXISTS (
    select ttla.id
    from taxa_taxon_list_attributes ttla
    join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
    --Use description field here to match, as the comment fields all have the same name.
    where ttla.description=attribute_description_to_use
    AND ttla.deleted=false
    -- Check the Area/Sub area combination for the attribute just to make sure it is definetely same one
    AND reporting_category_id = reporting_category_id_to_use
    order by id desc limit 1
  ))
  THEN

    allow_ranges_to_use := false;
    -- AVB must only be for fields that include the word freetext
    if (
       ((attribute_to_import.attribute_data_type not in ('T', 'I', 'F', 'D', 'V', 'B')
        OR attribute_to_import.colour_attribute_description = 'discrete colour selector')
        --Only Process termlists that include the word freetext (in German)
        AND lower(attribute_to_import.attribute_data_type) like '%freitext%')
        -- Need Comment fields for colour wheels also
        OR attribute_to_import.colour_attribute_description = 'free colour wheel')  THEN
    
      insert into taxa_taxon_list_attributes (caption,caption_i18n,description,data_type,created_on,created_by_id,updated_on,updated_by_id,reporting_category_id)
      values (deu_freetext_attribute_name, other_language_caption::jsonb,attribute_description_to_use,'T',now(),1,now(),1,reporting_category_id_to_use);
  
      insert into taxon_lists_taxa_taxon_list_attributes (taxa_taxon_list_attribute_id,taxon_list_id,created_on,created_by_id)
        select ttla.id,<dgfm_taxon_list_id>,now(),1
        from taxa_taxon_list_attributes ttla
        --Use description field here to match, as the comment fields all have the same name.
        where ttla.description=attribute_description_to_use
        AND ttla.deleted=false
        ORDER BY ttla.id DESC 
        LIMIT 1;
    
      insert into occurrence_attributes (caption,caption_i18n,description,data_type,created_on,created_by_id,updated_on,updated_by_id,reporting_category_id)
      values (deu_freetext_attribute_name, other_language_caption::jsonb,attribute_description_to_use,'T',now(),1,now(),1,reporting_category_id_to_use);

      insert into occurrence_attributes_websites (occurrence_attribute_id,website_id,restrict_to_survey_id,created_on,created_by_id)
        select oa.id,<dgfm_website_id>,<dgfm_survey_id>,now(),1
        from occurrence_attributes oa
        --Use description field here to match, as the comment fields all have the same name.
        where oa.description=attribute_description_to_use
        ORDER BY id DESC 
        LIMIT 1;

      -- Clone an occurrence attribute for the new taxon attribut
      -- This is automatically done by the system
      insert into occurrence_attributes_taxa_taxon_list_attributes (occurrence_attribute_id,taxa_taxon_list_attribute_id,restrict_occurrence_attribute_to_single_value,validate_occurrence_attribute_values_against_taxon_values,created_on,created_by_id,updated_on,updated_by_id)
      values(
        (select oa.id
        from occurrence_attributes oa
        --Use description field here to match, as the comment fields all have the same name.
        where oa.description=attribute_description_to_use AND oa.deleted=false
        ORDER BY oa.id DESC 
        LIMIT 1),
        (select ttla.id
        from taxa_taxon_list_attributes ttla
        join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id=ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
        --Use description field here to match, as the comment fields all have the same name.
        where ttla.description=attribute_description_to_use
        AND ttla.deleted=false
        ORDER BY ttla.id DESC 
        LIMIT 1),
        't',
        't',
        now(),
        1,
        now(),
        1
      );

      other_language_caption := null;
      deu_freetext_attribute_name := null;
    ELSE
    END IF;
  END IF;
END LOOP;
END
$do$;

update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list=replace(attribute_set_allocation_list, '::', ':0:');
--It is deliberate that this is done twice
update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list=replace(attribute_set_allocation_list, '::', ':0:');

update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list= '0' || attribute_set_allocation_list
where LEFT(attribute_set_allocation_list, 1) = ':';

update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list= attribute_set_allocation_list || '0'
where RIGHT(attribute_set_allocation_list, 1) = ':';

DO
$do$
declare attribute_set_allocation_to_import RECORD;
declare attribute_set_allocation_list_array text[];
declare attribute_set_names_array text[];
declare idx integer;
declare attribute_set_allocation_list integer;
declare attribute_description_to_use text;

BEGIN 
select string_to_array((select attribute_sets from dgfm.tbl_attribute_sets), ':') into attribute_set_names_array;
FOR attribute_set_allocation_to_import IN 
(
select dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area,
dta.deu_attribute as deu_attribute_main_attr_name,
LEFT(TRIM(BOTH from dta.deu_attribute),50) as deu_freetext_attribute_name, 
dta.attribute_set_allocation_list
from dgfm.tbl_attribute_set_allocations dta
) loop
  attribute_description_to_use = 'Kommentar für ' || attribute_set_allocation_to_import.deu_attribute_area || '/' || attribute_set_allocation_to_import.deu_attribute_sub_area || '/' || attribute_set_allocation_to_import.deu_attribute_main_attr_name;
  select string_to_array(attribute_set_allocation_to_import.attribute_set_allocation_list, ':') into attribute_set_allocation_list_array;
  idx := 1;
  FOREACH attribute_set_allocation_list IN ARRAY attribute_set_allocation_list_array LOOP
    if (attribute_set_allocation_list='1') THEN
      IF (EXISTS (
        select ttla.id 
        from taxa_taxon_list_attributes ttla
        join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
        where 
        ttla.description=attribute_description_to_use
        AND ttla.deleted=false 
        AND reporting_category_id in (
          select tt.id
          from termlists_terms tt 
          join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
          join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
          join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
          where tt.deleted=false  
          ORDER BY ID desc limit 1
        )
        order by ttla.id desc limit 1)
      AND
        NOT EXISTS(
          select id
          from indicia.attribute_sets_taxa_taxon_list_attributes asttla
          where 
            asttla.attribute_set_id =
              (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1)
          AND
            asttla.taxa_taxon_list_attribute_id =
              (
                select ttla.id 
                from taxa_taxon_list_attributes ttla
                join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
                where 
                ttla.description=attribute_description_to_use
                AND ttla.deleted=false 
                AND reporting_category_id in (
                  select tt.id
                  from termlists_terms tt 
                  join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                  join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                  join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                  where tt.deleted=false  
                  ORDER BY ID desc limit 1
                )
                order by ttla.id desc limit 1
              )
          AND
            asttla.deleted=false
          )
        )
      THEN
        insert into
        indicia.attribute_sets_taxa_taxon_list_attributes
        (
            attribute_set_id,
            taxa_taxon_list_attribute_id,
            created_by_id,
            created_on,
            updated_by_id,
            updated_on
        )
        values (
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1),
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
              where 
              ttla.description=attribute_description_to_use
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            ),
            1,
            now(),
            1,
            now()
        );
      ELSE
      END IF;
    ELSE
    END IF;   
    idx := idx + 1;
  END LOOP;
END LOOP;
END
$do$;


DO
$do$
declare attribute_set_allocation_to_import RECORD;
declare attribute_set_allocation_list_array text[];
declare attribute_set_names_array text[];
declare idx integer;
declare attribute_set_allocation_list integer;
declare attribute_description_to_use text;

BEGIN 
select string_to_array((select attribute_sets from dgfm.tbl_attribute_sets), ':') into attribute_set_names_array;
FOR attribute_set_allocation_to_import IN 
(
select dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area, dta.deu_attribute as attribute_name,
LEFT(TRIM(BOTH from dta.deu_attribute),50) as deu_attribute_name_shortened, 
dta.attribute_set_allocation_list
from dgfm.tbl_attribute_set_allocations dta
) loop
  attribute_description_to_use = 'Kommentar für ' || attribute_set_allocation_to_import.deu_attribute_area || '/' || attribute_set_allocation_to_import.deu_attribute_sub_area || '/' || attribute_set_allocation_to_import.attribute_name;
  select string_to_array(attribute_set_allocation_to_import.attribute_set_allocation_list, ':') into attribute_set_allocation_list_array;
  idx := 1;
  FOREACH attribute_set_allocation_list IN ARRAY attribute_set_allocation_list_array LOOP
    if (attribute_set_allocation_list = '0') THEN
      IF 
        (EXISTS(
        select id
        from indicia.attribute_sets_taxa_taxon_list_attributes asttla
        where 
          asttla.attribute_set_id =
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1)
        AND
          asttla.taxa_taxon_list_attribute_id =
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
              where 
              ttla.description=attribute_description_to_use
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            )
        AND
          asttla.deleted=false
        ))
      THEN
        update indicia.attribute_sets_taxa_taxon_list_attributes
        set deleted=true
        where id in 
        (
          select id
          from indicia.attribute_sets_taxa_taxon_list_attributes asttla
          where 
            asttla.attribute_set_id =
              (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1)
          AND
            asttla.taxa_taxon_list_attribute_id =
              (
                select ttla.id 
                from taxa_taxon_list_attributes ttla
                join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
                where 
                ttla.description=attribute_description_to_use
                AND ttla.deleted=false 
                AND reporting_category_id in (
                  select tt.id
                  from termlists_terms tt 
                  join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                  join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                  join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                  where tt.deleted=false  
                  ORDER BY ID desc limit 1
                )
                order by ttla.id desc limit 1
              )
          AND
            asttla.deleted=false
        );
      ELSE
      END IF;

      /* This code only refers to the ranged attributes with (95%) or (80%). Commented out as we don't need this running unless these exist.
         NOTE: this might need further testing as it won't have been run many times */

      /*IF (EXISTS (
        select ttla.id 
          from taxa_taxon_list_attributes ttla
          join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
          where ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (95%)' 
          AND ttla.deleted=false 
          AND reporting_category_id in (
            select tt.id
            from termlists_terms tt 
            join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
            join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
            join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
            where tt.deleted=false  
            ORDER BY ID desc limit 1
          )
          order by ttla.id desc limit 1))
      THEN
       insert into
        indicia.attribute_sets_taxa_taxon_list_attributes
        (
            attribute_set_id,
            taxa_taxon_list_attribute_id,
            created_by_id,
            created_on,
            updated_by_id,
            updated_on
        )
        values (
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1),
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
              where ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (95%)' 
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            ),
            1,
            now(),
            1,
            now()
        );
      ELSE
      END IF;

      IF (EXISTS (
        select ttla.id 
        from taxa_taxon_list_attributes ttla
        join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
        where 
        (ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (80%)')
        AND ttla.deleted=false 
        AND reporting_category_id in (
          select tt.id
          from termlists_terms tt 
          join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
          join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
          join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
          where tt.deleted=false  
          ORDER BY ID desc limit 1
        )
        order by ttla.id desc limit 1))
      THEN
        insert into
        indicia.attribute_sets_taxa_taxon_list_attributes
        (
            attribute_set_id,
            taxa_taxon_list_attribute_id,
            created_by_id,
            created_on,
            updated_by_id,
            updated_on
        )
        values (
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1),
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<dgfm_taxon_list_id> AND tlttla.deleted=false
              where 
              (ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (80%)')
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            ),
            1,
            now(),
            1,
            now()
        );
      ELSE
      END IF;*/
    ELSE
    END IF;   
    idx := idx + 1;
  END LOOP;
END LOOP;
END
$do$;