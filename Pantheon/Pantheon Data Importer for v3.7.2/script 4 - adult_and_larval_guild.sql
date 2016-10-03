--To run this code, you will need to do replacements of,
--<pantheon_taxon_list_id>
--This is the tax_list to limit the Indicia species lookup to for import

--Do the import itself
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
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='adult guild' 
--Some trait_values have not been written accurately in the data, so need translating into the correct trait value.
join indicia.terms iTerm on (iTerm.term=pst.trait_value OR 
	(pst.trait_value='Predator'AND iTerm.term='predator') OR
	(pst.trait_value='omnivore'AND iTerm.term='omnivorous') OR
	(pst.trait_value='Unknown'AND iTerm.term='unknown') OR
	(pst.trait_value='Nectivorous'AND iTerm.term='nectivorous') OR
	(pst.trait_value='Parasitoid'AND iTerm.term='parasitoid') OR
	(pst.trait_value='predator, nectivorous'AND (iTerm.term='predator' OR iTerm.term='nectivorous'))) 
	AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='adult guild' AND itl.deleted=false
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
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='adult guild' and deleted=false) AND ttlav2.int_value=trait_to_import.insertion_tt AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='adult guild' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;


--Do same as above but for Larval Guild
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
join pantheon.tbl_traits pt on pt.trait_id=pst.trait_id AND pt.trait_description='larval guild' 
join indicia.terms iTerm on (iTerm.term=pst.trait_value OR 
	(pst.trait_value='Predator'AND iTerm.term='predator') OR
	(pst.trait_value='predatory'AND iTerm.term='predator') OR
	(pst.trait_value='algivorous'AND iTerm.term='algivore') OR
	(pst.trait_value='herbivorous'AND iTerm.term='herbivore') OR
	(pst.trait_value='omnivore'AND iTerm.term='omnivorous') OR
	(pst.trait_value='Parasitoid'AND iTerm.term='parasitoid') OR
	(pst.trait_value='fungivore, predator'AND (iTerm.term='fungivore' OR iTerm.term='predator')) OR
	(pst.trait_value='Herbivore'AND iTerm.term='herbivore') OR
	(pst.trait_value='fungivore, saprophagous'AND (iTerm.term='fungivore' OR iTerm.term='saprophagous')) OR
	(pst.trait_value='fungivorous'AND iTerm.term='fungivore') OR
	(pst.trait_value='Saprophagous'AND iTerm.term='saprophagous') OR
	(pst.trait_value='saprophagus'AND iTerm.term='saprophagous') OR
	(pst.trait_value='coprophagous, necrophorus'AND (iTerm.term='coprophagous' OR iTerm.term='necrophorus')) OR
	(pst.trait_value='herbivore & carnivore'AND (iTerm.term='herbivore' OR iTerm.term='carnivore')) OR
	(pst.trait_value='cleptoparasite'AND iTerm.term='cleptoparasitic')) 
	AND iterm.deleted=false
join indicia.termlists_terms itt on itt.term_id=iTerm.id AND itt.deleted=false
join termlists itl on itl.id = itt.termlist_id AND itl.title='larval guild' AND itl.deleted=false
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
where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='larval guild' and deleted=false) AND ttlav2.int_value=trait_to_import.insertion_tt AND ttlav2.deleted=false))
THEN
insert into
indicia.taxa_taxon_list_attribute_values (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='larval guild' and deleted=false),trait_to_import.insertion_tt,1,now(),1,now(),trait_to_import.source);
ELSE 
END IF;
END LOOP;
END
$do$;



