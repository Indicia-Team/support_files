--To run this script, you need to do mass replacements of
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

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Native status','L',now(),1,now(),1,id
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
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
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Conservation status','L',now(),1,now(),1,id
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
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
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Rarity status','L',now(),1,now(),1,id
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
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
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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








