
DROP table complete_descriptions;
-- Create a table which holds the taxa_taxon_list_id and preferred species name
CREATE TABLE complete_descriptions ("id" INT, "name" VARCHAR);

-- Add the attributes to the table as columns. As there is a limit to the number of columns allowed, rerun this firstly with Limit 1000 & Offset 0
-- then rerun but put everything into a new table complete_descriptions_2 with Limit 1500 & Offset 1000 for remaining attributes
-- Note: these numbers may need to be altered in the future if the numbers of attributes increases.
-- Also as columns have limit to column characters, we take first 15 characters of area, then sub area, and caption, then add attribute ID on end (and replace all spaces with underscores)
DO
$do$
    DECLARE attribute_record RECORD;
BEGIN
FOR attribute_record IN 
    SELECT lower(regexp_replace(REPLACE(LEFT(ctt_area.term,15) || ' ' || LEFT(ctt_sub_area.term,15) || ' ' || LEFT(ttla.caption,15) || ' ' || ttla.id, ' ', '_'), '\W+', '', 'g')) as col_name
    FROM indicia.taxa_taxon_list_attributes ttla
    JOIN indicia.taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id=ttla.id and tlttla.taxon_list_id = 1 and tlttla.deleted=false and tlttla.id not in (30,33,2134,2132,2133)
    JOIN indicia.cache_termlists_terms ctt_sub_area on ctt_sub_area.id = ttla.reporting_category_id 
    JOIN indicia.cache_termlists_terms ctt_area on ctt_area.id = ctt_sub_area.parent_id
    WHERE ttla.deleted=false
    GROUP BY ctt_area.term, ctt_sub_area.term, ttla.id, ttla.caption,tlttla.weight
    ORDER BY ctt_area.term,ctt_sub_area.term,tlttla.weight asc
    Limit 1000
    Offset 0
    --Limit 1500
    --Offset 1000
LOOP
    EXECUTE 'ALTER TABLE complete_descriptions ADD COLUMN ' || attribute_record.col_name/*quote_ident(colnames)*/ || ' VARCHAR DEFAULT NULL;'; /* careful: in quoted text, the spaces are important */
END LOOP;
END
$do$;

-- Now add all species to the table
DO
$do$
    DECLARE taxon_record RECORD;
    DECLARE stmt varchar;
BEGIN
FOR taxon_record IN 
    SELECT cttl.id as id,cttl.taxon as taxon
    FROM indicia.cache_taxa_taxon_lists cttl
    where cttl.taxon_list_id = 1 AND cttl.taxon_rank_id = 3 AND cttl.preferred = true
    ORDER BY cttl.taxon asc
LOOP
stmt = 'INSERT INTO complete_descriptions(id, name) VALUES(' || taxon_record.id || ',''' || taxon_record.taxon || ''')';
EXECUTE stmt;
END LOOP;
END
$do$;

-- Finally cycle through each species
-- Then cycle through all the attributes and fill in the values into the table
DO
$do$
    DECLARE taxon_record_2 RECORD;
    DECLARE attribute_record_2 RECORD;
    DECLARE stmt2 varchar;
    DECLARE colToUse varchar;
BEGIN
FOR taxon_record_2 IN 
    SELECT cd_table.id as cycling_taxa_taxon_list_id, cd_table.name as cycling_taxon_name
    FROM complete_descriptions cd_table
    ORDER BY cd_table.name asc
LOOP
FOR attribute_record_2 IN 
    SELECT ttla.id,ttla.caption,
    string_agg(distinct coalesce(
        case when ttla.data_type = 'L' then coalesce(ctt_german.term,ctt_english.term) else null end,
        case when ttla.data_type = 'T' then ttlav.text_value else null end,
        case when ttla.data_type = 'I' then int_value::text else null end,
        case when ttla.data_type = 'F' then float_value::text else null end,
        case when ttla.data_type = 'D' then date_start_value || ', ' || date_end_value else null end,
        ''
    ) ||
    CASE WHEN upper_value IS NOT NULL THEN ' - ' || upper_value ELSE '' END,',') AS attribute_value
    , ctt_area.term as area, ctt_sub_area.term as sub_area
    FROM indicia.cache_taxa_taxon_lists cttl
    JOIN indicia.cache_taxa_taxon_lists cttl_preferred_not_req on cttl_preferred_not_req.taxon_meaning_id = cttl.taxon_meaning_id
      AND cttl_preferred_not_req.taxon_list_id=1
    JOIN indicia.taxa_taxon_list_attribute_values ttlav on ttlav.taxa_taxon_list_id = cttl_preferred_not_req.id AND ttlav.deleted=false 
    
    LEFT JOIN indicia.cache_termlists_terms ctt_meaning on ctt_meaning.id = ttlav.int_value
    LEFT JOIN indicia.cache_termlists_terms ctt_german on ctt_german.meaning_id = ctt_meaning.meaning_id  AND ctt_german.language_iso='deu'  
    LEFT JOIN indicia.cache_termlists_terms ctt_english on ctt_english.meaning_id = ctt_meaning.meaning_id  AND ctt_english.language_iso='eng'  
    LEFT JOIN indicia.cache_termlists_terms ctt_czech on ctt_czech.meaning_id = ctt_meaning.meaning_id  AND ctt_czech.language_iso='cze'  

    JOIN indicia.taxa_taxon_list_attributes ttla on ttla.id = ttlav.taxa_taxon_list_attribute_id AND ttla.deleted=false 
    JOIN indicia.taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id=ttla.id and tlttla.taxon_list_id = 1 and tlttla.deleted=false and tlttla.id not in (30,33,2134,2132,2133)
    JOIN indicia.cache_termlists_terms ctt_sub_area on ctt_sub_area.id = ttla.reporting_category_id 
    JOIN indicia.cache_termlists_terms ctt_area on ctt_area.id = ctt_sub_area.parent_id
    WHERE cttl.id = taxon_record_2.cycling_taxa_taxon_list_id AND cttl.taxon_list_id=1

    GROUP BY ctt_area.term, ctt_sub_area.term, ttla.id, ttla.caption,tlttla.weight
    ORDER BY ctt_area.term,ctt_sub_area.term,tlttla.weight asc
LOOP
colToUse = lower(regexp_replace(REPLACE(LEFT(attribute_record_2.area,15) || ' ' || LEFT(attribute_record_2.sub_area,15) || ' ' || LEFT(attribute_record_2.caption,15) || ' ' || attribute_record_2.id, ' ', '_'), '\W+', '', 'g'));
stmt2 = '
DO $$   
BEGIN               
if exists(
select 1 from information_schema.columns
where table_schema=''public'' and table_name=''complete_descriptions'' and column_name = ''' || colToUse || ''')  
THEN
update complete_descriptions set ' || colToUse || ' = ''' || REPLACE(attribute_record_2.attribute_value,'''','') || ''' where id = ' || taxon_record_2.cycling_taxa_taxon_list_id || '; 
END IF;
END
$$;';
EXECUTE stmt2;
END LOOP;
END LOOP;
END
$do$;
