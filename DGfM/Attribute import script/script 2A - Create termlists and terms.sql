-- IMPORTANT: This script does not replace terms in termlists where the term has previously been manually deleted.
-- However if a synonym has been deleted it will be reinstated.
--To run this code, you will need to do replacements of,
--<dgfm_website_id>
--<create_freetext_fields>
set search_path TO indicia, public;
-- First cycle through each row and insert termlist with terms
DO
$do$
declare termlist_to_import RECORD;
DECLARE eng_terms_for_termlist text[];
DECLARE deu_terms_for_termlist text[];
DECLARE cze_terms_for_termlist text[];
DECLARE term_position_counter integer;
DECLARE termlist_id_to_insert_into integer;
DECLARE termlist_external_key_to_insert_into text;
DECLARE deu_term_to_insert text;
BEGIN 
FOR termlist_to_import IN 
  -- The termlist name needs to be shortend to same length as attribute, so attribute knows termlist that is associated with it
  -- AVB Might be better to use a external key for attributes to check termlists - Non-critical
  (select LEFT(TRIM(BOTH from dta.deu_attribute),50)  as termlist_name, dta.deu_type as deu_terms_to_import,  dta.deu_area as deu_attr_area, dta.deu_sub_area as deu_attr_sub_area, dta.gb_type as gb_terms_to_import, dta.cz_type as cz_terms_to_import,
      -- Need the short version of the termlist name for use in the external key, take all characters before bracket or square bracket, then limit to 40
      dta.row_num as row_num, LEFT(TRIM(BOTH from substring(substring(dta.deu_attribute,'^[^(]+'),'^[^[]+')),40) as termlist_name_short_for_external_key
    from dgfm.tbl_attributes dta
  ) 
LOOP
  -- First check termlist doesn't already exist, note as the termlist not seen by the user, it isn't multi-lingual
  IF (NOT EXISTS (
    select tl.id
    from indicia.termlists tl
    -- Termlist must have row_num in external key to make sure it is unique (AVB use description as later spreadsheets have different row order)
    --where tl.external_key = 'dgfm:' || termlist_to_import.termlist_name_short_for_external_key || '/' || termlist_to_import.row_num 
    where tl.description = 'Termlist for ' || termlist_to_import.deu_attr_area || '/' || termlist_to_import.deu_attr_sub_area || '/' || termlist_to_import.termlist_name
    AND tl.website_id=<dgfm_website_id>
    AND tl.deleted=false
    ORDER BY tl.id desc
    LIMIT 1
  )
  --Make sure we don't add termlists for non-lookup lists
  AND termlist_to_import.deu_terms_to_import not in ('T', 'I', 'F', 'D', 'V', 'B')
  AND termlist_to_import.gb_terms_to_import not in ('free colour wheel', 'discrete colour selector'))
  THEN
    -- Insert the termlist if we don't find it
    insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
    values (
      termlist_to_import.deu_attr_area || '/' || termlist_to_import.deu_attr_sub_area || '/' || termlist_to_import.termlist_name, 
      'Termlist for ' || termlist_to_import.deu_attr_area || '/' || termlist_to_import.deu_attr_sub_area || '/' || termlist_to_import.termlist_name,
      <dgfm_website_id>,
      now(),
      1,
      now(),
      1,
      null
    );
  ELSE
  END IF;

  termlist_id_to_insert_into := (
    select tl.id
    from indicia.termlists tl
    -- Termlist must have row_num in external key to make sure it is unique (AVB use description as later spreadsheets have different row order)
    --where tl.external_key = 'dgfm:' || termlist_to_import.termlist_name_short_for_external_key || '/' || termlist_to_import.row_num 
    where tl.description = 'Termlist for ' || termlist_to_import.deu_attr_area || '/' || termlist_to_import.deu_attr_sub_area || '/' || termlist_to_import.termlist_name
    AND tl.website_id=<dgfm_website_id>
    AND tl.deleted=false
    ORDER BY tl.id desc
    LIMIT 1
  );

  update indicia.termlists
  set external_key = 'dgfm:' || cast(termlist_id_to_insert_into as text)
  where id = termlist_id_to_insert_into;
  
    deu_terms_for_termlist := regexp_split_to_array(termlist_to_import.deu_terms_to_import,'[,]+');
    eng_terms_for_termlist := regexp_split_to_array(termlist_to_import.gb_terms_to_import,'[,]+');
    cze_terms_for_termlist := regexp_split_to_array(termlist_to_import.cz_terms_to_import,'[,]+');

    term_position_counter := 1;
    FOREACH deu_term_to_insert IN ARRAY deu_terms_for_termlist LOOP
      IF (trim(BOTH from lower(deu_term_to_insert)) != 'freitext' OR <create_freetext_fields>=true) THEN
        -- Important, as the termlist name is not multi-linguage, we always reference the termlist external key as the german name
        IF (NOT EXISTS (
          select tl.id
          from indicia.termlists tl
          JOIN indicia.termlists_terms tt on tt.termlist_id = tl.id AND tl.id=termlist_id_to_insert_into AND tt.deleted=false
          JOIN terms t on t.id = tt.term_id AND t.term=trim(BOTH from deu_term_to_insert) AND t.language_id=6 AND t.deleted=false
          where tl.website_id=<dgfm_website_id> AND tl.deleted=false
        ))
        THEN
          perform insert_term(trim(BOTH from deu_term_to_insert), 'deu',null,'dgfm:' || cast(termlist_id_to_insert_into as text));
        ELSE
        END IF;
        IF (eng_terms_for_termlist[term_position_counter] is not null AND eng_terms_for_termlist[term_position_counter] != '') THEN
          IF (NOT EXISTS (
            select tl.id
            from indicia.termlists tl
            JOIN indicia.termlists_terms tt on tt.termlist_id = tl.id AND tl.id=termlist_id_to_insert_into AND tt.deleted=false
            JOIN terms t on t.id = tt.term_id AND t.term=trim(BOTH from eng_terms_for_termlist[term_position_counter]) AND t.language_id=1 AND t.deleted=false
            where tl.website_id=<dgfm_website_id> AND tl.deleted=false
          ))
          THEN
            perform insert_term(trim(BOTH from eng_terms_for_termlist[term_position_counter]), 'eng',null,'dgfm:' || cast(termlist_id_to_insert_into as text));
          ELSE
          END IF;
        ELSE
        END IF;

        IF (cze_terms_for_termlist[term_position_counter] is not null AND cze_terms_for_termlist[term_position_counter] != '') THEN
          IF (NOT EXISTS (
            select tl.id
            from indicia.termlists tl
            JOIN indicia.termlists_terms tt on tt.termlist_id = tl.id AND tl.id=termlist_id_to_insert_into AND tt.deleted=false
            JOIN terms t on t.id = tt.term_id AND t.term=trim(BOTH from cze_terms_for_termlist[term_position_counter]) AND t.language_id=7 AND t.deleted=false
            where tl.website_id=<dgfm_website_id> AND tl.deleted=false
          ))
          THEN
            perform insert_term(trim(BOTH from cze_terms_for_termlist[term_position_counter]), 'cze',null,'dgfm:' || cast(termlist_id_to_insert_into as text));
          ELSE
          END IF;
        ELSE
        END IF;

        update termlists_terms
        set 
        -- Get the German meaning
        preferred=false, meaning_id = (
          select tt.meaning_id from termlists_terms tt 
          join termlists tl on tl.id = tt.termlist_id AND tl.website_id=<dgfm_website_id> AND tl.id = termlist_id_to_insert_into AND tl.deleted=false
          join terms t on t.id = tt.term_id AND t.term=trim(BOTH from deu_term_to_insert) AND t.language_id = 6 AND t.deleted=false
          where tt.deleted=false
          order by tt.id desc limit 1)
        where id in (
          select tt.id 
          from termlists_terms tt 
          join terms t on t.id = tt.term_id AND t.deleted=false 
            AND t.term in (trim(BOTH from eng_terms_for_termlist[term_position_counter]), trim(BOTH from cze_terms_for_termlist[term_position_counter]))
            AND t.language_id in (1,7)
          join termlists tl on tl.id = tt.termlist_id AND tl.website_id=<dgfm_website_id> AND tl.id = termlist_id_to_insert_into AND tl.deleted=false
          where tt.deleted=false
          -- Don't limit 1 as we need two rows!
          order by tt.id desc limit 2);
      ELSE
      END IF;
      term_position_counter := term_position_counter+1;
    END LOOP;
END LOOP;
END
$do$;


