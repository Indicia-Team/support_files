--To run this code, you will need to do replacements of,
--<pantheon_taxon_list_id>
--This is the tax_list to limit the Indicia species lookup to for import

--Import Broad biotopes
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_type='broad biotope'
--Ecological Divs/Specific biotopes/Resources need to use full trait id, description, parent for comparison as there are multiple terms with same description
--broad biotopes don't have a parent
join indicia.terms iTerm on iTerm.term=(pt.trait_id || ' ' || pt.trait_description || ' ' || '0') AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='broad biotope/specific biotope/resource' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
--Don't re-insert terms where their is already a duplicate value for its parent species. As this is a multi value attribute, none duplicate values are allowed.
--in species order so we don't always need to examine all the data.
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='broad biotope') AND ttlav2.int_value=trait_to_import.insertion_tt AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='broad biotope'),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;



--Import Specific biotopes - Works same way as above.
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
--Special as 'generalist only' is missing a trait type in the data
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND (pt.trait_type='specific biotope' OR pt.trait_description = 'generalist only')
join indicia.terms iTerm on iTerm.term=(pt.trait_id || ' ' || pt.trait_description || ' '  || pt.parent_trait_id) AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='broad biotope/specific biotope/resource' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='specific biotope') AND ttlav2.int_value=trait_to_import.insertion_tt AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='specific biotope'),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;


--Import Resources (note there a 3 resource layers underneath specific biotope), this makes life slightly more complicated. See notes below in the code.
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
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<pantheon_taxon_list_id> AND ittl.deleted=false
--Special case as 'generalist only' is missing a trait type in the data
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_type='resource'
--One of the resources appears at the top level and doesn't have a parent
join indicia.terms iTerm on (iTerm.term=(pt.trait_id || ' ' || pt.trait_description || ' '  || pt.parent_trait_id) or iTerm.term=(pt.trait_id || ' ' || pt.trait_description || ' ' || '0')) AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='broad biotope/specific biotope/resource' AND itl.deleted=false
join websites w on w.id = itl.website_id AND w.title='Pantheon' AND w.deleted=false
--The way the source is written is not consistant, so we need to interpret these
left join indicia.terms itSource on (itSource.term=pst.coding_convention OR
(pst.coding_convention='from synanthropic (ISIS)' AND itSource.term='ISIS'))
AND pst.coding_convention!='0' AND itSource.deleted=false
left join indicia.termlists_terms ittSource on ittSource.term_id = itSource.id AND ittSource.deleted=false
left join indicia.termlists itlSource on itlSource.id = ittSource.termlist_id AND itlSource.title = 'Attribute value sources' AND ittSource.deleted=false
GROUP BY ps.preferred_tvk,ps.species_tvk,ittl.id,itt.id,ittSource.id
ORDER BY ps.species_tvk=ps.preferred_tvk desc
) loop
IF (NOT EXISTS (
select ttlav2.id
from taxa_taxon_list_attribute_values ttlav2
join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='resource') AND ttlav2.int_value=trait_to_import.insertion_tt AND ttlav2.deleted=false
))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='resource'),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;





--Broad biotopes, specific biotopes and traits need this bit after the import unlike other traits because there are multiple terms with same description, therefore we need to use trait id and parent trait for comparison also
-- Reset the term names, as they have all been given names of format "<trait_id> <term> <parent_trait_id>". Remove the trait and parent trait IDs.
update terms
set term = substring(term from '\s(.*)\s')
where 
term != substring(term from '\s(.*)\s')
AND
id in
(select tt.term_id
from termlists_terms tt
join termlists tl on tl.id = tt.termlist_id AND tl.title = 'broad biotope/specific biotope/resource' AND tl.deleted=false
join websites w on w.id = tl.website_id AND w.title='Pantheon' and w.deleted=false
where tt.deleted=false
);
