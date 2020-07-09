--To run this code, you will need to do replacements of,
-- <min_ttl_attr_id_to_process>
-- <min_occ_attr_id_to_process>
-- This will allow you to process new attributes without having to risk re-processing all existing attributes

set search_path TO indicia, public;

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -100 - (taxa_taxon_list_attribute_id * 2)
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where description = 'free colour wheel' and deleted=false);

DO
$do$
declare comment_field_to_update RECORD;
BEGIN 

-- Cycle through each row again
FOR comment_field_to_update IN (
    select ttla_comment.id as comment_id, ttla_main.id as main_field_id
    from indicia.taxa_taxon_list_attributes ttla_main
    join indicia.termlists_terms sub_area_tt on sub_area_tt.id = ttla_main.reporting_category_id and sub_area_tt.deleted=false
    join indicia.terms sub_area_term on sub_area_term.id = sub_area_tt.term_id and sub_area_term.deleted=false
    join indicia.termlists_terms main_area_tt on main_area_tt.id = sub_area_tt.parent_id and main_area_tt.deleted=false
    join indicia.terms main_area_term on main_area_term.id = main_area_tt.term_id and main_area_tt.deleted=false
    join indicia.taxa_taxon_list_attributes ttla_comment on ttla_comment.description like '%Kommentar für ' || main_area_term.term || '/' || sub_area_term.term || '/' || ttla_main.caption || '%'
    AND ttla_comment.deleted=false
    where ttla_main.deleted=false and ttla_main.description = 'free colour wheel') 
loop
    update indicia.taxon_lists_taxa_taxon_list_attributes
    set weight = -100-(comment_field_to_update.main_field_id * 2) + 1
    where taxa_taxon_list_attribute_id = comment_field_to_update.comment_id and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process>;
END LOOP;
END
$do$;


--These ones are the Journal fields
update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -100
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Zeitschrift' and deleted=false);

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -99
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Seiten' and deleted=false);

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -98
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Zeitschrift, Buch' and deleted=false);

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -97
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Titel' and deleted=false);

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -96
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Seitenzahl (von bis bei zeitschrift, Gesamtseitenz' and deleted=false);



update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -100
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Fruchtkörpertyp' and deleted=false);

update indicia.occurrence_attributes_websites
set weight = -100
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and occurrence_attribute_id in 
(select id from indicia.occurrence_attributes where caption = 'Fruchtkörpertyp' and deleted=false);

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -100
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Länge [µm]' and deleted=false);

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight = -99
where deleted=false and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process> and taxa_taxon_list_attribute_id in 
(select id from indicia.taxa_taxon_list_attributes where caption = 'Breite [µm]' and deleted=false);

update indicia.occurrence_attributes_websites
set weight = -100-occurrence_attribute_id
where deleted=false and occurrence_attribute_id > <min_occ_attr_id_to_process> and occurrence_attribute_id in 
(select id from indicia.occurrence_attributes where caption = 'free colour wheel' and deleted=false);

-- AVB might need to move colour wheels here, like we did for the taxon ones.

update indicia.occurrence_attributes_websites
set weight = -100
where deleted=false and occurrence_attribute_id > <min_occ_attr_id_to_process> and occurrence_attribute_id in 
(select id from indicia.occurrence_attributes where caption = 'Länge [µm]' and deleted=false);

update indicia.occurrence_attributes_websites
set weight = -99
where deleted=false and occurrence_attribute_id > <min_occ_attr_id_to_process> and occurrence_attribute_id in 
(select id from indicia.occurrence_attributes where caption = 'Breite [µm]' and deleted=false);

/*update indicia.taxa_taxon_list_attributes
set allow_ranges=true
where deleted=false and caption like '%[%' and caption like '%]%' and allow_ranges=false;*/

-- We now support all numbers as ranges
update indicia.taxa_taxon_list_attributes
set allow_ranges=true
where deleted=false and id > <min_ttl_attr_id_to_process> and data_type='F' and allow_ranges=false;

--Set order of journal fields
update indicia.taxon_lists_taxa_taxon_list_attributes
set weight=100
where taxa_taxon_list_attribute_id  in (select id from indicia.taxa_taxon_list_attributes where deleted=false and caption = 'Zeitschrift, Buch');

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight=101
where taxa_taxon_list_attribute_id  in (select id from indicia.taxa_taxon_list_attributes where deleted=false and caption = 'Titel');

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight=102
where taxa_taxon_list_attribute_id  in (select id from indicia.taxa_taxon_list_attributes where deleted=false and caption like '%Seitenzahl%');

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight=103
where taxa_taxon_list_attribute_id  in (select id from indicia.taxa_taxon_list_attributes where deleted=false and caption like '%Autoren%');

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight=104
where taxa_taxon_list_attribute_id  in (select id from indicia.taxa_taxon_list_attributes where deleted=false and caption = 'Jahr');

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight=105
where taxa_taxon_list_attribute_id  in (select id from indicia.taxa_taxon_list_attributes where deleted=false and caption like '%Ausgabenummer%');

update indicia.taxon_lists_taxa_taxon_list_attributes
set weight=106
where taxa_taxon_list_attribute_id  in (select id from indicia.taxa_taxon_list_attributes where deleted=false and caption = 'Seiten');
