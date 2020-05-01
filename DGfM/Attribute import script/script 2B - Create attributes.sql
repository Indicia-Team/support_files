--To run this code, you will need to do replacements of,
--<taxon_list_id>
--<restrict_to_survey_id>
--<dgfm_website_id>
set search_path TO indicia, public;

-- Next: need to insert the attributes themselves
DO
$do$
declare attribute_to_import RECORD;
declare other_language_caption text;
declare attribute_name_to_use text;
declare attribute_description_to_use text;
declare optional_second_attribute_name_to_use text;
declare reporting_category_id_to_use integer;
declare data_type_to_use text;
declare allow_ranges_to_use boolean;
declare termlist_id_to_use integer;
BEGIN 

-- Cycle through each row again
FOR attribute_to_import IN (
  select
    dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area,
    dta.gb_area as gb_attribute_area, dta.gb_sub_area as gb_attribute_sub_area,
    dta.deu_area as cz_attribute_area, dta.cz_sub_area as cz_attribute_sub_area,
    dta.deu_attribute as deu_attribute_full_name,
    -- Make sure attribute fits in the attribute name column
    -- AVB make sure this is unique (it is possible first 50 characters are not unique with an area, sub area, prob ok though)- Double check
    LEFT(TRIM(BOTH from dta.deu_attribute),50) 
    --LEFT(TRIM(BOTH from substring(substring(dta.deu_attribute,'^[^(]+'),'^[^[]+')),50) 
    as deu_attribute_name_shortened, 
    LEFT(TRIM(BOTH from dta.gb_attribute),50) 
    --LEFT(TRIM(BOTH from substring(substring(dta.gb_attribute,'^[^(]+'),'^[^[]+')),50) 
    as gb_attribute_name_shortened, 
    LEFT(TRIM(BOTH from dta.cz_attribute),50) 
    --LEFT(TRIM(BOTH from substring(substring(dta.cz_attribute,'^[^(]+'),'^[^[]+')),50) 
    as cz_attribute_name_shortened, 
    dta.deu_type,
    dta.multi_value,
    dta.deu_type as attribute_data_type, 
    dta.colour_attribute_description as colour_attribute_description,
    LEFT(TRIM(BOTH from dta.deu_attribute),50)  as termlist_name,
    --LEFT(TRIM(BOTH from substring(substring(dta.deu_attribute,'^[^(]+'),'^[^[]+')),40) as termlist_name_short_for_external_key,
    row_num
  from dgfm.tbl_attributes dta) 
loop
  -- Collect the sub-area termlist_term id for this row
  reporting_category_id_to_use := 
      (select tt.id
      from termlists_terms tt 
      join terms t on t.id = tt.term_id AND term = attribute_to_import.deu_attribute_sub_area AND t.deleted=false
      join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
      join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = LEFT(TRIM(BOTH from attribute_to_import.deu_attribute_area),200) AND t_parent_area.deleted=false
      where tt.deleted=false
      ORDER BY tt.id desc LIMIT 1);  

  --This needs to be before exists statement, as we update existing attributes, and those are outside the loop
  attribute_name_to_use := attribute_to_import.deu_attribute_name_shortened;
  other_language_caption='{';
  IF (attribute_to_import.gb_attribute_name_shortened != 'null') THEN
    other_language_caption=other_language_caption || '"eng":"' || attribute_to_import.gb_attribute_name_shortened || '"';
  ELSE
  END IF;

  IF (attribute_to_import.cz_attribute_name_shortened != 'null') THEN
    IF (other_language_caption != '{') THEN
      other_language_caption=other_language_caption || ',';
    ELSE
    END IF;
    other_language_caption = other_language_caption || '"cze":"' || attribute_to_import.cz_attribute_name_shortened || '"';
  ELSE
  END IF;
  other_language_caption=other_language_caption || '}';

  -- Update any existing attributes that have changed, AVB need to do other fields, not just langauge
  update indicia.taxa_taxon_list_attributes
  set caption_i18n=other_language_caption::jsonb
  where id in (
    select ttla.id
    from taxa_taxon_list_attributes ttla
    join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id>
    where ttla.caption=attribute_name_to_use and ttla.reporting_category_id = reporting_category_id_to_use
    AND ttla.deleted=false);

  update indicia.occurrence_attributes
  set caption_i18n=other_language_caption::jsonb
  where id in (
    select oa.id
    from occurrence_attributes oa
    join occurrence_attributes_websites oaw on oaw.occurrence_attribute_id = oa.id AND oaw.website_id=<dgfm_website_id>
    where oa.caption=attribute_name_to_use and oa.reporting_category_id = reporting_category_id_to_use
    AND oa.deleted=false);


  -- Create new attributes
  IF (NOT EXISTS (
    select ttla.id
    from taxa_taxon_list_attributes ttla
    join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
    where ttla.caption=attribute_to_import.deu_attribute_name_shortened and ttla.deleted=false 
    -- Check the Area/Sub area combination for the attribute just to make sure it is definetely same one
    AND reporting_category_id = reporting_category_id_to_use
    order by id desc limit 1
  ))
  THEN
    --IMPORTANT NOTE, THIS IS VALID CODE but we have already imported these specific ranges, so I have commented it out for now.
    -- Also the language bits probably need updating to match rest of script, the language json will be wrong.
    /*if ((attribute_to_import.gb_area = 'Micro description'AND attribute_to_import.gb_sub_area='spore packages' AND attribute_to_import.gb_attribute like '%width%') OR
        (attribute_to_import.gb_area = 'Micro description' AND attribute_to_import.gb_sub_area='spore packages' AND attribute_to_import.gb_attribute like '%length%') OR
        (attribute_to_import.gb_area = 'macro description' AND attribute_to_import.gb_sub_area = 'Fruitbody' AND attribute_to_import.gb_attribute like '%width%') OR
        (attribute_to_import.gb_area = 'macro description' AND attribute_to_import.gb_sub_area = 'Fruitbody' AND attribute_to_import.gb_attribute like '%length%')) THEN
      attribute_name_to_use := attribute_to_import.deu_attribute_name_shortened || ' (95%)';
      --AVB, the way this is built is new and needs testing
      other_language_caption_jsonb := string_to_array('', ':');
      IF (attribute_to_import.gb_attribute_name_shortened != 'null') THEN
        other_language_caption_jsonb = array_append(other_language_caption_jsonb,'{' || attribute_to_import.gb_attribute_name_shortened || ' (95%)' || '|eng' || '}');
      ELSE
      END IF;
      IF (attribute_to_import.cz_attribute_name_shortened != 'null') THEN
         other_language_caption_jsonb = array_append(other_language_caption_jsonb,'{' || attribute_to_import.cz_attribute_name_shortened || ' (95%)' || '|cze' || '}');
      ELSE
      END IF;

      optional_second_attribute_name_to_use := attribute_to_import.deu_attribute_name_shortened || ' (80%)';
      IF (attribute_to_import.gb_attribute_name_shortened != 'null') THEN
        optional_second_other_language_caption_jsonb := array_append(optional_second_other_language_caption_jsonb,'{' || attribute_to_import.gb_attribute_name_shortened || ' (80%)' || '|eng' || '}');
      ELSE
      END IF;
      IF (attribute_to_import.cz_attribute_name_shortened != 'null') THEN
        optional_second_other_language_caption_jsonb := array_append(optional_second_other_language_caption_jsonb,'{' || attribute_to_import.cz_attribute_name_shortened || ' (80%)' || '|cze' || '}');
      ELSE
      END IF;


      allow_ranges_to_use := true;
    ELSE*/
    allow_ranges_to_use := false;
    --END IF;
    if (attribute_to_import.attribute_data_type not in ('T', 'I', 'F', 'D', 'V', 'B')
        OR attribute_to_import.colour_attribute_description = ('discrete colour selector')) THEN
       data_type_to_use = 'L';
       -- AVB changed this as some of the termlist_ids were empty
       termlist_id_to_use := (
       select id 
       from termlists  
       where description = 'Termlist for ' || attribute_to_import.deu_attribute_area || '/' || attribute_to_import.deu_attribute_sub_area || '/' || attribute_to_import.termlist_name
       AND deleted=false AND website_id = <dgfm_website_id> order by id desc Limit 1);
       --termlist_id_to_use := (select id from termlists where title=attribute_name_to_use AND deleted=false AND website_id = 2 order by id desc Limit 1);
    ELSE 
      data_type_to_use = attribute_to_import.attribute_data_type;
      termlist_id_to_use := null;
    END IF;  
    if attribute_to_import.colour_attribute_description in ('free colour wheel', 'discrete colour selector') THEN
      attribute_description_to_use := attribute_to_import.colour_attribute_description;
    ELSE
      attribute_description_to_use := null;
    END IF;

    insert into taxa_taxon_list_attributes (caption,caption_i18n,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id, multi_value,reporting_category_id,allow_ranges)
    values (attribute_name_to_use,other_language_caption::jsonb,attribute_description_to_use,data_type_to_use,now(),1,now(),1,termlist_id_to_use, attribute_to_import.multi_value,reporting_category_id_to_use,allow_ranges_to_use);
 
     insert into taxon_lists_taxa_taxon_list_attributes (taxa_taxon_list_attribute_id,taxon_list_id,created_on,created_by_id)
      select ttla.id,<taxon_list_id>,now(),1
      from taxa_taxon_list_attributes ttla
      where ttla.caption=attribute_name_to_use
      AND ttla.deleted=false
      ORDER BY ttla.id DESC 
      LIMIT 1;
   
    --Create identical occurrence_attribute apart from allow_ranges and multi_value is always false
    -- AVB this needs testing occ _attr needs 95% chopped, noting unless the 95% is present this won't do anything
    insert into occurrence_attributes (caption,caption_i18n,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id, multi_value,reporting_category_id,allow_ranges)
    values (replace(replace(attribute_name_to_use, ' (80%)', ''), ' (95%)',''),other_language_caption::jsonb,attribute_description_to_use,data_type_to_use,now(),1,now(),1,termlist_id_to_use, false,reporting_category_id_to_use,false);

    insert into occurrence_attributes_websites (occurrence_attribute_id,website_id,restrict_to_survey_id,created_on,created_by_id)
      select oa.id,<dgfm_website_id>,<restrict_to_survey_id>,now(),1
      from occurrence_attributes oa
      where oa.caption=attribute_name_to_use
      ORDER BY id DESC 
      LIMIT 1;

    -- Clone an occurrence attribute for the new taxon attribut
    -- This is automatically done by the system
    insert into occurrence_attributes_taxa_taxon_list_attributes (occurrence_attribute_id,taxa_taxon_list_attribute_id,restrict_occurrence_attribute_to_single_value,validate_occurrence_attribute_values_against_taxon_values,created_on,created_by_id,updated_on,updated_by_id)
    values(
      (select oa.id
      from occurrence_attributes oa
      where oa.caption=replace(attribute_name_to_use, ' (95%)', '') AND oa.deleted=false
      ORDER BY oa.id DESC 
      LIMIT 1),
      (select ttla.id
      from taxa_taxon_list_attributes ttla
      join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id=ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
      where ttla.caption=attribute_name_to_use AND ttla.deleted=false
      ORDER BY ttla.id DESC 
      LIMIT 1),
      't',
      't',
      now(),
      1,
      now(),
      1
    );

    -- IMPORTANT - Again this was used for the specific ranged attributes. However we don't need this at the moment as those attributes have already been imported.
    -- DO same for the 80% attribute
    /*if (optional_second_attribute_name_to_use != '') THEN
      --AVB - NOTe there is no linked between the two ranged attributes, it is just the name that allows john's reports to know
      insert into taxa_taxon_list_attributes (caption,caption_i18n,description,data_type,created_on,created_by_id,updated_on,updated_by_id, allow_ranges,reporting_category_id)
      values (optional_second_attribute_name_to_use,array_to_json(optional_second_other_language_caption_jsonb)::jsonb,attribute_description_to_use,data_type_to_use,now(),1,now(),1,true,reporting_category_id_to_use);

      insert into taxon_lists_taxa_taxon_list_attributes (taxa_taxon_list_attribute_id,taxon_list_id,created_on,created_by_id)
        select ttla.id,<taxon_list_id>,now(),1
        from taxa_taxon_list_attributes ttla
        where ttla.caption=optional_second_attribute_name_to_use
        AND ttla.deleted=false
        ORDER BY ttla.id DESC 
        LIMIT 1;
      
    ELSE
    END IF;*/
    --AVB I don't think this needs to be inside the loop
    update taxon_lists_taxa_taxon_list_attributes
    set control_type_id=(select id from control_types where "control" = 'checkbox_group')
    where
    taxa_taxon_list_attribute_id in (select id from taxa_taxon_list_attributes where data_type='L' AND multi_value=true)
    AND
    id in (select id from taxon_lists_taxa_taxon_list_attributes where taxon_list_id = 1 AND deleted=false);

    other_language_caption := null;
    attribute_name_to_use := null;
    optional_second_attribute_name_to_use := null;
  END IF;

END LOOP;
END
$do$;


