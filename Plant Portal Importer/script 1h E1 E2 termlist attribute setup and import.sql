--To run this script, you need to do mass replacements of
--<plant_portal_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

--Update terms in original data to be full length
update plant_portal.tbl_plant_att
set e1='Arctic-montane (main distribution in tundra or above tree-line in temperatemountains) (1)'
where e1='1';

update plant_portal.tbl_plant_att
set e1='Boreo-arctic montane (in tundra and coniferous forest zones) (2)'
where e1='2';

update plant_portal.tbl_plant_att
set e1='Wide-boreal (from temperate zone to tundra) (3)'
where e1='3';

update plant_portal.tbl_plant_att
set e1='Boreal-montane (main distribution in coniferous forest zone) (4)'
where e1='4';

update plant_portal.tbl_plant_att
set e1='Boreo-temperate (in conifer and broadleaf zones) (5)'
where e1='5';

update plant_portal.tbl_plant_att
set e1='Wide-temperate (from Mediterranean region to coniferous forest zone) (6)'
where e1='6';

update plant_portal.tbl_plant_att
set e1='Temperate (in broadleaf forest zone) (7)'
where e1='7';

update plant_portal.tbl_plant_att
set e1='Southern-temperate (in Mediterranean region and broadleaf forest zones) (8)'
where e1='8';

update plant_portal.tbl_plant_att
set e1='Mediterranean-atlantic (in Med region, extending north in atlantic zoneof temperate Europe) (9)'
where e1='9';

update plant_portal.tbl_plant_att
set e1='Mediterranean (native range of some aliens) (0)'
where e1='0';

set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Biogeographic element, major biome (E1)','Biogeographic element, major biome for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:major_biome');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Biogeographic element, major biome (E1)','L',now(),1,now(),1,id
from termlists
where title='Biogeographic element, major biome (E1)' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Biogeographic element, major biome (E1)'
ORDER BY id DESC 
LIMIT 1;

select insert_term('Arctic-montane (main distribution in tundra or above tree-line in temperatemountains) (1)','eng',null,'indicia:major_biome');
select insert_term('Boreo-arctic montane (in tundra and coniferous forest zones) (2)','eng',null,'indicia:major_biome');
select insert_term('Wide-boreal (from temperate zone to tundra) (3)','eng',null,'indicia:major_biome');
select insert_term('Boreal-montane (main distribution in coniferous forest zone) (4)','eng',null,'indicia:major_biome');
select insert_term('Boreo-temperate (in conifer and broadleaf zones) (5)','eng',null,'indicia:major_biome');
select insert_term('Wide-temperate (from Mediterranean region to coniferous forest zone) (6)','eng',null,'indicia:major_biome');
select insert_term('Temperate (in broadleaf forest zone) (7)','eng',null,'indicia:major_biome');
select insert_term('Southern-temperate (in Mediterranean region and broadleaf forest zones) (8)','eng',null,'indicia:major_biome');
select insert_term('Mediterranean-atlantic (in Med region, extending north in atlantic zoneof temperate Europe) (9)','eng',null,'indicia:major_biome');
select insert_term('Mediterranean (native range of some aliens) (0)','eng',null,'indicia:major_biome');



set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now()
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.e1 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Biogeographic element, major biome (E1)' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.e1 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
update plant_portal.tbl_plant_att
set e2='Hyperoceanic, with a western distribution in atlantic zone (0)'
where e2='0';

update plant_portal.tbl_plant_att
set e2='Oceanic (in atlantic zone of Europe, not or scarcely reaching east to Sweden,Germany, S Spain) (1)'
where e2='1';

update plant_portal.tbl_plant_att
set e2='Suboceanic (extending east to Sweden, C Europe or Italy) (2)'
where e2='2';

update plant_portal.tbl_plant_att
set e2='European (extending to more continental parts of Europe but not to Siberia) (3)'
where e2='3';

update plant_portal.tbl_plant_att
set e2='Eurosiberian (eastern limit between 60°E and 120°E) (4)'
where e2='4';

update plant_portal.tbl_plant_att
set e2='Eurasian (extending across Asia to east of 120°E) (5)'
where e2='5';

update plant_portal.tbl_plant_att
set e2='Circumpolar (in Europe,Asia and N America) (6)'
where e2='6';


insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Biogeographic element, eastern limit category (E2)','Biogeographic element, eastern limit category for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:eastern_limit_category');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Biogeographic element, eastern limit category (E2)','L',now(),1,now(),1,id
from termlists
where title='Biogeographic element, eastern limit category (E2)' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Biogeographic element, eastern limit category (E2)'
ORDER BY id DESC 
LIMIT 1;

select insert_term('Hyperoceanic, with a western distribution in atlantic zone (0)','eng',null,'indicia:eastern_limit_category');
select insert_term('Oceanic (in atlantic zone of Europe, not or scarcely reaching east to Sweden,Germany, S Spain) (1)','eng',null,'indicia:eastern_limit_category');
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.e2 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Biogeographic element, eastern limit category (E2)' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.e2 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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



