
--- this termlist is language independant so just use french.
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('butterfly distribution', 'Qualitive distribution - how close species was to observer gives a indication of reliability of identification',
	now(), 1, now(), 1, 'butterfly:distribution');
SELECT insert_term(' ', 'fra', null, 'butterfly:distribution');
SELECT insert_term('X', 'fra', null, 'butterfly:distribution');
SELECT insert_term('/', 'fra', null, 'butterfly:distribution');
SELECT insert_term('0', 'fra', null, 'butterfly:distribution');

INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Butterfly Qual Dist', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:distribution'), 'f', 't'
);

--- use standard count, though make sure not required.

--- section sample attributes
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('HabitatType', 'Habitat Type for this Section.', now(), 1, now(), 1, 'butterfly:habitat');
SELECT insert_term('URB Milieux urbanisés', 'fra', null, 'butterfly:habitat');
SELECT insert_term('AGR Cultures annuelles', 'fra', null, 'butterfly:habitat');
SELECT insert_term('PRA Prairies et herbages', 'fra', null, 'butterfly:habitat');
SELECT insert_term('FFE Forêts de feuillus', 'fra', null, 'butterfly:habitat');
SELECT insert_term('PEL Pelouses', 'fra', null, 'butterfly:habitat');
SELECT insert_term('FRI Friches', 'fra', null, 'butterfly:habitat');
SELECT insert_term('BUI Milieux buissonneux', 'fra', null, 'butterfly:habitat');
SELECT insert_term('ZHU Zones humides', 'fra', null, 'butterfly:habitat');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Habitat Type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:habitat'), 'f', 't'
);

INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Aucune Observation', 'B', now(), 1, now(), 1, 'f', 't'
);
