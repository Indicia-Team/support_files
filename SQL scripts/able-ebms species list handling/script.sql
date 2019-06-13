create table fauna_europea_higher (
  id serial not null,
  taxon_name varchar,
  author varchar,
  year integer,
  rank varchar,
  synonym_name varchar,
  synonym_author varchar,
  synonym_year integer,
  tax_id integer,
  tax_id_parent integer
);

-- Save file from Excel.
-- Use Notepad++ to change encoding to UTF8 without BOM.

copy fauna_europea_higher(taxon_name, author, year, rank, synonym_name, synonym_author, synonym_year, tax_id, tax_id_parent)
from '/Users/john/Dropbox/oo_8640.csv' delimiter ',' CSV HEADER;

create table eubms (
  id serial not null,
  taxon varchar,
  authority varchar,
  parent varchar,
  rank varchar,
  common_names varchar,
  al_ varchar(2),
  ad_ varchar(2),
  at_ varchar(2),
  by_ varchar(2),
  be_ varchar(2),
  ba_ varchar(2),
  bg_ varchar(2),
  hr_ varchar(2),
  cy_ varchar(2),
  cz_ varchar(2),
  dk_ varchar(2),
  ee_ varchar(2),
  fi_ varchar(2),
  fr_ varchar(2),
  de_ varchar(2),
  gr_ varchar(2),
  hu_ varchar(2),
  is_ varchar(2),
  ie_ varchar(2),
  it_ varchar(2),
  lv_ varchar(2),
  li_ varchar(2),
  lt_ varchar(2),
  lu_ varchar(2),
  mk_ varchar(2),
  mt_ varchar(2),
  md_ varchar(2),
  me_ varchar(2),
  nl_ varchar(2),
  no_ varchar(2),
  pl_ varchar(2),
  pt_ varchar(2),
  pt_az_ varchar(2),
  pt_ma_ varchar(2),
  ro_ varchar(2),
  ru_ varchar(2),
  rs_ varchar(2),
  sk_ varchar(2),
  si_ varchar(2),
  es_ varchar(2),
  es_ca_ varchar(2),
  se_ varchar(2),
  ch_ varchar(2),
  tr_ varchar(2),
  ua_ varchar(2),
  gb_ varchar(2),
  sort_order integer,
  external_key integer
);

copy eubms(taxon, authority, parent, rank, common_names, al_, ad_, at_, by_, be_, ba_, bg_, hr_, cy_, cz_, dk_, ee_,
  fi_, fr_, de_, gr_, hu_, is_, ie_, it_, lv_, li_, lt_, lu_, mk_, mt_, md_, me_, nl_, no_, pl_, pt_, pt_az_, pt_ma_,
  ro_, ru_, rs_, sk_, si_, es_, es_ca_, se_, ch_, tr_, ua_, gb_, sort_order)
from '/Users/john/Dropbox/Euro-butterfly-checklist-formatted.csv' delimiter ',' CSV HEADER;

update eubms e
set external_key=f.tax_id
from fauna_europea_higher f
where f.taxon_name=e.taxon;

select * from eubms where rank not in ('Genus', 'Species') and external_key is null
select * from eubms where parent in ('Nemeobiinae', 'Hamearis')