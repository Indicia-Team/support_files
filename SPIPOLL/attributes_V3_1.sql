
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


INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('YesNoDontKnow', 'Generic Yes Ne Dont Know Termlist', now(), 1, now(), 1, 'bees:YesNoDontKnow');
SELECT insert_term('Oui', 'fra', null, 'bees:YesNoDontKnow');
SELECT tmp_add_term('Yes', 'eng', null, 'bees:YesNoDontKnow');
SELECT insert_term('Non', 'fra', null, 'bees:YesNoDontKnow');
SELECT tmp_add_term('No', 'eng', null, 'bees:YesNoDontKnow');
SELECT insert_term('Ne se prononce pas', 'fra', null, 'bees:YesNoDontKnow');
SELECT tmp_add_term('Don''t know', 'eng', null, 'bees:YesNoDontKnow');

INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'within50m', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bees:YesNoDontKnow'), 'f', 't'
);
INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Location Photo Camera', 'T', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Location Photo DateTime', 'T', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Occurrence Photo Camera', 'T', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Occurrence Photo DateTime', 'T', now(), 1, now(), 1, 'f', 't'
);




