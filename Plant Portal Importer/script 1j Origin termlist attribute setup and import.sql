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

--These codes are problematic if try and replace in the real expanded terms. For instance, the code "Am" would appear in many of the expanded
--terms also. We only want to do replacements for the codes, not parts of words in the full expanded terms.
--We can overcome this issue by changing the codes to be properly unique such that they would never appear in real words and such that they
--don't clash with each other either.
--Note that the ordering of the processing is important e.g. "SAm" is processed early to avoid clashing with "Am"
update plant_portal.tbl_plant_att
set origin=replace(origin,'SAm','S:A:m');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Am4','A;m;4');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Am6','A\m\6');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Am','A/m');

update plant_portal.tbl_plant_att
set origin=replace(origin,'As1','A>s>1');

update plant_portal.tbl_plant_att
set origin=replace(origin,'As2','A<s<2');

update plant_portal.tbl_plant_att
set origin=replace(origin,'As','A.s');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Aus','A-u-s');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Crop','C{r{o{p');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Eur','E}u}r');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Gard','G"a"r"d');

update plant_portal.tbl_plant_att
set origin=replace(origin,'NHem','N?H?e?m');

update plant_portal.tbl_plant_att
set origin=replace(origin,'NZ','N[Z');

update plant_portal.tbl_plant_att
set origin=replace(origin,'SAf','S]A]f');

update plant_portal.tbl_plant_att
set origin=replace(origin,'Unk','U#n#k');



update plant_portal.tbl_plant_att
set origin=replace(origin,'S:A:m','South America and/or Central America');

update plant_portal.tbl_plant_att
set origin=replace(origin,'A;m;4','Western North America');

update plant_portal.tbl_plant_att
set origin=replace(origin,'A\m\6','Eastern North America');

update plant_portal.tbl_plant_att
set origin=replace(origin,'A/m','North America');

update plant_portal.tbl_plant_att
set origin=replace(origin,'A>s>1','Asia between 60°E and 120°E');

update plant_portal.tbl_plant_att
set origin=replace(origin,'A<s<2','Asia E of 120°E');

update plant_portal.tbl_plant_att
set origin=replace(origin,'A.s','Asia east of 60°E');

update plant_portal.tbl_plant_att
set origin=replace(origin,'A-u-s','Australia');

update plant_portal.tbl_plant_att
set origin=replace(origin,'C{r{o{p','Crop plant| does not have a native range');

update plant_portal.tbl_plant_att
set origin=replace(origin,'E}u}r','Europe');

update plant_portal.tbl_plant_att
set origin=replace(origin,'G"a"r"d','Garden origin| does not have a native range');

update plant_portal.tbl_plant_att
set origin=replace(origin,'N?H?e?m','N Hemisphere (Europe|Asia and North America)');

update plant_portal.tbl_plant_att
set origin=replace(origin,'N[Z','New Zealand');

update plant_portal.tbl_plant_att
set origin=replace(origin,'S]A]f','Southern Africa');

update plant_portal.tbl_plant_att
set origin=replace(origin,'U#n#k','Unknown');

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

perform insert_term('South America and/or Central America','eng',null,'indicia:origin');
perform insert_term('North America','eng',null,'indicia:origin');
perform insert_term('Western North America','eng',null,'indicia:origin');
perform insert_term('Eastern North America','eng',null,'indicia:origin');
perform insert_term('Asia east of 60°E','eng',null,'indicia:origin');
perform insert_term('Asia between 60°E and 120°E','eng',null,'indicia:origin');
perform insert_term('Asia E of 120°E','eng',null,'indicia:origin');
perform insert_term('Australia','eng',null,'indicia:origin');
perform insert_term('Crop plant| does not have a native range','eng',null,'indicia:origin');
perform insert_term('Europe','eng',null,'indicia:origin');
perform insert_term('Garden origin| does not have a native range','eng',null,'indicia:origin');
perform insert_term('N Hemisphere (Europe|Asia and North America)','eng',null,'indicia:origin');
perform insert_term('New Zealand','eng',null,'indicia:origin');
perform insert_term('Southern Africa','eng',null,'indicia:origin');
perform insert_term('Unknown','eng',null,'indicia:origin');


FOR trait_to_import IN
(select ittl.id as taxa_taxon_list_id, origin as origin_to_split
from plant_portal.tbl_plant_att ppt
join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_port_taxon_list_id> AND ittl.deleted=false
where ppt.origin IS NOT NULL
) loop
  origin_to_split_array = string_to_array(trait_to_import.origin_to_split, ',');
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
           join terms t on t.id=itt.term_id AND t.term=trim(origin_to_split_array[i])
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
             join terms t on t.id=itt.term_id AND t.term=trim(origin_to_split_array[i])),
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

--Note as the lists of terms are separated using commas, if we use a pipe symbol inside terms
--where commas are normally used we can avoid replacements in the wrong place.
--However these these pipe symbols now need changing at the end
update terms 
set term = 'Crop plant, does not have a native range'
where term = 'Crop plant| does not have a native range';

update terms
set term = 'Garden origin, does not have a native range'
where term = 'Garden origin| does not have a native range';

update terms
set term = 'N Hemisphere (Europe,Asia and North America)'
where term = 'N Hemisphere (Europe|Asia and North America)';



