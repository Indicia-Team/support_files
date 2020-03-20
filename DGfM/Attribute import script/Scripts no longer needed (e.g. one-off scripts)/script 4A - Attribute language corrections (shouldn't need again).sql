-- Note: Ranged attributes need names updated manually
-- This script replaces the incorrect languages format in the caption_i18_n fields that are imported by previous scripts

--To run this code, you will need to do replacements of,
--<dgfm_taxon_list_id>
-- <min_ttl_attr_id_to_process>
-- <min_occ_attr_id_to_process>
-- (This will allow you to process new attributes without having to risk re-processing all existing attributes or run the script on irrelevant attributes)

set search_path TO indicia, public;

-- Next: need to insert the attributes themselves
DO
$do$
declare attribute_to_import RECORD;
declare other_language_caption text;
declare other_language_caption_jsonb text[];
declare attribute_name_to_use text;
declare attribute_description_to_use text;
declare optional_second_attribute_name_to_use text;
declare optional_second_other_language_caption_jsonb text[];
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
    LEFT(TRIM(BOTH from dta.deu_attribute),50) 
    as deu_attribute_name_shortened, 
    LEFT(TRIM(BOTH from dta.gb_attribute),50) 
    as gb_attribute_name_shortened, 
    LEFT(TRIM(BOTH from dta.cz_attribute),50) 
    as cz_attribute_name_shortened, 
    dta.deu_type,
    dta.multi_value,
    dta.deu_type as attribute_data_type, 
    dta.colour_attribute_description as colour_attribute_description,
    LEFT(TRIM(BOTH from substring(substring(dta.deu_attribute,'^[^(]+'),'^[^[]+')),40) as termlist_name_short_for_external_key,
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

      attribute_name_to_use := attribute_to_import.deu_attribute_name_shortened;
      other_language_caption_jsonb := string_to_array('', ':');
      other_language_caption='{' || '"eng":"' || attribute_to_import.gb_attribute_name_shortened  || '","cze":"' || attribute_to_import.cz_attribute_name_shortened  || '"}';

      update taxa_taxon_list_attributes
      set caption_i18n = other_language_caption::jsonb
      where caption = attribute_name_to_use and reporting_category_id = reporting_category_id_to_use
      and id in
      (select taxa_taxon_list_attribute_id from taxon_lists_taxa_taxon_list_attributes where taxon_list_id = <dgfm_taxon_list_id>)
      AND id > <min_ttl_attr_id_to_process>;

      update occurrence_attributes
      set caption_i18n = other_language_caption::jsonb
      where caption = attribute_name_to_use and reporting_category_id = reporting_category_id_to_use and id > <min_occ_attr_id_to_process>;


    attribute_name_to_use := null;
END LOOP;
END
$do$;


