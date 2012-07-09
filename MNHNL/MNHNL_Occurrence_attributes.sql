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

--- we assume here that the samples attributes have been loaded in already, with their Reliability termlist

--- The following new Occurrence Attributes are used for COBIMO: Common Bird Monitoring: mnhnl_bird_transect_walks (no survey allocated, direct to website)
--- the count attribute is a standard one.
--- TBD need to get definitions
--- Atlas Code
--- Overflying
--- Territorial
--- Approximation?
--- Confidence

--- The following new Occurrence Attributes are used for Butterflies1: Butterfly Monitoring: mnhnl_butterflies
--- the count attribute is a standard one.

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('butterfly distribution', 'Qualitive distribution - how close species was to observer gives a indication of reliability of identification',
	now(), 1, now(), 1, 'butterfly:distribution');
SELECT insert_term(' ', 'eng', null, 'butterfly:distribution');
SELECT insert_term('X', 'eng', null, 'butterfly:distribution');
SELECT insert_term('/', 'eng', null, 'butterfly:distribution');
SELECT insert_term('0', 'eng', null, 'butterfly:distribution');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly:distribution');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Butterfly Qual Dist', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly:distribution'), 'f', 't');

--- The following new Occurrence Attributes are used for Winter Bats: mnhnl_bats
--- we assume here that the samples attributes have been loaded in already, with their Reliability termlist

INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Num alive', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Num dead', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Excrement', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Occurrence reliability', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:reliability'), 'f', 't');

--- There are no new Occurrence Attributes used for Butterflies2: Butterfly de Jours: mnhnl_butterflies2
--- the count attribute is a standard one.

--- The following new Occurrence Attributes are used for Reptiles: mnhnl_reptiles
--- the count attribute is a standard one.
--- The Occurrence reliability is taken from the Bats attributes setup

INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Counting', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Type', 'Reptile Occurrence Type.', now(), 1, now(), 1, 'reptile:type');
SELECT insert_term('Dead specimen', 'eng', null, 'reptile:type');
SELECT insert_term('Slough', 'eng', null, 'reptile:type');
SELECT insert_term('Specimen', 'eng', null, 'reptile:type');
SELECT insert_term('Undetermined', 'eng', null, 'reptile:type');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='reptile:type');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:type'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Stage', 'Reptile Occurrence Stage.', now(), 1, now(), 1, 'reptile:stage');
SELECT insert_term('Egg', 'eng', null, 'reptile:stage');
SELECT insert_term('Juvenile', 'eng', null, 'reptile:stage');
SELECT insert_term('Adult', 'eng', null, 'reptile:stage');
SELECT insert_term('Undetermined', 'eng', null, 'reptile:stage');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='reptile:stage');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Stage', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:stage'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Sex', 'Reptile Occurrence Sex.', now(), 1, now(), 1, 'reptile:sex');
SELECT insert_term('Female', 'eng', null, 'reptile:sex');
SELECT insert_term('Male', 'eng', null, 'reptile:sex');
SELECT insert_term('Pair', 'eng', null, 'reptile:sex');
SELECT insert_term('Undetermined', 'eng', null, 'reptile:sex');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='reptile:sex');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Sex', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:sex'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Behaviour', 'Reptile Occurrence Behaviour.', now(), 1, now(), 1, 'reptile:behaviour');
SELECT insert_term('Basking', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Displaying', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Feeding', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Fighting', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Hunting', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Inactivity', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Lethargy', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Mating', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Ovipositing', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Resting', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Swimming', 'eng', null, 'reptile:behaviour');
SELECT insert_term('Undetermined', 'eng', null, 'reptile:behaviour');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='reptile:behaviour');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Behaviour', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:behaviour'), 'f', 't');

--- The following new Occurrence Attributes are used for Summer Bats: mnhnl_bats2
--- use 'Num alive', 'Num dead' from winter bats above: these will be used for the Maternity roost count
--- Standard Count attribute used for Dusk emergence
--- for a given species, there are 3 possibilities for a survey: (1) presence-absence recording, (2) count of individuals alive, (3) count of dead individuals 
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Emergence', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Faeces', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Cadaver', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'In maternity roost', 'B', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Emergence count', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Picture of Maternity Count', 'I', now(), 1, now(), 1, 'f', 't');


--- The following new Occurrence Attributes are used for Amphibian (Sites): uses the reptiles form
--- Standard occurrence reliability are used.
--- Sex from reptiles is used.
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Number', 'F', now(), 1, now(), 1, 'f', 't');
	
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Amphibian Type', 'Amphibian Type', now(), 1, now(), 1, 'amphibian:type');
SELECT insert_term('Clutch', 'eng', null, 'amphibian:type');
SELECT insert_term('Dead specimen', 'eng', null, 'amphibian:type');
SELECT insert_term('Specimen', 'eng', null, 'amphibian:type');
SELECT insert_term('Undetermined', 'eng', null, 'amphibian:type');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='amphibian:type');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Amphibian Type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='amphibian:type'), 'f', 't');

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Amphibian Stage', 'Amphibian Stage', now(), 1, now(), 1, 'amphibian:stage');
SELECT insert_term('Egg', 'eng', null, 'amphibian:stage');
SELECT insert_term('Larva', 'eng', null, 'amphibian:stage');
SELECT insert_term('Juvenile', 'eng', null, 'amphibian:stage');
SELECT insert_term('Adult', 'eng', null, 'amphibian:stage');
SELECT insert_term('Undetermined', 'eng', null, 'amphibian:stage');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='amphibian:stage');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Amphibian Stage', 'L', now(), 1, now(), 1, (select id from termlists where external_key='amphibian:stage'), 'f', 't');

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Amphibian Behaviour', 'Amphibian Behaviour', now(), 1, now(), 1, 'amphibian:behaviour');
SELECT insert_term('Basking', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Burrowing', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Calling', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Displaying', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Feeding', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Fighting', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Hunting', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Inactivity', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Lethargy', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Mating', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Migrating', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Ovipositing', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Resting', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Singing', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Swimming', 'eng', null, 'amphibian:behaviour');
SELECT insert_term('Undetermined', 'eng', null, 'amphibian:behaviour');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='amphibian:behaviour');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Amphibian Behaviour', 'L', now(), 1, now(), 1, (select id from termlists where external_key='amphibian:behaviour'), 'f', 't');

--- The following new Occurrence Attributes are used for Amphibian (Squares): uses the reptiles form
--- Most shared with Amphibian Sites.
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
  VALUES ('Units', 'Units', now(), 1, now(), 1, 'amphibian:units');
SELECT insert_term('m2', 'eng', null, 'amphibian:units');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='amphibian:units');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Units', 'L', now(), 1, now(), 1, (select id from termlists where external_key='amphibian:units'), 'f', 't');

	
--- The following new Occurrence Attributes are used for Dormice: mnhnl_mammals1
--- Standard count is used.
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Dormouse Type', 'Dormouse Type.', now(), 1, now(), 1, 'dormouse:type');
SELECT insert_term('Specimen', 'eng', null, 'dormouse:type');
SELECT insert_term('Nest', 'eng', null, 'dormouse:type');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='dormouse:type');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Dormouse type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='dormouse:type'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Dormouse Stage', 'Dormouse Stage.', now(), 1, now(), 1, 'dormouse:stage');
SELECT insert_term('Adult', 'eng', null, 'dormouse:stage');
SELECT insert_term('Pup', 'eng', null, 'dormouse:stage');
SELECT insert_term('?', 'eng', null, 'dormouse:stage');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='dormouse:stage');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Dormouse stage', 'L', now(), 1, now(), 1, (select id from termlists where external_key='dormouse:stage'), 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Dormouse Sex', 'Dormouse Sex.', now(), 1, now(), 1, 'dormouse:sex');
SELECT insert_term('M', 'eng', null, 'dormouse:sex');
SELECT insert_term('F', 'eng', null, 'dormouse:sex');
SELECT insert_term('?', 'eng', null, 'dormouse:sex');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='dormouse:sex');
INSERT INTO occurrence_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Dormouse sex', 'L', now(), 1, now(), 1, (select id from termlists where external_key='dormouse:sex'), 'f', 't');


