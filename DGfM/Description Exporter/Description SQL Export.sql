
DROP table complete_descriptions;
-- Create a table which holds the taxa_taxon_list_id and preferred species name
CREATE TABLE complete_descriptions ("id" INT, "name" VARCHAR);

-- Add the attributes to the table as columns. As there is a limit to the number of columns, replace XXX to limit attributes added to table
-- Also as columns have limit to column characters, we take first 15 characters of area, then sub area, and caption, then add attribute ID on end (and replace all spaces with underscores)
DO
$do$
    DECLARE colnames TEXT;
BEGIN
FOR colnames IN 
    SELECT lower(regexp_replace(REPLACE(LEFT(ctt_area.term,15) || ' ' || LEFT(ctt_sub_area.term,15) || ' ' || LEFT(ttla.caption,15) || ' ' || ttla.id, ' ', '_'), '\W+', '', 'g'))
    FROM indicia.taxa_taxon_list_attributes ttla
    JOIN indicia.taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id=ttla.id and tlttla.taxon_list_id = 1 and tlttla.deleted=false and tlttla.id not in (30,33,2134,2132,2133)
    JOIN indicia.cache_termlists_terms ctt_sub_area on ctt_sub_area.id = ttla.reporting_category_id 
    JOIN indicia.cache_termlists_terms ctt_area on ctt_area.id = ctt_sub_area.parent_id
    WHERE ttla.deleted=false AND ttla.id > XXX AND ttla.id < XXX
    ORDER BY ctt_area.term,ctt_sub_area.term,tlttla.weight asc
LOOP
    EXECUTE 'ALTER TABLE complete_descriptions ADD COLUMN ' || quote_ident(colnames) || ' VARCHAR DEFAULT NULL;'; /* careful: in quoted text, the spaces are important */
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
    DECLARE taxon_record RECORD;
    DECLARE attribute_record RECORD;
    DECLARE stmt2 varchar;
    DECLARE colToUse varchar;
BEGIN
FOR taxon_record IN 
    SELECT cttl.id as cycling_taxa_taxon_list_id, cttl.taxon as cycling_taxon_name
    FROM indicia.cache_taxa_taxon_lists cttl
    where cttl.taxon_list_id = 1 AND cttl.taxon_rank_id = 3 AND cttl.preferred = true
    ORDER BY cttl.taxon asc
LOOP
FOR attribute_record IN 
    SELECT ttla.id,ttla.caption,
    string_agg(coalesce(
        case when ttla.data_type = 'L' then ctt_german.term else null end,
        case when ttla.data_type = 'T' then ttlav.text_value else null end,
        case when ttla.data_type = 'I' then int_value::text else null end,
        case when ttla.data_type = 'F' then float_value::text else null end,
        case when ttla.data_type = 'D' then date_start_value || ', ' || date_end_value else null end,
        ''
    ) ||
    CASE WHEN upper_value IS NOT NULL THEN ', ' || upper_value ELSE '' END,',') AS attribute_value
    , ctt_area.term as area, ctt_sub_area.term as sub_area
    FROM indicia.taxa_taxon_list_attributes ttla
    JOIN indicia.taxa_taxon_list_attribute_values ttlav on ttlav.taxa_taxon_list_attribute_id = ttla.id AND ttlav.deleted=false 
        AND (ttlav.text_value IS NOT NULL OR ttlav.int_value IS NOT NULL OR ttlav.float_value IS NOT NULL OR
	    date_start_value || ', ' || date_end_value IS NOT NULL)
    JOIN indicia.cache_taxa_taxon_lists cttl_meaning on cttl_meaning.id = ttlav.taxa_taxon_list_id AND cttl_meaning.taxon_list_id=1 
    JOIN indicia.cache_taxa_taxon_lists cttl_preferred on cttl_preferred.taxon_meaning_id = cttl_meaning.taxon_meaning_id  AND cttl_preferred.preferred=true AND
        cttl_meaning.id = taxon_record.cycling_taxa_taxon_list_id

    LEFT JOIN indicia.cache_termlists_terms ctt_meaning on ctt_meaning.id = ttlav.int_value
    LEFT JOIN indicia.cache_termlists_terms ctt_german on ctt_german.meaning_id = ctt_meaning.meaning_id  AND ctt_german.language_iso='deu'

    LEFT JOIN indicia.cache_termlists_terms ctt on ctt.id = ttlav.id
    JOIN indicia.taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id=ttla.id and tlttla.taxon_list_id = 1 and tlttla.deleted=false and tlttla.id not in (30,33,2134,2132,2133)
    JOIN indicia.cache_termlists_terms ctt_sub_area on ctt_sub_area.id = ttla.reporting_category_id 
    JOIN indicia.cache_termlists_terms ctt_area on ctt_area.id = ctt_sub_area.parent_id
    where ttla.deleted=false AND ttla.id > XXX AND ttla.id < XXX
    GROUP BY ctt_area.term, ctt_sub_area.term, ttla.id, ttla.caption,tlttla.weight
    ORDER BY ctt_area.term,ctt_sub_area.term,tlttla.weight asc
LOOP
colToUse = lower(regexp_replace(REPLACE(LEFT(attribute_record.area,15) || ' ' || LEFT(attribute_record.sub_area,15) || ' ' || LEFT(attribute_record.caption,15) || ' ' || attribute_record.id, ' ', '_'), '\W+', '', 'g'));
stmt2 = 'update complete_descriptions set ' || colToUse || ' = ''' || REPLACE(attribute_record.attribute_value,'''','') || ''' where id = ' || taxon_record.cycling_taxa_taxon_list_id;
EXECUTE stmt2;
END LOOP;
END LOOP;
END
$do$;
