--Replace the following tag with the path to your csv data files
--<csv_areas_characters_file_path>
--<csv_group_allocations_per_attribute>
--<csv_groups>
--Path format (on mac) should be like '/users/joebloggs/tblSpeciesTrait.csv'
--If running in PSQL on a server, then the path is from the PSQL working directory, you can find this out by typing "\! pwd" inside PSQL

/*
Data exported from MS Access as text files, suffix .csv, field names in first row, " delimiter.
Open each file in notepad and save as UTF-8
Open each file in Notepad++ and convert to UTF-8 without BOM
*/

-- NOW, import the species

create schema if not exists dgfm;
set search_path TO dgfm, public;

DROP TABLE IF EXISTS tbl_attributes;

CREATE TABLE tbl_attributes (
row_num int,
cz_area varchar,
cz_sub_area varchar,
cz_attribute varchar,
cz_type varchar,
gb_area varchar,
gb_sub_area varchar,
gb_attribute varchar,
gb_type varchar,
deu_area varchar,
deu_sub_area varchar,
deu_attribute varchar,
deu_type varchar
);

COPY tbl_attributes
FROM '<csv_areas_characters_file_path>'
WITH DELIMITER ','
ENCODING 'UTF-8'
CSV HEADER;

DROP TABLE IF EXISTS tbl_attribute_set_allocations;

CREATE TABLE tbl_attribute_set_allocations (
row_num int,
deu_area varchar,
deu_sub_area varchar,
deu_attribute varchar,
attribute_set_allocation_list varchar
);

COPY tbl_attribute_set_allocations
FROM '<csv_group_allocations_per_attribute>'
WITH DELIMITER ','
ENCODING 'UTF-8'
CSV HEADER;

DROP TABLE IF EXISTS tbl_attribute_sets;

CREATE TABLE tbl_attribute_sets (
attribute_sets varchar
);

COPY tbl_attribute_sets
FROM '<csv_groups>'
WITH DELIMITER ','
ENCODING 'UTF-8'
CSV HEADER;

Alter table dgfm.tbl_attributes
ADD Column multi_value boolean default true,
ADD Column colour_attribute_description text;