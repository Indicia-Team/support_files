--AVB note: IN THEORY we shouldn't need this file anymore, however this line previously wouldn't of executed and still needs executing.
--The problematic line is as follows
--('seepage habitats fidelity score – woodland', 'seepage (woodland)'),
--It should of originally been the line you see below (the hyphen is different)
set search_path TO indicia, public;
drop table if exists score_name_tidy;
create temporary table score_name_tidy (
  old character varying,
  new character varying
);

insert into score_name_tidy values 
('seepage habitats fidelity score - woodland', 'seepage (woodland)');

update taxa_taxon_list_attributes a
set caption = score_name_tidy.new
from score_name_tidy
where caption = score_name_tidy.old;

-- AVB note: Only need running on data imported using an old version version of the importer if not previopusly run
-- If unsure, there is no harm in running
insert into score_name_tidy values 
('acid mire fidelity score', 'acid mire'),
('calcareous grassland fidelity score', 'calcareous grassland'),
('coarse woody debris fidelity score', 'coarse woody debris'),
('exposed riverine sediments fidelity score (DGHP)', 'ERS (Diptera)'),
('exposed riverine sediments fidelity score (B)', 'ERS (Coleoptera)'),
('revised index of ecology continuity score', 'IEC'),
('seepage habitats fidelity score - acid-neutral', 'seepage (acid-neutral)'),
('seepage habitats fidelity score - calcareous', 'seepage (calcareous)'),
('seepage habitats fidelity score - slumping cliff', 'seepage (soft rock cliff)'),
('seepage habitats fidelity score - stable cliff', 'seepage (stable cliff)'),
('soft rock cliff fidelity score', 'soft rock cliff'),
('spider indicator species for peat bogs', 'peat bog spiders'),
('index of ecology continuity score', 'IEC (older version)'),
('grazing coastal marsh score - species score', 'grazing marsh - status'),
('grazing coastal marsh score - salinity score', 'grazing marsh - salinity');

update taxa_taxon_list_attributes a
set caption = score_name_tidy.new
from score_name_tidy
where caption = score_name_tidy.old;


