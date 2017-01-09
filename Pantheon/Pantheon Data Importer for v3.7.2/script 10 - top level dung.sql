/*
Creates dung & carrion entries at the top level for any species that is typed to dung & carrion somewhere further
down the resource hierarchy.
*/
insert into taxa_taxon_list_attribute_values (
  taxa_taxon_list_id,
  taxa_taxon_list_attribute_id,
  int_value,
  created_on, 
  created_by_id,
  updated_on,
  updated_by_id
)
select 
  cttl.preferred_taxa_taxon_list_id, 
  (select id from taxa_taxon_list_attributes where caption='resource'),
  (select id from detail_termlists_terms where term='dung & carrion' and parent_id is null and termlist_external_key='indicia:broad biotope/habitat/resource'),
  now(), 
  1,
  now(),
  1
from cache_taxa_taxon_lists cttl
join taxa_taxon_list_attribute_values av on av.taxa_taxon_list_id=cttl.preferred_taxa_taxon_list_id
join cache_termlists_terms t on t.id=av.int_value and t.term='dung & carrion' and t.parent_id is not null
left join (
  taxa_taxon_list_attribute_values av2 
  join cache_termlists_terms t2 on t2.id=av2.int_value and t2.term='dung & carrion' and t2.parent_id is null
) on av2.taxa_taxon_list_id=cttl.preferred_taxa_taxon_list_id
where av2.id is null
order by cttl.preferred_taxon



