--To run this script, you need to do mass replacements of
--<pantheon_taxon_list_id>
--<broad_biotope_attr_id>
--<habitat_attr_id>

insert into taxa_taxon_list_attribute_values (taxa_taxon_list_id, taxa_taxon_list_attribute_id, int_value, created_on, created_by_id, updated_on, updated_by_id)
select distinct cttl.id, <broad_biotope_attr_id>, tbbderived.id, now(), 1, now(), 1
from cache_taxa_taxon_lists cttl
join taxa_taxon_list_attribute_values avh 
  on avh.taxa_taxon_list_id=cttl.id and avh.deleted=false
  and avh.taxa_taxon_list_attribute_id=<habitat_attr_id>
join cache_termlists_terms th on th.id=avh.int_value
join cache_termlists_terms tbbderived on tbbderived.id=th.parent_id
left join taxa_taxon_list_attribute_values avbb 
	on avbb.int_value=tbbderived.id
	and avbb.taxa_taxon_list_attribute_id=<broad_biotope_attr_id> 
	and avbb.deleted=false
	and avbb.taxa_taxon_list_id=cttl.id

where cttl.taxon_list_id=<pantheon_taxon_list_id>
and cttl.preferred=true
and avbb.id is null
