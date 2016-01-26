
--Replace the following tag with the path to your csv data files
--<csv_plant_att_file_path>
--Path format (on mac) should be like '/users/joebloggs/tblSpeciesTrait.csv'

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

-- NOW, import the data

drop schema plant_portal cascade;

create schema plant_portal;
set search_path TO plant_portal, public;

CREATE TABLE tbl_plant_att_19_nov_08 (
preferred_tvk varchar (25),
brc_code varchar (15),
taxon_name varchar (100),
fam varchar (4),
fama varchar (4),
orda varchar (4),
ns varchar (2),
cs varchar (2),
rs varchar (1),
chg float,
hght integer,
len float,
p1 varchar (1),
p2 varchar (1),
lf1 varchar (2),
lf2 varchar (2),
w varchar (2),
clone1 varchar (5),
clone2 varchar (5),
e1 varchar (1),
e2 varchar (1),
c varchar (1),
nbi integer,
neur varchar (7),
sbi integer,
seur varchar (7),
origin varchar (20),
gb integer,
ir integer,
ci integer,
tjan float,
tjul float,
prec integer,
co varchar (2),
br_habitats varchar (20),
l integer,
f integer,
r integer,
n integer,
s integer,
source_for_max_height varchar,
comment_on_life_form varchar,
comment_on_clonality varchar,
comment_on_n_and_s_limits_in_europe varchar
);

COPY tbl_plant_att_19_nov_08
FROM <csv_plant_att_file_path>
WITH DELIMITER ','
CSV HEADER;

--Manual corrections to the data as discussed with David Roy.
delete from plant_portal.tbl_plant_att_19_nov_08
where taxon_name = 'Zostera angustifolia';

update plant_portal.tbl_plant_att_19_nov_08
set preferred_tvk='NBNSYS0000002168'
where taxon_name = 'Asparagus officinalis subsp.officinalis';