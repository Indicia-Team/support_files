--To run this code, you will need to do replacements of,
--<pantheon_taxon_list_id>
--This is the taxon_list to limit the Indicia species to for the taxa_taxon_list_attributes

set search_path TO indicia, public;


-- JVB Cleanup the data a bit!
update pantheon.tbl_species_traits
set coding_convention='hand coded' where coding_convention in ('Hands Coded', 'hand-coded', 'hand', 'Hand coded');



--Now setup termlist/attributes for Broad biotopes, Habitats and Resources
--Insert termlists
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('broad biotope/habitat/resource','broad biotopes and habitats and resources',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:broad biotope/habitat/resource');

--Insert Attributes
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,multi_value)
select 'broad biotope','L',now(),1,now(),1,id,true
from termlists
where title='broad biotope/habitat/resource' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='broad biotope'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,multi_value)
select 'habitat','L',now(),1,now(),1,id,true
from termlists
where title='broad biotope/habitat/resource' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='habitat'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,multi_value)
select 'resource','L',now(),1,now(),1,id,true
from termlists
where title='broad biotope/habitat/resource' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='resource'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

--Insert terms and trait codes, we manipulate the names so the trait id precedes the term name and the parent id is after the term. We then use these to create the parent term hierarchy and strip them out later.
--At this stage we also insert the trait codes and then set their meaning to be the same as the trait, that way they are shown as a synonym of the trait.
set search_path TO indicia, public;
DO
$do$
declare trait_to_insert RECORD;
BEGIN 
FOR trait_to_insert IN (select * from pantheon.tbl_traits where trait_type='broad biotope' or trait_type='habitat' or trait_type='resource' or (trait_type='specific assemblage type' AND parent_trait_id IS NOT NULL) or trait_description = 'generalist only' order by trait_id asc) LOOP
   perform insert_term(trait_to_insert.trait_id || ' ' || trait_to_insert.trait_description || ' ' || coalesce(trait_to_insert.parent_trait_id,0),'eng',null,'indicia:broad biotope/habitat/resource');
   IF (trait_to_insert.trait_code IS NOT NULL)
   THEN
   perform insert_term(trait_to_insert.trait_code,'eng',null,'indicia:broad biotope/habitat/resource');
   ELSE
   END IF;

   update termlists_terms
   --When we find we are copying over a specific assemblage type, put 1 into the sort_order field. Then use this below to set the source_id to ISIS.
   --This may not be the most elegant way if we were starting from scratch, however as the specific assemblage types
   --were added to the broad biotope/habitat/resource termlist later, it is the best way without a rewrite.
   --The previous method just involved setting all the items in the termlist to OSIRIS, but now we need a method to set the SATs to ISIS.
   set sort_order = 1
   where 
   id in (
      select tt3.id from termlists_terms tt3
      join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'broad biotope/habitat/resource' AND tl3.deleted = false
      join websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
      join terms t3 on t3.id = tt3.term_id AND 
	(t3.term=(trait_to_insert.trait_id || ' ' || trait_to_insert.trait_description || ' ' || coalesce(trait_to_insert.parent_trait_id,0))) AND
      	(trait_to_insert.trait_type='specific assemblage type' AND trait_to_insert.parent_trait_id IS NOT NULL) AND t3.deleted=false
      where tt3.deleted=false
      order by tt3.id desc
      limit 1
   );

   --Do same for trait codes
   update termlists_terms
   set sort_order = 1
   where 
   id in (
      select tt3.id from termlists_terms tt3
      join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'broad biotope/habitat/resource' AND tl3.deleted = false
      join websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
      join terms t3 on t3.id = tt3.term_id AND 
	(t3.term=trait_to_insert.trait_code AND trait_to_insert.trait_code IS NOT NULL) AND
      	(trait_to_insert.trait_type='specific assemblage type' AND trait_to_insert.parent_trait_id IS NOT NULL) AND t3.deleted=false
      where tt3.deleted=false
      order by tt3.id desc
      limit 1
   );
	
   --Update meaning on all trait codes
   update termlists_terms
   set preferred = false, parent_id = null,
   meaning_id = (
      select meaning_id from termlists_terms tt2
      join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'broad biotope/habitat/resource' AND tl2.deleted = false
      join websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
      join terms t2 on t2.id = tt2.term_id AND t2.term = (trait_to_insert.trait_id || ' ' || trait_to_insert.trait_description || ' ' || coalesce(trait_to_insert.parent_trait_id,    0)) AND 	t2.deleted = false
      where tt2.deleted=false
   )
   where 
   id in (
      select tt3.id from termlists_terms tt3
      join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'broad biotope/habitat/resource' AND tl3.deleted = false
      join websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
      join terms t3 on t3.id = tt3.term_id AND t3.term=trait_to_insert.trait_code AND trait_to_insert.trait_code IS NOT NULL AND t3.deleted=false
      where tt3.deleted=false
      --There can be several trait code with the same name, so only get the last one added
      order by tt3.id desc
      limit 1
   );
END LOOP;
END
$do$;


--Hold the trait source at term level for termlist attributes
update termlists_terms
set source_id = 
case when sort_order = 1 then
  (select tt1.id
  from termlists_terms tt1
  join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Term sources' AND tl1.deleted=false
  join terms t1 on t1.id = tt1.term_id AND t1.term = 'ISIS' AND t1.deleted=false
  where tt1.deleted = false
  order by tt1.id desc
  limit 1)
else
  (select tt1.id
  from termlists_terms tt1
  join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Term sources' AND tl1.deleted=false
  join terms t1 on t1.id = tt1.term_id AND t1.term = 'OSIRIS' AND t1.deleted=false
  where tt1.deleted = false
  order by tt1.id desc
  limit 1)
end,
--See notes above on the use of the sort_order field to determine the specific assemblage types to set the correct source
sort_order=null
where termlist_id = 
(select tl2.id
from termlists tl2 
join websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
where tl2.title = 'broad biotope/habitat/resource' AND tl2.deleted=false
order by tl2.id desc
limit 1
);

-- Set the parent structure for the terms in the termlist
update indicia.termlists_terms as tt
set parent_id=(
select tt2.id
from termlists_terms tt2
join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'broad biotope/habitat/resource'  and tl2.deleted=false
join websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
join terms t2 on t2.id = tt2.term_id AND t2.deleted=false
left join terms t on t.id = tt.term_id AND t.deleted=false
-- The terms have been set to the following format <trait_id> <term> <parent trait id>
-- So to find the termlists_term id of that parent trait, we simply search for the term where the start of the term name (trait id) matches
-- the back end of the term (parent trait id) we are setting the parent for.
-- We also double check that (substring(t.term from '[^ ]+$') != t.term), this means the system won't process trait codes, this is because
-- a trait code like A1 with return A1 if we try to extract the back or front end of it.
where (substring(t.term from '[^ ]+$') = substring(t2.term from '([^ ]+)') AND tt2.deleted=false) AND (substring(t.term from '[^ ]+$') != t.term))
where tt.deleted=false AND tt.termlist_id in
(select tl.id
from indicia.termlists tl
join websites w on w.id = tl.website_id AND w.title='Pantheon' and w.deleted=false
where tl.title = 'broad biotope/habitat/resource' AND tl.deleted=false
order by tl.id desc
limit 1);













--Now Adult/Larval Guild Attribute/termlist setup
--Insert Termlists
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('adult guild','adult guilds',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:adult guild'),
('larval guild','larval guilds',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:larval guild');

--Insert attributes
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'adult guild','L',now(),1,now(),1,id
from termlists
where title='adult guild' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='adult guild'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'larval guild','L',now(),1,now(),1,id
from termlists
where title='larval guild' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='larval guild'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;


-- JVB converted insertion of adult guild and larval guild terms into dynamic query
-- AVB, added code to handle original special cases as originally discussed with client for data version 3.2. 
-- Note there maybe further special cases required for 3.3, but there have not been discussed yet.
-- Items do not need to be added to the termlists when it was agreed to map them to something else
select insert_term(trait_value,'eng',null,'indicia:adult guild')
from (
	select distinct trait_value 
	from pantheon.tbl_species_traits st
	join pantheon.tbl_traits t on t.trait_id=st.trait_id and t.trait_description='adult guild'
	where st.trait_value not in ('Predator','omnivore','Unknown','predator, nectivorous','Nectivorous','Parasitoid')
	order by trait_value
) as subtable;
select insert_term(trait_value,'eng',null,'indicia:larval guild')
from (
	select distinct trait_value 
	from pantheon.tbl_species_traits st
	join pantheon.tbl_traits t on t.trait_id=st.trait_id and t.trait_description='larval guild'
	where st.trait_value not in ('Predator','predatory','algivorous','herbivorous','omnivore','Parasitoid','fungivore, predator','Herbivore','fungivore, saprophagous','fungivorous','Saprophagous','saprophagus','coprophagous, necrophorus','herbivore & carnivore','cleptoparasite')
	order by trait_value
) as subtable;

--carnivore is an extra special case. We need to add it as it was agreed to split "herbivore & carnivore" into separate items, however we need to add it manually as it never appears in the data on its own.
select insert_term('carnivore','eng',null,'indicia:larval guild');


--Hold the trait source at term level for termlist attributes
update termlists_terms
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Term sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'OSIRIS' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where termlist_id in
(select tl2.id
from termlists tl2 
join websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
where (tl2.title = 'adult guild' OR tl2.title = 'larval guild') AND tl2.deleted=false
order by tl2.id desc
limit 2
);
















--New Assemblage termlist/attribute setup. Note this has changed and now shares the biotope/habitats/resources termlist

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'specific assemblage type','L',now(),1,now(),1,id
from termlists
where title='broad biotope/habitat/resource' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='specific assemblage type'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;










--Now keywords attributes and termlists setup
--Insert Termlists
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('keywords','keywords for Pantheon',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:keywords');

--Insert attributes
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,multi_value)
select 'keywords','L',now(),1,now(),1,id,true
from termlists
where title='keywords' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='keywords'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;



-- JVB converted insertion of keywords into a dynamic query
--Insert OSIRIS traits and trait code that have no value as keywords. 
--(AVB: This doesn't work for plant-associated, it is incorrectly
--is set as keyword, so put in exceptions for this
select insert_term(term,'eng',null,'indicia:keywords')
from (select trait_description as term
from pantheon.tbl_traits
where trait_source='OSIRIS'
and trait_type is null
and trait_code is not null
and trait_description != 'plant-associated'
order by trait_description
) as subtable;

select insert_term(term,'eng',null,'indicia:keywords')
from (select trait_code as term
from pantheon.tbl_traits
where trait_source='OSIRIS'
and trait_type is null
and trait_code is not null
and trait_description != 'plant-associated'
order by trait_description
) as subtable;

--JVB converted code matching to keywords to a dynamic query
--Update trait codes to have the same meaning as the traits they are associated with.
update termlists_terms tlt
set preferred=false, parent_id=null, meaning_id=sub.preferred_meaning_id
from (
	select tlt1.id as preferred_termlists_term_id, tlt1.meaning_id as preferred_meaning_id,
	    t1.term as preferred_term, tlt2.id as code_termlists_terms_id, t2.term as code
	from termlists_terms tlt1 
	join termlists tl1 on tl1.id=tlt1.termlist_id AND tl1.deleted=false and tl1.external_key='indicia:keywords'
      	join websites w on w.id = tl1.website_id AND w.title='Pantheon' and w.deleted=false
	join terms t1 on t1.id=tlt1.term_id and t1.deleted=false
	join pantheon.tbl_traits tr on tr.trait_description=t1.term and tr.trait_source='OSIRIS' and tr.trait_type is null and tr.trait_code is not null and tr.trait_description != 'plant-associated'
	join terms t2 on t2.term=tr.trait_code and t2.deleted=false
	join termlists_terms tlt2 on tlt2.term_id=t2.id and tlt2.deleted=false and tlt2.termlist_id=tl1.id
	where tlt1.deleted=false
) as sub
where sub.code_termlists_terms_id=tlt.id;


--Insert the sources for the terms (Attribute Value Sources come through at import stage). Termlists hold the source at term level, so there is no source for the attribute.

update termlists_terms
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Term sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'OSIRIS' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where termlist_id = 
(select tl2.id
from termlists tl2 
join websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
where tl2.title = 'keywords' AND tl2.deleted=false
order by tl2.id desc
limit 1
);


--Setup the parent hierarchy for the termlist.
update termlists_terms
set parent_id = 
(select tt2.id 
from termlists_terms tt2
JOIN termlists tl2 on tl2.id=tt2.termlist_id AND tl2.title = 'keywords' AND tl2.deleted=false 
join websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
JOIN terms t2 on t2.id = tt2.term_id AND t2.term = 'synanthropic' AND t2.deleted = false
where tt2.deleted=false
order by tt2.id desc
limit 1)
where
term_id in (select t3.id 
from terms t3 
join termlists_terms tt3 on tt3.term_id=t3.id
join termlists tl3 on tl3.id=tt3.termlist_id AND tl3.title = 'keywords'and tl3.deleted=false
join websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
where t3.term in ('in buildings','compost/manure heaps','flour mills/bone works','museum collections','wood products','stored food products')
AND t3.deleted=false
order by t3.id desc
limit 6);

update termlists_terms
set parent_id = 
(select tt2.id 
from termlists_terms tt2
JOIN termlists tl2 on tl2.id=tt2.termlist_id AND tl2.title = 'keywords' AND tl2.deleted=false 
JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
JOIN terms t2 on t2.id = tt2.term_id AND t2.term = 'parasite' AND t2.deleted = false
where tt2.deleted=false
order by tt2.id desc
limit 1)
where
term_id in (select t3.id 
from terms t3 
join termlists_terms tt3 on tt3.term_id=t3.id
join termlists tl3 on tl3.id=tt3.termlist_id AND tl3.title = 'keywords'
JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
where t3.term in ('bats','birds')
and t3.deleted=false
order by t3.id desc
limit 2);

update termlists_terms
set parent_id = 
(select tt2.id 
from termlists_terms tt2
JOIN termlists tl2 on tl2.id=tt2.termlist_id AND tl2.title = 'keywords' AND tl2.deleted=false 
JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
JOIN terms t2 on t2.id = tt2.term_id AND t2.term = 'ubiquitous' AND t2.deleted = false
where tt2.deleted=false
order by tt2.id desc
limit 1)
where
term_id in (select t3.id 
from terms t3 
join termlists_terms tt3 on tt3.term_id=t3.id
join termlists tl3 on tl3.id=tt3.termlist_id AND tl3.title = 'keywords'
JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
where t3.term in ('all habitats','animal/plant remains')
and t3.deleted=false
order by t3.id desc
limit 2);

























--Now Plant Associated setup

--Insert termlists
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('plant associated','plant associations',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:plant associated');

--Insert attributes
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,multi_value)
select 'plant associated','L',now(),1,now(),1,id,true
from termlists
where title='plant associated' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='plant associated'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id,multi_value)
select 'inflorescence associated','L',now(),1,now(),1,id,true
from termlists
where title='plant associated' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='inflorescence associated'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;



--Insert required terms, trait codes
select insert_term('plant-associated','eng',null,'indicia:plant associated');
select insert_term('P1','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'plant-associated' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P1' AND t3.deleted = false
  where tt3.deleted=false
);

select insert_term('inflorescence-associated','eng',null,'indicia:plant associated');
select insert_term('P21','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'inflorescence-associated' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P21' AND t3.deleted = false
  where tt3.deleted=false
);

select insert_term('nectar and/or pollen','eng',null,'indicia:plant associated');
select insert_term('P31','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'nectar and/or pollen' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P31' AND t3.deleted = false
  where tt3.deleted=false
);


select insert_term('inflorescence','eng',null,'indicia:plant associated');
select insert_term('P32','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'inflorescence' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P32' AND t3.deleted = false
  where tt3.deleted=false
);



select insert_term('fleshy fruits','eng',null,'indicia:plant associated');
select insert_term('P34','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'fleshy fruits' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P34' AND t3.deleted = false
  where tt3.deleted=false
);


select insert_term('seeds','eng',null,'indicia:plant associated');
select insert_term('P33','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'seeds' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P33' AND t3.deleted = false
  where tt3.deleted=false
);


select insert_term('leaves and/or stems','eng',null,'indicia:plant associated');
select insert_term('P22','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'leaves and/or stems' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P22' AND t3.deleted = false
  where tt3.deleted=false
);

select insert_term('roots','eng',null,'indicia:plant associated');
select insert_term('P23','eng',null,'indicia:plant associated');
update termlists_terms
set preferred = false, parent_id = null, 
meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted = false
  JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'roots' AND t2.deleted = false
  where tt2.deleted = false
)
where 
id in (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'plant associated' AND tl3.deleted = false
  JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'P23' AND t3.deleted = false
  where tt3.deleted=false
);


--Insert the sources for the terms (Attribute value sources are added at the import stage). No attribute source is set, as the termlist has the source at term level)

update termlists_terms
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Term sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'OSIRIS' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where termlist_id = 
(select tl2.id
from termlists tl2 
JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
where tl2.title = 'plant associated' AND tl2.deleted=false
order by tl2.id desc
limit 1
);

--Setup the termlist parent hierarchy.
update termlists_terms
set parent_id = 
(select tt2.id 
from termlists_terms tt2
JOIN termlists tl2 on tl2.id=tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted=false 
JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
JOIN terms t2 on t2.id = tt2.term_id AND t2.term = 'plant-associated' AND t2.deleted = false
where tt2.deleted=false
order by tt2.id desc
limit 1)
where
term_id in (select t3.id 
from terms t3 
join termlists_terms tt3 on tt3.term_id=t3.id
join termlists tl3 on tl3.id=tt3.termlist_id AND tl3.title = 'plant associated'
JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
where t3.term in ('inflorescence-associated','leaves and/or stems','roots')
AND t3.deleted=false
order by t3.id desc
limit 3);


update termlists_terms
set parent_id = 
(select tt2.id 
from termlists_terms tt2
JOIN termlists tl2 on tl2.id=tt2.termlist_id AND tl2.title = 'plant associated' AND tl2.deleted=false 
JOIN websites w on w.id = tl2.website_id AND w.title='Pantheon' and w.deleted=false
JOIN terms t2 on t2.id = tt2.term_id AND t2.term = 'inflorescence-associated' AND t2.deleted = false
where tt2.deleted=false
order by tt2.id desc
limit 1)
where
term_id in (select t3.id 
from terms t3 
join termlists_terms tt3 on tt3.term_id=t3.id
join termlists tl3 on tl3.id=tt3.termlist_id AND tl3.title = 'plant associated' 
JOIN websites w on w.id = tl3.website_id AND w.title='Pantheon' and w.deleted=false
where t3.term in ('nectar and/or pollen','inflorescence','fleshy fruits','seeds')
AND t3.deleted=false
order by t3.id desc
limit 4);












--Now rarity score termlist/attribute setup
--No termlists required for rarity score.

--Add attributes
insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
values 
('rarity score','I',now(),1,now(),1,'rarity score for Pantheon project');

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='rarity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;














--Quality Indices Setup
--Insert termlists
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('quality index capital characters','List of capital char values e.g. A,B,C for pantheon quality indices.',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:quality index capital characters'),
('quality index terms','List of terms like moderate,low for pantheon quality indices.',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:quality index terms'),
('quality index mixed characters','List of mixed character values e.g. a,a/b,b for pantheon quality indices.',(select id from websites where title='Pantheon' and deleted=false),now(),1,now(),1,'indicia:quality index mixed characters');

--Insert attributes
insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'acid mire fidelity score','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='acid mire fidelity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'calcareous grassland fidelity score','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index terms' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='calcareous grassland fidelity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'coarse woody debris fidelity score','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index mixed characters' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='coarse woody debris fidelity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('exposed riverine sediments fidelity score (D & H)','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='exposed riverine sediments fidelity score (D & H)'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('exposed riverine sediments fidelity score (S & B)','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='exposed riverine sediments fidelity score (S & B)'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('revised index of ecology continuity score','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='revised index of ecology continuity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - acid-neutral','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='seepage habitats fidelity score - acid-neutral'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - slumping cliff','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='seepage habitats fidelity score - slumping cliff'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;


insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - calcareous','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='seepage habitats fidelity score - calcareous'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - stable cliff','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='seepage habitats fidelity score - stable cliff'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'seepage habitats fidelity score - woodland','Pantheon quality indices','L',now(),1,now(),1,id
from termlists
where title='quality index capital characters' 
AND deleted=false
AND website_id = (select id from websites where title='Pantheon' and deleted=false);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='seepage habitats fidelity score - woodland'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('soft rock cliff fidelity score','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='soft rock cliff fidelity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;


insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('spider indicator species for peat bogs','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='spider indicator species for peat bogs'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('index of ecology continuity score','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='index of ecology continuity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('grazing coastal marsh score - species score','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='grazing coastal marsh score - species score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;

insert into taxa_taxon_list_attributes (caption,description,data_type,created_on,created_by_id,updated_on,updated_by_id)
values 
('grazing coastal marsh score - salinity score','Pantheon quality indices','I',now(),1,now(),1);

insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <pantheon_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='grazing coastal marsh score - salinity score'
AND deleted=false
ORDER BY id DESC 
LIMIT 1;


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
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='acid mire fidelity score' and deleted=false
order by id desc
limit 1);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Alexander (2003)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='calcareous grassland fidelity score' and deleted=false
order by id desc
limit 1) ;


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Godfrey (2003)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='coarse woody debris fidelity score' and deleted=false
order by id desc
limit 1);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Drake & Hewitt (2007)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (D & H)' and deleted=false
order by id desc
limit 1);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Sadler & Bell (2002)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='exposed riverine sediments fidelity score (S & B)' and deleted=false
order by id desc
limit 1);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - acid-neutral' and deleted=false
order by id desc
limit 1);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - calcareous' and deleted=false
order by id desc
limit 1);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - slumping cliff' and deleted=false
order by id desc
limit 1);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - stable cliff' and deleted=false
order by id desc
limit 1);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Boyce (2002)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='seepage habitats fidelity score - woodland' and deleted=false
order by id desc
limit 1);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Howe (2003)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='soft rock cliff fidelity score' and deleted=false
order by id desc
limit 1);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Scott, Oxford & Selden (2006)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='spider indicator species for peat bogs' and deleted=false
order by id desc
limit 1);

update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Palmer, Drake & Stewart (2010)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1)
where id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - species score' and deleted=false
order by id desc
limit 1);


update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'Palmer, Drake & Stewart (2010)' AND t1.deleted=false
where tt1.deleted = false
order by tt1.id desc
limit 1
)
where id = (select id from taxa_taxon_list_attributes where caption='grazing coastal marsh score - salinity score' and deleted=false
order by id desc
limit 1);

