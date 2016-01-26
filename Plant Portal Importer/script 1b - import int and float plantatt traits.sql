--Just perform one replacement for this script, mass replace 
--<plant_portal_taxon_list_id>

set search_path=indicia, public;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Height (terrestrial) (Hght)','I',now(),1,now(),1,'Hght for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Major Biome (European distribution)','I',now(),1,now(),1,'Major Biome (European distribution) (E1) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Eastern limit code','I',now(),1,now(),1,'Eastern limit code (E2) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('No of 10-km squares in Britain (inc Isle of Man)','I',now(),1,now(),1,'Number of 10-km squares in Britain (including Isle of Man) (GB) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('No of 10-km squares in Ireland','I',now(),1,now(),1,'Number of 10-km squares in Ireland (IR) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('No of 10-km squares in Channel Islands','I',now(),1,now(),1,'Number of 10-km squares in Channel Islands (CI) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Annual precipitation','I',now(),1,now(),1,'Annual precipitation (Prec) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Ellenberg indicator value (L)','I',now(),1,now(),1,'Ellenberg indicator value (L) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Ellenberg indicator value (F)','I',now(),1,now(),1,'Ellenberg indicator value (F) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Ellenberg indicator value (R)','I',now(),1,now(),1,'Ellenberg indicator value (R) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Ellenberg indicator value (N)','I',now(),1,now(),1,'Ellenberg indicator value (N) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Ellenberg indicator value (S)','I',now(),1,now(),1,'Ellenberg indicator value (S) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Length (aquatic)','F',now(),1,now(),1,'Length (aquatic) (Len) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Chg','F',now(),1,now(),1,'Chg for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('January mean temperature','F',now(),1,now(),1,'January mean temperature (Tjan) for plant portal project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('July mean temperature','F',now(),1,now(),1,'July mean temperature (Tjul) for plant portal project');


--Import height data
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(ppt.Hght as integer) as insertion_val,1,now(),1,now()
from plant_portal.tbl_plant_att_19_nov_08 ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
where ppt.Hght IS NOT NULL
) loop
--Guard against duplicates caused by accidently running importer twice
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Height (terrestrial) (Hght)' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Height (terrestrial) (Hght)' and deleted=false),trait_to_import.insertion_val,1,now(),1,now());
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
from plant_portal.tbl_plant_att_19_nov_08 ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
where ppt.Len IS NOT NULL
) loop
--We don't need to do any checks to make sure we aren't adding duplicate attribute data (unlike Pantheon) as there are only preferred_tvks in the import
--data and these only contain one attribute value each per trait.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='Length (aquatic)' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,float_value,created_by_id,created_on,updated_by_id,updated_on)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Length (aquatic)' and deleted=false),trait_to_import.insertion_val,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;



