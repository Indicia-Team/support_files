--To run this script, you need to do mass replacements of
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

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Life form 1','L',now(),1,now(),1,id
from termlists
where title='Life form' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Life form 2','L',now(),1,now(),1,id
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.lf1 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Life form' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.lf1 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.lf2 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Life form' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.lf2 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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

