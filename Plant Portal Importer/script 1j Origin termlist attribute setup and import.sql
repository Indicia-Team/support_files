--To run this script, you need to do mass replacements of
--<plant_port_taxon_list_id>
--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

DO
$do$
DECLARE trait_to_import RECORD;
DECLARE origin_piece   varchar[];
DECLARE origin_to_split_array   varchar[];

BEGIN
--None of the origins should have a question mark, however they do, so remove them for now until I have asked about this.
--I presume this was left in the data as it is considered unsure
update plant_portal.tbl_plant_att
set origin=replace(origin,'?','');

--Can't use comma separation, so replace with | as some of the origin names actually contain commas.
--Get rid of the spaces in the origin data as it is processed, this also helps us know which names we have swapped for the longer names
--e.g. "AS" would actually match Asia in a longer name and try a replacement when we don't want it to. However we can avoid this if we also detect if there is a space after the , or |
--then we know which items haven't been processed
update plant_portal.tbl_plant_att
set origin=replace(origin,'Am4,','Western North America|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Am4|','Western North America|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Am4','|Western North America');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Am4','|Western North America');

update plant_portal.tbl_plant_att
set origin='Western North America'
where origin='Am4';

update plant_portal.tbl_plant_att
set origin=replace(origin,'Am6,','Eastern North America|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Am6|','Eastern North America|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Am6','|Eastern North America');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Am6','|Eastern North America');

update plant_portal.tbl_plant_att
set origin='Eastern North America'
where origin='Am6';

update plant_portal.tbl_plant_att
set origin=replace(origin,'Am,','North America|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Am|','North America|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Am','|North America');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Am','|North America');

update plant_portal.tbl_plant_att
set origin='North America'
where origin='Am';

update plant_portal.tbl_plant_att
set origin=replace(origin,'As1,','Asia between 60°E and 120°E|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'As1|','Asia between 60°E and 120°E|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', As1','|Asia between 60°E and 120°E');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| As1','|Asia between 60°E and 120°E');

update plant_portal.tbl_plant_att
set origin='Asia between 60°E and 120°E'
where origin='As1';

update plant_portal.tbl_plant_att
set origin=replace(origin,'As2,','Asia E of 120°E|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'As2|','Asia E of 120°E|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', As2','|Asia E of 120°E');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| As2','|Asia E of 120°E');

update plant_portal.tbl_plant_att
set origin='Asia E of 120°E'
where origin='As2';

update plant_portal.tbl_plant_att
set origin=replace(origin,'As,','Asia east of 60°E|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'As|','Asia east of 60°E|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', As','|Asia east of 60°E');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| As','|Asia east of 60°E');

update plant_portal.tbl_plant_att
set origin='Asia east of 60°E'
where origin='As';

update plant_portal.tbl_plant_att
set origin=replace(origin,'Aus,','Australia|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Aus|','Australia|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Aus','|Australia');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Aus','|Australia');

update plant_portal.tbl_plant_att
set origin='Australia'
where origin='Aus';

update plant_portal.tbl_plant_att
set origin=replace(origin,'Crop,','Crop plant, does not have a native range|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Crop|','Crop plant, does not have a native range|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Crop','|Crop plant, does not have a native range');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Crop','|Crop plant, does not have a native range');

update plant_portal.tbl_plant_att
set origin='Crop plant, does not have a native range'
where origin='Crop';

update plant_portal.tbl_plant_att
set origin=replace(origin,'Eur,','Europe|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Eur|','Europe|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Eur','|Europe');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Eur','|Europe');

update plant_portal.tbl_plant_att
set origin='Europe'
where origin='Eur';

update plant_portal.tbl_plant_att
set origin=replace(origin,'Gard,','Garden origin, does not have a native range|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Gard|','Garden origin, does not have a native range|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Gard','|Garden origin, does not have a native range');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Gard','|Garden origin, does not have a native range');

update plant_portal.tbl_plant_att
set origin='Garden origin, does not have a native range'
where origin='Gard';

update plant_portal.tbl_plant_att
set origin=replace(origin,'NHem,','N Hemisphere (Europe,Asia and North America)|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'NHem|','N Hemisphere (Europe,Asia and North America)|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', NHem','|N Hemisphere (Europe,Asia and North America)');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| NHem','|N Hemisphere (Europe,Asia and North America)');

update plant_portal.tbl_plant_att
set origin='N Hemisphere (Europe,Asia and North America)'
where origin='NHem';

update plant_portal.tbl_plant_att
set origin=replace(origin,'NZ,','New Zealand|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'NZ|','New Zealand|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', NZ','|New Zealand');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| NZ','|New Zealand');

update plant_portal.tbl_plant_att
set origin='New Zealand'
where origin='NZ';

update plant_portal.tbl_plant_att
set origin=replace(origin,'SAf,','Southern Africa|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'SAf|','Southern Africa|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', SAf','|Southern Africa');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| SAf','|Southern Africa');

update plant_portal.tbl_plant_att
set origin='Southern Africa'
where origin='SAf';

update plant_portal.tbl_plant_att
set origin=replace(origin,'SAm,','South America and/or Central America|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'SAm|','South America and/or Central America|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', SAm','|South America and/or Central America');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| SAm','|South America and/or Central America');

update plant_portal.tbl_plant_att
set origin='South America and/or Central America'
where origin='SAm';

update plant_portal.tbl_plant_att
set origin=replace(origin,'Unk,','Unknown|');
update plant_portal.tbl_plant_att
set origin=replace(origin,'Unk|','Unknown|');

update plant_portal.tbl_plant_att
set origin=replace(origin,', Unk','|Unknown');
update plant_portal.tbl_plant_att
set origin=replace(origin,'| Unk','|Unknown');

update plant_portal.tbl_plant_att
set origin='Unknown'
where origin='Unk';


set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('origin','Origin terms for Plant Portal',(select id from websites where title='Plant Portal' and deleted=false),now(),1,now(),1,'indicia:origin');

insert into taxa_taxon_list_attributes (caption,multi_value,data_type,created_on,created_by_id,updated_on,updated_by_id,termlist_id)
select 'origin',true,'L',now(),1,now(),1,id
from termlists
where title='origin' AND website_id = (select id from websites where title='Plant Portal' and deleted=false);

--We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
--We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
select <plant_port_taxon_list_id>,id,now(),1
from taxa_taxon_list_attributes
where caption='origin'
ORDER BY id DESC 
LIMIT 1;


perform insert_term('North America','eng',null,'indicia:origin');
perform insert_term('Western North America','eng',null,'indicia:origin');
perform insert_term('Eastern North America','eng',null,'indicia:origin');
perform insert_term('Asia east of 60°E','eng',null,'indicia:origin');
perform insert_term('Asia between 60°E and 120°E','eng',null,'indicia:origin');
perform insert_term('Asia E of 120°E','eng',null,'indicia:origin');
perform insert_term('Australia','eng',null,'indicia:origin');
perform insert_term('Crop plant, does not have a native range','eng',null,'indicia:origin');
perform insert_term('Europe','eng',null,'indicia:origin');
perform insert_term('Garden origin, does not have a native range','eng',null,'indicia:origin');
perform insert_term('N Hemisphere (Europe,Asia and North America)','eng',null,'indicia:origin');
perform insert_term('New Zealand','eng',null,'indicia:origin');
perform insert_term('Southern Africa','eng',null,'indicia:origin');
perform insert_term('South America and/or Central America','eng',null,'indicia:origin');
perform insert_term('Unknown','eng',null,'indicia:origin');


FOR trait_to_import IN
(select ittl.id as taxa_taxon_list_id, origin as origin_to_split
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_port_taxon_list_id> AND ittl.deleted=false
where ppt.origin IS NOT NULL
) loop
  origin_to_split_array = string_to_array(trait_to_import.origin_to_split, '|');
  FOR i IN array_lower(origin_to_split_array, 1) .. array_upper(origin_to_split_array, 1)
      LOOP
         --As this is a multi-value attribute, this time we only don't add the trait if there is an exact taxa_taxon_list_id and attribute value match
         IF (NOT EXISTS (
           select ttlav2.id
           from taxa_taxon_list_attribute_values ttlav2
           join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
           join termlists_terms itt on itt.id = ttlav2.int_value AND itt.deleted=false
           join termlists itl on itl.id = itt.termlist_id AND itl.title='origin' AND itl.deleted=false
           join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
           join terms t on t.id=itt.term_id AND t.term=origin_to_split_array[i]
           where ttlav2.taxa_taxon_list_attribute_id = (select id from taxa_taxon_list_attributes where caption='origin' and deleted=false order by id desc limit 1) AND ttlav2.deleted=false
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
             (select id from taxa_taxon_list_attributes where caption='origin' and deleted=false),
             --As the comma separated origin field is split and cycled through we need to collect the termlist term to insert.
             --This probably isn't fast way to do this, but it is a one off import and it is advantageous to keep this import as similar to the other ones as possible
             (select itt.id 
             from indicia.termlists_terms itt 
             join termlists itl on itl.id = itt.termlist_id AND itl.title='origin' AND itl.deleted=false
             join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
             join terms t on t.id=itt.term_id AND t.term=origin_to_split_array[i]),
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














