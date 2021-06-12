
DROP table complete_hosts;
-- Create a table which holds the taxa_taxon_list_id and preferred species name and host names
CREATE TABLE complete_hosts ("id" INT, "species_name" VARCHAR, "host_names" VARCHAR);


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
stmt = 'INSERT INTO complete_hosts(id, species_name) VALUES(' || taxon_record.id || ',''' || taxon_record.taxon || ''')';
EXECUTE stmt;
END LOOP;
END
$do$;

-- Finally cycle through each species and use string_agg to add all the hosts into the host field comma separated
DO
$do$
    DECLARE taxon_record_2 RECORD;
    DECLARE host_record RECORD;
    DECLARE stmt2 varchar;
    DECLARE colToUse varchar;
BEGIN
FOR taxon_record_2 IN 
    SELECT ch_table.id as cycling_taxa_taxon_list_id, ch_table.species_name as cycling_taxon_name
    FROM complete_hosts ch_table
    ORDER BY ch_table.species_name asc
LOOP
FOR host_record IN 
    SELECT coalesce(string_agg(cttl_host.taxon, ',' ORDER BY cttl_host.taxon asc), '') as host_names
    FROM indicia.cache_taxa_taxon_lists cttl
    LEFT JOIN indicia.taxon_associations ta on ta.from_taxon_meaning_id = cttl.taxon_meaning_id and ta.deleted=false
    LEFT JOIN  indicia.cache_taxa_taxon_lists cttl_host on cttl_host.taxon_meaning_id = ta.to_taxon_meaning_id 
      AND cttl_host.preferred=true AND cttl_host.taxon_list_id = 2
    WHERE cttl.id = taxon_record_2.cycling_taxa_taxon_list_id  
LOOP
stmt2 = '
DO $$   
BEGIN         
update complete_hosts set host_names = ''' || host_record.host_names || ''' where id = ' || taxon_record_2.cycling_taxa_taxon_list_id || ';
END
$$;';
EXECUTE stmt2;
END LOOP;
END LOOP;
END
$do$;

-- Once the code has been run, the data can be exported using the following commands.
-- It is important to include the "order by", because then the row order is the same as the description files

--COPY (select * from complete_hosts order by species_name asc) TO '/root/complete_hosts.csv' DELIMITER ',' CSV HEADER;