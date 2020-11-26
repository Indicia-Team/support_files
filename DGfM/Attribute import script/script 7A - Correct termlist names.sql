set search_path TO indicia, public;
-- First cycle through each row and insert termlist with terms
DO
$do$
declare termlist_to_import RECORD;
DECLARE eng_terms_for_termlist text[];
DECLARE deu_terms_for_termlist text[];
DECLARE cze_terms_for_termlist text[];
DECLARE term_position_counter integer;
DECLARE deu_term_to_insert text;
BEGIN 
FOR termlist_to_import IN 
  -- The termlist name needs to be shortend to same length as attribute, so attribute knows termlist that is associated with it
  (select LEFT(TRIM(BOTH from dta.deu_attribute),50)  as deu_attribute, dta.deu_type as deu_terms_to_import,  dta.deu_area as deu_attr_area, dta.deu_sub_area as deu_attr_sub_area, dta.gb_type as gb_terms_to_import, dta.cz_type as cz_terms_to_import,
      -- Need the short version of the termlist name for use in the external key, take all characters before bracket or square bracket, then limit to 40
      dta.row_num as row_num, LEFT(TRIM(BOTH from substring(substring(dta.deu_attribute,'^[^(]+'),'^[^[]+')),40) as termlist_name_short_for_external_key
    from dgfm.tbl_attributes dta
  ) 
LOOP
update termlists
set title = 
LEFT(TRIM(BOTH from termlist_to_import.deu_attr_area),33) || '/' || LEFT(TRIM(BOTH from termlist_to_import.deu_attr_sub_area),33) || '/' || LEFT(TRIM(BOTH from termlist_to_import.deu_attribute),33)
where description = 'Termlist for ' || termlist_to_import.deu_attr_area || '/' || termlist_to_import.deu_attr_sub_area || '/' || termlist_to_import.deu_attribute;
END LOOP;
END
$do$;