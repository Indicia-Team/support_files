/* One off script to create a lookup for habitat score values */
create table pantheon.score_details (
  id serial primary key not null,
  category character varying not null,
  key character varying not null,
  value character varying not null
);

insert into pantheon.score_details(category, key, value) values
('acid mire', 'A', 'acid mire obligates'),
('acid mire', 'B', 'acid mire specialists'),
('acid mire', 'C', 'acid mire preferential'),
('coarse woody debris', 'a', 'obligate xylophages'),
('coarse woody debris', 'a/b', 'obligate xylophages/possible obligate xylophages'),
('coarse woody debris', 'b', 'possible obligate xylophages'),
('coarse woody debris', 'b/c', 'possible obligate xylophages/facultative xylophages'),
('coarse woody debris', 'c', 'facultative xylophages'),
('coarse woody debris', 'c/d', 'facultative xylophages/probable xylophages'),
('coarse woody debris', 'd', 'probable xylophages'),
('coarse woody debris', 'd/e', 'probable xylophages/non xylophages'),
('coarse woody debris', 'e', 'non xylophages'),
('ERS (Diptera)', '1', 'total fidelity'),
('ERS (Diptera)', '2', 'strong fidelity'),
('ERS (Diptera)', '3', 'moderate fidelity'),
('seepage (woodland)', 'A', 'seepage obligates'),
('seepage (woodland)', 'B', 'seepage specialists'),
('seepage (woodland)', 'C', 'seepage associates'),
('seepage (acid-neutral)', 'A', 'seepage obligates'),
('seepage (acid-neutral)', 'B', 'seepage specialists'),
('seepage (acid-neutral)', 'C', 'seepage associates'),
('seepage (calcareous)', 'A', 'seepage obligates'),
('seepage (calcareous)', 'B', 'seepage specialists'),
('seepage (calcareous)', 'C', 'seepage associates'),
('seepage (soft rock cliff)', 'A', 'seepage obligates'),
('seepage (soft rock cliff)', 'B', 'seepage specialists'),
('seepage (soft rock cliff)', 'C', 'seepage associates'),
('seepage (stable cliff)', 'A', 'seepage obligates'),
('seepage (stable cliff)', 'B', 'seepage specialists'),
('seepage (stable cliff)', 'C', 'seepage associates'),
('soft rock cliff', '1', 'Grade 1'),
('soft rock cliff', '2', 'Grade 2'),
('soft rock cliff', '3', 'Grade 3'),
('grazing marsh - salinity', '0', 'Freshwater species tolerant of only mildly brackish water'),
('grazing marsh - salinity', '1', 'Species tolerant of mildly brackish conditions'),
('grazing marsh - salinity', '2', 'Species that are obligately dependent upon mild to moderately brackish conditions'),
('ERS (Coleoptera)', '1', 'ERS dependent'),
('ERS (Coleoptera)', '2', 'ERS associated');

GRANT SELECT ON pantheon.score_details TO indicia_report_user;
