/*
Data exported from MS Access as text files, suffix .csv, field names in first row, " delimiter.
Open each file in notepad and save as UTF-8
Open each file in Notepad++ and convert to UTF-8 without BOM

Also if you need to recreate the species list
2) Upload the distinct groups from tblSpecies
1) run this query to export the species data to import as a list (if not using an existing list):
select distinct PreferredName, PreferredAuthority, PreferredTVK, Group
FROM tblSpecies
WHERE PreferredTVK is not null;
Also treat this output for UTF-8 without BOM as above
*/

set search_path=indicia, public;

delete from cache_occurrences;
delete from occurrence_attribute_values;
delete from occurrences;
delete from sample_attribute_values;
delete from samples;
delete from cache_taxa_taxon_lists;
delete from cache_taxon_searchterms;
delete from taxa_taxon_list_attribute_values;
delete from taxon_lists_taxa_taxon_list_attributes;
delete from taxa_taxon_list_attributes;
delete from taxa_taxon_lists;
delete from taxa;
delete from taxon_meanings;
delete from cache_termlists_terms where termlist_id>=14 and termlist_id<>22;
delete from termlists_terms where termlist_id>=14 and termlist_id<>22;
delete from terms where id not in (select term_id from termlists_terms);
delete from termlists where id>=14 and id<>22;

-- NOW, import the species

drop schema pantheon cascade;

create schema pantheon;
set search_path TO pantheon, public;

CREATE TABLE tbl_species (
species_id integer, -- JVB Added to first col, made integer as it is to pick up actual value not create them serially
species_name varchar (200),
species_tvk varchar (50),
preferred_name varchar (200),
preferred_authority varchar (100),
preferred_tvk varchar (50),
"group" varchar (100),
family varchar (100),
status varchar (20),
sort_code varchar (20),
notes varchar,
-- species_id serial NOT NULL, -- JVB Removed as column first in table
CONSTRAINT pk_tbl_species PRIMARY KEY (species_id)
);

CREATE TABLE tbl_traits (
trait_id integer, -- JVB Added to first col, made integer as it is to pick up actual value not create them serially
trait_code varchar (20),
trait_description varchar,
trait_type varchar (100),
trait_source varchar (50),
parent_trait_code varchar (50),
parent_trait_id integer,
-- trait_id serial NOT NULL, JVB Removed as column first in table
CONSTRAINT pk_tbl_traits PRIMARY KEY (trait_id)
);

Create table tbl_species_traits (
species_trait_id Integer, -- JVB moved to first column to match data
species_id Integer,
trait_id Integer,
trait_value text,
coding_convention varchar (50),
CONSTRAINT fk_tbl_species_traits_species_id FOREIGN KEY (species_id)
	REFERENCES tbl_species (species_id) MATCH SIMPLE,
CONSTRAINT fk_tbl_species_traits_trait_id FOREIGN KEY (trait_id)
	REFERENCES tbl_traits (trait_id) MATCH SIMPLE
);

COPY tbl_traits
FROM '/users/john/Dropbox/tblTraits.csv'
WITH DELIMITER ','
CSV HEADER;

COPY tbl_species
FROM '/users/john/Dropbox/tblSpecies.csv'
WITH DELIMITER ','
CSV HEADER;

COPY tbl_species_traits
FROM '/users/john/Dropbox/tblSpeciesTrait.csv'
WITH DELIMITER ','
CSV HEADER;


