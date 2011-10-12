--- MNHNL Location types.
SELECT insert_term('Lux5KSquare', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('LizardLocation', 'eng', null, 'mnhnl:loctype');

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Survey 1', 'Reptile Single Survey.', now(), 1, now(), 1, 'reptile:survey1');
SELECT insert_term('1', 'eng', null, 'reptile:survey1');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Reptile Survey 1', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:survey1'), 'f', 't'
);
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Survey 2', 'Reptile Twin Survey.', now(), 1, now(), 1, 'reptile:survey2');
SELECT insert_term('1', 'eng', null, 'reptile:survey2');
SELECT insert_term('2', 'eng', null, 'reptile:survey2');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Reptile Survey 2', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:survey2'), 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Duration', 'I', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Suitability Checkbox', 'B', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Picture Provided', 'B', now(), 1, now(), 1, 'f', 't'
);
--- for temperature use the standard temp, enforce integer validation
--- for clouds use the butterfly clouds: sample attribute 'Cloud Cover'
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Rain Checkbox', 'B', now(), 1, now(), 1, 'f', 't'
);

INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Count', 'I', now(), 1, now(), 1, 'f', 't'
);
--- for Reliability, will use the termlist 'bats:reliability'
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Occurrence Reliability', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:reliability'), 'f', 't'
);
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Counting', 'B', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Type', 'Reptile Occurrence Type.', now(), 1, now(), 1, 'reptile:type');
SELECT insert_term('Dead specimen', 'eng', null, 'reptile:type');
SELECT insert_term('Slough', 'eng', null, 'reptile:type');
SELECT insert_term('Specimen', 'eng', null, 'reptile:type');
SELECT insert_term('Undetermined', 'eng', null, 'reptile:type');
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Reptile Occurrence Type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:type'), 'f', 't'
);
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Stage', 'Reptile Occurrence Stage.', now(), 1, now(), 1, 'reptile:stage');
SELECT insert_term('Egg', 'eng', null, 'reptile:stage');
SELECT insert_term('Juvenile', 'eng', null, 'reptile:stage');
SELECT insert_term('Adult', 'eng', null, 'reptile:stage');
SELECT insert_term('Undetermined', 'eng', null, 'reptile:stage');
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Reptile Occurrence Stage', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:stage'), 'f', 't'
);
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Reptile Sex', 'Reptile Occurrence Stage.', now(), 1, now(), 1, 'reptile:sex');
SELECT insert_term('Female', 'eng', null, 'reptile:sex');
SELECT insert_term('Male', 'eng', null, 'reptile:sex');
SELECT insert_term('Pair', 'eng', null, 'reptile:sex');
SELECT insert_term('Undetermined', 'eng', null, 'reptile:sex');
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Reptile Occurrence Sex', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:sex'), 'f', 't'
);

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
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Reptile Occurrence Behaviour', 'L', now(), 1, now(), 1, (select id from termlists where external_key='reptile:behaviour'), 'f', 't'
);

