
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


