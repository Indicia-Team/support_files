--To run this script you need the following replacements,
<pantheon_taxon_list_id>


--Insert termlists
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('quality index capital characters','List of capital char values e.g. A,B,C for pantheon quality indices.',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:quality index capital characters'),
('quality index terms','List of terms like moderate,low for pantheon quality indices.',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:quality index terms'),
('quality index mixed characters','List of mixed character values e.g. a,a/b,b for pantheon quality indices.',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:quality index mixed characters');

--Insert attributes
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'acid mire fidelity score','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'calcareous grassland fidelity score','L',now(),1,now(),1,id
from termlists
where title='quality index terms' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'coarse woody debris fidelity score','L',now(),1,now(),1,id
from termlists
where title='quality index mixed characters' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('exposed riverine sediments fidelity score (D & H)','I',now(),1,now(),1,'exposed riverine sediments fidelity score for Pantheon project (Drake & Hewitt source)');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('exposed riverine sediments fidelity score (S & B)','I',now(),1,now(),1,'exposed riverine sediments fidelity score for Pantheon project (Sadler & Bell source)');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('revised index of ecology continuity score','I',now(),1,now(),1,'revised index of ecology continuity score for Pantheon project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - acid-neutral','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - calcareous','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - slumping cliff','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - stable cliff','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - woodland','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('soft rock cliff fidelity score','I',now(),1,now(),1,'soft rock cliff fidelity score for Pantheon project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('spider indicator species for peat bogs','I',now(),1,now(),1,'spider indicator species for peat bogs for Pantheon project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('index of ecology continuity score','I',now(),1,now(),1,'index of ecology continuity score for Pantheon project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('grazing coastal marsh score - species score','I',now(),1,now(),1,'grazing coastal marsh score - species score for Pantheon project');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('grazing coastal marsh score - salinity score','I',now(),1,now(),1,'grazing coastal marsh score - salinity score for Pantheon project');




--Insert terms. Note that no trait codes required for quality indices. Different quality score need different termlists
select insert_term('A','eng',null,'indicia:quality index capital characters');
select insert_term('B','eng',null,'indicia:quality index capital characters');
select insert_term('C','eng',null,'indicia:quality index capital characters');

select insert_term('High','eng',null,'indicia:quality index terms');
select insert_term('Moderate','eng',null,'indicia:quality index terms');
select insert_term('Moderate to low','eng',null,'indicia:quality index terms');
select insert_term('Low','eng',null,'indicia:quality index terms');
select insert_term('Unknown','eng',null,'indicia:quality index terms');

select insert_term('a','eng',null,'indicia:quality index mixed characters');
select insert_term('a/b','eng',null,'indicia:quality index mixed characters');
select insert_term('b','eng',null,'indicia:quality index mixed characters');
select insert_term('b/c','eng',null,'indicia:quality index mixed characters');
select insert_term('c','eng',null,'indicia:quality index mixed characters');
select insert_term('c/d','eng',null,'indicia:quality index mixed characters');
select insert_term('d','eng',null,'indicia:quality index mixed characters');
select insert_term('d/e','eng',null,'indicia:quality index mixed characters');
select insert_term('e','eng',null,'indicia:quality index mixed characters');





--Note that although we have terms for Quality Indices, we don't have sources for them as the trait source seems to vary between quality indices that use the same termlist. Need to hold source at attribute level.
--Note there are no coding conventions either
update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2004)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='acid mire fidelity score' and deleted=false);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Alexander (2003)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='calcareous grassland fidelity score' and deleted=false) ;


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Godfrey (2003)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='coarse woody debris fidelity score' and deleted=false);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Drake & Hewitt (2007)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (D & H)' and deleted=false);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Sadler & Bell (2002)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (S & B)' and deleted=false);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - acid-neutral' and deleted=false);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - calcareous' and deleted=false);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - slumping cliff' and deleted=false);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - stable cliff' and deleted=false);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - woodland' and deleted=false);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Howe (2003)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='soft rock cliff fidelity score' and deleted=false);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Scott, Oxford & Selden (2006)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='spider indicator species for peat bogs' and deleted=false);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Palmer, Drake & Stewart (2010)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - species score' and deleted=false);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Palmer, Drake & Stewart (2010)' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - salinity score' and deleted=false);




-- Terms do not have a hierarchy for this attribute


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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='revised index of ecology continuity score'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
--Single value attribute so only need to check last item added
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='revised index of ecology continuity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='revised index of ecology continuity score' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='soft rock cliff fidelity score'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='soft rock cliff fidelity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='soft rock cliff fidelity score' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='spider indicator species for peat bogs'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='spider indicator species for peat bogs' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='spider indicator species for peat bogs' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='index of ecology continuity score'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='index of ecology continuity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='index of ecology continuity score' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='grazing coastal marsh score - species score'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - species score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - species score' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='grazing coastal marsh score - salinity score'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id  AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - salinity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - salinity score' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='exposed riverine sediments fidelity score' AND pt.trait_source='Drake & Hewitt (2007)'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id  AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (D & H)' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (D & H)' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='exposed riverine sediments fidelity score' AND pt.trait_source='Sadler & Bell (2002)'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id  AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (S & B)' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (S & B)' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='acid mire fidelity score' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='acid mire fidelity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='acid mire fidelity score' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - acid-neutral' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - acid-neutral' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - acid-neutral' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - calcareous' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - calcareous' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - calcareous' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - slumping cliff' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - slumping cliff' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - slumping cliff' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - stable cliff' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - stable cliff' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - stable cliff' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='seepage habitats fidelity score - woodland' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index capital characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - woodland' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - woodland' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='calcareous grassland fidelity score' 
join indicia.terms iTerm on iTerm.term=pst.trait_value AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index terms' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='calcareous grassland fidelity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='calcareous grassland fidelity score' and deleted=false) ,trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='coarse woody debris fidelity score' 
join indicia.terms iTerm on (iTerm.term=pst.trait_value OR 
	(pst.trait_value='d/c' AND iTerm.term='c/d'))
	AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='quality index mixed characters' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='coarse woody debris fidelity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='coarse woody debris fidelity score' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;