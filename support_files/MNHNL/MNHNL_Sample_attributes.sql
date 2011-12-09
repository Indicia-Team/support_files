CREATE OR REPLACE FUNCTION tmp_add_term(t character varying(100), lang_iso character(3), list integer, list_external_key character varying) RETURNS integer AS
$BODY$
DECLARE
  m_id integer;
  t_id integer;
  l_id integer;
BEGIN
    l_id := CASE WHEN list IS NULL THEN (SELECT id FROM termlists WHERE external_key=list_external_key) ELSE list END;

    t_id := nextval('terms_id_seq'::regclass);

    INSERT INTO terms (id, term, language_id, created_on, created_by_id, updated_on, updated_by_id)
    VALUES (t_id, t, (SELECT id from languages WHERE iso = lang_iso), now(), 1, now(), 1);

    m_id := currval('meanings_id_seq'::regclass);

    INSERT INTO termlists_terms (term_id, termlist_id, meaning_id, preferred, created_on, created_by_id, updated_on, updated_by_id)
    VALUES (t_id, l_id, m_id, 'f', now(), 1, now(), 1);

    RETURN 1;
END
$BODY$
LANGUAGE 'plpgsql';

--- The following new Sample Attributes are used for COBIMO: Common Bird Monitoring: mnhnl_bird_transect_walks (no survey allocated, direct to website)
--- The Temperature, CMS Username, CMS User ID and Emailcount attribute is a standard one.
--- TBD need to get definitions
--- Wind Force
--- Cloud Cover
--- Walk started at end
--- Closed
--- Reliability of this data
--- Visit number in year
--- Precipitation

INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, applies_to_location, multi_value, public, applies_to_recorder, validation_rules) VALUES (
	'Start time', 'T', now(), 1, now(), 1, 'f', 'f', 't', 't', 'time');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, applies_to_location, multi_value, public, applies_to_recorder, validation_rules) VALUES (
	'End time', 'T', now(), 1, now(), 1, 'f', 'f', 't', 't', 'time');

--- The following new Occurrence Attributes are used for Butterflies1: Butterfly Monitoring: mnhnl_butterflies
--- The Temperature, CMS Username, CMS User ID and Emailcount attribute is a standard one.
--- Start Time and End Time is used from COBIMO Above.

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('HabitatType', 'Habitat Type for this Section.', now(), 1, now(), 1, 'butterfly:habitat');
SELECT insert_term('URB', 'eng', null, 'butterfly:habitat'); ---  Milieux urbanisés
SELECT insert_term('AGR', 'eng', null, 'butterfly:habitat'); --- Cultures annuelles
SELECT insert_term('PRA', 'eng', null, 'butterfly:habitat'); --- Prairies et herbages
SELECT insert_term('FFE', 'eng', null, 'butterfly:habitat'); --- Forêts de feuillus
SELECT insert_term('PEL', 'eng', null, 'butterfly:habitat'); --- Pelouses
SELECT insert_term('FRI', 'eng', null, 'butterfly:habitat'); --- Friches
SELECT insert_term('BUI', 'eng', null, 'butterfly:habitat'); --- Milieux buissonneux
SELECT insert_term('ZHU', 'eng', null, 'butterfly:habitat'); --- Zones humides
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly:habitat');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Habitat type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:habitat'), 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'No observation', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reliability', 'Reliability of data for this Section.', now(), 1, now(), 1, 'butterfly:reliability');
SELECT insert_term('1', 'eng', null, 'butterfly:reliability'); --- Reliable data
SELECT insert_term('2', 'eng', null, 'butterfly:reliability'); --- Weakly reliable data
SELECT insert_term('3', 'eng', null, 'butterfly:reliability'); --- Unreliable data
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly:reliability');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Survey reliability', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:reliability'), 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Observer', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Month', 'Survey month', now(), 1, now(), 1, 'butterfly:Month');
SELECT insert_term('April', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('May', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('June', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('July', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('August', 'eng', null, 'butterfly:Month'); 
SELECT insert_term('September', 'eng', null, 'butterfly:Month'); 
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly:Month');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'MNHNL Month', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:Month'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Number In Month', 'Survey number within this month', now(), 1, now(), 1, 'butterfly:numInMonth');
SELECT insert_term('1', 'fra', null, 'butterfly:numInMonth'); 
SELECT insert_term('2', 'fra', null, 'butterfly:numInMonth'); 
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly:numInMonth');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Number in month', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:numInMonth'), 'f', 't');
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
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly:wind');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Wind force', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:wind'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Cloud', 'Percent Cloud Cover', now(), 1, now(), 1, 'butterfly:cloud');
SELECT insert_term('0%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('5%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('10%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('15%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('20%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('25%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('30%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('35%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('40%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('45%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('50%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('55%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('60%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('65%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('70%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('75%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('80%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('85%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('90%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('95%', 'eng', null, 'butterfly:cloud');
SELECT insert_term('100%', 'eng', null, 'butterfly:cloud');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly:cloud');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Cloud cover', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:cloud'), 'f', 't');

--- The following new Sample Attributes are used for Winter Bats: mnhnl_bats
--- The CMS Username, CMS User ID and Emailcount attribute is a standard one.
--- Need to Check reliabilty WRT reliability in COBIMO above.
--- No observation is used from Butterfly1 above.

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatRegularFollowup', 'Suitablity for regular follow ups', now(), 1, now(), 1, 'bats:followup');
SELECT insert_term('Appropriate', 'eng', null, 'bats:followup');
SELECT tmp_add_term('Approprié', 'fra', null, 'bats:followup');
SELECT insert_term('A bit appropriate', 'eng', null, 'bats:followup');
SELECT tmp_add_term('Peu approprié', 'fra', null, 'bats:followup');
SELECT insert_term('Inappropriate', 'eng', null, 'bats:followup');
SELECT tmp_add_term('Inapproprié', 'fra', null, 'bats:followup');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats:followup');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Site followup', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:followup'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatVisit', 'Visit Number in Year', now(), 1, now(), 1, 'bats:visit');
SELECT insert_term('1/1', 'eng', null, 'bats:visit');
SELECT insert_term('1/2', 'eng', null, 'bats:visit');
SELECT insert_term('2/2', 'eng', null, 'bats:visit');
SELECT insert_term('1/3', 'eng', null, 'bats:visit');
SELECT insert_term('2/3', 'eng', null, 'bats:visit');
SELECT insert_term('3/3', 'eng', null, 'bats:visit');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats:visit');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Bat Visit', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:visit'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatCavityOpening', 'Cavity Opening', now(), 1, now(), 1, 'bats:cavityopening');
SELECT insert_term('Blocked off', 'eng', null, 'bats:cavityopening');
SELECT tmp_add_term('Fermeture artificielle', 'fra', null, 'bats:cavityopening');
SELECT insert_term('Impenetrable for bats', 'eng', null, 'bats:cavityopening');
SELECT tmp_add_term('Imperméable au passage des chiroptères', 'fra', null, 'bats:cavityopening');
SELECT insert_term('Impenetrable for humans', 'eng', null, 'bats:cavityopening');
SELECT tmp_add_term('Imperméable au passage des hommes', 'fra', null, 'bats:cavityopening');
SELECT insert_term('Defective locking system', 'eng', null, 'bats:cavityopening');
SELECT tmp_add_term('Système de fermeture défectueux', 'fra', null, 'bats:cavityopening');
SELECT insert_term('Unstable entrance or entrance threatened with obstruction', 'eng', null, 'bats:cavityopening');
SELECT tmp_add_term('Entrée instable ou menacée d’obstruction', 'fra', null, 'bats:cavityopening');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats:cavityopening');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Cavity entrance', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:cavityopening'), 't', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Cavity entrance comment', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatDisturbances', 'List of Disturbances', now(), 1, now(), 1, 'bats:disturbances');
SELECT insert_term('Noise', 'eng', null, 'bats:disturbances');
SELECT tmp_add_term('Bruit', 'fra', null, 'bats:disturbances');
SELECT insert_term('Instability', 'eng', null, 'bats:disturbances');
SELECT tmp_add_term('Instabilité', 'fra', null, 'bats:disturbances');
SELECT insert_term('Vibrations', 'eng', null, 'bats:disturbances');
SELECT tmp_add_term('Vibrations', 'fra', null, 'bats:disturbances');
SELECT insert_term('Artifical light', 'eng', null, 'bats:disturbances');
SELECT tmp_add_term('Lumière artificielle', 'fra', null, 'bats:disturbances');
SELECT insert_term('Risk of temporary flooding', 'eng', null, 'bats:disturbances');
SELECT tmp_add_term('Risques d’inondation temporaire', 'fra', null, 'bats:disturbances');
SELECT insert_term('Toxic waste present', 'eng', null, 'bats:disturbances');
SELECT tmp_add_term('Présence de déchets toxiques', 'fra', null, 'bats:disturbances');
SELECT insert_term('Other', 'eng', null, 'bats:disturbances');
SELECT tmp_add_term('Autre', 'fra', null, 'bats:disturbances');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats:disturbances');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Disturbances', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:disturbances'), 't', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Disturbances other comment', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('HumanFrequentation', 'Site Type', now(), 1, now(), 1, 'bats:humanfreq');
SELECT insert_term('None', 'eng', null, 'bats:humanfreq');
SELECT tmp_add_term('Nulle', 'fra', null, 'bats:humanfreq');
SELECT insert_term('Occasional', 'eng', null, 'bats:humanfreq');
SELECT tmp_add_term('Occasionnelle', 'fra', null, 'bats:humanfreq');
SELECT insert_term('Moderate', 'eng', null, 'bats:humanfreq');
SELECT tmp_add_term('Modérée', 'fra', null, 'bats:humanfreq');
SELECT insert_term('Intense', 'eng', null, 'bats:humanfreq');
SELECT tmp_add_term('Intense', 'fra', null, 'bats:humanfreq');
SELECT insert_term('Unknown', 'eng', null, 'bats:humanfreq');
SELECT tmp_add_term('Inconnue', 'fra', null, 'bats:humanfreq');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats:humanfreq');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Human frequentation', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:humanfreq'), 'f', 't');
--- TBD use standard temperature as outside temp
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Temp Exterior', 'F', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Temp Int 1', 'F', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Temp Int 2', 'F', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Temp Int 3', 'F', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Humid Exterior', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Humid Int 1', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Humid Int 2', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Humid Int 3', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Positions marked', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reliability', 'Reliability of data for this Section.', now(), 1, now(), 1, 'bats:reliability');
SELECT insert_term('1 - Reliable', 'eng', null, 'bats:reliability');
SELECT tmp_add_term('1 - Fiable', 'fra', null, 'bats:reliability');
SELECT insert_term('2 - Weakly reliable', 'eng', null, 'bats:reliability');
SELECT tmp_add_term('2 – Peu fiable', 'fra', null, 'bats:reliability');
SELECT insert_term('3 - Unreliable', 'eng', null, 'bats:reliability');
SELECT tmp_add_term('3 – Non fiable', 'fra', null, 'bats:reliability'); 
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats:reliability');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Reliability', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:reliability'), 'f', 't');
--- NEW
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Accompanied By', 'T', now(), 1, now(), 1, 'f', 't');

--- The following new Occurrence Attributes are used for Butterflies2: Butterfly de Jours: mnhnl_butterflies2
--- The Temperature, CMS Username, CMS User ID and Emailcount attribute is a standard one.
--- Start Time is used from COBIMO above.
--- Cloud Cover, No observation are used from Butterfly1 above.
--- Reliability is used from Bats above.

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Butterfly2 Passage', 'Survey month', now(), 1, now(), 1, 'butterfly2:Passage');
SELECT insert_term('May', 'eng', null, 'butterfly2:Passage');
SELECT tmp_add_term('Mai', 'fra', null, 'butterfly2:Passage'); 
SELECT insert_term('June', 'eng', null, 'butterfly2:Passage');
SELECT tmp_add_term('Juin', 'fra', null, 'butterfly2:Passage'); 
SELECT insert_term('July', 'eng', null, 'butterfly2:Passage');
SELECT tmp_add_term('Juillet', 'fra', null, 'butterfly2:Passage'); 
SELECT insert_term('August', 'eng', null, 'butterfly2:Passage');
SELECT tmp_add_term('Août', 'fra', null, 'butterfly2:Passage'); 
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly2:Passage');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Passage', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly2:Passage'), 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Duration', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Windspeed', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Rain', 'B', now(), 1, now(), 1, 'f', 't');
	
--- The following new Sample Attributes are used for Reptiles: mnhnl_reptiles
--- The Temperature, CMS Username, CMS User ID and Emailcount attributes are standard ones.
--- Wind Force, Cloud Cover, No observation are used from Butterfly1 above.
--- Rain and Duration are used from Butterflies2 above.

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('ReptileProgramme', 'Reptile Programmes', now(), 1, now(), 1, 'reptile:programme');
SELECT insert_term('Sand Lizard Survey', 'eng', null, 'reptile:programme');
SELECT insert_term('Common Wall Lizard Survey', 'eng', null, 'reptile:programme');
SELECT insert_term('Smooth Snake Survey', 'eng', null, 'reptile:programme');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='reptile:programme');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Programme', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:programme'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Survey 1', 'Reptile Single Survey.', now(), 1, now(), 1, 'reptile:survey1');
SELECT insert_term('1', 'eng', null, 'reptile:survey1');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Survey (1)', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:survey1'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Survey 2', 'Reptile Twin Survey.', now(), 1, now(), 1, 'reptile:survey2');
SELECT insert_term('1', 'eng', null, 'reptile:survey2');
SELECT insert_term('2', 'eng', null, 'reptile:survey2');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='reptile:survey2');
INSERT INTO sample_attributes (	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Survey (2)', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:survey2'), 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (	
	'Suitability', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Picture provided', 'B', now(), 1, now(), 1, 'f', 't');

