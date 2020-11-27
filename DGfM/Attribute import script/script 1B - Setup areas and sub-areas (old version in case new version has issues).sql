
-- IMPORTANT. This script assumes that the external key for the Area, sub-area termlist is 'indicia:area_sub_area'. If needed this can be set in the 
-- database first.
--To run this code, you will need to do replacements of,
--<areas_tl_id>


set search_path TO indicia, public;

-- Firstly Cycle through each row to import, 
DO
$do$
declare area_sub_area_to_import RECORD;
BEGIN 
FOR area_sub_area_to_import IN 
(
  --Select all rows (attributes) to import
  --select_all_from_dgfm_attributes_tag
  select 
  dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area,
  dta.gb_area as gb_attribute_area, dta.gb_sub_area as gb_attribute_sub_area,
  dta.cz_area as cz_attribute_area, dta.cz_sub_area as cz_attribute_sub_area
  from dgfm.tbl_attributes dta
) loop

    IF (NOT EXISTS (
      select tl.id
      from indicia.termlists tl
      JOIN indicia.termlists_terms tt on tt.termlist_id = tl.id AND tl.id=<areas_tl_id> AND tt.deleted=false
      JOIN terms t on t.id = tt.term_id AND t.term=area_sub_area_to_import.deu_attribute_area AND t.language_id=6 AND t.deleted=false
      where tl.website_id=2 AND tl.deleted=false
    ))
    THEN
      perform insert_term(area_sub_area_to_import.deu_attribute_area,'deu',null,'indicia:area_sub_area');
    ELSE
    END IF;
    
    IF (area_sub_area_to_import.gb_attribute_area is not null AND area_sub_area_to_import.gb_attribute_area != '') THEN
      IF (NOT EXISTS (
        select tl.id
        from indicia.termlists tl
        JOIN indicia.termlists_terms tt on tt.termlist_id = tl.id AND tl.id=<areas_tl_id> AND tt.deleted=false
        JOIN terms t on t.id = tt.term_id AND t.term=area_sub_area_to_import.gb_attribute_area AND t.language_id=1 AND t.deleted=false
        where tl.website_id=2 AND tl.deleted=false
      ))
      THEN
        perform insert_term(area_sub_area_to_import.gb_attribute_area,'eng',null,'indicia:area_sub_area');
      ELSE
      END IF;
    ELSE
    END IF;

    IF (area_sub_area_to_import.cz_attribute_area is not null AND area_sub_area_to_import.cz_attribute_area != '') THEN
      IF (NOT EXISTS (
        select tl.id
        from indicia.termlists tl
        JOIN indicia.termlists_terms tt on tt.termlist_id = tl.id AND tl.id=<areas_tl_id> AND tt.deleted=false
        JOIN terms t on t.id = tt.term_id AND t.term=area_sub_area_to_import.cz_attribute_area AND t.language_id=7 AND t.deleted=false
        where tl.website_id=2 AND tl.deleted=false
      ))
      THEN
        perform insert_term(area_sub_area_to_import.cz_attribute_area,'cze',null,'indicia:area_sub_area');
      ELSE
      END IF;
    ELSE
    END IF;


  -- Set all the Area language terms (synonyms) for have the same meaning as the german term. Note: synonyms don't have parent set and
  -- have preferred false
  update termlists_terms
  set
  -- Get the German (the main language) area meaning id
  preferred=false, meaning_id = (
    select tt.meaning_id from termlists_terms tt 
    join termlists tl on tl.id = tt.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
    join terms t on t.id = tt.term_id AND t.term=area_sub_area_to_import.deu_attribute_area AND t.deleted=false
    AND tt.deleted=false
    order by tt.id desc limit 1)
  where 
  -- Apply to to the English and Czech area on the same list.
    id in (
    select tt.id 
    from termlists_terms tt
    join terms t on t.id = tt.term_id AND t.deleted=false AND term in 
      (area_sub_area_to_import.gb_attribute_area,
      area_sub_area_to_import.cz_attribute_area)  
    join termlists tl on tl.id = tt.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
    where tt.deleted=false
    -- Don't limit 1 as we need two rows!
    order by tt.id desc limit 2);


  IF (NOT EXISTS (
    select t_sub_area.id
    from terms t_sub_area
    join termlists_terms tt_sub_area on tt_sub_area.term_id = t_sub_area.id AND tt_sub_area.deleted = false
    join termlists_terms tt_area on tt_area.id = tt_sub_area.parent_id AND tt_area.deleted = false
    join terms t_area on t_area.id = tt_area.term_id 
    AND t_area.term =
      area_sub_area_to_import.deu_attribute_area
    AND t_area.deleted = false
    join termlists tl on tl.id = tt_area.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
    where t_sub_area.term in (
      area_sub_area_to_import.deu_attribute_sub_area,
      area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area
    )
    AND t_sub_area.language_id = 6
    AND t_sub_area.deleted = false
  ))
  THEN
    perform insert_term(area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area,'deu',null,'indicia:area_sub_area');
  ELSE
  END IF;

  IF (area_sub_area_to_import.gb_attribute_sub_area is not null AND area_sub_area_to_import.gb_attribute_sub_area != '') THEN
    IF (NOT EXISTS (
      select t_gb_sub_area.id
      from terms t_gb_sub_area
      join termlists_terms tt_gb_sub_area on tt_gb_sub_area.term_id = t_gb_sub_area.id AND tt_gb_sub_area.deleted = false
      join termlists_terms tt_sub_area on tt_sub_area.meaning_id = tt_gb_sub_area.meaning_id AND tt_sub_area.deleted = false
      join terms t_sub_area on t_sub_area.id = tt_sub_area.term_id AND t_sub_area.language_id = 6 AND t_sub_area.deleted = false
      join termlists_terms tt_area on tt_area.id = tt_sub_area.parent_id AND tt_area.deleted = false
      join terms t_area on t_area.id = tt_area.term_id AND t_area.language_id = 6 AND t_area.term = area_sub_area_to_import.deu_attribute_area AND t_area.deleted=false
      join termlists tl on tl.id = tt_area.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
      where t_gb_sub_area.term in (
        area_sub_area_to_import.gb_attribute_sub_area,
        area_sub_area_to_import.gb_attribute_area  || ' child ' || area_sub_area_to_import.gb_attribute_sub_area
      )
      AND t_gb_sub_area.language_id = 1
      AND t_gb_sub_area.deleted = false
    ))
    THEN
      perform insert_term(area_sub_area_to_import.gb_attribute_area  || ' child ' || area_sub_area_to_import.gb_attribute_sub_area,'eng',null,'indicia:area_sub_area');
    ELSE
    END IF;
  ELSE
  END IF;
  
  IF (area_sub_area_to_import.cz_attribute_sub_area is not null AND area_sub_area_to_import.cz_attribute_sub_area != '') THEN
    IF (NOT EXISTS (
      select t_cz_sub_area.id
      from terms t_cz_sub_area
      join termlists_terms tt_cz_sub_area on tt_cz_sub_area.term_id = t_cz_sub_area.id AND tt_cz_sub_area.deleted = false
      join termlists_terms tt_sub_area on tt_sub_area.meaning_id = tt_cz_sub_area.meaning_id AND tt_sub_area.deleted = false
      join terms t_sub_area on t_sub_area.id = tt_sub_area.term_id AND t_sub_area.language_id = 6 AND t_sub_area.deleted = false
      join termlists_terms tt_area on tt_area.id = tt_sub_area.parent_id AND tt_area.deleted = false
      join terms t_area on t_area.id = tt_area.term_id AND t_area.language_id = 6 AND t_area.term = area_sub_area_to_import.deu_attribute_area AND t_area.deleted=false
      join termlists tl on tl.id = tt_area.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
      where t_cz_sub_area.term in (
        area_sub_area_to_import.cz_attribute_sub_area,
        area_sub_area_to_import.cz_attribute_area  || ' child ' || area_sub_area_to_import.cz_attribute_sub_area
      )
      AND t_cz_sub_area.language_id = 7
      AND t_cz_sub_area.deleted = false
    ))
    THEN
      perform insert_term(area_sub_area_to_import.cz_attribute_area  || ' child ' || area_sub_area_to_import.cz_attribute_sub_area,'cze',null,'indicia:area_sub_area');
    ELSE
    END IF;
  ELSE
  END IF;

  -- Set the parent id on the subarea, we only do this for the main language (German), not the synonyms.
  update termlists_terms
  set preferred=true, parent_id = (
    select tt.id from termlists_terms tt 
    join termlists tl on tl.id = tt.termlist_id AND tl.id = <areas_tl_id> and tt.parent_id is null AND tl.deleted=false
    join terms t on t.id = tt.term_id AND t.term=area_sub_area_to_import.deu_attribute_area AND t.language_id = 6 AND t.deleted=false
    AND tt.deleted=false
    order by tt.id desc limit 1)
  where 
  id in (
    select tt.id
    from termlists_terms tt
    join terms t on t.id = tt.term_id AND t.language_id = 6 AND t.deleted=false
      AND term = area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area
    join termlists tl on tl.id = tt.termlist_id AND tt.termlist_id = <areas_tl_id> AND tl.deleted=false
    where tt.deleted=false
    order by id desc limit 1);

  --
  --Again set the Englsih and Czech sub-areas to have the same meaning as the German (Note : synonyms don't have a parent_id, only the preferred does)
  --update termlists_terms
  --set 
  --preferred = false, meaning_id = (
  --  select tt.meaning_id
  --  from termlists_terms tt
  --  join terms t on t.id = tt.term_id AND t.term in 
  --  (area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area,
  --  area_sub_area_to_import.deu_attribute_sub_area)
  --      AND t.language_id = 6 AND t.deleted = false
  --  join termlists_terms tt_parent on tt_parent.id = tt.parent_id AND tt_parent.parent_id is null AND tt_parent.deleted=false
  --  join indicia.terms t_parent on t_parent.id = tt_parent.term_id AND t_parent.term=area_sub_area_to_import.deu_attribute_area AND t_parent.deleted=false
  --  join termlists tl on tl.id = tt.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
  --  where tt.deleted = false
  --  order by tt.id desc limit 1)
  --where 
  --  id in (
  --  select tt.id 
  --  from termlists_terms tt
  --  join terms t on t.id = tt.term_id AND t.language_id in (1,7) AND t.deleted=false AND term in 
  --    (
  --    area_sub_area_to_import.gb_attribute_sub_area,
  --    area_sub_area_to_import.cz_attribute_sub_area,
  --    area_sub_area_to_import.gb_attribute_area  || ' child ' || area_sub_area_to_import.gb_attribute_sub_area,
  --    area_sub_area_to_import.cz_attribute_area  || ' child ' || area_sub_area_to_import.cz_attribute_sub_area)  
  --  join termlists_terms tt_deu on tt_deu.meaning_id = tt.meaning_id AND tt_deu.termlist_id = <areas_tl_id> AND tt_deu.deleted=false
  --  join terms t_deu on t_deu.id = tt_deu.term_id AND t_deu.language_id = 6 AND t_deu.deleted=false
  --  join termlists_terms tt_deu_parent on tt_deu_parent.id = tt_deu.parent_id AND tt_deu_parent.parent_id is null AND tt_deu_parent.deleted=false
  --  join indicia.terms t_deu_parent on t_deu_parent.id = tt_deu_parent.term_id AND t_deu_parent.term=area_sub_area_to_import.deu_attribute_area AND t_deu_parent.deleted=false
  --  join termlists tl on tl.id = tt.termlist_id AND tt.termlist_id = <areas_tl_id> AND tl.deleted=false
  --  where tt.deleted=false
    -- Don't limit 1 as we want 2 results for German and Czech
  --  order by tt.id desc limit 2);

  update termlists_terms
  set 
  preferred = false, meaning_id = (
    select tt.meaning_id
    from termlists_terms tt
    join terms t on t.id = tt.term_id AND t.term in 
      (area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area,
      area_sub_area_to_import.deu_attribute_sub_area)
      AND t.language_id = 6 AND t.deleted = false
    join termlists_terms tt_parent on tt_parent.id = tt.parent_id AND tt_parent.parent_id is null AND tt_parent.deleted=false
    join indicia.terms t_parent on t_parent.id = tt_parent.term_id AND t_parent.term=area_sub_area_to_import.deu_attribute_area AND t_parent.deleted=false
    join termlists tl on tl.id = tt.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
    where tt.deleted = false
    order by tt.id desc limit 1)
  where 
    id in (
    select tt.id 
    from termlists_terms tt
    join terms t on t.id = tt.term_id AND t.deleted=false AND term in 
      (area_sub_area_to_import.gb_attribute_area  || ' child ' || area_sub_area_to_import.gb_attribute_sub_area,
      area_sub_area_to_import.cz_attribute_area  || ' child ' || area_sub_area_to_import.cz_attribute_sub_area)  
    join termlists tl on tl.id = tt.termlist_id AND tt.termlist_id = <areas_tl_id> AND tl.deleted=false
    where tt.deleted=false
    -- Don't limit 1 as we want 2 results for German and Czech
    order by id desc limit 2);


--ELSE 
--END IF;
END LOOP;
END
$do$;

-- We used a customised format name format for the sub-area names (see earlier notes). Reset these names.
DO
$do$
declare area_sub_area_to_import RECORD;
BEGIN 
FOR area_sub_area_to_import IN 
(
  --select_all_from_dgfm_attributes_tag
  select dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area,
  dta.gb_area as gb_attribute_area, dta.gb_sub_area as gb_attribute_sub_area,
  dta.cz_area as cz_attribute_area, dta.cz_sub_area as cz_attribute_sub_area
  from dgfm.tbl_attributes dta
) loop
  update terms
  -- Takes the part after the word child (the sub-area)
  set term = split_part(term,' child ', 2)
  where term in 
    (area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area,
    area_sub_area_to_import.gb_attribute_area  || ' child ' || area_sub_area_to_import.gb_attribute_sub_area,
    area_sub_area_to_import.cz_attribute_area  || ' child ' || area_sub_area_to_import.cz_attribute_sub_area);
END LOOP;
END
$do$;













