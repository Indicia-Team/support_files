--Just perform one replacement for this script, mass replace 
--<plant_portal_importer_taxon_list_id>

set search_path=indicia, public;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('BRC code','T',now(),1,now(),1,'BRC code field for plant portal project');

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='BRC code'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Source for maximum height','T',now(),1,now(),1,'Source for maximum height for plant portal project');

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Source for maximum height'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Comment on life form','T',now(),1,now(),1,'Comment on life form for plant portal project');

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Comment on life form'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Comment on clonality','T',now(),1,now(),1,'Comment on clonality for plant portal project');

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_importer_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Comment on clonality'
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Comment on north and south limits in Europe','T',now(),1,now(),1,'Comment on north and south limits in Europe for plant portal project');

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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
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
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.source_for_max_height IS NOT NULL AND ppt.source_for_max_height != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.comment_on_life_form IS NOT NULL AND ppt.comment_on_life_form != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.comment_on_clonality IS NOT NULL AND ppt.comment_on_clonality != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_importer_taxon_list_id> AND ittl.deleted=false
where ppt.comment_on_n_and_s_limits_in_europe IS NOT NULL AND ppt.comment_on_n_and_s_limits_in_europe != ' '
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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