
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
SELECT insert_term('URB', 'fra', null, 'butterfly:habitat'); ---  Milieux urbanisés
SELECT insert_term('AGR', 'fra', null, 'butterfly:habitat'); --- Cultures annuelles
SELECT insert_term('PRA', 'fra', null, 'butterfly:habitat'); --- Prairies et herbages
SELECT insert_term('FFE', 'fra', null, 'butterfly:habitat'); --- Forêts de feuillus
SELECT insert_term('PEL', 'fra', null, 'butterfly:habitat'); --- Pelouses
SELECT insert_term('FRI', 'fra', null, 'butterfly:habitat'); --- Friches
SELECT insert_term('BUI', 'fra', null, 'butterfly:habitat'); --- Milieux buissonneux
SELECT insert_term('ZHU', 'fra', null, 'butterfly:habitat'); --- Zones humides
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

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reliability', 'Reliability of data for this Section.', now(), 1, now(), 1, 'butterfly:reliability');
SELECT insert_term('1', 'fra', null, 'butterfly:reliability'); --- Reliable data
SELECT insert_term('2', 'fra', null, 'butterfly:reliability'); --- Weakly reliable data
SELECT insert_term('3', 'fra', null, 'butterfly:reliability'); --- Unreliable data
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Fiabilité du comptage', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:reliability'), 'f', 't'
);

