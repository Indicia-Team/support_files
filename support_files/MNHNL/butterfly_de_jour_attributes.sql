--- use standard count, though make sure not required.

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Butterfly de Jour Passage', 'Survey month', now(), 1, now(), 1, 'butterfly2:Passage');
SELECT insert_term('Mai', 'fra', null, 'butterfly2:Passage'); 
SELECT tmp_add_term('May', 'eng', null, 'butterfly2:Passage');
SELECT insert_term('Juin', 'fra', null, 'butterfly2:Passage'); 
SELECT tmp_add_term('June', 'eng', null, 'butterfly2:Passage');
SELECT insert_term('Juillet', 'fra', null, 'butterfly2:Passage'); 
SELECT tmp_add_term('July', 'eng', null, 'butterfly2:Passage');
SELECT insert_term('Août', 'fra', null, 'butterfly2:Passage'); 
SELECT tmp_add_term('August', 'eng', null, 'butterfly2:Passage');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'MNHNL Butterfly de Jour Passage', 'L', now(), 1, now(), 1, (select id from termlists where external_key='butterfly2:Passage'), 'f', 't'
);

--- start time may already exist
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, applies_to_location, multi_value, public, applies_to_recorder, validation_rules) VALUES (
	'Start Time', 'T', now(), 1, now(), 1, 'f', 'f', 't', 't', 'regex[/^(2[0-3]|[0,1][0-9]):[0-5][0-9]$/]');
--- duration may already exist
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
			'Duration', 'I', now(), 1, now(), 1, 'f', 't');
--- Temperature already exists
--- Numeric Windspeed
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
			'Numeric Windspeed', 'I', now(), 1, now(), 1, 'f', 't');
--- Pluie may already exist
INSERT INTO sample_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Rain Checkbox', 'B', now(), 1, now(), 1, 'f', 't');
--- for clouds use the butterfly clouds: sample attribute 'Cloud Cover'
--- Reliability already exists : use Bats survey reliability