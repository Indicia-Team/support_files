--This script assumes the name of the Plant Portal website is "Plant Portal", if it isn't you will need to adjust the website name in the script.
--To run this script, you need to mass replace the following tag
--<plant_portal_importer_taxon_list_id>


set search_path TO indicia, public;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id, description)
values ('Continentality in europe','B',now(),1,now(),1,'Species marked c are continental, i.e. they are rare in the atlantic zone of Europe but commoner further east');

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Continentality in europe'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values ('Reaching northern European limit in British Isles','B',now(),1,now(),1,'Reaching northern European limit in British Isles for plant portal project');

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Reaching northern European limit in British Isles'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id, description)
values ('Reaching southern European limit in British Isles','B',now(),1,now(),1,'Reaching southern European limit in British Isles for plant portal project');

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Reaching southern European limit in British Isles'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id, description)
values ('Coastal','B',now(),1,now(),1,'At least 80% of occupied squares contain sea at high tide');

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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.C IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.NBI IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.SBI IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.Co IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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