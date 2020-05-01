--To run this code, you will need to do replacements of,
-- <min_ttl_attr_id_to_process>
-- <min_occ_attr_id_to_process>
-- This will allow you to process new attributes without having to risk re-processing all existing attributes

DO
$do$
declare main_field_to_update RECORD;
BEGIN 

-- Cycle through each row again
FOR main_field_to_update IN (
    select ttla_comment.id as comment_id, ttla_main.id as main_field_id
    from indicia.taxa_taxon_list_attributes ttla_main
    join indicia.termlists_terms sub_area_tt on sub_area_tt.id = ttla_main.reporting_category_id and sub_area_tt.deleted=false
    join indicia.terms sub_area_term on sub_area_term.id = sub_area_tt.term_id and sub_area_term.deleted=false
    join indicia.termlists_terms main_area_tt on main_area_tt.id = sub_area_tt.parent_id and main_area_tt.deleted=false
    join indicia.terms main_area_term on main_area_term.id = main_area_tt.term_id and main_area_tt.deleted=false
    join indicia.taxa_taxon_list_attributes ttla_comment on ttla_comment.description like '%Kommentar für ' || main_area_term.term || '/' || sub_area_term.term || '/' || ttla_main.caption || '%'
    AND ttla_comment.deleted=false
    where ttla_main.deleted=false) 
loop
    update indicia.taxon_lists_taxa_taxon_list_attributes
    set weight = main_field_to_update.main_field_id * 2
    where taxa_taxon_list_attribute_id = main_field_to_update.main_field_id and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process>;
END LOOP;
END
$do$;



set search_path TO indicia, public;

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
    where ttla_main.deleted=false) 
loop
    update indicia.taxon_lists_taxa_taxon_list_attributes
    set weight = (comment_field_to_update.main_field_id * 2) + 1
    where taxa_taxon_list_attribute_id = comment_field_to_update.comment_id and taxa_taxon_list_attribute_id > <min_ttl_attr_id_to_process>;
END LOOP;
END
$do$;




DO
$do$
declare main_field_to_update RECORD;
BEGIN 

-- Cycle through each row again
FOR main_field_to_update IN (
    select ttla_comment.id as comment_id, ttla_main.id as main_field_id
    from indicia.occurrence_attributes ttla_main
    join indicia.termlists_terms sub_area_tt on sub_area_tt.id = ttla_main.reporting_category_id and sub_area_tt.deleted=false
    join indicia.terms sub_area_term on sub_area_term.id = sub_area_tt.term_id and sub_area_term.deleted=false
    join indicia.termlists_terms main_area_tt on main_area_tt.id = sub_area_tt.parent_id and main_area_tt.deleted=false
    join indicia.terms main_area_term on main_area_term.id = main_area_tt.term_id and main_area_tt.deleted=false
    join indicia.occurrence_attributes ttla_comment on ttla_comment.description like '%Kommentar für ' || main_area_term.term || '/' || sub_area_term.term || '/' || ttla_main.caption || '%'
    AND ttla_comment.deleted=false
    where ttla_main.deleted=false) 
loop
    update indicia.occurrence_attributes_websites
    set weight = main_field_to_update.main_field_id * 2
    where occurrence_attribute_id = main_field_to_update.main_field_id and occurrence_attribute_id > <min_occ_attr_id_to_process>;
END LOOP;
END
$do$;



set search_path TO indicia, public;

DO
$do$
declare comment_field_to_update RECORD;
BEGIN 

-- Cycle through each row again
FOR comment_field_to_update IN (
    select ttla_comment.id as comment_id, ttla_main.id as main_field_id
    from indicia.occurrence_attributes ttla_main
    join indicia.termlists_terms sub_area_tt on sub_area_tt.id = ttla_main.reporting_category_id and sub_area_tt.deleted=false
    join indicia.terms sub_area_term on sub_area_term.id = sub_area_tt.term_id and sub_area_term.deleted=false
    join indicia.termlists_terms main_area_tt on main_area_tt.id = sub_area_tt.parent_id and main_area_tt.deleted=false
    join indicia.terms main_area_term on main_area_term.id = main_area_tt.term_id and main_area_tt.deleted=false
    join indicia.occurrence_attributes ttla_comment on ttla_comment.description like '%Kommentar für ' || main_area_term.term || '/' || sub_area_term.term || '/' || ttla_main.caption || '%'
    AND ttla_comment.deleted=false
    where ttla_main.deleted=false) 
loop
    update indicia.occurrence_attributes_websites
    set weight = (comment_field_to_update.main_field_id * 2) + 1
    where occurrence_attribute_id = comment_field_to_update.comment_id and occurrence_attribute_id > <min_occ_attr_id_to_process>;
END LOOP;
END
$do$;


-- Put brackets around the comment field, as this ensures even if its weight is in use with the next attribute, if will be placed in front of it as the ordering is alphabetical if the weight is the same.
update indicia.taxa_taxon_list_attributes
set caption = '(Kommentar)'
where caption = 'Kommentar';


update indicia.taxa_taxon_list_attributes
set caption_i18n = '{"cze": "(Komentář)", "eng": "(Comment)"}'
where caption = '(Kommentar)';

update indicia.occurrence_attributes
set caption = '(Kommentar)'
where caption = 'Kommentar';


update indicia.occurrence_attributes
set caption_i18n = '{"cze": "(Komentář)", "eng": "(Comment)"}'
where caption = '(Kommentar)';

-- Remove any freetext terms
update indicia.termlists_terms 
set deleted=true
where term_id in
(select id from indicia.terms where lower(term) = 'freitext');


update indicia.termlists_terms 
set deleted=true
where term_id in
(select id from indicia.terms where lower(term) = 'freetext');


--If you need to to visually see the pairs, you can get comment field pairs using this code
/*select ttla_comment.id, ttla_main.id
from indicia.taxa_taxon_list_attributes ttla_main
join indicia.termlists_terms sub_area_tt on sub_area_tt.id = ttla_main.reporting_category_id and sub_area_tt.deleted=false
join indicia.terms sub_area_term on sub_area_term.id = sub_area_tt.term_id and sub_area_term.deleted=false
join indicia.termlists_terms main_area_tt on main_area_tt.id = sub_area_tt.parent_id and main_area_tt.deleted=false
join indicia.terms main_area_term on main_area_term.id = main_area_tt.term_id and main_area_tt.deleted=false
join indicia.taxa_taxon_list_attributes ttla_comment on ttla_comment.description = 'Kommentar für ' || main_area_term.term || '/' || sub_area_term.term || '/' || ttla_main.caption
AND ttla_comment.deleted=false
where ttla_main.deleted=false
order by ttla_comment.id asc;*/