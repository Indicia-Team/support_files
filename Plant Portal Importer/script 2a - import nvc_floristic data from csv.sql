
--Replace the following tag with the path to your csv data files
--<csv_nvc_floristic_tables_file_path>
--Path format (on mac) should be like '/users/joebloggs/nvc_floristic_tables.csv'

set search_path TO plant_portal_importer, public;

CREATE TABLE tbl_nvc_floristic_tables (
row_number integer,
community_or_sub_community_code varchar,
community_or_sub_community_name varchar,
community_level_code varchar,
species_name_or_special_variable varchar,
species_constancy_value varchar,
maximum_abundance_species integer,
special_variable_value integer,
preferred_tvk varchar
);

COPY tbl_nvc_floristic_tables
FROM <csv_nvc_floristic_tables_file_path>
WITH DELIMITER ','
CSV HEADER;