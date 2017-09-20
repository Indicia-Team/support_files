--Replace the following tag with the path to your csv data files
--<csv_plant_att_file_path>
--Path format (on mac) should be like '/users/joebloggs/plantAtt.csv'

/*
Data exported from MS Access as text files, suffix .csv, field names in first row, " delimiter.
Open each file in notepad and save as UTF-8
Open each file in Notepad++ and convert to UTF-8 without BOM
*/

-- NOW, import the data

create schema plant_portal_importer;
set search_path TO plant_portal_importer, public;

CREATE TABLE tbl_plant_att (
preferred_tvk varchar,
brc_code varchar,
taxon_name varchar,
fam varchar,
fama varchar,
orda varchar,
ns varchar,
cs varchar,
rs varchar,
chg float,
hght integer,
len float,
p1 varchar,
p2 varchar,
lf1 varchar,
lf2 varchar,
w varchar,
clone1 varchar,
clone2 varchar,
e1 varchar,
e2 varchar,
c varchar,
nbi integer,
neur varchar,
sbi integer,
seur varchar,
origin varchar,
gb integer,
ir integer,
ci integer,
tjan float,
tjul float,
prec integer,
co varchar,
br_habitats varchar,
l integer,
f integer,
r integer,
n integer,
s integer,
source_for_max_height varchar,
comment_on_life_form varchar,
comment_on_clonality varchar,
comment_on_n_and_s_limits_in_europe varchar
);

COPY tbl_plant_att
FROM <csv_plant_att_file_path>
WITH DELIMITER ','
CSV HEADER;

--Manual corrections to the data as discussed with David Roy.
delete from plant_portal_importer.tbl_plant_att
where taxon_name = 'Zostera angustifolia';

update plant_portal_importer.tbl_plant_att
set preferred_tvk='NBNSYS0000002168'
where taxon_name = 'Asparagus officinalis subsp.officinalis';



set search_path=indicia, public;
DO
$do$
BEGIN

insert into indicia.termlists (title,description,website_id,parent_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Plant Portal sources','Plant Portal sources',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),
(select id from termlists where external_key='indicia:attribute_sources' and deleted=false order by id desc limit 1),
now(),1,now(),1,'indicia:plant_portal_sources');


perform insert_term('PLANTATT - attributes of British and Irish plants.','eng',null,'indicia:plant_portal_sources');


insert into termlists_term_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id)
values (
'PLANTATT source link'
,'T',now(),1,now(),1);

insert into termlists_termlists_term_attributes (termlists_term_attribute_id,termlist_id,created_on,created_by_id)
values (
(select id from termlists_term_attributes where caption = 'PLANTATT source link' and deleted=false order by id desc limit 1),
(select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1)
,now(),1);

insert into
indicia.termlists_term_attribute_values (termlists_term_id,termlists_term_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
values (
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)),
(select id from termlists_term_attributes where caption = 'PLANTATT source link' order by id desc limit 1),
'http://brc.ac.uk/sites/www.brc.ac.uk/files/biblio/PLANTATT_19_Nov_08.zip'
,1,now(),1,now());

insert into termlists_term_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id)
values (
'PLANTATT source references'
,'T',now(),1,now(),1);

insert into termlists_termlists_term_attributes (termlists_term_attribute_id,termlist_id,created_on,created_by_id)
values (
(select id from termlists_term_attributes where caption = 'PLANTATT source references' and deleted=false order by id desc limit 1),
(select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1)
,now(),1);

insert into
indicia.termlists_term_attribute_values (termlists_term_id,termlists_term_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
values (
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)),
(select id from termlists_term_attributes where caption = 'PLANTATT source references' order by id desc limit 1),
'Hill, M.O., Preston, C.D., & Roy, D.B. (2004). NERC Centre for Ecology & Hydrology: Monks Wood.'
,1,now(),1,now());


END
$do$;


--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>

set search_path=indicia, public;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Height (terrestrial) (Hght)','I',now(),1,now(),1,'Hght for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Height (terrestrial) (Hght)'
ORDER BY id DESC 
LIMIT 1;


insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('No of 10-km squares in Britain (inc Isle of Man)','I',now(),1,now(),1,'Number of 10-km squares in Britain (including Isle of Man) (GB) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='No of 10-km squares in Britain (inc Isle of Man)'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('No of 10-km squares in Ireland','I',now(),1,now(),1,'Number of 10-km squares in Ireland (IR) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='No of 10-km squares in Ireland'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('No of 10-km squares in Channel Islands','I',now(),1,now(),1,'Number of 10-km squares in Channel Islands (CI) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='No of 10-km squares in Channel Islands'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Annual precipitation','I',now(),1,now(),1,'Annual precipitation (Prec) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Annual precipitation'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Ellenberg indicator value (L)','I',now(),1,now(),1,'Ellenberg indicator value (L) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Ellenberg indicator value (L)'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Ellenberg indicator value (F)','I',now(),1,now(),1,'Ellenberg indicator value (F) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Ellenberg indicator value (F)'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Ellenberg indicator value (R)','I',now(),1,now(),1,'Ellenberg indicator value (R) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Ellenberg indicator value (R)'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Ellenberg indicator value (N)','I',now(),1,now(),1,'Ellenberg indicator value (N) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Ellenberg indicator value (N)'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Ellenberg indicator value (S)','I',now(),1,now(),1,'Ellenberg indicator value (S) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Ellenberg indicator value (S)'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Length (aquatic)','F',now(),1,now(),1,'Length (aquatic) (Len) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Length (aquatic)'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Change index','F',now(),1,now(),1,'Change index (Chg) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Change index'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('January mean temperature','F',now(),1,now(),1,'January mean temperature (Tjan) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='January mean temperature'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('July mean temperature','F',now(),1,now(),1,'July mean temperature (Tjul) for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='July mean temperature'
ORDER BY id DESC 
LIMIT 1;

--Import height data
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.Hght as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Hght IS NOT NULL
) loop
--We don't need to do any checks to make sure we aren't adding duplicate attribute data (unlike Pantheon) as there are only preferred_tvks in the import
--data and these only contain one attribute value each per trait.
--However the code isn't doing any harm here and it is known to be reliable so best to leave it in.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Height (terrestrial) (Hght)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Height (terrestrial) (Hght)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;


--Import No of 10-km squares in Britain (inc Isle of Man)
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.GB as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.GB IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='No of 10-km squares in Britain (inc Isle of Man)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='No of 10-km squares in Britain (inc Isle of Man)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import No of 10-km squares in Ireland
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.IR as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.IR IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='No of 10-km squares in Ireland' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='No of 10-km squares in Ireland' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import No of 10-km squares in Channel Islands
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.CI as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.CI IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='No of 10-km squares in Channel Islands' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='No of 10-km squares in Channel Islands' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import Annual precipitation
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.Prec as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Prec IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Annual precipitation' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Annual precipitation' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import Ellenberg indicator value (L)
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.L as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.L IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (L)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (L)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import Ellenberg indicator value (F)
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.F as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.F IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (F)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (F)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import Ellenberg indicator value (R)
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.R as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.R IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (R)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (R)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Ellenberg indicator value (N)
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.N as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.N IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (N)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (N)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Ellenberg indicator value (S)
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.S as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.S IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (S)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Ellenberg indicator value (S)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import aquatic length data
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.Len as float) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Len IS NOT NULL
) loop
--We don't need to do any checks to make sure we aren't adding duplicate attribute data (unlike Pantheon) as there are only preferred_tvks in the import
--data and these only contain one attribute value each per trait.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Length (aquatic)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,float_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Length (aquatic)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import change index (chg)
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.Chg as float) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Chg IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Change index' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,float_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Change index' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import January mean temperature
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.Tjan as float) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Tjan IS NOT NULL
) loop
--We don't need to do any checks to make sure we aren't adding duplicate attribute data (unlike Pantheon) as there are only preferred_tvks in the import
--data and these only contain one attribute value each per trait.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='January mean temperature' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,float_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='January mean temperature' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Import July mean temperature
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.Tjul as float) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Tjul IS NOT NULL
) loop
--We don't need to do any checks to make sure we aren't adding duplicate attribute data (unlike Pantheon) as there are only preferred_tvks in the import
--data and these only contain one attribute value each per trait.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='July mean temperature' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,float_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='July mean temperature' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;


--This script assumes the name of the Plant Portal website is "Plant Portal", if it isn't you will need to adjust the website name in the script.
--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>

set search_path TO indicia, public;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id, description,source_id)
values ('Continentality in europe','B',now(),1,now(),1,'Species marked c are continental, i.e. they are rare in the atlantic zone of Europe but commoner further east',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Continentality in europe'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values ('Reaching northern European limit in British Isles','B',now(),1,now(),1,'Reaching northern European limit in British Isles for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Reaching northern European limit in British Isles'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id, description,source_id)
values ('Reaching southern European limit in British Isles','B',now(),1,now(),1,'Reaching southern European limit in British Isles for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Reaching southern European limit in British Isles'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id, description,source_id)
values ('Coastal','B',now(),1,now(),1,'At least 80% of occupied squares contain sea at high tide',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Coastal'
ORDER BY id DESC 
LIMIT 1;







--Import Continentality in europe
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
--Note as we are only return non-null data all the data will have a 'c' value, and as 'c' equates to true (1) then we only ever need to put one into the int_value field
(select ittl.id as taxa_taxon_list_id,1 as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.C IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Continentality in europe' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Continentality in europe' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;








--Import Reaching northern European limit in British Isles
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
--The spreadsheet has 1s and 0s which can go straight into the int_value field for the boolean attribute
(select ittl.id as taxa_taxon_list_id,cast(ppt.NBI as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.NBI IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Reaching northern European limit in British Isles' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Reaching northern European limit in British Isles' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;








--Import Reaching southern European limit in British Isles
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
--The spreadsheet has 1s and 0s which can go straight into the int_value field for the boolean attribute
(select ittl.id as taxa_taxon_list_id,cast(ppt.SBI as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.SBI IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Reaching southern European limit in British Isles' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Reaching southern European limit in British Isles' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;







--Import Coastal
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
--Note as we are only return non-null data all the data will have a 'Co' value, and as 'Co' equates to true (1) then we only even need to put one into the int_value field
(select ittl.id as taxa_taxon_list_id,1 as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Co IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Coastal' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Coastal' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;



--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

--Setup Native Status (NS)
update plant_portal_importer.tbl_plant_att
set ns='Alien casual; many are crop plants (AC)'
where ns='AC';

update plant_portal_importer.tbl_plant_att
set ns='Neophyte, alien introduced after 1500 (AN)'
where ns='AN';

update plant_portal_importer.tbl_plant_att
set ns='Archaeophyte, alien introduced before 1500 (AR)'
where ns='AR';

update plant_portal_importer.tbl_plant_att
set ns='Spontaneous hybrid between two alien parents (AX)'
where ns='AX';

update plant_portal_importer.tbl_plant_att
set ns='Native, not endemic (N)'
where ns='N';

update plant_portal_importer.tbl_plant_att
set ns='Native or alien (native status doubtful) (NA)'
where ns='NA';

update plant_portal_importer.tbl_plant_att
set ns='Native endemic (NE)'
where ns='NE';

update plant_portal_importer.tbl_plant_att
set ns='Spontaneous hybrid between two native parents (NH)'
where ns='NH';

set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Native status','Native status',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:native_status');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Native status','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Native status' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Native status'
ORDER BY id DESC 
LIMIT 1;

--Need to put terms in by hand. There is not gauruntee the terms we need are already in the existing data, get terms from PlantAtt PDF document
select insert_term('Alien casual; many are crop plants (AC)','eng',null,'indicia:native_status');
select insert_term('Neophyte, alien introduced after 1500 (AN)','eng',null,'indicia:native_status');
select insert_term('Archaeophyte, alien introduced before 1500 (AR)','eng',null,'indicia:native_status');
select insert_term('Spontaneous hybrid between two alien parents (AX)','eng',null,'indicia:native_status');
select insert_term('Native, not endemic (N)','eng',null,'indicia:native_status');
select insert_term('Native or alien (native status doubtful) (NA)','eng',null,'indicia:native_status');
select insert_term('Native endemic (NE)','eng',null,'indicia:native_status');
select insert_term('Spontaneous hybrid between two native parents (NH)','eng',null,'indicia:native_status');

--Do the import itself.
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.ns AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Native status' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.ns IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Native status' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
--Again this assumes Native Status is the only termlist called that
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Native status' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;























update plant_portal_importer.tbl_plant_att
set cs='Critically endangered (CR)'
where cs='CR';

update plant_portal_importer.tbl_plant_att
set cs='Data deficient (DD)'
where cs='DD';

update plant_portal_importer.tbl_plant_att
set cs='Endangered (EN)'
where cs='EN';

update plant_portal_importer.tbl_plant_att
set cs='Extinct in the wild (EW)'
where cs='EW';

update plant_portal_importer.tbl_plant_att
set cs='Extinct (EX)'
where cs='EX';

update plant_portal_importer.tbl_plant_att
set cs='Vulnerable (VU)'
where cs='VU';

insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Conservation status','Conservation status',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:conservation_status');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Conservation status','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Conservation status' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Conservation status'
ORDER BY id DESC 
LIMIT 1;


select insert_term('Critically endangered (CR)','eng',null,'indicia:conservation_status');
select insert_term('Data deficient (DD)','eng',null,'indicia:conservation_status');
select insert_term('Endangered (EN)','eng',null,'indicia:conservation_status');
select insert_term('Extinct in the wild (EW)','eng',null,'indicia:conservation_status');
select insert_term('Extinct (EX)','eng',null,'indicia:conservation_status');
select insert_term('Vulnerable (VU)','eng',null,'indicia:conservation_status');




set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.cs AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Conservation status' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.cs IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Conservation status' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Conservation status' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;



















update plant_portal_importer.tbl_plant_att
set rs='Present, not rare or scarce (n)'
where rs='n';

update plant_portal_importer.tbl_plant_att
set rs='Rare (1-15 10-km squares in Britain, 1987-1999) (r)'
where rs='r';

update plant_portal_importer.tbl_plant_att
set rs='Scarce (16-100 10-km squares in Britain, 1987-1999) (s)'
where rs='s';

update plant_portal_importer.tbl_plant_att
set rs='Absent from Britain and Isle of Man as a native, but native in Ireland or the Channel Islands) (o)'
where rs='o';

update plant_portal_importer.tbl_plant_att
set rs='Apparently extinct (not recorded since 1986) (x)'
where rs='x';

update plant_portal_importer.tbl_plant_att
set rs='Insufficient data available to assess rarity (i)'
where rs='i';

update plant_portal_importer.tbl_plant_att
set rs='Alien taxa'
where rs='' or rs IS NULL;

insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Rarity status','Rarity status',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:rarity_status');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Rarity status','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Rarity status' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Rarity status'
ORDER BY id DESC 
LIMIT 1;


select insert_term('Present, not rare or scarce (n)','eng',null,'indicia:rarity_status');
select insert_term('Rare (1-15 10-km squares in Britain, 1987-1999) (r)','eng',null,'indicia:rarity_status');
select insert_term('Scarce (16-100 10-km squares in Britain, 1987-1999) (s)','eng',null,'indicia:rarity_status');
select insert_term('Absent from Britain and Isle of Man as a native, but native in Ireland or the Channel Islands) (o)','eng',null,'indicia:rarity_status');
select insert_term('Apparently extinct (not recorded since 1986) (x)','eng',null,'indicia:rarity_status');
select insert_term('Insufficient data available to assess rarity (i)','eng',null,'indicia:rarity_status');
select insert_term('Alien taxa','eng',null,'indicia:rarity_status');

set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.rs AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Rarity status' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
--"Alien taxa" is selected if the data is null, however we can still do a null check here because we have already converted the null values to be "Alien taxa"
where ppt.rs IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Rarity status' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Rarity status' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;






--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

--Update original data to be proper terms rather than just codes
update plant_portal_importer.tbl_plant_att
set p1='biennial (b)'
where p1='b';

update plant_portal_importer.tbl_plant_att
set p2='biennial (b)'
where p2='b';

update plant_portal_importer.tbl_plant_att
set p1='annual (a)'
where p1='a';

update plant_portal_importer.tbl_plant_att
set p2='annual (a)'
where p2='a';

update plant_portal_importer.tbl_plant_att
set p1='perennial (p)'
where p1='p';

update plant_portal_importer.tbl_plant_att
set p2='perennial (p)'
where p2='p';




set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Perennation','Perennation for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:perennation');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Perennation 1','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Perennation' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Perennation 2','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Perennation' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);


--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Perennation 1'
ORDER BY id DESC 
LIMIT 1;

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Perennation 2'
ORDER BY id DESC 
LIMIT 1;

--Need to put terms in by hand. There is not gauruntee the terms we need are already in the existing data, get terms from PlantAtt PDF document
select insert_term('biennial (b)','eng',null,'indicia:perennation');
select insert_term('annual (a)','eng',null,'indicia:perennation');
select insert_term('perennial (p)','eng',null,'indicia:perennation');










--Works much the same as previous importer files, see comments on those
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.p1 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Perennation' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.p1 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Perennation 1' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Perennation 1' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.p2 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Perennation' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.p2 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Perennation 2' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Perennation 2' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;




--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.


--Update original data to be proper terms rather than just codes
update plant_portal_importer.tbl_plant_att
set lf1='Chamaephyte (Ch)'
where lf1='Ch';

update plant_portal_importer.tbl_plant_att
set lf2='Chamaephyte (Ch)'
where lf2='Ch';

update plant_portal_importer.tbl_plant_att
set lf1='Bulbous geophyte (Gb)'
where lf1='Gb';

update plant_portal_importer.tbl_plant_att
set lf2='Bulbous geophyte (Gb)'
where lf2='Gb';

update plant_portal_importer.tbl_plant_att
set lf1='Non-bulbous geophyte (rhizome, corm or tuber) (Gn)'
where lf1='Gn';

update plant_portal_importer.tbl_plant_att
set lf2='Non-bulbous geophyte (rhizome, corm or tuber) (Gn)'
where lf2='Gn';

update plant_portal_importer.tbl_plant_att
set lf1='Hemicryptophyte (hc)'
where lf1='hc';

update plant_portal_importer.tbl_plant_att
set lf2='Hemicryptophyte (hc)'
where lf2='hc';

update plant_portal_importer.tbl_plant_att
set lf1='Perennial hydrophyte (perennial water plant) (Hy)'
where lf1='Hy';

update plant_portal_importer.tbl_plant_att
set lf2='Perennial hydrophyte (perennial water plant) (Hy)'
where lf2='Hy';

update plant_portal_importer.tbl_plant_att
set lf1='Annual hydrophyte (aquatic therophyte) (Hz)'
where lf1='Hz';

update plant_portal_importer.tbl_plant_att
set lf2='Annual hydrophyte (aquatic therophyte) (Hz)'
where lf2='Hz';

update plant_portal_importer.tbl_plant_att
set lf1='Mega-, meso- and microphanerophyte (Ph)'
where lf1='Ph';

update plant_portal_importer.tbl_plant_att
set lf2='Mega-, meso- and microphanerophyte (Ph)'
where lf2='Ph';

update plant_portal_importer.tbl_plant_att
set lf1='Nanophanerophyte (Pn)'
where lf1='Pn';

update plant_portal_importer.tbl_plant_att
set lf2='Nanophanerophyte  (Pn)'
where lf2='Pn';

update plant_portal_importer.tbl_plant_att
set lf1='Therophyte (annual land plant) (Th)'
where lf1='Th';

update plant_portal_importer.tbl_plant_att
set lf2='Therophyte (annual land plant) (Th)'
where lf2='Th';





set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Life form','Life forms for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:life_form');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Life form 1','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Life form' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Life form 2','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Life form' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);


--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption in ('Life form 1', 'Life form 2')
ORDER BY id DESC 
LIMIT 2;

--Need to put terms in by hand. There is not gauruntee the terms we need are already in the existing data, get terms from PlantAtt PDF document
select insert_term('Chamaephyte (Ch)','eng',null,'indicia:life_form');
select insert_term('Bulbous geophyte (Gb)','eng',null,'indicia:life_form');
select insert_term('Non-bulbous geophyte (rhizome, corm or tuber) (Gn)','eng',null,'indicia:life_form');
select insert_term('Hemicryptophyte (hc)','eng',null,'indicia:life_form');
select insert_term('Perennial hydrophyte (perennial water plant) (Hy)','eng',null,'indicia:life_form');
select insert_term('Annual hydrophyte (aquatic therophyte) (Hz)','eng',null,'indicia:life_form');
select insert_term('Mega-, meso- and microphanerophyte (Ph)','eng',null,'indicia:life_form');
select insert_term('Nanophanerophyte  (Pn)','eng',null,'indicia:life_form');
select insert_term('Therophyte (annual land plant) (Th)','eng',null,'indicia:life_form');



--Importer largely the same as other files, see other files for comments
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.lf1 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Life form' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.lf1 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Life form 1' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Life form 1' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.lf2 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Life form' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.lf2 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Life form 2' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Life form 2' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;




--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

--Update terms in original data to be full length
update plant_portal_importer.tbl_plant_att
set w='Herbaceous (h)'
where w='h';

update plant_portal_importer.tbl_plant_att
set w='Semi-woody (sw)'
where w='sw';

update plant_portal_importer.tbl_plant_att
set w='Woody (w)'
where w='w';

insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Woodiness','Woodiness for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:woodiness');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Woodiness','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Woodiness' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Woodiness'
ORDER BY id DESC 
LIMIT 1;

select insert_term('Herbaceous (h)','eng',null,'indicia:woodiness');
select insert_term('Semi-woody (sw)','eng',null,'indicia:woodiness');
select insert_term('Woody (w)','eng',null,'indicia:woodiness');

set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.w AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Woodiness' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.w IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Woodiness' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Woodiness' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;














update plant_portal_importer.tbl_plant_att
set clone1='Little or no vegetative spread (0)'
where clone1='0';

update plant_portal_importer.tbl_plant_att
set clone2='Little or no vegetative spread (0)'
where clone2='0';

update plant_portal_importer.tbl_plant_att
set clone1='Tussock-forming graminoid, may slowly spread (0gr)'
where clone1='0gr';

update plant_portal_importer.tbl_plant_att
set clone2='Tussock-forming graminoid, may slowly spread (0gr)'
where clone2='0gr';

update plant_portal_importer.tbl_plant_att
set clone1='Tuberous or bulbous, slowing cloning by offsets (0tb)'
where clone1='0tb';

update plant_portal_importer.tbl_plant_att
set clone2='Tuberous or bulbous, slowing cloning by offsets (0tb)'
where clone2='0tb';

update plant_portal_importer.tbl_plant_att
set clone1='Detaching ramets above ground (often axillary) (DRa)'
where clone1='DRa';

update plant_portal_importer.tbl_plant_att
set clone2='Detaching ramets above ground (often axillary) (DRa)'
where clone2='DRa';

update plant_portal_importer.tbl_plant_att
set clone1='Detaching ramets at or below ground (DRg)'
where clone1='DRg';

update plant_portal_importer.tbl_plant_att
set clone2='Detaching ramets at or below ground (DRg)'
where clone2='DRg';

update plant_portal_importer.tbl_plant_att
set clone1='Detaching ramets on inflorescence (DRi)'
where clone1='DRi';

update plant_portal_importer.tbl_plant_att
set clone2='Detaching ramets on inflorescence (DRi)'
where clone2='DRi';

update plant_portal_importer.tbl_plant_att
set clone1='Detaching ramets on leaves (Hammarbya) (DRl)'
where clone1='DRl';

update plant_portal_importer.tbl_plant_att
set clone2='Detaching ramets on leaves (Hammarbya) (DRl)'
where clone2='DRl';

update plant_portal_importer.tbl_plant_att
set clone1='Detaching ramets on prothallus (Trichomanes) (DRp)'
where clone1='DRp';

update plant_portal_importer.tbl_plant_att
set clone2='Detaching ramets on prothallus (Trichomanes) (DRp)'
where clone2='DRp';

update plant_portal_importer.tbl_plant_att
set clone1='Fragmenting as part of normal growth (Frag)'
where clone1='Frag';

update plant_portal_importer.tbl_plant_att
set clone2='Fragmenting as part of normal growth (Frag)'
where clone2='Frag';

update plant_portal_importer.tbl_plant_att
set clone1='Irregularly fragmenting (mainly water plants) (Irreg)'
where clone1='Irreg';

update plant_portal_importer.tbl_plant_att
set clone2='Irregularly fragmenting (mainly water plants) (Irreg)'
where clone2='Irreg';

update plant_portal_importer.tbl_plant_att
set clone1='Plantlets formed on leaves (Cardamine pratensis) (Leaf)'
where clone1='Leaf';

update plant_portal_importer.tbl_plant_att
set clone2='Plantlets formed on leaves (Cardamine pratensis) (Leaf)'
where clone2='Leaf';

update plant_portal_importer.tbl_plant_att
set clone1='Shortly creeping and rooting at nodes (Node1)'
where clone1='Node1';

update plant_portal_importer.tbl_plant_att
set clone2='Shortly creeping and rooting at nodes (Node1)'
where clone2='Node1';

update plant_portal_importer.tbl_plant_att
set clone1='Extensively creeping and rooting at nodes (Node2)'
where clone1='Node2';

update plant_portal_importer.tbl_plant_att
set clone2='Extensively creeping and rooting at nodes (Node2)'
where clone2='Node2';

update plant_portal_importer.tbl_plant_att
set clone1='Rhizome shortly creeping (Rhiz1)'
where clone1='Rhiz1';

update plant_portal_importer.tbl_plant_att
set clone2='Rhizome shortly creeping (Rhiz1)'
where clone2='Rhiz1';

update plant_portal_importer.tbl_plant_att
set clone1='Rhizome far-creeping (Rhiz2)'
where clone1='Rhiz2';

update plant_portal_importer.tbl_plant_att
set clone2='Rhizome far-creeping (Rhiz2)'
where clone2='Rhiz2';

update plant_portal_importer.tbl_plant_att
set clone1='Clones formed by suckering from roots (Root)'
where clone1='Root';

update plant_portal_importer.tbl_plant_att
set clone2='Clones formed by suckering from roots (Root)'
where clone2='Root';

update plant_portal_importer.tbl_plant_att
set clone1='Shortly creeping, stolons in illuminated medium (Stol1)'
where clone1='Stol1';

update plant_portal_importer.tbl_plant_att
set clone2='Shortly creeping, stolons in illuminated medium (Stol1)'
where clone2='Stol1';

update plant_portal_importer.tbl_plant_att
set clone1='Far-creeping by stolons in illuminated medium (Stol2)'
where clone1='Stol2';

update plant_portal_importer.tbl_plant_att
set clone2='Far-creeping by stolons in illuminated medium (Stol2)'
where clone2='Stol2';

update plant_portal_importer.tbl_plant_att
set clone1='Tip rooting (the stems often turn downwards) (Tip)'
where clone1='Tip';

update plant_portal_importer.tbl_plant_att
set clone2='Tip rooting (the stems often turn downwards) (Tip)'
where clone2='Tip';


insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Categories of clonality','Categories of clonality for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:categories_of_clonality');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Categories of clonality 1','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Categories of clonality' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Categories of clonality 2','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Categories of clonality' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);


insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption in ('Categories of clonality 1','Categories of clonality 2')
ORDER BY id DESC 
LIMIT 2;


select insert_term('Little or no vegetative spread (0)','eng',null,'indicia:categories_of_clonality');
select insert_term('Tussock-forming graminoid, may slowly spread (0gr)','eng',null,'indicia:categories_of_clonality');
select insert_term('Tuberous or bulbous, slowing cloning by offsets (0tb)','eng',null,'indicia:categories_of_clonality');
select insert_term('Detaching ramets above ground (often axillary) (DRa)','eng',null,'indicia:categories_of_clonality');
select insert_term('Detaching ramets at or below ground (DRg)','eng',null,'indicia:categories_of_clonality');
select insert_term('Detaching ramets on inflorescence (DRi)','eng',null,'indicia:categories_of_clonality');
select insert_term('Detaching ramets on leaves (Hammarbya) (DRl)','eng',null,'indicia:categories_of_clonality');
select insert_term('Detaching ramets on prothallus (Trichomanes) (DRp)','eng',null,'indicia:categories_of_clonality');
select insert_term('Fragmenting as part of normal growth (Frag)','eng',null,'indicia:categories_of_clonality');
select insert_term('Irregularly fragmenting (mainly water plants) (Irreg)','eng',null,'indicia:categories_of_clonality');
select insert_term('Plantlets formed on leaves (Cardamine pratensis) (Leaf)','eng',null,'indicia:categories_of_clonality');
select insert_term('Shortly creeping and rooting at nodes (Node1)','eng',null,'indicia:categories_of_clonality');
select insert_term('Extensively creeping and rooting at nodes (Node2)','eng',null,'indicia:categories_of_clonality');
select insert_term('Rhizome shortly creeping (Rhiz1)','eng',null,'indicia:categories_of_clonality');
select insert_term('Rhizome far-creeping (Rhiz2)','eng',null,'indicia:categories_of_clonality');
select insert_term('Clones formed by suckering from roots (Root)','eng',null,'indicia:categories_of_clonality');
select insert_term('Shortly creeping, stolons in illuminated medium (Stol1)','eng',null,'indicia:categories_of_clonality');
select insert_term('Far-creeping by stolons in illuminated medium (Stol2)','eng',null,'indicia:categories_of_clonality');
select insert_term('Tip rooting (the stems often turn downwards) (Tip)','eng',null,'indicia:categories_of_clonality');








set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.clone1 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Categories of clonality' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.clone1 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Categories of clonality 1' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Categories of clonality 1' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.clone2 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Categories of clonality' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.clone2 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Categories of clonality 2' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Categories of clonality 2' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;




--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

--Update terms in original data to be full length
update plant_portal_importer.tbl_plant_att
set e1='Arctic-montane (main distribution in tundra or above tree-line in temperate mountains) (1)'
where e1='1';

update plant_portal_importer.tbl_plant_att
set e1='Boreo-arctic montane (in tundra and coniferous forest zones) (2)'
where e1='2';

update plant_portal_importer.tbl_plant_att
set e1='Wide-boreal (from temperate zone to tundra) (3)'
where e1='3';

update plant_portal_importer.tbl_plant_att
set e1='Boreal-montane (main distribution in coniferous forest zone) (4)'
where e1='4';

update plant_portal_importer.tbl_plant_att
set e1='Boreo-temperate (in conifer and broadleaf zones) (5)'
where e1='5';

update plant_portal_importer.tbl_plant_att
set e1='Wide-temperate (from Mediterranean region to coniferous forest zone) (6)'
where e1='6';

update plant_portal_importer.tbl_plant_att
set e1='Temperate (in broadleaf forest zone) (7)'
where e1='7';

update plant_portal_importer.tbl_plant_att
set e1='Southern-temperate (in Mediterranean region and broadleaf forest zones) (8)'
where e1='8';

update plant_portal_importer.tbl_plant_att
set e1='Mediterranean-atlantic (in Med region, extending north in atlantic zone of temperate Europe) (9)'
where e1='9';

update plant_portal_importer.tbl_plant_att
set e1='Mediterranean (native range of some aliens) (0)'
where e1='0';

set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Biogeographic element, major biome (E1)','Biogeographic element, major biome for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:major_biome');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Biogeographic element, major biome (E1)','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Biogeographic element, major biome (E1)' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Biogeographic element, major biome (E1)'
ORDER BY id DESC 
LIMIT 1;

select insert_term('Arctic-montane (main distribution in tundra or above tree-line in temperate mountains) (1)','eng',null,'indicia:major_biome');
select insert_term('Boreo-arctic montane (in tundra and coniferous forest zones) (2)','eng',null,'indicia:major_biome');
select insert_term('Wide-boreal (from temperate zone to tundra) (3)','eng',null,'indicia:major_biome');
select insert_term('Boreal-montane (main distribution in coniferous forest zone) (4)','eng',null,'indicia:major_biome');
select insert_term('Boreo-temperate (in conifer and broadleaf zones) (5)','eng',null,'indicia:major_biome');
select insert_term('Wide-temperate (from Mediterranean region to coniferous forest zone) (6)','eng',null,'indicia:major_biome');
select insert_term('Temperate (in broadleaf forest zone) (7)','eng',null,'indicia:major_biome');
select insert_term('Southern-temperate (in Mediterranean region and broadleaf forest zones) (8)','eng',null,'indicia:major_biome');
select insert_term('Mediterranean-atlantic (in Med region, extending north in atlantic zone of temperate Europe) (9)','eng',null,'indicia:major_biome');
select insert_term('Mediterranean (native range of some aliens) (0)','eng',null,'indicia:major_biome');



set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.e1 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Biogeographic element, major biome (E1)' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.e1 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Biogeographic element, major biome (E1)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Biogeographic element, major biome (E1)' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;










--Now do exactly the same for traits E2
update plant_portal_importer.tbl_plant_att
set e2='Hyperoceanic, with a western distribution in atlantic zone (0)'
where e2='0';

update plant_portal_importer.tbl_plant_att
set e2='Oceanic (in atlantic zone of Europe, not or scarcely reaching east to Sweden, Germany, S Spain) (1)'
where e2='1';

update plant_portal_importer.tbl_plant_att
set e2='Suboceanic (extending east to Sweden, C Europe or Italy) (2)'
where e2='2';

update plant_portal_importer.tbl_plant_att
set e2='European (extending to more continental parts of Europe but not to Siberia) (3)'
where e2='3';

update plant_portal_importer.tbl_plant_att
set e2='Eurosiberian (eastern limit between 60°E and 120°E) (4)'
where e2='4';

update plant_portal_importer.tbl_plant_att
set e2='Eurasian (extending across Asia to east of 120°E) (5)'
where e2='5';

update plant_portal_importer.tbl_plant_att
set e2='Circumpolar (in Europe,Asia and N America) (6)'
where e2='6';


insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Biogeographic element, eastern limit category (E2)','Biogeographic element, eastern limit category for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:eastern_limit_category');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'Biogeographic element, eastern limit category (E2)','L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='Biogeographic element, eastern limit category (E2)' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Biogeographic element, eastern limit category (E2)'
ORDER BY id DESC 
LIMIT 1;

select insert_term('Hyperoceanic, with a western distribution in atlantic zone (0)','eng',null,'indicia:eastern_limit_category');
select insert_term('Oceanic (in atlantic zone of Europe, not or scarcely reaching east to Sweden, Germany, S Spain) (1)','eng',null,'indicia:eastern_limit_category');
select insert_term('Suboceanic (extending east to Sweden, C Europe or Italy) (2)','eng',null,'indicia:eastern_limit_category');
select insert_term('European (extending to more continental parts of Europe but not to Siberia) (3)','eng',null,'indicia:eastern_limit_category');
select insert_term('Eurosiberian (eastern limit between 60°E and 120°E) (4)','eng',null,'indicia:eastern_limit_category');
select insert_term('Eurasian (extending across Asia to east of 120°E) (5)','eng',null,'indicia:eastern_limit_category');
select insert_term('Circumpolar (in Europe,Asia and N America) (6)','eng',null,'indicia:eastern_limit_category');


set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.e2 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Biogeographic element, eastern limit category (E2)' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.e2 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Biogeographic element, eastern limit category (E2)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values 
(taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Biogeographic element, eastern limit category (E2)' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;


--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

set search_path TO indicia, public;
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Lat of northern European limit 5º band (NEur)-LV','I',now(),1,now(),1,'Holds lower NEur value',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Lat of northern European limit 5º band (NEur)-HV','I',now(),1,now(),1,'Holds higher NEur value',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Lat of northern European limit 5º band (SEur)-LV','I',now(),1,now(),1,'Holds lower SEur value',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Lat of northern European limit 5º band (SEur)-HV','I',now(),1,now(),1,'Holds higher SEur value',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (NEur)-LV'
ORDER BY id DESC 
LIMIT 1;

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (NEur)-HV'
ORDER BY id DESC 
LIMIT 1;

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (SEur)-LV'
ORDER BY id DESC 
LIMIT 1;

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (SEur)-HV'
ORDER BY id DESC 
LIMIT 1;


ALTER TABLE plant_portal_importer.tbl_plant_att
ADD COLUMN NEur_lower integer,
ADD COLUMN NEur_higher integer,
ADD COLUMN SEur_lower integer,
ADD COLUMN SEur_higher integer;


DO
$do$
declare neur_seur_to_convert RECORD;
BEGIN
FOR neur_seur_to_convert IN 
select NEur, SEur, NEur_lower, NEur_higher, SEur_lower, SEur_higher,preferred_tvk
from plant_portal_importer.tbl_plant_att
loop

update plant_portal_importer.tbl_plant_att
set NEur_lower=
	(case when neur_seur_to_convert.NEur LIKE '%-%' THEN 
		cast(substring(neur_seur_to_convert.NEur from '\d+') as integer)
	when neur_seur_to_convert.NEur LIKE '>%' THEN
		cast(substring(neur_seur_to_convert.NEur from '(\d+)(?!.*\d)')  as integer)
	END)
where preferred_tvk = neur_seur_to_convert.preferred_tvk;

update plant_portal_importer.tbl_plant_att
set NEur_higher=
	(case when neur_seur_to_convert.NEur LIKE '%-%' THEN 
		cast(substring(neur_seur_to_convert.NEur from '(\d+)(?!.*\d)') as integer) 
	when neur_seur_to_convert.NEur LIKE '<%' THEN
		cast(substring(neur_seur_to_convert.NEur from '(\d+)(?!.*\d)') as integer)
	END)
where preferred_tvk = neur_seur_to_convert.preferred_tvk;


update plant_portal_importer.tbl_plant_att
set SEur_lower=
	(case when neur_seur_to_convert.SEur LIKE '%-%' THEN 
		cast(substring(neur_seur_to_convert.SEur from '\d+') as integer) 
	when neur_seur_to_convert.SEur LIKE '>%' THEN
		cast(substring(neur_seur_to_convert.SEur from '(\d+)(?!.*\d)') as integer) 
	END)
where preferred_tvk = neur_seur_to_convert.preferred_tvk;

update plant_portal_importer.tbl_plant_att
set SEur_higher=
	(case when neur_seur_to_convert.SEur LIKE '%-%' THEN 
		cast(substring(neur_seur_to_convert.SEur from '(\d+)(?!.*\d)') as integer)  
	when neur_seur_to_convert.SEur LIKE '<%' THEN
		cast(substring(neur_seur_to_convert.SEur from '(\d+)(?!.*\d)') as integer) 
	END)
where preferred_tvk = neur_seur_to_convert.preferred_tvk;

END LOOP;
END
$do$;



DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.NEur_lower as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.NEur_lower IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (NEur)-LV' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (NEur)-LV' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;





DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.NEur_higher as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.NEur_higher IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (NEur)-HV' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (NEur)-HV' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;





DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.SEur_lower as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.SEur_lower IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (SEur)-LV' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (SEur)-LV' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;




DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.SEur_higher as integer) as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.SEur_higher IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (SEur)-HV' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Lat of northern European limit 5º band (SEur)-HV' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

DO
$do$
DECLARE trait_to_import RECORD;
DECLARE origin_piece   varchar[];
DECLARE origin_to_split_array   varchar[];

BEGIN
--None of the origins should have a question mark, however they do, so remove them for now until I have asked about this.
--I presume this was left in the data as it is considered unsure
update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'?','');

--These codes are problematic if try and replace in the real expanded terms. For instance, the code "Am" would appear in many of the expanded
--terms also. We only want to do replacements for the codes, not parts of words in the full expanded terms.
--We can overcome this issue by changing the codes to be properly unique such that they would never appear in real words and such that they
--don't clash with each other either.
--Note that the ordering of the processing is important e.g. "SAm" is processed early to avoid clashing with "Am"
update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'SAm','S:A:m');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Am4','A;m;4');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Am6','A\m\6');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Am','A/m');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'As1','A>s>1');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'As2','A<s<2');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'As','A.s');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Aus','A-u-s');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Crop','C{r{o{p');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Eur','E}u}r');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Gard','G"a"r"d');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'NHem','N?H?e?m');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'NZ','N[Z');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'SAf','S]A]f');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'Unk','U#n#k');



update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'S:A:m','South America and/or Central America');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'A;m;4','Western North America');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'A\m\6','Eastern North America');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'A/m','North America');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'A>s>1','Asia between 60°E and 120°E');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'A<s<2','Asia E of 120°E');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'A.s','Asia east of 60°E');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'A-u-s','Australia');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'C{r{o{p','Crop plant| does not have a native range');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'E}u}r','Europe');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'G"a"r"d','Garden origin| does not have a native range');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'N?H?e?m','N Hemisphere (Europe|Asia and North America)');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'N[Z','New Zealand');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'S]A]f','Southern Africa');

update plant_portal_importer.tbl_plant_att
set origin=replace(origin,'U#n#k','Unknown');

set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('origin','Origin terms for Plant Portal',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:origin');

insert into taxa_taxon_list_attributes (caption,multi_value,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'origin',true,'L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='origin' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='origin'
ORDER BY id DESC 
LIMIT 1;

perform insert_term('South America and/or Central America','eng',null,'indicia:origin');
perform insert_term('North America','eng',null,'indicia:origin');
perform insert_term('Western North America','eng',null,'indicia:origin');
perform insert_term('Eastern North America','eng',null,'indicia:origin');
perform insert_term('Asia east of 60°E','eng',null,'indicia:origin');
perform insert_term('Asia between 60°E and 120°E','eng',null,'indicia:origin');
perform insert_term('Asia E of 120°E','eng',null,'indicia:origin');
perform insert_term('Australia','eng',null,'indicia:origin');
perform insert_term('Crop plant| does not have a native range','eng',null,'indicia:origin');
perform insert_term('Europe','eng',null,'indicia:origin');
perform insert_term('Garden origin| does not have a native range','eng',null,'indicia:origin');
perform insert_term('N Hemisphere (Europe|Asia and North America)','eng',null,'indicia:origin');
perform insert_term('New Zealand','eng',null,'indicia:origin');
perform insert_term('Southern Africa','eng',null,'indicia:origin');
perform insert_term('Unknown','eng',null,'indicia:origin');


FOR trait_to_import IN
(select ittl.id as taxa_taxon_list_id, origin as origin_to_split
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.origin IS NOT NULL
) loop
  origin_to_split_array = string_to_array(trait_to_import.origin_to_split, ',');
  FOR i IN array_lower(origin_to_split_array, 1) .. array_upper(origin_to_split_array, 1)
      LOOP
         --As this is a multi-value attribute, this time we only don't add the trait if there is an exact taxa_taxon_list_id and attribute value match
         IF (NOT EXISTS (
           select ttlav2.id
           from taxa_taxon_list_attribute_values ttlav2
           join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
           join termlists_terms itt on itt.id = ttlav2.int_value AND itt.deleted=false
           join termlists itl on itl.id = itt.termlist_id AND itl.title='origin' AND itl.deleted=false
           join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
           join terms t on t.id=itt.term_id AND t.term=trim(origin_to_split_array[i])
           where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='origin' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
           ORDER BY ttlav2.id desc))
         THEN
           insert into
           indicia.taxa_taxon_list_attribute_values 
           (
             taxa_taxon_list_id,
             taxa_taxon_list_attribute_id,
             int_value,
             created_by_id,
             created_on,
             updated_by_id,
             updated_on
           )
           values (
             trait_to_import.taxa_taxon_list_id,
             (select id from taxa_taxon_list_attributes where caption='origin' and deleted=false order by id desc limit 1),
             --As the comma separated origin field is split and cycled through we need to collect the termlist term to insert.
             --This probably isn't fast way to do this, but it is a one off import and it is advantageous to keep this import as similar to the other ones as possible
             (select itt.id 
             from indicia.termlists_terms itt 
             join termlists itl on itl.id = itt.termlist_id AND itl.title='origin' AND itl.deleted=false
             join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
             join terms t on t.id=itt.term_id AND t.term=trim(origin_to_split_array[i])),
             1,
             now(),
             1,
             now()
           );
         ELSE 
         END IF;
      END LOOP;         

END LOOP;
END
$do$;

--Note as the lists of terms are separated using commas, if we use a pipe symbol inside terms
--where commas are normally used we can avoid replacements in the wrong place.
--However these these pipe symbols now need changing at the end
update terms 
set term = 'Crop plant, does not have a native range'
where term = 'Crop plant| does not have a native range';

update terms
set term = 'Garden origin, does not have a native range'
where term = 'Garden origin| does not have a native range';

update terms
set term = 'N Hemisphere (Europe,Asia and North America)'
where term = 'N Hemisphere (Europe|Asia and North America)';





--Mass replace following tag for this script 
--<plant_portal_importer_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

DO
$do$
DECLARE trait_to_import RECORD;
DECLARE br_habitats_piece   varchar[];
DECLARE br_habitats_to_split_array   varchar[];

BEGIN

--Can't use comma separation, so replace with | as some of the br_habitats names actually contain commas.
--Process numbers high to low because the single digit replacements would incorrectly replace digits in the large values
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'23, ','Inshore sublittoral sediment (only Zostera marina)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 23','|Inshore sublittoral sediment (only Zostera marina)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'23|','Inshore sublittoral sediment (only Zostera marina)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|23','|Inshore sublittoral sediment (only Zostera marina)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Inshore sublittoral sediment (only Zostera marina)'
where br_habitats='23';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'21, ','Littoral sediment (includes saltmarsh and saltmarsh pools)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 21','|Littoral sediment (includes saltmarsh and saltmarsh pools)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'21|','Littoral sediment (includes saltmarsh and saltmarsh pools)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|21','|Littoral sediment (includes saltmarsh and saltmarsh pools)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Littoral sediment (includes saltmarsh and saltmarsh pools)'
where br_habitats='21';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'19, ','Supralittoral sediment (strandlines, shingle, coastal dunes)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 19','|Supralittoral sediment (strandlines, shingle, coastal dunes)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'19|','Supralittoral sediment (strandlines, shingle, coastal dunes)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|19','|Supralittoral sediment (strandlines, shingle, coastal dunes)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Supralittoral sediment (strandlines, shingle, coastal dunes)'
where br_habitats='19';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'18, ','Supralittoral rock (does not include maritime grassland)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 18','|Supralittoral rock (does not include maritime grassland)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'18|','Supralittoral rock (does not include maritime grassland)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|18','|Supralittoral rock (does not include maritime grassland)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Supralittoral rock (does not include maritime grassland)'
where br_habitats='18';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'17, ','Built-up areas and gardens|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 17','|Built-up areas and gardens');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'17|','Built-up areas and gardens|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|17','|Built-up areas and gardens');

update plant_portal_importer.tbl_plant_att
set br_habitats='Built-up areas and gardens'
where br_habitats='17';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'16, ','Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 16','|Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'16|','Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|16','|Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)'
where br_habitats='16';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'15, ','Montane habitats (acid grassland and heath with montane species)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 15','|Montane habitats (acid grassland and heath with montane species)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'15|','Montane habitats (acid grassland and heath with montane species)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|15','|Montane habitats (acid grassland and heath with montane species)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Montane habitats (acid grassland and heath with montane species)'
where br_habitats='15';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'14, ','Rivers and streams|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 14','|Rivers and streams');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'14|','Rivers and streams|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|14','|Rivers and streams');

update plant_portal_importer.tbl_plant_att
set br_habitats='Rivers and streams'
where br_habitats='14';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'13, ','Standing water and canals|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 13','|Standing water and canals');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'13|','Standing water and canals|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|13','|Standing water and canals');

update plant_portal_importer.tbl_plant_att
set br_habitats='Standing water and canals'
where br_habitats='13';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'12, ','Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 12','|Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'12|','Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|12','|Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)'
where br_habitats='12';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'11, ','Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 11','|Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'11|','Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|11','|Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)'
where br_habitats='11';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'10, ','Dwarf shrub heath (cover of dwarf shrubs at least 25%)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 10','|Dwarf shrub heath (cover of dwarf shrubs at least 25%)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'10|','Dwarf shrub heath (cover of dwarf shrubs at least 25%)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|10','|Dwarf shrub heath (cover of dwarf shrubs at least 25%)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Dwarf shrub heath (cover of dwarf shrubs at least 25%)'
where br_habitats='10';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'9, ','Bracken|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 9','|Bracken');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'9|','Bracken|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|9','|Bracken');

update plant_portal_importer.tbl_plant_att
set br_habitats='Bracken'
where br_habitats='9';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'8, ','Acid grassland (includes non-calcareous sandy grassland)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 8','|Acid grassland (includes non-calcareous sandy grassland)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'8|','Acid grassland (includes non-calcareous sandy grassland)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|8','|Acid grassland (includes non-calcareous sandy grassland)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Acid grassland (includes non-calcareous sandy grassland)'
where br_habitats='8';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'7, ','Calcareous grassland (includes lowland and montane types)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 7','|Calcareous grassland (includes lowland and montane types)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'7|','Calcareous grassland (includes lowland and montane types)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|7','|Calcareous grassland (includes lowland and montane types)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Calcareous grassland (includes lowland and montane types)'
where br_habitats='7';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'6, ','Neutral grassland (includes coarse Arrhenatherum grassland)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 6','|Neutral grassland (includes coarse Arrhenatherum grassland)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'6|','Neutral grassland (includes coarse Arrhenatherum grassland)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|6','|Neutral grassland (includes coarse Arrhenatherum grassland)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Neutral grassland (includes coarse Arrhenatherum grassland)'
where br_habitats='6';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'5, ','Improved grassland|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 5','|Improved grassland');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'5|','Improved grassland|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|5','|Improved grassland');

update plant_portal_importer.tbl_plant_att
set br_habitats='Improved grassland'
where br_habitats='5';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'4, ','Arable and horticultural (includes orchards, excludes domestic gardens)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 4','|Arable and horticultural (includes orchards, excludes domestic gardens)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'4|','Arable and horticultural (includes orchards, excludes domestic gardens)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|4','|Arable and horticultural (includes orchards, excludes domestic gardens)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Arable and horticultural (includes orchards, excludes domestic gardens)'
where br_habitats='4';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'3, ','Boundary and linear features (eg hedges, roadsides, walls)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 3','|Boundary and linear features (eg hedges, roadsides, walls)');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'3|','Boundary and linear features (eg hedges, roadsides, walls)|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|3','|Boundary and linear features (eg hedges, roadsides, walls)');

update plant_portal_importer.tbl_plant_att
set br_habitats='Boundary and linear features (eg hedges, roadsides, walls)'
where br_habitats='3';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'2, ','Coniferous woodland|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 2','|Coniferous woodland');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'2|','Coniferous woodland|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|2','|Coniferous woodland');

update plant_portal_importer.tbl_plant_att
set br_habitats='Coniferous woodland'
where br_habitats='2';

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'1, ','Broadleaved, mixed and yew woodland|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,', 1','|Broadleaved, mixed and yew woodland');

update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'1|','Broadleaved, mixed and yew woodland|');
update plant_portal_importer.tbl_plant_att
set br_habitats=replace(br_habitats,'|1','|Broadleaved, mixed and yew woodland');

update plant_portal_importer.tbl_plant_att
set br_habitats='Broadleaved, mixed and yew woodland'
where br_habitats='1';


set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('BR Habitats','BR Habitats terms for Plant Portal',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:br_habitats');

insert into taxa_taxon_list_attributes (caption,multi_value,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,source_id)
select 'BR Habitats',true,'L',now(),1,now(),1,id,
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1))
from termlists
where title='BR Habitats' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='BR Habitats'
ORDER BY id DESC 
LIMIT 1;


perform insert_term('Broadleaved, mixed and yew woodland','eng',null,'indicia:br_habitats');
perform insert_term('Coniferous woodland','eng',null,'indicia:br_habitats');
perform insert_term('Boundary and linear features (eg hedges, roadsides, walls)','eng',null,'indicia:br_habitats');
perform insert_term('Arable and horticultural (includes orchards, excludes domestic gardens)','eng',null,'indicia:br_habitats');
perform insert_term('Improved grassland','eng',null,'indicia:br_habitats');
perform insert_term('Neutral grassland (includes coarse Arrhenatherum grassland)','eng',null,'indicia:br_habitats');
perform insert_term('Calcareous grassland (includes lowland and montane types)','eng',null,'indicia:br_habitats');
perform insert_term('Acid grassland (includes non-calcareous sandy grassland)','eng',null,'indicia:br_habitats');
perform insert_term('Bracken','eng',null,'indicia:br_habitats');
perform insert_term('Dwarf shrub heath (cover of dwarf shrubs at least 25%)','eng',null,'indicia:br_habitats');
perform insert_term('Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)','eng',null,'indicia:br_habitats');
perform insert_term('Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)','eng',null,'indicia:br_habitats');
perform insert_term('Standing water and canals','eng',null,'indicia:br_habitats');
perform insert_term('Rivers and streams','eng',null,'indicia:br_habitats');
perform insert_term('Montane habitats (acid grassland and heath with montane species)','eng',null,'indicia:br_habitats');
perform insert_term('Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)','eng',null,'indicia:br_habitats');
perform insert_term('Built-up areas and gardens','eng',null,'indicia:br_habitats');
perform insert_term('Supralittoral rock (does not include maritime grassland)','eng',null,'indicia:br_habitats');
perform insert_term('Supralittoral sediment (strandlines, shingle, coastal dunes)','eng',null,'indicia:br_habitats');
perform insert_term('Littoral sediment (includes saltmarsh and saltmarsh pools)','eng',null,'indicia:br_habitats');
perform insert_term('Inshore sublittoral sediment (only Zostera marina)','eng',null,'indicia:br_habitats');

FOR trait_to_import IN
(select ittl.id as taxa_taxon_list_id, br_habitats as br_habitats_to_split
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.br_habitats IS NOT NULL
) loop
  br_habitats_to_split_array = string_to_array(trait_to_import.br_habitats_to_split, '|');
  FOR i IN array_lower(br_habitats_to_split_array, 1) .. array_upper(br_habitats_to_split_array, 1)
      LOOP
         --As this is a multi-value attribute, this time we only don't add the trait if there is an exact taxa_taxon_list_id and attribute value match
         IF (NOT EXISTS (
           select ttlav2.id
           from taxa_taxon_list_attribute_values ttlav2
           join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
           join termlists_terms itt on itt.id = ttlav2.int_value AND itt.deleted=false
           join termlists itl on itl.id = itt.termlist_id AND itl.title='BR Habitats' AND itl.deleted=false
           join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
           join terms t on t.id=itt.term_id AND t.term=br_habitats_to_split_array[i]
           where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='BR Habitats' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
           ORDER BY ttlav2.id desc))
         THEN
           insert into
           indicia.taxa_taxon_list_attribute_values 
           (
             taxa_taxon_list_id,
             taxa_taxon_list_attribute_id,
             int_value,
             created_by_id,
             created_on,
             updated_by_id,
             updated_on
           )
           values (
             trait_to_import.taxa_taxon_list_id,
             (select id from taxa_taxon_list_attributes where caption='BR Habitats' and deleted=false order by id desc limit 1),
             --As the comma separated BR Habitats field is split and cycled through we need to collect the termlist term to insert.
             --This probably isn't fast way to do this, but it is a one off import and it is advantageous to keep this import as similar to the other ones as possible
             (select itt.id 
             from indicia.termlists_terms itt 
             join termlists itl on itl.id = itt.termlist_id AND itl.title='BR Habitats' AND itl.deleted=false
             join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
             join terms t on t.id=itt.term_id AND t.term=br_habitats_to_split_array[i]),
             1,
             now(),
             1,
             now()
           );
         ELSE 
         END IF;
      END LOOP;         

END LOOP;
END
$do$;




--Mass replace following tags for this script 
--<plant_portal_importer_taxon_list_id>

set search_path=indicia, public;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('BRC code','T',now(),1,now(),1,'BRC code field for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='BRC code'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Source for maximum height','T',now(),1,now(),1,'Source for maximum height for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Source for maximum height'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Comment on life form','T',now(),1,now(),1,'Comment on life form for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Comment on life form'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Comment on clonality','T',now(),1,now(),1,'Comment on clonality for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Comment on clonality'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description,source_id)
values 
('Comment on north and south limits in Europe','T',now(),1,now(),1,'Comment on north and south limits in Europe for plant portal project',
(select id from termlists_terms where 
termlist_id = (select id from termlists where external_key='indicia:plant_portal_sources' and deleted=false order by id desc limit 1) 
AND 
term_id = (select id from terms where term = 'PLANTATT - attributes of British and Irish plants.' and deleted=false order by id desc limit 1)));

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Comment on north and south limits in Europe'
ORDER BY id DESC 
LIMIT 1;

--Import height data
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,ppt.brc_code as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
--We check for empty space also. The reason for this is we needed to correct the format of the original file before processing and to do that I have included a space for 
--blanks instead of nothing.
where ppt.brc_code IS NOT NULL AND ppt.brc_code != ' '
) loop
--We don't need to do any checks to make sure we aren't adding duplicate attribute data (unlike Pantheon) as there are only preferred_tvks in the import
--data and these only contain one attribute value each per trait.
--However the code isn't doing any harm here and it is known to be reliable so best to leave it in.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='BRC code' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='BRC code' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,ppt.source_for_max_height as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.source_for_max_height IS NOT NULL AND ppt.source_for_max_height != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Source for maximum height' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Source for maximum height' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,ppt.comment_on_life_form as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.comment_on_life_form IS NOT NULL AND ppt.comment_on_life_form != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Comment on life form' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Comment on life form' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,ppt.comment_on_clonality as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.comment_on_clonality IS NOT NULL AND ppt.comment_on_clonality != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Comment on clonality' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Comment on clonality' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;

DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,ppt.comment_on_n_and_s_limits_in_europe as insertion_val,1,now(),1,now()
from plant_portal_importer.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.preferred=true AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.comment_on_n_and_s_limits_in_europe IS NOT NULL AND ppt.comment_on_n_and_s_limits_in_europe != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.preferred=true AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Comment on north and south limits in Europe' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Comment on north and south limits in Europe' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;











