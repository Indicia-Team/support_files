--To run this script, you need to do mass replacements of
--<plant_portal_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

--Update terms in original data to be full length
update plant_portal.tbl_plant_att
set w='Herbaceous (h)'
where w='h';

update plant_portal.tbl_plant_att
set w='Semi-woody (sw)'
where w='sw';

update plant_portal.tbl_plant_att
set w='Woody (w)'
where w='w';

insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Woodiness','Woodiness for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:woodiness');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Woodiness','L',now(),1,now(),1,id
from termlists
where title='Woodiness' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.w AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Woodiness' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.w IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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














update plant_portal.tbl_plant_att
set clone1='Little or no vegetative spread (0)'
where clone1='0';

update plant_portal.tbl_plant_att
set clone2='Little or no vegetative spread (0)'
where clone2='0';

update plant_portal.tbl_plant_att
set clone1='Tussock-forming graminoid, may slowly spread (0gr)'
where clone1='0gr';

update plant_portal.tbl_plant_att
set clone2='Tussock-forming graminoid, may slowly spread (0gr)'
where clone2='0gr';

update plant_portal.tbl_plant_att
set clone1='Tuberous or bulbous, slowing cloning by offsets (0tb)'
where clone1='0tb';

update plant_portal.tbl_plant_att
set clone2='Tuberous or bulbous, slowing cloning by offsets (0tb)'
where clone2='0tb';

update plant_portal.tbl_plant_att
set clone1='Detaching ramets above ground (often axillary) (DRa)'
where clone1='DRa';

update plant_portal.tbl_plant_att
set clone2='Detaching ramets above ground (often axillary) (DRa)'
where clone2='DRa';

update plant_portal.tbl_plant_att
set clone1='Detaching ramets at or below ground (DRg)'
where clone1='DRg';

update plant_portal.tbl_plant_att
set clone2='Detaching ramets at or below ground (DRg)'
where clone2='DRg';

update plant_portal.tbl_plant_att
set clone1='Detaching ramets on inflorescence (DRi)'
where clone1='DRi';

update plant_portal.tbl_plant_att
set clone2='Detaching ramets on inflorescence (DRi)'
where clone2='DRi';

update plant_portal.tbl_plant_att
set clone1='Detaching ramets on leaves (Hammarbya) (DRl)'
where clone1='DRl';

update plant_portal.tbl_plant_att
set clone2='Detaching ramets on leaves (Hammarbya) (DRl)'
where clone2='DRl';

update plant_portal.tbl_plant_att
set clone1='Detaching ramets on prothallus (Trichomanes) (DRp)'
where clone1='DRp';

update plant_portal.tbl_plant_att
set clone2='Detaching ramets on prothallus (Trichomanes) (DRp)'
where clone2='DRp';

update plant_portal.tbl_plant_att
set clone1='Fragmenting as part of normal growth (Frag)'
where clone1='Frag';

update plant_portal.tbl_plant_att
set clone2='Fragmenting as part of normal growth (Frag)'
where clone2='Frag';

update plant_portal.tbl_plant_att
set clone1='Irregularly fragmenting (mainly water plants) (Irreg)'
where clone1='Irreg';

update plant_portal.tbl_plant_att
set clone2='Irregularly fragmenting (mainly water plants) (Irreg)'
where clone2='Irreg';

update plant_portal.tbl_plant_att
set clone1='Plantlets formed on leaves (Cardamine pratensis) (Leaf)'
where clone1='Leaf';

update plant_portal.tbl_plant_att
set clone2='Plantlets formed on leaves (Cardamine pratensis) (Leaf)'
where clone2='Leaf';

update plant_portal.tbl_plant_att
set clone1='Shortly creeping and rooting at nodes (Node1)'
where clone1='Node1';

update plant_portal.tbl_plant_att
set clone2='Shortly creeping and rooting at nodes (Node1)'
where clone2='Node1';

update plant_portal.tbl_plant_att
set clone1='Extensively creeping and rooting at nodes (Node2)'
where clone1='Node2';

update plant_portal.tbl_plant_att
set clone2='Extensively creeping and rooting at nodes (Node2)'
where clone2='Node2';

update plant_portal.tbl_plant_att
set clone1='Rhizome shortly creeping (Rhiz1)'
where clone1='Rhiz1';

update plant_portal.tbl_plant_att
set clone2='Rhizome shortly creeping (Rhiz1)'
where clone2='Rhiz1';

update plant_portal.tbl_plant_att
set clone1='Rhizome far-creeping (Rhiz2)'
where clone1='Rhiz2';

update plant_portal.tbl_plant_att
set clone2='Rhizome far-creeping (Rhiz2)'
where clone2='Rhiz2';

update plant_portal.tbl_plant_att
set clone1='Clones formed by suckering from roots (Root)'
where clone1='Root';

update plant_portal.tbl_plant_att
set clone2='Clones formed by suckering from roots (Root)'
where clone2='Root';

update plant_portal.tbl_plant_att
set clone1='Shortly creeping, stolons in illuminated medium (Stol1)'
where clone1='Stol1';

update plant_portal.tbl_plant_att
set clone2='Shortly creeping, stolons in illuminated medium (Stol1)'
where clone2='Stol1';

update plant_portal.tbl_plant_att
set clone1='Far-creeping by stolons in illuminated medium (Stol2)'
where clone1='Stol2';

update plant_portal.tbl_plant_att
set clone2='Far-creeping by stolons in illuminated medium (Stol2)'
where clone2='Stol2';

update plant_portal.tbl_plant_att
set clone1='Tip rooting (the stems often turn downwards) (Tip)'
where clone1='Tip';

update plant_portal.tbl_plant_att
set clone2='Tip rooting (the stems often turn downwards) (Tip)'
where clone2='Tip';


insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Categories of clonality','Categories of clonality for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:categories_of_clonality');

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Categories of clonality 1','L',now(),1,now(),1,id
from termlists
where title='Categories of clonality' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'Categories of clonality 2','L',now(),1,now(),1,id
from termlists
where title='Categories of clonality' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);


insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.clone1 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Categories of clonality' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.clone1 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
join indicia.terms iTerm on iTerm.term=ppt.clone2 AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='Categories of clonality' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
where ppt.clone2 IS NOT NULL
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
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

