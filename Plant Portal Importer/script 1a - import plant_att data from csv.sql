
--Replace the following tag with the path to your csv data files
--<csv_plant_att_file_path>
--Path format (on mac) should be like '/users/joebloggs/plantAtt.csv'

/*
Data exported from MS Access as text files, suffix .csv, field names in first row, " delimiter.
Open each file in notepad and save as UTF-8
Open each file in Notepad++ and convert to UTF-8 without BOM
*/

-- NOW, import the data

create schema plant_portal;
set search_path TO plant_portal, public;

CREATE TABLE tbl_plant_att (
preferred_tvk varchar,
brc_code varchar,
taxon_name varchar,
fam varchar,
fama varchar,
orda varchar,
ns varchar,
cs varchar,
rs varchar,
chg float,
hght integer,
len float,
p1 varchar,
p2 varchar,
lf1 varchar,
lf2 varchar,
w varchar,
clone1 varchar,
clone2 varchar,
e1 varchar,
e2 varchar,
c varchar,
nbi integer,
neur varchar,
sbi integer,
seur varchar,
origin varchar,
gb integer,
ir integer,
ci integer,
tjan float,
tjul float,
prec integer,
co varchar,
br_habitats varchar,
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

COPY tbl_plant_att
FROM <csv_plant_att_file_path>
WITH DELIMITER ','
CSV HEADER;

--Manual corrections to the data as discussed with David Roy.
delete from plant_portal.tbl_plant_att
where taxon_name = 'Zostera angustifolia';

update plant_portal.tbl_plant_att
set preferred_tvk='NBNSYS0000002168'
where taxon_name = 'Asparagus officinalis subsp.officinalis';