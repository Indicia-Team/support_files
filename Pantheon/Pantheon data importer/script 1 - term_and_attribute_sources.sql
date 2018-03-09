set search_path TO indicia, public;
--The Pantheon project does not own the Term/Attribute sources and these can be used for by other projects.
--Therefore these are not removed by the warehouse cleaning script
--This script only needs to run in the case that an import has never been run at all for the warehouse, although it shouldn't
--do any harm running it anyway as the insert_term function does not insert duplicates.

-- JVB changed to a dynamic query rather than hard coded list of sources, so works on new data
select insert_term(term,'eng',null,'indicia:term_sources')
from (select distinct trait_source as term from pantheon.tbl_traits where trait_source is not null) as subtable;

-- JVB changed to a dynamic query rather than hard coded list of sources, so works on new data
select insert_term(term,'eng',null,'indicia:attribute_sources')
from (select distinct trait_source as term from pantheon.tbl_traits where trait_source is not null) as subtable;

-- JVB changed to a dynamic query rather than hard coded list of sources, so works on new data
-- Changed to include special cases as agreed with client, from synanthropic (ISIS) is ignored as these are mapped to ISIS and 0 as a source is completely ignored.
select insert_term(term,'eng',null,'indicia:attribute_value_sources')
from (select distinct coding_convention as term from pantheon.tbl_species_traits where coding_convention is not null AND coding_convention not in ('0','from synanthropic (ISIS)')) as subtable;



--Set the common terms in the above lists to have the same meaning.
update termlists_terms
set meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'Term sources' AND tl2.deleted = false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'ISIS' AND t2.deleted=false
  where tt2.deleted=false
  order by tt2.id desc
  limit 1
)
where 
id = (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'Attribute sources' AND tl3.deleted = false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'ISIS' AND t3.deleted=false
  where tt3.deleted=false
  order by tt3.id desc
  limit 1
)
OR 
id = (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'Attribute value sources' AND tl3.deleted = false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'ISIS' AND t3.deleted=false
  where tt3.deleted=false
  order by tt3.id desc
  limit 1
);

update termlists_terms
set meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'Term sources' AND tl2.deleted = false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'OSIRIS' AND t2.deleted=false
  where tt2.deleted=false
  order by tt2.id desc
  limit 1
)
where 
id = (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'Attribute sources' AND tl3.deleted = false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'OSIRIS' AND t3.deleted=false
  where tt3.deleted=false
  order by tt3.id desc
  limit 1
);

update termlists_terms
set meaning_id = (
  select meaning_id from termlists_terms tt2
  join termlists tl2 on tl2.id = tt2.termlist_id AND tl2.title = 'Term sources' AND tl2.deleted = false
  join terms t2 on t2.id = tt2.term_id AND t2.term = 'HORUS' AND t2.deleted=false
  where tt2.deleted=false
  order by tt2.id desc
  limit 1
)
where 
id = (
  select tt3.id from termlists_terms tt3
  join termlists tl3 on tl3.id = tt3.termlist_id AND tl3.title = 'Attribute sources' AND tl3.deleted = false
  join terms t3 on t3.id = tt3.term_id AND t3.term = 'HORUS' AND t3.deleted=false
  where tt3.deleted=false
  order by tt3.id desc
  limit 1
);
