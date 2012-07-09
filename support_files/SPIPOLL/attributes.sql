
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



INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Complete', 'B', now(), 1, now(), 1, 'f', 't'
);


INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Protocol', 'The format under which this collection was surveyed.', now(), 1, now(), 1, 'bees:protocol');
SELECT insert_term('Flash (une seule session photographique de 20mn)', 'fra', null, 'bees:protocol');
SELECT tmp_add_term('Flash (a single 20 minute photographic session)', 'eng', null, 'bees:protocol');
SELECT insert_term('Long (un ou plusieurs sessions photographiques de plus de 20mn sur 3 jour max.)', 'fra', null, 'bees:protocol');
SELECT tmp_add_term('Long (one or more photographic sessions of more than 20 minutes over a maximum of 3 days)', 'eng', null, 'bees:protocol');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Protocol', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bees:protocol'), 'f', 't'
);


INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Flower Type', 'How the flower got there', now(), 1, now(), 1, 'bees:flowertype');
SELECT insert_term('spontanée', 'fra', null, 'bees:flowertype');
SELECT tmp_add_term('Self seeded', 'eng', null, 'bees:flowertype');
SELECT insert_term('de culture', 'fra', null, 'bees:flowertype');
SELECT tmp_add_term('Cultivated', 'eng', null, 'bees:flowertype');
SELECT insert_term('ne se prononce pas', 'fra', null, 'bees:flowertype');
SELECT tmp_add_term('Don''t know', 'eng', null, 'bees:flowertype');
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Flower Type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bees:flowertype'), 'f', 't'
);


INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Habitat', 'Habitat description', now(), 1, now(), 1, 'bees:habitat');
SELECT insert_term('urbain', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('urban', 'eng', null, 'bees:habitat');
SELECT insert_term('péri-urbain', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('suburban', 'eng', null, 'bees:habitat');
SELECT insert_term('rural', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('Rural', 'eng', null, 'bees:habitat');
SELECT insert_term('grande(s) culture(s)', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('large cultivated area', 'eng', null, 'bees:habitat');
SELECT insert_term('forêt', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('Woodland', 'eng', null, 'bees:habitat');
SELECT insert_term('prairie', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('grassland/meadow', 'eng', null, 'bees:habitat');
SELECT insert_term('litoral', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('??????', 'eng', null, 'bees:habitat');
SELECT insert_term('parc ou jardin public', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('park or public garden', 'eng', null, 'bees:habitat');
SELECT insert_term('jardin privé', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('private garden', 'eng', null, 'bees:habitat');
SELECT insert_term('rochers', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('rocks', 'eng', null, 'bees:habitat');
SELECT insert_term('bord du route', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('beside a road', 'eng', null, 'bees:habitat');
SELECT insert_term('bord de l eau', 'fra', null, 'bees:habitat');
SELECT tmp_add_term('beside Water', 'eng', null, 'bees:habitat');
INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Habitat', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bees:habitat'), 't', 't'
);


INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Nearest Hive', 'I', now(), 1, now(), 1, 'f', 't'
);


INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, applies_to_location, multi_value, public, applies_to_recorder, validation_rules
) VALUES (
	'Start Time', 'T', now(), 1, now(), 1, 'f', 'f', 't', 't', 'regex[/^(2[0-3]|[0,1][0-9]):[0-5][0-9]$/]'
);

INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, applies_to_location, multi_value, public, applies_to_recorder, validation_rules
) VALUES (
	'End Time', 'T', now(), 1, now(), 1, 'f', 'f', 't', 't', 'regex[/^(2[0-3]|[0,1][0-9]):[0-5][0-9]$/]'
);



INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Sky', 'The cloud Cover during this session.', now(), 1, now(), 1, 'bees:sky');
SELECT insert_term('0-25%', 'fra', null, 'bees:sky');
SELECT tmp_add_term('0-25%', 'eng', null, 'bees:sky');
SELECT insert_term('25-50%', 'fra', null, 'bees:sky');
SELECT tmp_add_term('25-50%', 'eng', null, 'bees:sky');
SELECT insert_term('50-75%', 'fra', null, 'bees:sky');
SELECT tmp_add_term('50-75%', 'eng', null, 'bees:sky');
SELECT insert_term('75-100%', 'fra', null, 'bees:sky');
SELECT tmp_add_term('75-100%', 'eng', null, 'bees:sky');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Sky', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bees:sky'), 'f', 't'
);


INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Temperature Bands', 'The temperature during this session.', now(), 1, now(), 1, 'bees:temp');
SELECT insert_term('< 10C', 'fra', null, 'bees:temp');
SELECT tmp_add_term('< 10C, 50F', 'eng', null, 'bees:temp');
SELECT insert_term('10-20C', 'fra', null, 'bees:temp');
SELECT tmp_add_term('10-20C, 50-68F', 'eng', null, 'bees:temp');
SELECT insert_term('20-30C', 'fra', null, 'bees:temp');
SELECT tmp_add_term('20-30C, 68-86F', 'eng', null, 'bees:temp');
SELECT insert_term('> 30C', 'fra', null, 'bees:temp');
SELECT tmp_add_term('> 30C, 86F', 'eng', null, 'bees:temp');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Temperature', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bees:temp'), 'f', 't'
);


INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Wind', 'The wind during this session.', now(), 1, now(), 1, 'bees:wind');
SELECT insert_term('nul', 'fra', null, 'bees:wind');
SELECT tmp_add_term('calm', 'eng', null, 'bees:wind');
SELECT insert_term('faible, irregulier', 'fra', null, 'bees:wind');
SELECT tmp_add_term('weak, irregular', 'eng', null, 'bees:wind');
SELECT insert_term('faible, continu', 'fra', null, 'bees:wind');
SELECT tmp_add_term('weak, continuous', 'eng', null, 'bees:wind');
SELECT insert_term('fort, irregulier', 'fra', null, 'bees:wind');
SELECT tmp_add_term('strong, blustery', 'eng', null, 'bees:wind');
SELECT insert_term('fort, continu', 'fra', null, 'bees:wind');
SELECT tmp_add_term('strong, continuous', 'eng', null, 'bees:wind');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, applies_to_location, termlist_id, multi_value, public, applies_to_recorder
) VALUES (
	'Wind', 'L', now(), 1, now(), 1, 'f', (select id from termlists where external_key='bees:wind'), 'f', 't', 't'
);


INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, applies_to_location, multi_value, public, applies_to_recorder
) VALUES (
	'Shade', 'B', now(), 1, now(), 1, 'f', 'f', 't', 't'
);


INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Number Insects', 'The nuber of insects seen at one time.', now(), 1, now(), 1, 'bees:numInsects');
SELECT insert_term('1', 'fra', null, 'bees:numInsects');
SELECT tmp_add_term('1', 'eng', null, 'bees:numInsects');
SELECT insert_term('entre 2 et 5', 'fra', null, 'bees:numInsects');
SELECT tmp_add_term('2 - 5', 'eng', null, 'bees:numInsects');
SELECT insert_term('plus de 5', 'fra', null, 'bees:numInsects');
SELECT tmp_add_term('> 5', 'eng', null, 'bees:numInsects');
SELECT insert_term('je n''ai pas l''information', 'fra', null, 'bees:numInsects');
SELECT tmp_add_term('dont know', 'eng', null, 'bees:numInsects');
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Number Insects', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bees:numInsects'), 'f', 't'
);

INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Foraging', 'B', now(), 1, now(), 1, 'f', 't'
);
