
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
	'No observation', 'B', now(), 1, now(), 1, 'f', 't'
);

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reliability', 'Reliability of data for this Section.', now(), 1, now(), 1, 'butterfly:reliability');
SELECT insert_term('1', 'fra', null, 'butterfly:reliability'); --- Reliable data
SELECT insert_term('2', 'fra', null, 'butterfly:reliability'); --- Weakly reliable data
SELECT insert_term('3', 'fra', null, 'butterfly:reliability'); --- Unreliable data
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Survey Reliability', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:reliability'), 'f', 't'
);

-- after the following are set up, need to set their structure blocks, as well as their website allocation
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Observer', 'T', now(), 1, now(), 1, 'f', 't'
);
-- start and end time already exist
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Month', 'Survey month', now(), 1, now(), 1, 'butterfly:Month');
SELECT insert_term('April', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('May', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('June', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('July', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('August', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('September', 'eng', null, 'butterfly:Month'); 
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'MNHNL Month', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:Month'), 'f', 't'
);
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Number In Month', 'Survey number within this month', now(), 1, now(), 1, 'butterfly:numInMonth');
SELECT insert_term('1', 'fra', null, 'butterfly:numInMonth'); 
SELECT insert_term('2', 'fra', null, 'butterfly:numInMonth'); 
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Number in Month', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:numInMonth'), 'f', 't'
);
-- Use existing attribute for temperature
-- need to set sort order for following termlist
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Wind', 'Beaufort wind Force', now(), 1, now(), 1, 'butterfly:wind');
SELECT insert_term('Force  0: Calm. Smoke rises vertically.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  1: Smoke drift indicates wind direction, still wind vanes.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  2: Wind felt on exposed skin. Leaves rustle, vanes begin to move.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  3: Leaves and small twigs constantly moving, light flags extended.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  4: Dust and loose paper raised. Small branches begin to move.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  5: Branches of a moderate size move. Small trees in leaf begin to sway.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  6: Large branches in motion. Whistling heard in overhead wires.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  7: Whole trees in motion. Effort needed to walk against the wind.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  8: Some twigs broken from trees. Progress on foot is seriously impeded.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force  9: Some branches break off trees, and some small trees blow over.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force 10: Trees are broken off or uprooted, saplings bent and deformed.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force 11: Widespread damage to vegetation. Many roofing surfaces are damaged.', 'eng', null, 'butterfly:wind');
SELECT insert_term('Force 12: Very widespread damage to vegetation. Debris may be hurled about.', 'eng', null, 'butterfly:wind');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Wind Force', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:wind'), 'f', 't'
);

-- need to set sort order for following termlist
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Cloud', 'Percent Cloud Cover', now(), 1, now(), 1, 'butterfly:cloud');
SELECT insert_term('0%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('5%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('10%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('15%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('20%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('25%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('30%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('35%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('40%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('45%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('50%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('55%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('60%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('65%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('70%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('75%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('80%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('85%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('90%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('95%', 'fra', null, 'butterfly:cloud');
SELECT insert_term('100%', 'fra', null, 'butterfly:cloud');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Cloud Cover', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:cloud'), 'f', 't'
);
