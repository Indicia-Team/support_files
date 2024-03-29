--Important: Before running this script it is assumed the external_key of the journals termlist 'dgfm:journal_references'
--It is assumed the standard Indicia IDs for the language are being used, these are 6,1,7 for German, English and Czech
--Tags to replace in this script are as follows
--<dgfm_website_id>


-- NOW, import the species

set search_path TO indicia, public;
DO
$do$
BEGIN
IF (NOT EXISTS (
  select tl.id
  from indicia.termlists tl
  where tl.external_key = 'dgfm:journal_references'
  AND tl.website_id=<dgfm_website_id>
  AND tl.deleted=false
  ORDER BY tl.id desc
  LIMIT 1
))
THEN
  -- Insert the termlist if we don't find it
  insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
  values (
    'Journal references', 
    'Termlist for containing journal entries',
    (select id from indicia.websites where id=<dgfm_website_id> and deleted=false),
    now(),
    1,
    now(),
    1,
    'dgfm:journal_references'
  );
ELSE
END IF;
END
$do$;


set search_path TO indicia, public;
-- First cycle through each row and insert termlist with terms
DO
$do$
declare reference_to_import RECORD;
DECLARE data_type_to_insert text;
DECLARE data_value_to_insert text;
DECLARE journal_ref_being_used text;
DECLARE attribute_being_used text;
declare other_language_caption text;

BEGIN 
FOR reference_to_import IN 
  -- The termlist name needs to be shortend to same length as attribute, so attribute knows termlist that is associated with it
  (select trim(BOTH '"' from trim(BOTH from data_type)) as data_type_to_insert, trim(BOTH '"' from trim(BOTH from data_value)) as data_value_to_insert
    from dgfm.tbl_reference_data
  ) 
LOOP
--Insert the Journal into the termlist. Any other types of rows will be termlist_term_attributes
IF (reference_to_import.data_type_to_insert = 'journal_reference') THEN
  journal_ref_being_used := reference_to_import.data_value_to_insert;
  IF (NOT EXISTS (
    select t.term
    from indicia.terms t
    join termlists_terms tt on tt.term_id = t.id and tt.deleted=false
    join termlists tl on tl.id = tt.termlist_id and tl.external_key = 'dgfm:journal_references' and tl.deleted=false
    where t.term = journal_ref_being_used
    AND t.deleted=false
    ORDER BY t.id desc
    LIMIT 1
  ))
  THEN
    perform insert_term(journal_ref_being_used, 'eng',null,'dgfm:journal_references');
    perform insert_term(journal_ref_being_used, 'deu',null,'dgfm:journal_references');
    perform insert_term(reference_to_import.data_value_to_insert, 'cze',null,'dgfm:journal_references');
    
    update termlists_terms
    set
    preferred=false, meaning_id = (
      select tt.meaning_id from termlists_terms tt 
      join termlists tl on tl.id = tt.termlist_id AND tl.id = (select id from termlists where external_key = 'dgfm:journal_references' order by id desc limit 1) AND tl.deleted=false
      join terms t on t.id = tt.term_id AND t.deleted=false AND term = journal_ref_being_used and t.language_id = 6 
      AND tt.deleted=false
      order by tt.id desc limit 1)
    where 
    -- Apply to to the English and Czech area on the same list.
      id in (
      select tt.id 
      from termlists_terms tt
      join terms t on t.id = tt.term_id AND t.deleted=false AND term = journal_ref_being_used and t.language_id in (1,7)  
      join termlists tl on tl.id = tt.termlist_id AND tl.id = (select id from termlists where external_key = 'dgfm:journal_references' order by id desc limit 1) AND tl.deleted=false
      where tt.deleted=false
      -- Don't limit 1 as we need two rows!
        order by tt.id desc limit 2);
  ELSE
  END IF;
-- Any non-Journal Reference rows will be termlist_term_attributes
-- Each journal attribute appears as a row under the journal row with the attribute type first (e.g. Author), then the value
ELSE
  attribute_being_used := reference_to_import.data_type_to_insert;
  -- Create an attribute if it doesn't exist. So, for instance, if no Author attribute exists we create one, otherwise there will be an existing one we can use.
  if (NOT EXISTS(
    select tta.id
    from termlists_term_attributes tta
    join termlists_termlists_term_attributes ttta on ttta.termlists_term_attribute_id = tta.id AND ttta.termlist_id = (select id from termlists where external_key = 'dgfm:journal_references' order by id desc limit 1) AND ttta.deleted=false
    where tta.caption = attribute_being_used
    AND tta.deleted=false))
  THEN
    other_language_caption = '{"eng":"' || attribute_being_used || '","cze":"' || attribute_being_used || '"}';
    insert into termlists_term_attributes (
      caption,
      caption_i18n,
      description,
      data_type,
      created_on,created_by_id,updated_on,updated_by_id
    )
    values (
      attribute_being_used,
      other_language_caption::jsonb,
      'Journal reference attr for ' || attribute_being_used,
      'T',
      now(),1,now(),1
    );
    
    insert into termlists_termlists_term_attributes (termlists_term_attribute_id,termlist_id,created_on,created_by_id)
    values ((select id from indicia.termlists_term_attributes where caption = attribute_being_used and deleted=false order by id desc limit 1),(select id from termlists where external_key = 'dgfm:journal_references' order by id desc limit 1),now(),1);
  ELSE
  END IF;

  if (NOT EXISTS(
    select ttav.id
    from termlists_term_attribute_values ttav
    where 
      ttav.termlists_term_attribute_id = (select id from indicia.termlists_term_attributes where caption = attribute_being_used and deleted=false order by id desc limit 1) and 
      ttav.text_value = reference_to_import.data_value_to_insert and
      ttav.termlists_term_id = 
        (select tt.id 
        from indicia.termlists_terms tt 
        join terms t on tt.term_id = t.id and t.term = journal_ref_being_used and t.language_id = 6 and t.deleted=false
        where termlist_id = (select id from termlists where external_key = 'dgfm:journal_references' order by id desc limit 1) and tt.deleted=false order by id desc limit 1) and
      ttav.deleted=false))
  THEN 
    insert into termlists_term_attribute_values (
      termlists_term_attribute_id,
      text_value,

      termlists_term_id,

      created_on,created_by_id,updated_on,updated_by_id)
    values (
      (select id from indicia.termlists_term_attributes where caption = attribute_being_used and deleted=false order by id desc limit 1),
      reference_to_import.data_value_to_insert,

      (select tt.id 
      from indicia.termlists_terms tt 
      join terms t on tt.term_id = t.id and t.term = journal_ref_being_used and t.language_id = 6 and t.deleted=false
      where termlist_id = (select id from termlists where external_key = 'dgfm:journal_references' order by id desc limit 1) and tt.deleted=false order by id desc limit 1),

      now(),1,now(),1);
  ELSE
  END IF;
END IF;
END LOOP;
END
$do$;


