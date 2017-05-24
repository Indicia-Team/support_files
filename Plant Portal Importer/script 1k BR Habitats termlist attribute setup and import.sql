--To run this script, you need to do mass replacements of
--<plant_portal_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

DO
$do$
DECLARE trait_to_import RECORD;
DECLARE br_habitats_piece   varchar[];
DECLARE br_habitats_to_split_array   varchar[];

BEGIN

--Can't use comma separation, so replace with | as some of the br_habitats names actually contain commas.
--Process numbers high to low because the single digit replacements would incorrectly replace digits in the large values
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'23, ','Inshore sublittoral sediment (only Zostera marina)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 23','|Inshore sublittoral sediment (only Zostera marina)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'23|','Inshore sublittoral sediment (only Zostera marina)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|23','|Inshore sublittoral sediment (only Zostera marina)');

update plant_portal.tbl_plant_att
set br_habitats='Inshore sublittoral sediment (only Zostera marina)'
where br_habitats='23';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'21, ','Littoral sediment (includes saltmarsh and saltmarsh pools)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 21','|Littoral sediment (includes saltmarsh and saltmarsh pools)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'21|','Littoral sediment (includes saltmarsh and saltmarsh pools)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|21','|Littoral sediment (includes saltmarsh and saltmarsh pools)');

update plant_portal.tbl_plant_att
set br_habitats='Littoral sediment (includes saltmarsh and saltmarsh pools)'
where br_habitats='21';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'19, ','Supralittoral sediment (strandlines, shingle, coastal dunes)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 19','|Supralittoral sediment (strandlines, shingle, coastal dunes)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'19|','Supralittoral sediment (strandlines, shingle, coastal dunes)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|19','|Supralittoral sediment (strandlines, shingle, coastal dunes)');

update plant_portal.tbl_plant_att
set br_habitats='Supralittoral sediment (strandlines, shingle, coastal dunes)'
where br_habitats='19';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'18, ','Supralittoral rock (does not include maritime grassland)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 18','|Supralittoral rock (does not include maritime grassland)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'18|','Supralittoral rock (does not include maritime grassland)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|18','|Supralittoral rock (does not include maritime grassland)');

update plant_portal.tbl_plant_att
set br_habitats='Supralittoral rock (does not include maritime grassland)'
where br_habitats='18';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'17, ','Built-up areas and gardens|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 17','|Built-up areas and gardens');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'17|','Built-up areas and gardens|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|17','|Built-up areas and gardens');

update plant_portal.tbl_plant_att
set br_habitats='Built-up areas and gardens'
where br_habitats='17';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'16, ','Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 16','|Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'16|','Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|16','|Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)');

update plant_portal.tbl_plant_att
set br_habitats='Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)'
where br_habitats='16';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'15, ','Montane habitats (acid grassland and heath with montane species)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 15','|Montane habitats (acid grassland and heath with montane species)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'15|','Montane habitats (acid grassland and heath with montane species)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|15','|Montane habitats (acid grassland and heath with montane species)');

update plant_portal.tbl_plant_att
set br_habitats='Montane habitats (acid grassland and heath with montane species)'
where br_habitats='15';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'14, ','Rivers and streams|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 14','|Rivers and streams');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'14|','Rivers and streams|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|14','|Rivers and streams');

update plant_portal.tbl_plant_att
set br_habitats='Rivers and streams'
where br_habitats='14';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'13, ','Standing water and canals|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 13','|Standing water and canals');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'13|','Standing water and canals|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|13','|Standing water and canals');

update plant_portal.tbl_plant_att
set br_habitats='Standing water and canals'
where br_habitats='13';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'12, ','Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 12','|Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'12|','Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|12','|Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)');

update plant_portal.tbl_plant_att
set br_habitats='Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)'
where br_habitats='12';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'11, ','Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 11','|Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'11|','Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|11','|Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)');

update plant_portal.tbl_plant_att
set br_habitats='Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)'
where br_habitats='11';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'10, ','Dwarf shrub heath (cover of dwarf shrubs at least 25%)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 10','|Dwarf shrub heath (cover of dwarf shrubs at least 25%)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'10|','Dwarf shrub heath (cover of dwarf shrubs at least 25%)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|10','|Dwarf shrub heath (cover of dwarf shrubs at least 25%)');

update plant_portal.tbl_plant_att
set br_habitats='Dwarf shrub heath (cover of dwarf shrubs at least 25%)'
where br_habitats='10';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'9, ','Bracken|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 9','|Bracken');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'9|','Bracken|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|9','|Bracken');

update plant_portal.tbl_plant_att
set br_habitats='Bracken'
where br_habitats='9';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'8, ','Acid grassland (includes non-calcareous sandy grassland)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 8','|Acid grassland (includes non-calcareous sandy grassland)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'8|','Acid grassland (includes non-calcareous sandy grassland)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|8','|Acid grassland (includes non-calcareous sandy grassland)');

update plant_portal.tbl_plant_att
set br_habitats='Acid grassland (includes non-calcareous sandy grassland)'
where br_habitats='8';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'7, ','Calcareous grassland (includes lowland and montane types)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 7','|Calcareous grassland (includes lowland and montane types)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'7|','Calcareous grassland (includes lowland and montane types)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|7','|Calcareous grassland (includes lowland and montane types)');

update plant_portal.tbl_plant_att
set br_habitats='Calcareous grassland (includes lowland and montane types)'
where br_habitats='7';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'6, ','Neutral grassland (includes coarse Arrhenatherum grassland)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 6','|Neutral grassland (includes coarse Arrhenatherum grassland)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'6|','Neutral grassland (includes coarse Arrhenatherum grassland)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|6','|Neutral grassland (includes coarse Arrhenatherum grassland)');

update plant_portal.tbl_plant_att
set br_habitats='Neutral grassland (includes coarse Arrhenatherum grassland)'
where br_habitats='6';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'5, ','Improved grassland|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 5','|Improved grassland');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'5|','Improved grassland|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|5','|Improved grassland');

update plant_portal.tbl_plant_att
set br_habitats='Improved grassland'
where br_habitats='5';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'4, ','Arable and horticultural (includes orchards, excludes domestic gardens)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 4','|Arable and horticultural (includes orchards, excludes domestic gardens)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'4|','Arable and horticultural (includes orchards, excludes domestic gardens)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|4','|Arable and horticultural (includes orchards, excludes domestic gardens)');

update plant_portal.tbl_plant_att
set br_habitats='Arable and horticultural (includes orchards, excludes domestic gardens)'
where br_habitats='4';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'3, ','Boundary and linear features (eg hedges, roadsides, walls)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 3','|Boundary and linear features (eg hedges, roadsides, walls)');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'3|','Boundary and linear features (eg hedges, roadsides, walls)|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|3','|Boundary and linear features (eg hedges, roadsides, walls)');

update plant_portal.tbl_plant_att
set br_habitats='Boundary and linear features (eg hedges, roadsides, walls)'
where br_habitats='3';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'2, ','Coniferous woodland|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 2','|Coniferous woodland');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'2|','Coniferous woodland|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|2','|Coniferous woodland');

update plant_portal.tbl_plant_att
set br_habitats='Coniferous woodland'
where br_habitats='2';

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'1, ','Broadleaved, mixed and yew woodland|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,', 1','|Broadleaved, mixed and yew woodland');

update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'1|','Broadleaved, mixed and yew woodland|');
update plant_portal.tbl_plant_att
set br_habitats=replace(br_habitats,'|1','|Broadleaved, mixed and yew woodland');

update plant_portal.tbl_plant_att
set br_habitats='Broadleaved, mixed and yew woodland'
where br_habitats='1';


set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('BR Habitats','BR Habitats terms for Plant Portal',(select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1),now(),1,now(),1,'indicia:br_habitats');

insert into taxa_taxon_list_attributes (caption,multi_value,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'BR Habitats',true,'L',now(),1,now(),1,id
from termlists
where title='BR Habitats' AND website_id = (select id from websites where title='Plant Portal' and deleted=false order by id desc limit 1);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_portal_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='BR Habitats'
ORDER BY id DESC 
LIMIT 1;


perform insert_term('Broadleaved, mixed and yew woodland','eng',null,'indicia:br_habitats');
perform insert_term('Coniferous woodland','eng',null,'indicia:br_habitats');
perform insert_term('Boundary and linear features (eg hedges, roadsides, walls)','eng',null,'indicia:br_habitats');
perform insert_term('Arable and horticultural (includes orchards, excludes domestic gardens)','eng',null,'indicia:br_habitats');
perform insert_term('Improved grassland','eng',null,'indicia:br_habitats');
perform insert_term('Neutral grassland (includes coarse Arrhenatherum grassland)','eng',null,'indicia:br_habitats');
perform insert_term('Calcareous grassland (includes lowland and montane types)','eng',null,'indicia:br_habitats');
perform insert_term('Acid grassland (includes non-calcareous sandy grassland)','eng',null,'indicia:br_habitats');
perform insert_term('Bracken','eng',null,'indicia:br_habitats');
perform insert_term('Dwarf shrub heath (cover of dwarf shrubs at least 25%)','eng',null,'indicia:br_habitats');
perform insert_term('Fen, marsh and swamp (not wooded; includes flushes, rush-pastures, springs and
mud communities)','eng',null,'indicia:br_habitats');
perform insert_term('Bog (on deep peat; includes bog pools and acid lowland valley mires on
slightly shallower peat)','eng',null,'indicia:br_habitats');
perform insert_term('Standing water and canals','eng',null,'indicia:br_habitats');
perform insert_term('Rivers and streams','eng',null,'indicia:br_habitats');
perform insert_term('Montane habitats (acid grassland and heath with montane species)','eng',null,'indicia:br_habitats');
perform insert_term('Inland rock (heterogeneous - quarries, limestone pavement, cliffs, screes, skeletal soils over rock)','eng',null,'indicia:br_habitats');
perform insert_term('Built-up areas and gardens','eng',null,'indicia:br_habitats');
perform insert_term('Supralittoral rock (does not include maritime grassland)','eng',null,'indicia:br_habitats');
perform insert_term('Supralittoral sediment (strandlines, shingle, coastal dunes)','eng',null,'indicia:br_habitats');
perform insert_term('Littoral sediment (includes saltmarsh and saltmarsh pools)','eng',null,'indicia:br_habitats');
perform insert_term('Inshore sublittoral sediment (only Zostera marina)','eng',null,'indicia:br_habitats');

FOR trait_to_import IN
(select ittl.id as taxa_taxon_list_id, br_habitats as br_habitats_to_split
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
where ppt.br_habitats IS NOT NULL
) loop
  br_habitats_to_split_array = string_to_array(trait_to_import.br_habitats_to_split, '|');
  FOR i IN array_lower(br_habitats_to_split_array, 1) .. array_upper(br_habitats_to_split_array, 1)
      LOOP
         --As this is a multi-value attribute, this time we only don't add the trait if there is an exact taxa_taxon_list_id and attribute value match
         IF (NOT EXISTS (
           select ttlav2.id
           from taxa_taxon_list_attribute_values ttlav2
           join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
           join termlists_terms itt on itt.id = ttlav2.int_value AND itt.deleted=false
           join termlists itl on itl.id = itt.termlist_id AND itl.title='BR Habitats' AND itl.deleted=false
           join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
           join terms t on t.id=itt.term_id AND t.term=br_habitats_to_split_array[i]
           where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='BR Habitats' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
           ORDER BY ttlav2.id desc))
         THEN
           insert into
           indicia.taxa_taxon_list_attribute_values 
           (
             taxa_taxon_list_id,
             taxa_taxon_list_attribute_id,
             int_value,
             created_by_id,
             created_on,
             updated_by_id,
             updated_on
           )
           values (
             trait_to_import.taxa_taxon_list_id,
             (select id from taxa_taxon_list_attributes where caption='BR Habitats' and deleted=false order by id desc limit 1),
             --As the comma separated BR Habitats field is split and cycled through we need to collect the termlist term to insert.
             --This probably isn't fast way to do this, but it is a one off import and it is advantageous to keep this import as similar to the other ones as possible
             (select itt.id 
             from indicia.termlists_terms itt 
             join termlists itl on itl.id = itt.termlist_id AND itl.title='BR Habitats' AND itl.deleted=false
             join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
             join terms t on t.id=itt.term_id AND t.term=br_habitats_to_split_array[i]),
             1,
             now(),
             1,
             now()
           );
         ELSE 
         END IF;
      END LOOP;         

END LOOP;
END
$do$;














