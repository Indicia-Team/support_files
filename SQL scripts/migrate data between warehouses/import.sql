/*
 * Script which processes exported data from another warehouse (in a schema called
 * export) by reworking all the foreign keys to fit into the destination warehouse.
 *
*/
set search_path=indicia, public;
drop schema if exists import cascade;
create schema import;

/* Users and people */

select *, id as old_id, null::boolean as new
into import.users
from export.users;

update import.users set id=null;

select *, id as old_id, null::boolean as new
into import.people
from export.people;

update import.people set id=null;

update import.people p1
set id=p2.id, new=false
from people p2
where coalesce(p2.email_address, p2.surname)=coalesce(p1.email_address, p1.surname) and p2.deleted=false;

update import.people set id=nextval('people_id_seq'::regclass), new=true where id is null;

update import.users u1
set person_id=p.id
from import.people p
where person_id=p.old_id
and person_id<>p.id;

update import.users u1
set id=u2.id, new=false
from users u2
where u2.person_id=u1.person_id
and u2.deleted=false;

update import.users set id=nextval('users_id_seq'::regclass), new=true where id is null;

select *, id as old_id, true as new
into import.users_websites
from export.users_websites;

-- Users table may contain username clashes, so make them unique.
update import.users u1
set username = u1.username || '_' || floor(random() * 10000 + 1)::int::text
from users u2
where u2.username=u1.username
and u1.new=true;

-- Metadata user FKs - created_by_id and updated_by_id
update import.users set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.users u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.users set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.users u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.people set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.people u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.people set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.people u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.users_websites set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.users_websites u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.users_websites set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.users_websites u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Languages */

-- Insert records and create new key values.
select *, id as old_id, null::boolean as new
  into import.languages
  from export.languages;

update import.languages set id=null;

update import.languages u1
set id=u2.id, new=false
from languages u2
where u2.iso=u1.iso;

update import.languages set id=nextval('languages_id_seq'::regclass), new=true where id is null;

-- Metadata user FKs - created_by_id and updated_by_id
update import.languages set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.languages u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.languages set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.languages u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Websites */

-- Insert records and create new key values.
select *, id as old_id, true as new
  into import.websites
  from export.websites;
  
update import.websites set id=null;

/** If website entry exists, set it here, e.g.
update import.websites set id=123, new=false where title='my website';
*/

update import.websites set id=nextval('websites_id_seq'::regclass) where id is null;

-- Metadata user FKs - created_by_id and updated_by_id
update import.websites set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.websites u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.websites set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.websites u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

-- Foreign keys for users_websites can be done now we know the website mapping.

update import.users_websites u1
  set user_id=u2.id
  from import.users u2
  where u1.user_id=u2.old_id
  and u1.user_id<>u2.id;

update import.users_websites u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

/* Termlists and contents */

select *, id as old_id, null::boolean as new
  into import.termlists
  from export.termlists;

update import.termlists set id=null;

select *, id as old_id, null::boolean as new
  into import.terms
  from export.terms;

update import.terms set id=null;

select *, id as old_id, meaning_id as old_meaning_id, null::boolean as new
  into import.termlists_terms
  from export.termlists_terms;

update import.termlists_terms set id=null, meaning_id=null;

/** Link any termlists that exist on both warehouses. Example given here. **/
--update import.termlists set id=8, new=false where title='Countries';

-- Work out the links to existing terms
drop table if exists term_updates;
select distinct on(it.old_id)
  it.old_id as old_term_id, t.id as new_term_id,
  itlt.old_id as old_termlists_term_id, tlt.id as new_termlists_term_id,
  itlt.old_meaning_id, tlt.meaning_id as new_meaning_id
into temporary term_updates
from import.termlists_terms itlt
join import.termlists itl on itl.old_id=itlt.termlist_id and itl.new=false
join import.terms it on it.old_id=itlt.term_id
join termlists_terms tlt on tlt.termlist_id=itl.id and tlt.deleted=false
join terms t on t.id=tlt.term_id and t.deleted=false
where t.term=it.term
and coalesce(tlt.sort_order, 0)=coalesce(itlt.sort_order, 0);

update import.terms t
set id=new_term_id, new=false
from term_updates tu
where tu.old_term_id=t.old_id;

update import.termlists_terms tlt
set id=new_termlists_term_id, meaning_id=new_meaning_id, new=false
from term_updates tu
where tu.old_termlists_term_id=tlt.old_id;

update import.termlists set id=nextval('termlists_id_seq'::regclass), new=true where id is null;
update import.termlists_terms set id=nextval('termlists_terms_id_seq'::regclass), new=true where id is null;
update import.terms set id=nextval('terms_id_seq'::regclass), new=true where id is null;

-- Foreign keys

update import.termlists u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

-- Termlists might be included even if they belong to a different website. If so make
-- them public for the export so nothing breaks.
update import.termlists set website_id=null where website_id not in (select id from import.websites);

update import.termlists u1
  set parent_id=u2.id
  from import.termlists u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

update import.termlists_terms u1
  set termlist_id=u2.id
  from import.termlists u2
  where u1.termlist_id=u2.old_id
  and u1.termlist_id<>u2.id;

update import.termlists_terms u1
  set term_id=u2.id
  from import.terms u2
  where u1.term_id=u2.old_id
  and u1.term_id<>u2.id;

update import.termlists_terms u1
  set parent_id=u2.id
  from import.termlists_terms u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

update import.termlists_terms u1
  set source_id=u2.id
  from import.termlists_terms u2
  where u1.source_id=u2.old_id
  and u1.source_id<>u2.id;

update import.terms u1
  set language_id=u2.id
  from import.languages u2
  where u1.language_id=u2.old_id
  and u1.language_id<>u2.id;

-- New meaning IDs will need to be generated.
update import.termlists_terms set meaning_id=nextval('meanings_id_seq'::regclass) where meaning_id is null and preferred=true;
select distinct meaning_id as id
  into import.meanings
  from import.termlists_terms where new=true
  and meaning_id is not null;
update import.termlists_terms u1
  set meaning_id=u2.meaning_id
  from import.termlists_terms u2
where u2.old_meaning_id=u1.old_meaning_id
and u1.meaning_id is null
and u2.meaning_id is not null
and u2.preferred=true;

-- Metadata user FKs - created_by_id and updated_by_id
update import.termlists set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.termlists u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.termlists set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.termlists u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.termlists_terms set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.termlists_terms u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.termlists_terms set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.termlists_terms u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.terms set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.terms u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.terms set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.terms u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Taxon groups */

-- Insert records and create new key values.
select *, id as old_id, null::boolean as new
  into import.taxon_groups
  from export.taxon_groups;
update import.taxon_groups set id=null;

/** Fix any taxon groups to known IDs, e.g. 
update import.taxon_groups set id=104, new=false where title='Butterflies';
*/

update import.taxon_groups u1
set id=u2.id, new=false
from taxon_groups u2
where u2.title=u1.title
and coalesce(u2.external_key, '')=coalesce(u1.external_key, '')
and u2.deleted=false
and u1.id is null;

update import.taxon_groups set id=nextval('taxon_groups_id_seq'::regclass), new=true where id is null;

-- Foreign keys
update import.taxon_groups u1
  set parent_id=u2.id
  from import.taxon_groups u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.taxon_groups set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.taxon_groups u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.taxon_groups set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.taxon_groups u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Taxon ranks */

-- Insert records and create new key values.
select *, id as old_id, null::boolean as new
  into import.taxon_ranks
  from export.taxon_ranks;
update import.taxon_ranks set id=null;

update import.taxon_ranks u1
set id=u2.id, new=false
from taxon_ranks u2
where u2.rank=u1.rank
and coalesce(u2.short_name, '')=coalesce(u1.short_name, '')
and u2.deleted=false;

update import.taxon_ranks set id=nextval('taxon_ranks_id_seq'::regclass), new=true where id is null;

-- Metadata user FKs - created_by_id and updated_by_id
update import.taxon_ranks set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.taxon_ranks u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.taxon_ranks set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.taxon_ranks u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Taxon lists and contents */

-- Insert records and create new key values.
select *, id as old_id, null::boolean as new
  into import.taxon_lists
  from export.taxon_lists;

update import.taxon_lists set id=null;

select *, id as old_id, null::boolean as new
  into import.taxa
  from export.taxa;

update import.taxa set id=null;

select *, id as old_id, taxon_meaning_id as old_taxon_meaning_id, null::boolean as new
  into import.taxa_taxon_lists
  from export.taxa_taxon_lists;

update import.taxa_taxon_lists set id=null, taxon_meaning_id=null;

/** Link any taxon lists that exist on both warehouses. Example given here. **/
--update import.taxon_lists set id=1, new=false where title='UKSI';

drop table if exists taxon_updates;
select distinct on(it.old_id)
  it.old_id as old_taxon_id, t.id as new_taxon_id,
  ittl.old_id as old_taxa_taxon_list_id, ttl.id as new_taxa_taxon_list_id,
  ittl.old_taxon_meaning_id, ttl.taxon_meaning_id as new_taxon_meaning_id
into temporary taxon_updates
from import.taxa_taxon_lists ittl
join import.taxon_lists itl on itl.old_id=ittl.taxon_list_id and itl.new=false
join import.taxa it on it.old_id=ittl.taxon_id
join taxa_taxon_lists ttl on ttl.taxon_list_id=itl.id and ttl.deleted=false
join taxa t on t.id=ttl.taxon_id and t.deleted=false
where t.taxon=it.taxon
and coalesce(t.authority, '')=coalesce(it.authority, '')
and coalesce(t.attribute, '')=coalesce(it.attribute, '')
and coalesce(t.external_key, '')=coalesce(it.external_key, '')
and coalesce(t.search_code, '')=coalesce(it.search_code, '');

update import.taxa t
set id=new_taxon_id, new=false
from taxon_updates tu
where tu.old_taxon_id=t.old_id;

update import.taxa_taxon_lists ttl
set id=new_taxa_taxon_list_id, taxon_meaning_id=new_taxon_meaning_id, new=false
from taxon_updates tu
where tu.old_taxa_taxon_list_id=ttl.old_id;

update import.taxon_lists set id=nextval('taxon_lists_id_seq'::regclass), new=true where id is null;
update import.taxa_taxon_lists set id=nextval('taxa_taxon_lists_id_seq'::regclass), new=true where id is null;
update import.taxa set id=nextval('taxa_id_seq'::regclass), new=true where id is null;

-- Foreign keys
update import.taxon_lists u1
  set parent_id=u2.id
  from import.taxon_lists u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

update import.taxon_lists u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

update import.taxa u1
  set taxon_group_id=u2.id
  from import.taxon_groups u2
  where u1.taxon_group_id=u2.old_id
  and u1.taxon_group_id<>u2.id;

update import.taxa u1
  set taxon_rank_id=u2.id
  from import.taxon_ranks u2
  where u1.taxon_rank_id=u2.old_id
  and u1.taxon_rank_id<>u2.id;

update import.taxa u1
  set language_id=u2.id
  from import.languages u2
  where u1.language_id=u2.old_id
  and u1.language_id<>u2.id;

update import.taxa_taxon_lists u1
  set taxon_list_id=u2.id
  from import.taxon_lists u2
  where u1.taxon_list_id=u2.old_id
  and u1.taxon_list_id<>u2.id;

update import.taxa_taxon_lists u1
  set taxon_id=u2.id
  from import.taxa u2
  where u1.taxon_id=u2.old_id
  and u1.taxon_id<>u2.id;

update import.taxa_taxon_lists u1
  set parent_id=u2.id
  from import.taxa_taxon_lists u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

update import.taxa_taxon_lists u1
  set common_taxon_id=u2.id
  from import.taxa u2
  where u1.common_taxon_id=u2.old_id
  and u1.common_taxon_id<>u2.id;

-- New taxon meaning IDs will need to be generated.
update import.taxa_taxon_lists set taxon_meaning_id=nextval('taxon_meanings_id_seq'::regclass) where taxon_meaning_id is null and preferred=true;
select distinct taxon_meaning_id as id
  into import.taxon_meanings
  from import.taxa_taxon_lists where new=true
  and taxon_meaning_id is not null;
update import.taxa_taxon_lists u1
  set taxon_meaning_id=u2.taxon_meaning_id
  from import.taxa_taxon_lists u2
where u2.old_taxon_meaning_id=u1.old_taxon_meaning_id
and u1.taxon_meaning_id is null
and u2.taxon_meaning_id is not null
and u2.preferred=true;

-- Metadata user FKs - created_by_id and updated_by_id
update import.taxon_lists set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.taxon_lists u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.taxon_lists set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.taxon_lists u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.taxa_taxon_lists set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.taxa_taxon_lists u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.taxa_taxon_lists set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.taxa_taxon_lists u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.taxa set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.taxa u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.taxa set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.taxa u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Locations */
select *, id as old_id, null::boolean as new
  into import.locations
  from export.locations;

-- Do location_type_id FK matchup first, as it is needed to match to existing locations.
update import.locations u1
  set location_type_id=u2.id
  from import.termlists_terms u2
  where u1.location_type_id=u2.old_id
  and u1.location_type_id<>u2.id;

update import.locations set id=null;

update import.locations u1
set id=u2.id, new=false
from locations u2
where u2.name=u1.name
and coalesce(u2.code, '')=coalesce(u1.code, '')
and u2.centroid_sref=u1.centroid_sref
and u2.centroid_sref_system=u1.centroid_sref_system
and u2.location_type_id=u1.location_type_id
-- only match up public locations
and u2.id not in (select location_id from locations_websites)
and u1.old_id not in (select location_id from export.locations_websites);

update import.locations set id=nextval('locations_id_seq'::regclass), new=true where id is null;

-- Foreign keys
update import.locations u1
  set parent_id=u2.id
  from import.locations u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

update import.locations u1
  set location_type_id=u2.id
  from import.termlists_terms u2
  where u1.location_type_id=u2.old_id
  and u1.location_type_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.locations set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.locations u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.locations set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.locations u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Locations_websites */

select *, id as old_id, true as new
  into import.locations_websites
  from export.locations_websites;

update import.locations_websites set id=nextval('locations_websites_id_seq'::regclass);

-- Foreign keys
update import.locations_websites u1
  set location_id=u2.id
  from import.locations u2
  where u1.location_id=u2.old_id
  and u1.location_id<>u2.id;

update import.locations_websites u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.locations_websites set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.locations_websites u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.locations_websites set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.locations_websites u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Surveys */

-- Insert records and create new key values.
select *, id as old_id, true as new
  into import.surveys
  from export.surveys;

update import.surveys set id=nextval('surveys_id_seq'::regclass);

-- Foreign keys
update import.surveys u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.surveys set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.surveys u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.surveys set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.surveys u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Samples */

-- Insert records and create new key values.
select *, id as old_id, true as new
  into import.samples
  from export.samples;

update import.samples set id=nextval('samples_id_seq'::regclass);

-- Foreign keys
update import.samples u1
  set survey_id=u2.id
  from import.surveys u2
  where u1.survey_id=u2.old_id
  and u1.survey_id<>u2.id;

update import.samples u1
  set parent_id=u2.id
  from import.samples u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

update import.samples u1
  set sample_method_id=u2.id
  from import.termlists_terms u2
  where u1.sample_method_id=u2.old_id
  and u1.sample_method_id<>u2.id;

update import.samples u1
  set location_id=u2.id
  from import.locations u2
  where u1.location_id=u2.old_id
  and u1.location_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.samples set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.samples u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.samples set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.samples u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;
update import.samples set verified_by_id=1 where verified_by_id not in (select old_id from import.users);
update import.samples u1
  set verified_by_id=u2.id
  from import.users u2
  where u1.verified_by_id=u2.old_id
  and u1.verified_by_id<>u2.id;

/* Occurrences */

-- Insert records and create new key values.
select *, id as old_id, true as new
  into import.occurrences
  from export.occurrences;

update import.occurrences set id=nextval('occurrences_id_seq'::regclass);

-- Foreign keys
update import.occurrences u1
  set sample_id=u2.id
  from import.samples u2
  where u1.sample_id=u2.old_id
  and u1.sample_id<>u2.id;

update import.occurrences u1
  set determiner_id=u2.id
  from import.people u2
  where u1.determiner_id=u2.old_id
  and u1.determiner_id<>u2.id;

update import.occurrences u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

update import.occurrences u1
  set taxa_taxon_list_id=u2.id
  from import.taxa_taxon_lists u2
  where u1.taxa_taxon_list_id=u2.old_id
  and u1.taxa_taxon_list_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.occurrences set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.occurrences u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.occurrences set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.occurrences u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;
update import.occurrences set verified_by_id=1 where verified_by_id not in (select old_id from import.users);
update import.occurrences u1
  set verified_by_id=u2.id
  from import.users u2
  where u1.verified_by_id=u2.old_id
  and u1.verified_by_id<>u2.id;

/* Determinations */

-- Insert records and create new key values.
select *, id as old_id, true as new
  into import.determinations
  from export.determinations;

update import.determinations set id=nextval('determinations_id_seq'::regclass);

-- Foreign keys
update import.determinations u1
  set occurrence_id=u2.id
  from import.occurrences u2
  where u1.occurrence_id=u2.old_id
  and u1.occurrence_id<>u2.id;

update import.determinations u1
  set taxa_taxon_list_id=u2.id
  from import.taxa_taxon_lists u2
  where u1.taxa_taxon_list_id=u2.old_id
  and u1.taxa_taxon_list_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.determinations set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.determinations u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.determinations set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.determinations u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Form structure blocks */

select *, id as old_id, true as new
  into import.form_structure_blocks
  from export.form_structure_blocks;
update import.form_structure_blocks set id=nextval('form_structure_blocks_id_seq'::regclass);

-- Foreign keys
update import.form_structure_blocks u1
  set parent_id=u2.id
  from import.form_structure_blocks u2
  where u1.parent_id=u2.old_id
  and u1.parent_id<>u2.id;

-- Foreign keys
update import.form_structure_blocks u1
  set survey_id=u2.id
  from import.surveys u2
  where u1.survey_id=u2.old_id
  and u1.survey_id<>u2.id;

/* Attributes */

select *, id as old_id, null::boolean as new
  into import.survey_attributes
  from export.survey_attributes;
update import.survey_attributes set id=null;

select *, id as old_id, null::boolean as new
  into import.sample_attributes
  from export.sample_attributes;
update import.sample_attributes set id=null;

select *, id as old_id, null::boolean as new
  into import.occurrence_attributes
  from export.occurrence_attributes;
update import.occurrence_attributes set id=null;

select *, id as old_id, null::boolean as new
  into import.location_attributes
  from export.location_attributes;
update import.location_attributes set id=null;

select *, id as old_id, null::boolean as new
  into import.person_attributes
  from export.person_attributes;
update import.person_attributes set id=null;

select *, id as old_id, null::boolean as new
  into import.taxa_taxon_list_attributes
  from export.taxa_taxon_list_attributes;
update import.taxa_taxon_list_attributes set id=null;

/** Link any attributes that exist on both warehouses. Example given here. **/
--update import.survey_attributes set id=..., new=false where title='...';

update import.survey_attributes set id=nextval('survey_attributes_id_seq'::regclass), new=true where id is null;
update import.sample_attributes set id=nextval('sample_attributes_id_seq'::regclass), new=true where id is null;
update import.occurrence_attributes set id=nextval('occurrence_attributes_id_seq'::regclass), new=true where id is null;
update import.location_attributes set id=nextval('location_attributes_id_seq'::regclass), new=true where id is null;
update import.person_attributes set id=nextval('person_attributes_id_seq'::regclass), new=true where id is null;
update import.taxa_taxon_list_attributes set id=nextval('taxa_taxon_list_attributes_id_seq'::regclass), new=true where id is null;

-- Foreign keys
update import.survey_attributes u1
  set termlist_id=u2.id
  from import.termlists u2
  where u1.termlist_id=u2.old_id
  and u1.termlist_id<>u2.id;

update import.sample_attributes u1
  set termlist_id=u2.id
  from import.termlists u2
  where u1.termlist_id=u2.old_id
  and u1.termlist_id<>u2.id;

update import.occurrence_attributes u1
  set termlist_id=u2.id
  from import.termlists u2
  where u1.termlist_id=u2.old_id
  and u1.termlist_id<>u2.id;

update import.location_attributes u1
  set termlist_id=u2.id
  from import.termlists u2
  where u1.termlist_id=u2.old_id
  and u1.termlist_id<>u2.id;

update import.person_attributes u1
  set termlist_id=u2.id
  from import.termlists u2
  where u1.termlist_id=u2.old_id
  and u1.termlist_id<>u2.id;

update import.taxa_taxon_list_attributes u1
  set termlist_id=u2.id
  from import.termlists u2
  where u1.termlist_id=u2.old_id
  and u1.termlist_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.survey_attributes set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.survey_attributes u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.survey_attributes set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.survey_attributes u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.sample_attributes set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.sample_attributes u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.sample_attributes set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.sample_attributes u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.occurrence_attributes set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.occurrence_attributes u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.occurrence_attributes set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.occurrence_attributes u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.location_attributes set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.location_attributes u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.location_attributes set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.location_attributes u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.person_attributes set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.person_attributes u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.person_attributes set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.person_attributes u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.taxa_taxon_list_attributes set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.taxa_taxon_list_attributes u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.taxa_taxon_list_attributes set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.taxa_taxon_list_attributes u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

/* Attribute links */

select *, id as old_id, true as new
  into import.survey_attributes_websites
  from export.survey_attributes_websites;
update import.survey_attributes_websites set id=nextval('survey_attributes_websites_id_seq'::regclass);

select *, id as old_id, true as new
  into import.sample_attributes_websites
  from export.sample_attributes_websites;
update import.sample_attributes_websites set id=nextval('sample_attributes_websites_id_seq'::regclass);

select *, id as old_id, true as new
  into import.occurrence_attributes_websites
  from export.occurrence_attributes_websites;
update import.occurrence_attributes_websites set id=nextval('occurrence_attributes_websites_id_seq'::regclass);

select *, id as old_id, true as new
  into import.location_attributes_websites
  from export.location_attributes_websites;
update import.location_attributes_websites set id=nextval('location_attributes_websites_id_seq'::regclass);

select *, id as old_id, true as new
  into import.taxon_lists_taxa_taxon_list_attributes
  from export.taxon_lists_taxa_taxon_list_attributes;
update import.taxon_lists_taxa_taxon_list_attributes set id=nextval('taxon_lists_taxa_taxon_list_attributes_id_seq'::regclass);

-- Foreign keys

update import.survey_attributes_websites u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

update import.survey_attributes_websites u1
  set survey_attribute_id=u2.id
  from import.survey_attributes u2
  where u1.survey_attribute_id=u2.old_id
  and u1.survey_attribute_id<>u2.id;

update import.sample_attributes_websites u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

update import.sample_attributes_websites u1
  set sample_attribute_id=u2.id
  from import.sample_attributes u2
  where u1.sample_attribute_id=u2.old_id
  and u1.sample_attribute_id<>u2.id;

update import.sample_attributes_websites u1
  set restrict_to_survey_id=u2.id
  from import.surveys u2
  where u1.restrict_to_survey_id=u2.old_id
  and u1.restrict_to_survey_id<>u2.id;

update import.occurrence_attributes_websites u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

update import.occurrence_attributes_websites u1
  set occurrence_attribute_id=u2.id
  from import.occurrence_attributes u2
  where u1.occurrence_attribute_id=u2.old_id
  and u1.occurrence_attribute_id<>u2.id;

update import.occurrence_attributes_websites u1
  set restrict_to_survey_id=u2.id
  from import.surveys u2
  where u1.restrict_to_survey_id=u2.old_id
  and u1.restrict_to_survey_id<>u2.id;

update import.location_attributes_websites u1
  set website_id=u2.id
  from import.websites u2
  where u1.website_id=u2.old_id
  and u1.website_id<>u2.id;

update import.location_attributes_websites u1
  set location_attribute_id=u2.id
  from import.location_attributes u2
  where u1.location_attribute_id=u2.old_id
  and u1.location_attribute_id<>u2.id;

update import.location_attributes_websites u1
  set restrict_to_survey_id=u2.id
  from import.surveys u2
  where u1.restrict_to_survey_id=u2.old_id
  and u1.restrict_to_survey_id<>u2.id;

update import.taxon_lists_taxa_taxon_list_attributes u1
  set taxon_list_id=u2.id
  from import.taxon_lists u2
  where u1.taxon_list_id=u2.old_id
  and u1.taxon_list_id<>u2.id;

update import.taxon_lists_taxa_taxon_list_attributes u1
  set taxa_taxon_list_attribute_id=u2.id
  from import.taxa_taxon_list_attributes u2
  where u1.taxa_taxon_list_attribute_id=u2.old_id
  and u1.taxa_taxon_list_attribute_id<>u2.id;

/* Attribute values */

select *, id as old_id, true as new
  into import.survey_attribute_values
  from export.survey_attribute_values;
update import.survey_attribute_values set id=nextval('survey_attribute_values_id_seq'::regclass);

select *, id as old_id, true as new
  into import.sample_attribute_values
  from export.sample_attribute_values;
update import.sample_attribute_values set id=nextval('sample_attribute_values_id_seq'::regclass);

select *, id as old_id, true as new
  into import.occurrence_attribute_values
  from export.occurrence_attribute_values;
update import.occurrence_attribute_values set id=nextval('occurrence_attribute_values_id_seq'::regclass);

select *, id as old_id, true as new
  into import.location_attribute_values
  from export.location_attribute_values;
update import.location_attribute_values set id=nextval('location_attribute_values_id_seq'::regclass);

select *, id as old_id, true as new
  into import.person_attribute_values
  from export.person_attribute_values;
update import.person_attribute_values set id=nextval('person_attribute_values_id_seq'::regclass);

select *, id as old_id, true as new
  into import.taxa_taxon_list_attribute_values
  from export.taxa_taxon_list_attribute_values;
update import.taxa_taxon_list_attribute_values set id=nextval('taxa_taxon_list_attribute_values_id_seq'::regclass);

-- Foreign keys

update import.survey_attribute_values u1
  set int_value=u2.id
  from import.termlists_terms u2, import.survey_attributes a
  where u1.int_value=u2.old_id
  and u1.int_value<>u2.id
  and a.old_id=u1.survey_attribute_id
  and a.data_type='L';

update import.survey_attribute_values u1
  set survey_attribute_id=u2.id
  from import.survey_attributes u2
  where u1.survey_attribute_id=u2.old_id
  and u1.survey_attribute_id<>u2.id;

update import.survey_attribute_values u1
  set survey_id=u2.id
  from import.surveys u2
  where u1.survey_id=u2.old_id
  and u1.survey_id<>u2.id;

update import.sample_attribute_values u1
  set int_value=u2.id
  from import.termlists_terms u2, import.sample_attributes a
  where u1.int_value=u2.old_id
  and u1.int_value<>u2.id
  and a.old_id=u1.sample_attribute_id
  and a.data_type='L';

update import.sample_attribute_values u1
  set sample_attribute_id=u2.id
  from import.sample_attributes u2
  where u1.sample_attribute_id=u2.old_id
  and u1.sample_attribute_id<>u2.id;

update import.sample_attribute_values u1
  set sample_id=u2.id
  from import.samples u2
  where u1.sample_id=u2.old_id
  and u1.sample_id<>u2.id;

update import.occurrence_attribute_values u1
  set int_value=u2.id
  from import.termlists_terms u2, import.occurrence_attributes a
  where u1.int_value=u2.old_id
  and u1.int_value<>u2.id
  and a.old_id=u1.occurrence_attribute_id
  and a.data_type='L';

update import.occurrence_attribute_values u1
  set occurrence_attribute_id=u2.id
  from import.occurrence_attributes u2
  where u1.occurrence_attribute_id=u2.old_id
  and u1.occurrence_attribute_id<>u2.id;

update import.occurrence_attribute_values u1
  set occurrence_id=u2.id
  from import.occurrences u2
  where u1.occurrence_id=u2.old_id
  and u1.occurrence_id<>u2.id;

update import.location_attribute_values u1
  set int_value=u2.id
  from import.termlists_terms u2, import.location_attributes a
  where u1.int_value=u2.old_id
  and u1.int_value<>u2.id
  and a.old_id=u1.location_attribute_id
  and a.data_type='L';

update import.location_attribute_values u1
  set location_attribute_id=u2.id
  from import.location_attributes u2
  where u1.location_attribute_id=u2.old_id
  and u1.location_attribute_id<>u2.id;

update import.location_attribute_values u1
  set location_id=u2.id
  from import.locations u2
  where u1.location_id=u2.old_id
  and u1.location_id<>u2.id;

update import.person_attribute_values u1
  set int_value=u2.id
  from import.termlists_terms u2, import.person_attributes a
  where u1.int_value=u2.old_id
  and u1.int_value<>u2.id
  and a.old_id=u1.person_attribute_id
  and a.data_type='L';

update import.person_attribute_values u1
  set person_attribute_id=u2.id
  from import.person_attributes u2
  where u1.person_attribute_id=u2.old_id
  and u1.person_attribute_id<>u2.id;

update import.person_attribute_values u1
  set person_id=u2.id
  from import.people u2
  where u1.person_id=u2.old_id
  and u1.person_id<>u2.id;

update import.taxa_taxon_list_attribute_values u1
  set int_value=u2.id
  from import.termlists_terms u2, import.taxa_taxon_list_attributes a
  where u1.int_value=u2.old_id
  and u1.int_value<>u2.id
  and a.old_id=u1.taxa_taxon_list_attribute_id
  and a.data_type='L';

update import.taxa_taxon_list_attribute_values u1
  set taxa_taxon_list_attribute_id=u2.id
  from import.taxa_taxon_list_attributes u2
  where u1.taxa_taxon_list_attribute_id=u2.old_id
  and u1.taxa_taxon_list_attribute_id<>u2.id;

update import.taxa_taxon_list_attribute_values u1
  set taxa_taxon_list_id=u2.id
  from import.taxa_taxon_lists u2
  where u1.taxa_taxon_list_id=u2.old_id
  and u1.taxa_taxon_list_id<>u2.id;

-- Metadata user FKs - created_by_id and updated_by_id
update import.survey_attribute_values set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.survey_attribute_values u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.survey_attribute_values set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.survey_attribute_values u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.sample_attribute_values set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.sample_attribute_values u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.sample_attribute_values set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.sample_attribute_values u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.occurrence_attribute_values set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.occurrence_attribute_values u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.occurrence_attribute_values set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.occurrence_attribute_values u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.location_attribute_values set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.location_attribute_values u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.location_attribute_values set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.location_attribute_values u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.person_attributes set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.person_attributes u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.person_attribute_values set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.person_attribute_values u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;

update import.taxa_taxon_list_attribute_values set created_by_id=1 where created_by_id not in (select old_id from import.users);
update import.taxa_taxon_list_attribute_values u1
  set created_by_id=u2.id
  from import.users u2
  where u1.created_by_id=u2.old_id
  and u1.created_by_id<>u2.id;
update import.taxa_taxon_list_attribute_values set updated_by_id=1 where updated_by_id not in (select old_id from import.users);
update import.taxa_taxon_list_attribute_values u1
  set updated_by_id=u2.id
  from import.users u2
  where u1.updated_by_id=u2.old_id
  and u1.updated_by_id<>u2.id;
