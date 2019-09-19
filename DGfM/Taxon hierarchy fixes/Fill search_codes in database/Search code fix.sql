--To run this code, you will need to do replacements of,
--<taxon_file_file_path>

set search_path TO dgfm, public;

create schema if not exists dgfm;

DROP TABLE IF EXISTS tbl_simplified_taxon_list;

CREATE TABLE tbl_simplified_taxon_list (
Rang varchar (7),
Taxnr integer,
gattung varchar,
art varchar,
Qualifizierungsvermerk varchar,
autor varchar,
jahr varchar
);


COPY tbl_simplified_taxon_list
FROM <taxon_file_file_path>
WITH DELIMITER ','
CSV HEADER;

DO
$do$
declare taxon_search_code_to_update RECORD;
BEGIN 
FOR taxon_search_code_to_update IN (
select * 
from dgfm.tbl_simplified_taxon_list
)
loop
update indicia.taxa 
set search_code= taxon_search_code_to_update.Taxnr,updated_by_id=1,updated_on=now()
where 
taxon = (taxon_search_code_to_update.gattung || coalesce(' ' || taxon_search_code_to_update.art,'') ||  coalesce(' ' ||taxon_search_code_to_update.Qualifizierungsvermerk,''))
AND authority = coalesce(taxon_search_code_to_update.autor,'') || coalesce(' ' || taxon_search_code_to_update.jahr,'')
and taxon_rank_id=3 
AND id in 
(select taxon_id
from indicia.taxa_taxon_lists
where preferred = true);
END LOOP;
END
$do$;

--Should return nothing if fix has worked in full
select count(id)
from indicia.taxa_taxon_lists
where preferred = true and deleted=false and taxon_list_id = 1 and taxon_id in
(select id
from indicia.taxa
where deleted=false and search_code is NULL and taxon_rank_id=3 );

--Should return nothing if fix has worked in full
select id,taxon from indicia.cache_taxa_taxon_lists where id in 
(select id
from indicia.taxa_taxon_lists
where preferred = true and deleted=false and taxon_list_id = 1 and taxon_id in
(select id
from indicia.taxa
where deleted=false and search_code is NULL and taxon_rank_id=3))
order by id asc;
