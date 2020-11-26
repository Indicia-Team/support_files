--The references text file must be a single column of full journal references
--The attributes file must be a csv of columns containing the attributes to save against the journal terms
--Tags to replace in this script are as follows
-- <dgfm_website_id>
-- <references_text_file_path>
-- <attributes_file_path>
--Path format (on mac) should be like '/users/joebloggs/tblSpeciesTrait.csv'
--If running in PSQL on a server, then the path is from the PSQL working directory, you can find this out by typing "\! pwd" inside PSQL

/*
Data exported from MS Access as text files, suffix .csv, field names in first row, " delimiter.
Open each file in notepad and save as UTF-8
Open each file in Notepad++ and convert to UTF-8 without BOM
*/

-- NOW, import the species

create schema if not exists dgfm;
set search_path TO dgfm, public;

DROP TABLE IF EXISTS tbl_references_list_temp;

CREATE TABLE tbl_references_list_temp (
  reference varchar
);
-- User pipe as delimiter as this never appears in the file. As we are importing one column that includes commas it means we can do the import without introducing quotes
COPY tbl_references_list_temp
FROM '<references_text_file_path>'
WITH DELIMITER '|'
ENCODING 'UTF-8'
CSV HEADER;

DROP TABLE IF EXISTS tbl_attributes_list_temp;

CREATE TABLE tbl_attributes_list_temp (
  Author varchar,
  Year varchar,
  Title varchar,
  PeriodicalTitle varchar,
  Volume varchar,
  Pages varchar,
  URL varchar,
  Publisher varchar,
  City varchar,
  BookAuthor varchar,
  BookTitle varchar,
  DOI varchar
);

COPY tbl_attributes_list_temp
FROM '<attributes_file_path>'
WITH DELIMITER ','
ENCODING 'UTF-8'
CSV HEADER;

-- Cleanup data, mostly remove full stops, commas and colons from ends of strings, apart from year where we remove everything that isn't a number
update tbl_attributes_list_temp
set Author = trim(BOTH '.' from Author);

update tbl_attributes_list_temp
set Author = trim(BOTH ',' from Author);

update tbl_attributes_list_temp
set Author = trim(BOTH ':' from Author);

update tbl_attributes_list_temp
set Year = substring(Year from '(([0-9]+.*)*[0-9]+)');

update tbl_attributes_list_temp
set Title = trim(BOTH '.' from Title);

update tbl_attributes_list_temp
set Title = trim(BOTH ',' from Title);

update tbl_attributes_list_temp
set Title = trim(BOTH ':' from Title);

update tbl_attributes_list_temp
set PeriodicalTitle = trim(BOTH '.' from PeriodicalTitle);

update tbl_attributes_list_temp
set PeriodicalTitle = trim(BOTH ',' from PeriodicalTitle);

update tbl_attributes_list_temp
set PeriodicalTitle = trim(BOTH ':' from PeriodicalTitle);

update tbl_attributes_list_temp
set Volume = trim(BOTH '.' from Volume);

update tbl_attributes_list_temp
set Volume = trim(BOTH ',' from Volume);

update tbl_attributes_list_temp
set Volume = trim(BOTH ':' from Volume);

update tbl_attributes_list_temp
set Pages = trim(BOTH '.' from Pages);

update tbl_attributes_list_temp
set Pages = trim(BOTH ',' from Pages);

update tbl_attributes_list_temp
set Pages = trim(BOTH ':' from Pages);

update tbl_attributes_list_temp
set URL = trim(BOTH '.' from URL);

update tbl_attributes_list_temp
set URL = trim(BOTH ',' from URL);

update tbl_attributes_list_temp
set URL = trim(BOTH ':' from URL);

update tbl_attributes_list_temp
set Publisher = trim(BOTH '.' from Publisher);

update tbl_attributes_list_temp
set Publisher = trim(BOTH ',' from Publisher);

update tbl_attributes_list_temp
set Publisher = trim(BOTH ':' from Publisher);

update tbl_attributes_list_temp
set City = trim(BOTH '.' from City);

update tbl_attributes_list_temp
set City = trim(BOTH ',' from City);

update tbl_attributes_list_temp
set City = trim(BOTH ':' from City);

update tbl_attributes_list_temp
set BookAuthor = trim(BOTH '.' from BookAuthor);

update tbl_attributes_list_temp
set BookAuthor = trim(BOTH ',' from BookAuthor);

update tbl_attributes_list_temp
set BookAuthor = trim(BOTH ':' from BookAuthor);

update tbl_attributes_list_temp
set BookTitle = trim(BOTH '.' from BookTitle);

update tbl_attributes_list_temp
set BookTitle = trim(BOTH ',' from BookTitle);

update tbl_attributes_list_temp
set BookTitle = trim(BOTH ':' from BookTitle);

update tbl_attributes_list_temp
set DOI = trim(BOTH '.' from DOI);

update tbl_attributes_list_temp
set DOI = trim(BOTH ',' from DOI);

update tbl_attributes_list_temp
set DOI = trim(BOTH ':' from DOI);


set search_path TO dgfm, public;
-- First cycle through each row and insert termlist with terms
DO
$do$
DECLARE reference_to_process RECORD;
DECLARE attributes_to_copy RECORD;
DECLARE data_type_to_insert text;
DECLARE data_value_to_insert text;

BEGIN 
FOR reference_to_process IN 
  -- The termlist name needs to be shortend to same length as attribute, so attribute knows termlist that is associated with it
  (select trim(BOTH '"' from trim(BOTH from reference)) as reference_to_convert
    from dgfm.tbl_references_list_temp
  ) 
LOOP
--Insert the Journal into the termlist. Any other types of rows will be termlist_term_attributes
IF (reference_to_process.reference_to_convert IS NOT NULL AND reference_to_process.reference_to_convert != 'Literaturliste') THEN
  insert into tbl_reference_data(data_type,data_value)
  values('journal_reference',reference_to_process.reference_to_convert);

  FOR attributes_to_copy IN 
    -- The termlist name needs to be shortend to same length as attribute, so attribute knows termlist that is associated with it
    (select 
      trim(BOTH '"' from trim(BOTH from Author)) as Author,
      trim(BOTH '"' from trim(BOTH from Year)) as Year,
      trim(BOTH '"' from trim(BOTH from Title)) as Title,
      trim(BOTH '"' from trim(BOTH from PeriodicalTitle)) as PeriodicalTitle,
      trim(BOTH '"' from trim(BOTH from Volume)) as Volume,
      trim(BOTH '"' from trim(BOTH from Pages)) as Pages,
      trim(BOTH '"' from trim(BOTH from URL)) as URL,
      trim(BOTH '"' from trim(BOTH from Publisher)) as Publisher,
      trim(BOTH '"' from trim(BOTH from City)) as City,
      trim(BOTH '"' from trim(BOTH from BookAuthor)) as BookAuthor,
      trim(BOTH '"' from trim(BOTH from BookTitle)) as BookTitle,
      trim(BOTH '"' from trim(BOTH from DOI)) as DOI
      from dgfm.tbl_attributes_list_temp
    ) 
  LOOP
  -- AVB note: this won't work as not every row has a title
    IF (reference_to_process.reference_to_convert like '%' || attributes_to_copy.Title || '%') THEN
      IF (attributes_to_copy.Author IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('Author',attributes_to_copy.Author);
      ELSE
      END IF;

      IF (attributes_to_copy.Year IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('Year',attributes_to_copy.Year);
      ELSE
      END IF;

      IF (attributes_to_copy.Title IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('Title',attributes_to_copy.Title);
      ELSE
      END IF;

      IF (attributes_to_copy.PeriodicalTitle IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('PeriodicalTitle',attributes_to_copy.PeriodicalTitle);
      ELSE
      END IF;

      IF (attributes_to_copy.Volume IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('Volume',attributes_to_copy.Volume);
      ELSE
      END IF;

      IF (attributes_to_copy.Pages IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('Pages',attributes_to_copy.Pages);
      ELSE
      END IF;

      IF (attributes_to_copy.URL IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('URL',attributes_to_copy.URL);
      ELSE
      END IF;

      IF (attributes_to_copy.Publisher IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('Publisher',attributes_to_copy.Publisher);
      ELSE
      END IF;

      IF (attributes_to_copy.City IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('City',attributes_to_copy.City);
      ELSE
      END IF;
      -- AVB TODO: see if I can attach this to author
      IF (attributes_to_copy.BookAuthor IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('BookAuthor',attributes_to_copy.BookAuthor);
      ELSE
      END IF;

      IF (attributes_to_copy.BookTitle IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('BookTitle',attributes_to_copy.BookTitle);
      ELSE
      END IF;

      IF (attributes_to_copy.BookTitle IS NOT NULL) THEN
        insert into tbl_reference_data(data_type,data_value)
        values('DOI',attributes_to_copy.DOI);
      ELSE
      END IF;
    ELSE 
    END IF;
  END LOOP;

  IF (attributes_to_copy.Author IS NULL AND
      regexp_matches(regexp_matches(reference_to_process.reference_to_convert, '^[^:]+'), '^[^(]+') IS NOT NULL) THEN
    insert into tbl_reference_data(data_type,data_value)
    --Get everything before first open bracket and first colon
    values('Author',regexp_matches(regexp_matches(reference_to_process.reference_to_convert, '^[^:]+'), '^[^(]+'));
  ELSE
  END IF;

  IF (attributes_to_copy.Year IS NULL AND 
      regexp_matches(reference_to_process.reference_to_convert, '\((.*?)\)') IS NOT NULL) THEN
    insert into tbl_reference_data(data_type,data_value)
    -- Get everything between first pair of brackets (the year)
    values('Year',regexp_matches(reference_to_process.reference_to_convert, '\((.*?)\)'));
  ELSE
  END IF;

  --Get everything after first bracket with colon and before last colon
  IF (attributes_to_copy.Title IS NULL AND
      replace(
      split_part(reference_to_process.reference_to_convert,')',2),
      ':' || reverse(split_part(reverse(reference_to_process.reference_to_convert), ':', 1)),
      '') IS NOT NULL) THEN
    insert into tbl_reference_data(data_type,data_value)
     values('Title', 
      replace(
        split_part(reference_to_process.reference_to_convert,')',2),
        ':' || reverse(split_part(reverse(reference_to_process.reference_to_convert), ':', 1)),
        '')
      )
     ;
  ELSE
  END IF;

  IF (attributes_to_copy.Pages IS NULL) THEN
    insert into tbl_reference_data(data_type,data_value)
    --Get everything after last colon
    values('Pages',reverse(split_part(reverse(reference_to_process.reference_to_convert), ':', 1)));
  ELSE
  END IF;
ELSE
END IF;
END LOOP;
END
$do$;


