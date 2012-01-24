-- after the following are set up, need to set their structure blocks (sample attributes), as well as their website allocation
-- also need to set the order by in the termlists, remembering that the sort order from the front end does not get carried forward to children: have to do direct in DB
-- have to set up the smaple attributes for CMS id, username and email.

--- Tab 1: Site
--- Nom du site : location name
INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'address', 'T', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'commune', 'T', now(), 1, now(), 1, 'f', 't'
);
--- Type de gîte :
--- Already defined for the winter bats. (SOME DIFFERENCES CONFIRM CAN USE SAME)
--- Type de gîte Other :
--- Already defined for the winter bats.
--- Pertinence for follw up
--- Already defined for the winter bats.

--- Tab 2: Conditions

--- Passage
--- Already defined for the winter bats.
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

--- Observateur(s)
--- Already defined for the winter bats.

--- Croquis du (des) trou(s) d’envol TBD
--- À faire au verso

Perturbations
Lumière artificielle éclairant le(s) trou(s) d’envol
Travaux de rénovation : en projet en cours récemment effectués
Autre : ……………………………………………………………………...
Conditions climatiques :
Température:
Vitesse du vent
Humidité de l’air
Couverture nuageuse
Précipitations : Aucune Bruine Averses

--- Fiabilité (exhaustivité) de l’inventaire : 1 - Fiable 2 – Peu fiable 3 – Non fiable
--- Already defined for the winter bats.

3. Espèces
Observations
Nombre d’individus
Espèce Type d’observation
Présence
Emergences Cadavres
……………………………...
Contrôle de présence
Comptage à l’émergence
Photographie
……………………………...

Aucune observation
Commentaires : ………………………………………………………………………………………………………
………………………………………………………………………………………………………………………..


----------------------------*********************************************___________________________
----------------------------*********************************************___________________________
----------------------------*********************************************___________________________
----------------------------*********************************************___________________________

INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'village', 'T', now(), 1, now(), 1, 'f', 't'
);

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
VALUES ('BatSiteType', 'Site Type', now(), 1, now(), 1, 'bats:sitetype');
SELECT insert_term('Arbre creux', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Hollow Tree', 'eng', null, 'bats:sitetype');
SELECT insert_term('Bunker', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Bunker', 'eng', null, 'bats:sitetype');
SELECT insert_term('Casemate', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Military Pillbox', 'eng', null, 'bats:sitetype');
SELECT insert_term('Cave', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Cavern', 'eng', null, 'bats:sitetype');
SELECT insert_term('Clocher', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Bell tower or Steeple', 'eng', null, 'bats:sitetype');
SELECT insert_term('Comble', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Loft', 'eng', null, 'bats:sitetype');
SELECT insert_term('Fort', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Fort', 'eng', null, 'bats:sitetype');
SELECT insert_term('Glacière', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Icehouse', 'eng', null, 'bats:sitetype');
SELECT insert_term('Grenier', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Granery', 'eng', null, 'bats:sitetype');
SELECT insert_term('Grotte ou faille naturelle', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Cave or natural fault', 'eng', null, 'bats:sitetype');
SELECT insert_term('Mine, carrière ou ardoisière', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Mine or quarry', 'eng', null, 'bats:sitetype');
SELECT insert_term('Nichoir', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Nest', 'eng', null, 'bats:sitetype');
SELECT insert_term('Souterrain artificiel', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Artificial underground', 'eng', null, 'bats:sitetype');
SELECT insert_term('Tunnel', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Tunnel', 'eng', null, 'bats:sitetype');
SELECT insert_term('Volet', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Shutter', 'eng', null, 'bats:sitetype');
SELECT insert_term('Autre', 'fra', null, 'bats:sitetype');
SELECT tmp_add_term('Other', 'eng', null, 'bats:sitetype');
INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'site type', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:sitetype'), 'f', 't'
);

INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'site type other', 'T', now(), 1, now(), 1, 'f', 't'
);

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatRegularFollowup', 'Suitablity for regular follow ups', now(), 1, now(), 1, 'bats:followup');
SELECT insert_term('Approprié', 'fra', null, 'bats:followup');
SELECT tmp_add_term('Appropriate', 'eng', null, 'bats:followup');
SELECT insert_term('Peu approprié', 'fra', null, 'bats:followup');
SELECT tmp_add_term('A bit appropriate', 'eng', null, 'bats:followup');
SELECT insert_term('Inapproprié', 'fra', null, 'bats:followup');
SELECT tmp_add_term('Inappropriate', 'eng', null, 'bats:followup');
INSERT INTO location_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'site followup', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:followup'), 'f', 't'
);

--- sample attributes
INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatVisit', 'Visit Number in Year', now(), 1, now(), 1, 'bats:visit');
SELECT insert_term('1/1', 'fra', null, 'bats:visit');
SELECT tmp_add_term('1 of 1', 'eng', null, 'bats:visit');
SELECT insert_term('1/2', 'fra', null, 'bats:visit');
SELECT tmp_add_term('1 of 2', 'eng', null, 'bats:visit');
SELECT insert_term('2/2', 'fra', null, 'bats:visit');
SELECT tmp_add_term('2 of 2', 'eng', null, 'bats:visit');
SELECT insert_term('1/3', 'fra', null, 'bats:visit');
SELECT tmp_add_term('1 of 3', 'eng', null, 'bats:visit');
SELECT insert_term('2/3', 'fra', null, 'bats:visit');
SELECT tmp_add_term('2 of 3', 'eng', null, 'bats:visit');
SELECT insert_term('3/3', 'fra', null, 'bats:visit');
SELECT tmp_add_term('3 of 3', 'eng', null, 'bats:visit');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Bat Visit', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:visit'), 'f', 't'
);

INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Observers', 'T', now(), 1, now(), 1, 'f', 't'
);

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatCavityOpening', 'Cavity Opening', now(), 1, now(), 1, 'bats:cavityopening');
SELECT insert_term('Fermeture artificielle', 'fra', null, 'bats:cavityopening');
SELECT tmp_add_term('Blocked Off', 'eng', null, 'bats:cavityopening');
SELECT insert_term('Imperméable au passage des chiroptères', 'fra', null, 'bats:cavityopening');
SELECT tmp_add_term('Impenetrable for bats', 'eng', null, 'bats:cavityopening');
SELECT insert_term('Système de fermeture défectueux', 'fra', null, 'bats:cavityopening');
SELECT tmp_add_term('Defective locking system', 'eng', null, 'bats:cavityopening');
SELECT insert_term('Entrée instable ou menacée d’obstruction', 'fra', null, 'bats:cavityopening');
SELECT tmp_add_term('Unstable entrance or entrance threatened with obstruction', 'eng', null, 'bats:cavityopening');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'cavity entrance', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:cavityopening'), 't', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'cavity entrance comment', 'T', now(), 1, now(), 1, 'f', 't'
);

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('BatDisturbances', 'List of Disturbances', now(), 1, now(), 1, 'bats:disturbances');
SELECT insert_term('Bruit', 'fra', null, 'bats:disturbances');
SELECT tmp_add_term('Noise', 'eng', null, 'bats:disturbances');
SELECT insert_term('Instabilité', 'fra', null, 'bats:disturbances');
SELECT tmp_add_term('Instability', 'eng', null, 'bats:disturbances');
SELECT insert_term('Vibrations', 'fra', null, 'bats:disturbances');
SELECT tmp_add_term('Vibrations', 'eng', null, 'bats:disturbances');
SELECT insert_term('Lumière artificielle', 'fra', null, 'bats:disturbances');
SELECT tmp_add_term('Artifical light', 'eng', null, 'bats:disturbances');
SELECT insert_term('Risques d’inondation temporaire', 'fra', null, 'bats:disturbances');
SELECT tmp_add_term('Risk of temporary flooding', 'eng', null, 'bats:disturbances');
SELECT insert_term('Présence de déchets toxiques', 'fra', null, 'bats:disturbances');
SELECT tmp_add_term('Toxic waste present', 'eng', null, 'bats:disturbances');
SELECT insert_term('Autre', 'fra', null, 'bats:disturbances');
SELECT tmp_add_term('Other', 'eng', null, 'bats:disturbances');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'disturbances', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:disturbances'), 't', 't'
);

INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'disturbances other comment', 'T', now(), 1, now(), 1, 'f', 't'
);

INSERT INTO termlists (title, description, created_on, created_by_id, updated_on, updated_by_id, external_key)
VALUES ('HumanFrequentation', 'Site Type', now(), 1, now(), 1, 'bats:humanfreq');
SELECT insert_term('Nulle', 'fra', null, 'bats:humanfreq');
SELECT tmp_add_term('None', 'eng', null, 'bats:humanfreq');
SELECT insert_term('Occasionnelle', 'fra', null, 'bats:humanfreq');
SELECT tmp_add_term('Occasional', 'eng', null, 'bats:humanfreq');
SELECT insert_term('Modérée', 'fra', null, 'bats:humanfreq');
SELECT tmp_add_term('Moderate', 'eng', null, 'bats:humanfreq');
SELECT insert_term('Intense', 'fra', null, 'bats:humanfreq');
SELECT tmp_add_term('Intense', 'eng', null, 'bats:humanfreq');
SELECT insert_term('Inconnue', 'fra', null, 'bats:humanfreq');
SELECT tmp_add_term('Unknown', 'eng', null, 'bats:humanfreq');
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, termlist_id, multi_value, public
) VALUES (
	'Human Frequentation', 'L', now(), 1, now(), 1, (select id from termlists where external_key='bats:humanfreq'), 'f', 't'
);

INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Temp Exterior', 'F', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Temp Int 1', 'F', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Temp Int 2', 'F', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Temp Int 3', 'F', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Humid Exterior', 'I', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Humid Int 1', 'I', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Humid Int 2', 'I', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Bats Humid Int 3', 'I', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO sample_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Positions Marked', 'B', now(), 1, now(), 1, 'f', 't'
);

-- Sample Reliability drop down set up by winter bats.
-- No Observation sample attribute defined in winter bats.

INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'sleepy', 'B', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'corpse', 'B', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'excrement', 'B', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Number: previous area', 'I', now(), 1, now(), 1, 'f', 't'
);
INSERT INTO occurrence_attributes (
	caption, data_type, created_on, created_by_id, updated_on, updated_by_id, multi_value, public
) VALUES (
	'Number: new area', 'I', now(), 1, now(), 1, 'f', 't'
);
