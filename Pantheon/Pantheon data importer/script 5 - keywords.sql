--To run this script, you need to do mass replacements of
--<pantheon_taxon_list_id>

--Do the import itself.
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
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description in 
('extinct','parasite','synanthropic','ubiquitous','unknown','vagrant/introduced','in buildings','compost/manure heaps','flour mills/bone works','museum collections','wood products'
,'stored food products','bats','birds','all habitats','animal/plant remains')
join indicia.terms iTerm on iTerm.term=pt.trait_description AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='keywords' AND itl.deleted=false
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
--Species are allowed to be associated with multiple keywords, although exact duplicate are obviously not allowed.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='keywords' and deleted=false order by id desc limit 1) AND ttlav2.int_value=trait_to_import.insertion_tt AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='keywords' and deleted=false order by id desc limit 1),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;