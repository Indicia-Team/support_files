--Just perform one replacement for this script, mass replace 
--<pantheon_taxon_list_id>

set search_path=indicia, public;
-- Set attribute source only (attribute value comes over during import). No terms to set sources for.
update taxa_taxon_list_attributes
set source_id = 
(select tt1.id
from termlists_terms tt1
join termlists tl1 on tl1.id = tt1.termlist_id AND tl1.title = 'Attribute sources' AND tl1.deleted=false
join terms t1 on t1.id = tt1.term_id AND t1.term = 'HORUS' AND t1.deleted=false
where tt1.deleted = false)
where id = (select id from taxa_taxon_list_attributes where caption='rarity score' and deleted=false);


--Do Import, note this is a single value import per species.
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
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='rarity score'
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,pst.trait_value,ittl.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
--Only need to check last added item for single value attributes
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='rarity score' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='rarity score' and deleted=false),trait_to_import.insertion_val,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;




