--To run this code, you will need to do replacements for,
-- JVB made dynamic
--<termlist_id_for_assemblage_type> with (select id from termlists where title='assemblage type' and deleted=false)
--<taxa_taxon_list_attribute_id_for_broad_assemblages> with (select id from taxa_taxon_list_attributes where caption='broad assemblage type' and deleted=false)
--<taxa_taxon_list_attribute_id_for_specific_assemblages> with (select id from taxa_taxon_list_attributes where caption='specific assemblage type' and deleted=false)

--DO IMPORT
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_type='broad assemblage type'
join indicia.terms iTerm on iTerm.term=pt.trait_description AND iterm.deleted=false
join indicia.termlists_terms itt on itt.termlist_id=(select id from termlists where title='assemblage type' and deleted=false) AND itt.term_id=iTerm.id AND itt.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
((pst.coding_convention ='hand' OR pst.coding_convention ='Hands Coded' OR pst.coding_convention ='hand-coded' OR pst.coding_convention ='Hand coded') AND itSource.term='predator') OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0'AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
--Don't re-insert terms where their is already a duplicate value for its parent species. As this is a single value attribute, species can only have 1 value for a broad assemblage. We order by "ORDER
--BY ttlav2.id desc, as this is only a single value attribute we can use "LIMIT 1" as this means we only look at the last value added for performance reasons, we can do this as the items are added to taxa_taxon_list_attribute_values
--in species order so we don't always need to examine all the data.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='broad assemblage type' and deleted=false) AND ttlav2.deleted=false
ORDER BY ttlav2.id desc
LIMIT 1))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='broad assemblage type' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;

--Assemblages are a special case. Only one broad is allowed, but any number of specific ones are allowed, even if they appear under a different borad (noting that in that case as only one broad is allowed, there will be no value saved for those broads, they are a specific assemblages that do not have a broad)
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_type='specific assemblage type'
join indicia.terms iTerm on iTerm.term=pt.trait_description AND iterm.deleted=false
join indicia.termlists_terms itt on itt.termlist_id=(select id from termlists where title='assemblage type' and deleted=false) AND itt.term_id=iTerm.id AND itt.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
((pst.coding_convention ='hand' OR pst.coding_convention ='Hands Coded' OR pst.coding_convention ='hand-coded' OR pst.coding_convention ='Hand coded') AND itSource.term='predator') OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0'AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
--Assemblages are unique in that although the parent broad is single value, any number of specific assemblages are allowed, so any non duplicate specific assemblages are allowed for a species.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='specific assemblage type' and deleted=false) AND ttlav2.int_value=trait_to_import.insertion_tt AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='specific assemblage type' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;
