-- Instructions for user
-- Firstly find and replace this tag in the script <pantheon_taxon_list_id>
-- Secondly uncomment all the first lines in the statements (prevents accidental use)

set search_path TO indicia, public;

--select taxa_taxon_list_attribute_id into taxon_lists_taxa_taxon_list_attributes_removal_rows
from indicia.taxon_lists_taxa_taxon_list_attributes
where deleted = false AND taxon_list_id = <pantheon_taxon_list_id>;

--update taxa_taxon_list_attribute_values
set deleted = true 
where taxa_taxon_list_attribute_id in
(select id from taxa_taxon_list_attributes where id  in
(select taxa_taxon_list_attribute_id from taxon_lists_taxa_taxon_list_attributes_removal_rows));

--update taxon_lists_taxa_taxon_list_attributes 
set deleted = true 
where deleted = false AND taxon_list_id = <pantheon_taxon_list_id>;

--update taxa_taxon_list_attributes 
set deleted = true
where id in
(select taxa_taxon_list_attribute_id from taxon_lists_taxa_taxon_list_attributes_removal_rows);

--Remove temporary table
drop table taxon_lists_taxa_taxon_list_attributes_removal_rows;


--select id, term_id, termlist_id into termlists_terms_removal_rows
from indicia.termlists_terms
where termlist_id in
(select id from termlists where deleted = false AND website_id in
(select id from websites where title = 'Pantheon' and deleted = false));

--update termlists_terms 
set deleted = true
where id in
(select id from termlists_terms_removal_rows);

--update termlists
set deleted = true
where id in
(select termlist_id from termlists_terms_removal_rows);

--update terms 
set deleted = true
where id in
(select term_id from termlists_terms_removal_rows);

--Remove temporary table
drop table termlists_terms_removal_rows;
