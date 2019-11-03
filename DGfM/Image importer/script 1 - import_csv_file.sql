--Replace the following tag with the path to your csv data file
--<taxon_image_details_file_path>
--Path format (on mac) should be like '/users/joebloggs/taxonImageDetailsFile.csv'
--If running in PSQL on a server, then the path is from the PSQL working directory, you can find this out by typing "\! pwd" inside PSQL

/*
Data exported from MS Access as text files, suffix .csv, field names in first row, " delimiter.
Open each file in notepad and save as UTF-8
Open each file in Notepad++ and convert to UTF-8 without BOM
*/

-- NOW, import the species

create schema if not exists dgfm;
set search_path TO dgfm, public;

DROP TABLE IF EXISTS tbl_taxon_image_details;

CREATE TABLE tbl_taxon_image_details (
row_num int,
bildnummer varchar,
taxRef_gattung varchar,
art varchar,
taxref_ID  varchar,
bildkategorie  varchar,
TKnr  varchar,
TKname  varchar,
land  varchar,
bundesland  varchar,
regierungsbezirk  varchar,
landkreis varchar,
fundort_1  varchar,
NN_hohe varchar,
koordinaten_1 varchar,
koordinaten_2 varchar,
begleitpflanzen varchar,
datum_gesammelt varchar,
leg varchar,
det varchar,
conf varchar,
fot varchar,
herbar varchar,
herbarbelegnr varchar,
anmerkung varchar
);

COPY tbl_taxon_image_details
FROM '<taxon_image_details_file_path>'
WITH DELIMITER ','
ENCODING 'UTF-8'
CSV HEADER;