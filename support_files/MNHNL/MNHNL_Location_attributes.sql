--- Sample Attributes must be loaded first.

--- MNHNL Location types.
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('LocationTypes', 'MNHNL Location types', now(), 1, now(), 1, 'mnhnl:loctype');
SELECT insert_term('Lux5KSquare', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('ReptileLocation', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('WinterBats Confirmed', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('WinterBats Submitted', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('Butterflies2', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('Summer Bats Submitted', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('Summer Bats Confirmed', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('Lux1KSquare', 'eng', null, 'mnhnl:loctype');
SELECT insert_term('Dormice', 'eng', null, 'mnhnl:loctype');

-- after the following are set up, need to set their structure blocks (sample attributes), as well as their website allocation

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

--- There are no new Location Attributes used for COBIMO: Common Bird Monitoring: mnhnl_bird_transect_walks
--- There are no new Location Attributes used for Butterflies1: Butterfly Monitoring: mnhnl_butterflies

--- The following new Location Attributes are used for Winter Bats: mnhnl_bats

INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Village', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Commune', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatSiteType', 'Site Type', now(), 1, now(), 1, 'bats:sitetype');
SELECT insert_term('Hollow tree', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Arbre creux', 'fra', null, 'bats:sitetype');
SELECT insert_term('Slate quarry', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Ardoisière', 'fra', null, 'bats:sitetype');
SELECT insert_term('Bunker', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Bunker', 'fra', null, 'bats:sitetype');
SELECT insert_term('Underground quarry', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Carrière souterraine', 'fra', null, 'bats:sitetype');
SELECT insert_term('Military pillbox', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Casemate', 'fra', null, 'bats:sitetype');
SELECT insert_term('Cellar', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Cave', 'fra', null, 'bats:sitetype');
SELECT insert_term('Bell tower or steeple', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Clocher', 'fra', null, 'bats:sitetype');
SELECT insert_term('Loft', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Comble', 'fra', null, 'bats:sitetype');
SELECT insert_term('Fort', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Fort', 'fra', null, 'bats:sitetype');
SELECT insert_term('Icehouse', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Glacière', 'fra', null, 'bats:sitetype');
SELECT insert_term('Granery', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Grenier', 'fra', null, 'bats:sitetype');
SELECT insert_term('Natural cave or fault', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Grotte ou faille naturelle', 'fra', null, 'bats:sitetype');
SELECT insert_term('Semi-natural cave or fault', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Grotte ou faille semi-naturelle', 'fra', null, 'bats:sitetype');
SELECT insert_term('Mine', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Mine', 'fra', null, 'bats:sitetype');
SELECT insert_term('Nestbox', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Nichoir', 'fra', null, 'bats:sitetype');
SELECT insert_term('Artificial underground', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Souterrain artificiel', 'fra', null, 'bats:sitetype');
SELECT insert_term('Tunnel', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Tunnel', 'fra', null, 'bats:sitetype');
SELECT insert_term('Shutter', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Volet', 'fra', null, 'bats:sitetype');
SELECT insert_term('Other', 'eng', null, 'bats:sitetype');
SELECT tmp_add_term('Autre', 'fra', null, 'bats:sitetype');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats:sitetype');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Site type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:sitetype'), 'f', 't');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Site type other', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Precision', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Code GSL', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Depth', 'I', now(), 1, now(), 1, 'f', 't');
INSERT INTO location_attributes (	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Development', 'I', now(), 1, now(), 1, 'f', 't');

--- There are no new Location Attributes used for Butterflies2: Butterfly de Jours: mnhnl_butterflies2
--- But it does use a termlist for the location names.

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('MNHNL Butterfly de Jour Sites', 'Site Names', now(), 1, now(), 1, 'butterfly2:Sites');
SELECT insert_term('1', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('2', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('3', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('4', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('5', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('6', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('7', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('8', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('9', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('10', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('11', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('12', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('13', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('14', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('15', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('16', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('17', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('18', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('19', 'eng', null, 'butterfly2:Sites'); 
SELECT insert_term('20', 'eng', null, 'butterfly2:Sites'); 
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='butterfly2:Sites');

--- The following new Location Attributes are used for Reptiles: mnhnl_reptiles

INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Creator', 'T', now(), 1, now(), 1, 'f', 't');

--- The following new Location Attributes are used for Summer Bats: mnhnl_bats2
--- Commune, village and Precision are used from the Bats form.
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Address Number', 'T', now(), 1, now(), 1, 'f', 't');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public) VALUES (
	'Street', 'T', now(), 1, now(), 1, 'f', 't');
--- Commune is used from Winter Bats
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('Bat2SiteType', 'Site Type 2', now(), 1, now(), 1, 'bats2:sitetype');
SELECT insert_term('Hollow tree', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Bunker', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Cellar', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Bell tower or steeple', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Loft', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Fort', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Granery', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Nestbox', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Tunnel', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Shutter', 'eng', null, 'bats2:sitetype');
SELECT insert_term('Other', 'eng', null, 'bats2:sitetype');
UPDATE termlists_terms SET sort_order = 10*id WHERE termlist_id = (SELECT id FROM termlists WHERE external_key='bats2:sitetype');
INSERT INTO location_attributes (caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public) VALUES (
	'Site type2', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats2:sitetype'), 'f', 't');
--- Site type other from Bats1


	