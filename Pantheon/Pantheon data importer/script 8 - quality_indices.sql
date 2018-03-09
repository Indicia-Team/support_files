--To run this script you need the following replacements,
--<pantheon_taxon_list_id>


--Do imports for traits which use a number first rather than a termlist
--Note all Quality Indices are single value, although species can be associated with all the quality indices.
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='revised index of ecology continuity score'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
--Single value attribute so only need to check last item added
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='revised index of ecology continuity score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='revised index of ecology continuity score' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='soft rock cliff fidelity score'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='soft rock cliff fidelity score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='soft rock cliff fidelity score' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='spider indicator species for peat bogs'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='spider indicator species for peat bogs' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='spider indicator species for peat bogs' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='index of ecology continuity score'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='index of ecology continuity score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='index of ecology continuity score' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='grazing coastal marsh score - species score'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - species score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - species score' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='grazing coastal marsh score - salinity score'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id  AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - salinity score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - salinity score' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;

--Note there are 2 exposed riverine sediments fidelity score items with same name, so we use source as well for identification
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='exposed riverine sediments fidelity score' AND pt.trait_source='Drake, Godrey, Hewitt & Parker (2007)'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id  AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (DGHP)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (DGHP)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,cast(pst.trait_value as integer) as insertion_val,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='exposed riverine sediments fidelity score' AND pt.trait_source='Bates (2005)'
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id  AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (B)' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (B)' and deleted=false order by id desc limit 1),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;

--Next do ones that use the Capital Characters termlist
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='acid mire fidelity score' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='acid mire fidelity score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='acid mire fidelity score' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - acid-neutral' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - acid-neutral' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - acid-neutral' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - calcareous' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - calcareous' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - calcareous' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - slumping cliff' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - slumping cliff' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - slumping cliff' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - stable cliff' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - stable cliff' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - stable cliff' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - woodland' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - woodland' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - woodland' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;


--Now import ones that use that use the quality index terms, such as "Moderate" and "Low"
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='calcareous grassland fidelity score' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index terms' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='calcareous grassland fidelity score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='calcareous grassland fidelity score' and deleted=false order by id desc limit 1) ,trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;

--Now import ones that use that use the quality index mixed characters, such as "d/e" and "d"
set search_path TO indicia, public;
DO
$do$
declare trait_to_import RECORD;
BEGIN 
FOR trait_to_import IN 
(select ittl.id as taxa_taxon_list_id,itt.id as insertion_tt,1,now(),1,now(),ittSource.id as source
from pantheon.tbl_species_traits pst
join pantheon.tbl_species ps on ps.species_id=pst.species_id
join indicia.taxa it on it.external_key=ps.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.preferred=true AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='coarse woody debris fidelity score' 
join indicia.terms iTerm on (iTerm.term=pst.trait_value OR 
	(pst.trait_value='d/c' AND iTerm.term='c/d'))
	AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index mixed characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
left join indicia.termlists itlSource on itlSource.title = 'Attribute value sources' AND itlSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.termlist_id = itlSource.id AND ittSource.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on itSource.id = ittSource.term_id AND (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='coarse woody debris fidelity score' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='coarse woody debris fidelity score' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;