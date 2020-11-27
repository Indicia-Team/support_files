
-- IMPORTANT. This script assumes that the external key for the Area, sub-area termlist is 'indicia:area_sub_area'. If needed this can be set in the 
-- database first.
-- To run this code, you will need to do replacements of,
-- <areas_tl_id>

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

  -- Next, does the Area already exist in the termlist?
  -- If Area doesn't exist, then insert a term for the 3 languages
  IF (NOT EXISTS (
    select t.id
      from terms t
      join termlists_terms tt on tt.term_id = t.id AND tt.deleted = false
      join termlists tl on tl.id = tt.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
      where 
      t.term = area_sub_area_to_import.deu_attribute_area AND t.deleted = false))
  THEN
    -- It may seem logical to check area!=null, however don't do this for Area or we could leave sub-area hanging if it doesn't have a parent (althought there should be no nulls ideally).
    -- Data should be checked before import that it is correct without nulls
    perform insert_term(LEFT(TRIM(BOTH from area_sub_area_to_import.deu_attribute_area),200),'deu',null,'indicia:area_sub_area');
    IF (area_sub_area_to_import.gb_attribute_area != 'null' AND area_sub_area_to_import.gb_attribute_area IS NOT NULL) THEN
        perform insert_term(LEFT(TRIM(BOTH from area_sub_area_to_import.gb_attribute_area),200),'eng',null,'indicia:area_sub_area');
    ELSE 
    END IF;    
    IF (area_sub_area_to_import.cz_attribute_area != 'null' AND area_sub_area_to_import.cz_attribute_area IS NOT NULL) THEN
      perform insert_term(LEFT(TRIM(BOTH from area_sub_area_to_import.cz_attribute_area),200),'cze',null,'indicia:area_sub_area');
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


  -- Next import the sub-areas, however, this is a much more complex situation as the same sub-area name can be associated with different areas.
  -- Firstly need to check if the sub-area already exists but need to take into account its parent area. So a sub-area with the same name but different parents is counted
  -- as as a different sub-area

  -- Another thing to note is because insert term doesn't insert duplicates, we need to create the name as a combination of the Area and Sub-Area so we can differentiate
  -- it from other sub-areas with the same name. We need to set the name back to what it was after we are done
  -- Only need to check the German version as the English and Czech are synonyms

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
    where t_sub_area.term in 
    --Need to check deu_attribute_sub_area on its own as well, as if we are importing over existing data the sub area name already have been converted not to use the
    -- area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area format
    (
    area_sub_area_to_import.deu_attribute_sub_area,
    area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area)
    AND t_sub_area.deleted = false))
  THEN
    -- If we don't find a sub-area with the same area parent then add the language terms (these need to be made synonyms later)
    -- We have a problem though as insert_term won't add duplicates within the same termlist, so create the term name out of
    -- both the parent area and sub-area names to ensure uniqueness, we then change the name back again in a minute
    IF (area_sub_area_to_import.deu_attribute_sub_area != 'null') THEN
      perform insert_term(LEFT(TRIM(BOTH from area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area),200),'deu',null,'indicia:area_sub_area');
      -- Only add these if we found the German sub-area, basically we are are assuming everything in German is filled-in
      IF (area_sub_area_to_import.gb_attribute_sub_area != 'null') THEN
        perform insert_term(LEFT(TRIM(BOTH from area_sub_area_to_import.gb_attribute_area  || ' child ' || area_sub_area_to_import.gb_attribute_sub_area),200),'eng',null,'indicia:area_sub_area');
      ELSE 
      END IF;
      IF (area_sub_area_to_import.cz_attribute_sub_area != 'null') THEN
        perform insert_term(LEFT(TRIM(BOTH from area_sub_area_to_import.cz_attribute_area  || ' child ' || area_sub_area_to_import.cz_attribute_sub_area),200),'cze',null,'indicia:area_sub_area');
      ELSE 
      END IF;
    ELSE 
    END IF;
  ELSE 
  END IF; 

  -- Again set the Englsih and Czech sub-areas to have the same meaning as the German (Note : synonyms don't have a parent_id, only the preferred does)
  update termlists_terms
  set 
  preferred = false, meaning_id = (
    select tt.meaning_id
    from termlists_terms tt
    join terms t on t.id = tt.term_id AND t.term = area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area  AND t.deleted = false
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

  -- Set the parent id on the subarea, we only do this for the main language (German), not the synonyms.
  update termlists_terms
  set preferred=true, parent_id = (
    select tt.id from termlists_terms tt 
    join termlists tl on tl.id = tt.termlist_id AND tl.id = <areas_tl_id> AND tl.deleted=false
    join terms t on t.id = tt.term_id AND t.term=area_sub_area_to_import.deu_attribute_area AND t.deleted=false
    AND tt.deleted=false
    order by tt.id desc limit 1)
  where 
  id in (
    select tt.id
    from termlists_terms tt
    join terms t on t.id = tt.term_id AND t.deleted=false AND term = area_sub_area_to_import.deu_attribute_area  || ' child ' || area_sub_area_to_import.deu_attribute_sub_area
    join termlists tl on tl.id = tt.termlist_id AND tt.termlist_id = <areas_tl_id> AND tl.deleted=false
    where tt.deleted=false
    order by id desc limit 1);

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













