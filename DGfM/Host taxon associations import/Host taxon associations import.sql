-- Replace the following tag with the path to your csv data files
-- <file_to_import_path>
-- Path format (on mac) should be like '/users/joebloggs/hosts.csv'
-- If running in PSQL on a server, then the path is from the PSQL working directory, you can find this out by typing "\! pwd" inside PSQL
-- Note the variables (e.g. species list ids) in this script have been setup to work with the DGfM Warehouse and this script should not be attempted on any other Warehouse
-- without taking this into account
-- Note the following row can be used to control the number of rows imported from the file and work out where problems may be occurring
-- IF (association_to_import.row_num >= 0 and association_to_import.row_num < xxxxx) THEN
/*
Use UTF-8 without BOM CSV file format
*/

create schema if not exists dgfm;
set search_path TO dgfm, public;

DROP TABLE IF EXISTS tbl_fungi_hosts;

CREATE TABLE tbl_fungi_hosts (
row_num int,
fungi_name_authority varchar,
name_of_host varchar
);

COPY tbl_fungi_hosts
FROM <file_to_import_path>
WITH DELIMITER ','
ENCODING 'UTF-8'
CSV HEADER;


DO
$do$
declare association_to_import RECORD;
BEGIN 
FOR association_to_import IN 
(
  --select_all_from_dgfm_attributes_tag
  select replace(tfh.fungi_name_authority,'  ',' ') as fungi_name_authority, replace(tfh.name_of_host,'  ',' ') as name_of_host, tfh.row_num as row_num
  from dgfm.tbl_fungi_hosts tfh
) loop
IF (association_to_import.row_num >= 0 and association_to_import.row_num < xxxxx) THEN
  IF (NOT EXISTS (
    select ta.id
    from indicia.taxon_associations ta
    join indicia.cache_taxa_taxon_lists cttl_fungi on cttl_fungi.taxon_meaning_id = ta.from_taxon_meaning_id AND 
        coalesce(trim(BOTH from lower(cttl_fungi.taxon || ' ' || cttl_fungi.authority)),cttl_fungi.taxon) like trim(BOTH from lower(association_to_import.fungi_name_authority)) || '%' and cttl_fungi.taxon_list_id = 1 and cttl_fungi.preferred = 't' and cttl_fungi.taxon_rank_id=3
    join indicia.cache_taxa_taxon_lists cttl_hosts on cttl_hosts.taxon_meaning_id = ta.to_taxon_meaning_id AND
        trim(BOTH from lower(cttl_hosts.taxon)) = trim(BOTH from lower(association_to_import.name_of_host)) and cttl_hosts.taxon_list_id = 2 and cttl_hosts.preferred = 't'
    AND ta.deleted=false
    ORDER BY ta.id desc
    LIMIT 1
  )
  AND
  EXISTS (
    select cttl_fungi.id
    from indicia.cache_taxa_taxon_lists cttl_fungi
    join indicia.cache_taxa_taxon_lists cttl_hosts on trim(BOTH from lower(cttl_hosts.taxon)) = trim(BOTH from lower(association_to_import.name_of_host))  and cttl_hosts.taxon_list_id = 2 and cttl_hosts.preferred = 't'
    where 
      coalesce(trim(BOTH from lower(cttl_fungi.taxon || ' ' || cttl_fungi.authority)),cttl_fungi.taxon) like trim(BOTH from lower(association_to_import.fungi_name_authority)) || '%' and cttl_fungi.taxon_list_id = 1 and cttl_fungi.preferred = 't' and cttl_fungi.taxon_rank_id=3
    ORDER BY cttl_fungi.id desc
    LIMIT 1
  ))
  THEN
    insert into indicia.taxon_associations (
        from_taxon_meaning_id,
        to_taxon_meaning_id,
        association_type_id,
        created_on,
        created_by_id,
        updated_on,
        updated_by_id
    )
    values (
        (select taxon_meaning_id from indicia.cache_taxa_taxon_lists where coalesce(trim(BOTH from lower(taxon || ' ' || authority)),taxon) like trim(BOTH from lower(association_to_import.fungi_name_authority)) || '%' and taxon_list_id = 1 and preferred = 't' and taxon_rank_id=3),
        (select taxon_meaning_id from indicia.cache_taxa_taxon_lists where trim(BOTH from lower(taxon)) = trim(BOTH from lower(association_to_import.name_of_host)) and taxon_list_id = 2 and preferred = 't'),
        930,
        now(),
        1,
        now(),
        1
    );
  ELSE
  END IF;
ELSE
END IF;
END LOOP;
END
$do$;