drop table score_name_tidy;
create temporary table score_name_tidy (
  old character varying,
  new character varying
);

insert into score_name_tidy values 
('acid mire fidelity score', 'acid mire'),
('calcareous grassland fidelity score', 'calcareous grassland'),
('coarse woody debris fidelity score', 'coarse woody debris'),
('exposed riverine sediments fidelity score (D & H)', 'ERS (D & H)'),
('revised index of ecology continuity score', 'IEC (revised)'),
('seepage habitats fidelity score - acid-neutral', 'seepage (acid-neutral)'),
('seepage habitats fidelity score - calcareous', 'seepage (calcareous)'),
('seepage habitats fidelity score - slumping cliff', 'seepage (soft rock cliff)'),
('seepage habitats fidelity score - stable cliff', 'seepage (stable cliff)'),
('seepage habitats fidelity score – woodland', 'seepage (woodland)'),
('soft rock cliff fidelity score', 'soft rock cliff'),
('spider indicator species for peat bogs', 'peat bog spiders'),
('index of ecology continuity score', 'IEC (older version)'),
('grazing coastal marsh score - species score', 'grazing marsh - species'),
('grazing coastal marsh score - salinity score', 'grazing marsh - salinity');

update taxa_taxon_list_attributes a
set caption = score_name_tidy.new
from score_name_tidy
where caption = score_name_tidy.old;
