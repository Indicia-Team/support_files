/*
 * Script which generates a schema called export containing a copy of all data required
 * for a website registration.
 */

set search_path=indicia, public;
drop schema if exists export cascade;
create schema export;

-- Change the ID of the website(s) you are exporting here.
select * into export.websites
from websites
where id in (2); /** MODIFY WEBSITE ID HERE **/

select distinct p.* into export.people
from people p
join users u on u.person_id=p.id and u.deleted=false
join users_websites uw on uw.user_id=u.id
where uw.website_id in (select id from export.websites)
and p.deleted=false;

select distinct u.* into export.users
from users u
join users_websites uw on uw.user_id=u.id
where uw.website_id in (select id from export.websites)
and u.deleted=false;

select * into export.users_websites
from users_websites
where website_id in (select id from export.websites);

select * into export.surveys
from surveys
where website_id in (select id from export.websites)
and deleted=false;

select * into export.samples
from samples
where survey_id in (select id from export.surveys)
and deleted=false;

select * into export.occurrences
from occurrences
where website_id in (select id from export.websites)
and deleted=false;

select * into export.determinations
from determinations
where occurrence_id in (select id from export.occurrences)
and deleted=false;

select l.* into export.locations
from locations l
join locations_websites lw on lw.location_id=l.id and lw.deleted=false
where lw.website_id in (select id from export.websites)
and l.deleted=false
union
select * from locations
where id in (select location_id from export.samples)
and deleted=false;

select * into export.locations_websites
from locations_websites lw
where lw.website_id in (select id from export.websites)
and lw.deleted=false;

select * into export.form_structure_blocks
from form_structure_blocks
where survey_id in (select id from export.surveys);

select distinct a.* into export.survey_attributes
from survey_attributes a
join survey_attributes_websites aw on aw.survey_attribute_id=a.id and aw.deleted=false
where aw.website_id in (select id from export.websites)
and a.deleted=false;

select * into export.survey_attribute_values
from survey_attribute_values
where survey_id in (select id from export.surveys)
and survey_attribute_id in (select id from export.survey_attributes)
and deleted=false;

select * into export.survey_attributes_websites
from survey_attributes_websites
where website_id in (select id from export.websites)
and survey_attribute_id in (select id from export.survey_attributes)
and deleted=false;

select distinct a.* into export.sample_attributes
from sample_attributes a
join sample_attributes_websites aw on aw.sample_attribute_id=a.id and aw.deleted=false
where aw.website_id in (select id from export.websites)
and a.deleted=false;

select * into export.sample_attribute_values
from sample_attribute_values
where sample_id in (select id from export.samples)
and sample_attribute_id in (select id from export.sample_attributes)
and deleted=false;

select * into export.sample_attributes_websites
from sample_attributes_websites
where website_id in (select id from export.websites)
and sample_attribute_id in (select id from export.sample_attributes)
and deleted=false;

select distinct a.* into export.occurrence_attributes
from occurrence_attributes a
join occurrence_attributes_websites aw on aw.occurrence_attribute_id=a.id and aw.deleted=false
where aw.website_id in (select id from export.websites)
and a.deleted=false;

select * into export.occurrence_attribute_values
from occurrence_attribute_values
where occurrence_id in (select id from export.occurrences)
and occurrence_attribute_id in (select id from export.occurrence_attributes)
and deleted=false;

select * into export.occurrence_attributes_websites
from occurrence_attributes_websites
where website_id in (select id from export.websites)
and occurrence_attribute_id in (select id from export.occurrence_attributes)
and deleted=false;

select distinct a.* into export.location_attributes
from location_attributes a
join location_attributes_websites aw on aw.location_attribute_id=a.id and aw.deleted=false
where aw.website_id in (select id from export.websites)
and a.deleted=false;

select * into export.location_attribute_values
from location_attribute_values
where location_id in (select id from export.locations)
and location_attribute_id in (select id from export.location_attributes)
and deleted=false;

select * into export.location_attributes_websites
from location_attributes_websites
where website_id in (select id from export.websites)
and location_attribute_id in (select id from export.location_attributes)
and deleted=false;

select distinct a.* into export.person_attributes
from person_attributes a
join person_attributes_websites aw on aw.person_attribute_id=a.id and aw.deleted=false
where aw.website_id in (select id from export.websites)
and a.deleted=false;

select * into export.person_attribute_values
from person_attribute_values
where person_id in (select id from export.people)
and person_attribute_id in (select id from export.person_attributes)
and deleted=false;

select * into export.taxon_lists
from taxon_lists
where website_id in (select id from export.websites)
and deleted=false
union
select tl.*
from taxon_lists tl
join taxa_taxon_lists ttl on ttl.taxon_list_id=tl.id and ttl.deleted=false
join export.occurrences o on o.taxa_taxon_list_id=ttl.id
where tl.deleted=false
union
select tl.*
from taxon_lists tl
join taxa_taxon_lists ttl on ttl.taxon_list_id=tl.id and ttl.deleted=false
join export.determinations d on d.taxa_taxon_list_id=ttl.id
where tl.deleted=false;

select * into export.taxa_taxon_lists
from taxa_taxon_lists
where taxon_list_id in (select id from export.taxon_lists)
and deleted=false;

select * into export.taxa
from taxa
where id in (select taxon_id from export.taxa_taxon_lists)
and deleted=false;

select * into export.taxon_groups
from taxon_groups
where id in (select taxon_group_id from export.taxa)
and deleted=false;

select * into export.taxon_ranks
from taxon_ranks
where id in (select taxon_rank_id from export.taxa)
and deleted=false;

select distinct a.* into export.taxa_taxon_list_attributes
from taxa_taxon_list_attributes a
join taxon_lists_taxa_taxon_list_attributes tla on tla.taxa_taxon_list_attribute_id=a.id and tla.deleted=false
where tla.taxon_list_id in (select id from export.taxon_lists)
and a.deleted=false;

select v.* into export.taxa_taxon_list_attribute_values
from taxa_taxon_list_attribute_values v
join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla.taxa_taxon_list_attribute_id=v.taxa_taxon_list_attribute_id and tlttla.deleted=false
where v.taxa_taxon_list_id in (select id from export.taxa_taxon_lists)
and tlttla.taxon_list_id in (select id from export.taxon_lists)
and v.deleted=false;

select * into export.taxon_lists_taxa_taxon_list_attributes
from taxon_lists_taxa_taxon_list_attributes
where taxon_list_id in (select id from export.taxon_lists)
and taxa_taxon_list_attribute_id in (select id from export.taxa_taxon_list_attributes)
and deleted=false;

select * into export.termlists
from termlists
where website_id in (select id from export.websites)
union
select *
from termlists
where id in (
  select termlist_id from export.survey_attributes
  union select termlist_id from export.sample_attributes
  union select termlist_id from export.occurrence_attributes
  union select termlist_id from export.location_attributes
  union select termlist_id from export.person_attributes
  union select termlist_id from export.taxa_taxon_list_attributes
  -- union select termlist_id from export.termlists_term_attributes
  union select distinct termlist_id from cache_termlists_terms where id in (select location_type_id from export.locations)
  union select distinct termlist_id from cache_termlists_terms where id in (select sample_method_id from export.samples)
);

select * into export.termlists_terms
from termlists_terms
where termlist_id in (select id from export.termlists)
and deleted=false;

select * into export.terms
from terms
where id in (select term_id from export.termlists_terms)
and deleted=false;

select * into export.languages
from languages
where id in (select language_id from export.terms)
and deleted=false;
