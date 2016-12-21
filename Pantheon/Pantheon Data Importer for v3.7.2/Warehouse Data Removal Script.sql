set search_path TO indicia, public;

select id 
into temporary taxa_taxon_list_attributes_removal_rows
from taxa_taxon_list_attributes
where id between 158 and 183;

delete from taxa_taxon_list_attribute_values where taxa_taxon_list_attribute_id in (
  select id from taxa_taxon_list_attributes_removal_rows
);

delete from taxon_lists_taxa_taxon_list_attributes where taxa_taxon_list_attribute_id in (
  select id from taxa_taxon_list_attributes_removal_rows
);

delete from taxa_taxon_list_attributes where id in (
  select id from taxa_taxon_list_attributes_removal_rows
);

--Remove temporary table
drop table taxa_taxon_list_attributes_removal_rows;

select id, term_id, termlist_id into temporary termlists_terms_removal_rows
from termlists_terms
where termlist_id in (
  select t.id from termlists t 
  join websites w on w.id=t.website_id and w.title='Pantheon' and w.deleted=false
  where t.deleted = false
);

update termlists_terms set parent_id=null where parent_id in (select id from termlists_terms_removal_rows);

delete from cache_termlists_terms where id in
(select id from termlists_terms_removal_rows);

delete from termlists_terms where id in
(select id from termlists_terms_removal_rows);

delete from termlists where id in
(select termlist_id from termlists_terms_removal_rows);

delete from terms where id not in (select term_id from termlists_terms);

--Remove temporary table
drop table termlists_terms_removal_rows;
