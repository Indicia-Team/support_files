--To run this script, you need to do mass replacements of
--<plant_portal_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

set search_path TO indicia, public;
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Lat of northern European limit 5º band (NEur)-LV','I',now(),1,now(),1,'Holds lower NEur value');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Lat of northern European limit 5º band (NEur)-HV','I',now(),1,now(),1,'Holds higher NEur value');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Lat of northern European limit 5º band (SEur)-LV','I',now(),1,now(),1,'Holds lower SEur value');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('Lat of northern European limit 5º band (SEur)-HV','I',now(),1,now(),1,'Holds higher SEur value');

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (NEur)-LV'
ORDER BY id DESC 
LIMIT 1;

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (NEur)-HV'
ORDER BY id DESC 
LIMIT 1;

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (SEur)-LV'
ORDER BY id DESC 
LIMIT 1;

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='Lat of northern European limit 5º band (SEur)-HV'
ORDER BY id DESC 
LIMIT 1;


ALTER TABLE plant_portal.tbl_plant_att
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
from plant_portal.tbl_plant_att
loop

update plant_portal.tbl_plant_att
set NEur_lower=
	(case when neur_seur_to_convert.NEur LIKE '%-%' THEN 
		cast(substring(neur_seur_to_convert.NEur from '\d+') as integer)
	when neur_seur_to_convert.NEur LIKE '>%' THEN
		cast(substring(neur_seur_to_convert.NEur from '(\d+)(?!.*\d)')  as integer)
	END)
where preferred_tvk = neur_seur_to_convert.preferred_tvk;

update plant_portal.tbl_plant_att
set NEur_higher=
	(case when neur_seur_to_convert.NEur LIKE '%-%' THEN 
		cast(substring(neur_seur_to_convert.NEur from '(\d+)(?!.*\d)') as integer) 
	when neur_seur_to_convert.NEur LIKE '<%' THEN
		cast(substring(neur_seur_to_convert.NEur from '(\d+)(?!.*\d)') as integer)
	END)
where preferred_tvk = neur_seur_to_convert.preferred_tvk;


update plant_portal.tbl_plant_att
set SEur_lower=
	(case when neur_seur_to_convert.SEur LIKE '%-%' THEN 
		cast(substring(neur_seur_to_convert.SEur from '\d+') as integer) 
	when neur_seur_to_convert.SEur LIKE '>%' THEN
		cast(substring(neur_seur_to_convert.SEur from '(\d+)(?!.*\d)') as integer) 
	END)
where preferred_tvk = neur_seur_to_convert.preferred_tvk;

update plant_portal.tbl_plant_att
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
where ppt.NEur_lower IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
where ppt.NEur_higher IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
where ppt.SEur_lower IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
where ppt.SEur_higher IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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



