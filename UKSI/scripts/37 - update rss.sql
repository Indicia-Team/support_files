SET SESSION datestyle = 'ISO,DMY';
SET search_path=public;

-- Table: uksi.recording_schemes

DROP TABLE IF EXISTS uksi.recording_schemes;

CREATE TABLE uksi.recording_schemes
(
  scheme_key varchar,
  scheme_name varchar
)
WITH (
  OIDS=FALSE
);

TRUNCATE uksi.recording_schemes;
COPY uksi.recording_schemes FROM '{{ data-path }}recording_schemes.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

-- Table: uksi.recording_scheme_taxa

DROP TABLE IF EXISTS uksi.recording_scheme_taxa;

CREATE TABLE uksi.recording_scheme_taxa
(
  scheme_key varchar,
  organism_key varchar
)
WITH (
  OIDS=FALSE
);

TRUNCATE uksi.recording_scheme_taxa;
COPY uksi.recording_scheme_taxa FROM '{{ data-path }}recording_scheme_taxa.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

-- Populate indicia.recording_schemes - new schemes
INSERT INTO indicia.recording_schemes(
  external_key,
  title,
  created_on,
  created_by_id,
  updated_on,
  updated_by_id,
  deleted
)
SELECT
  scheme_key,
  scheme_name,
  now(),
  (SELECT updated_by_user_id FROM uksi.uksi_settings),
  now(),
  (SELECT updated_by_user_id FROM uksi.uksi_settings),
  FALSE
FROM uksi.recording_schemes u
WHERE u.scheme_key NOT IN (SELECT external_key FROM indicia.recording_schemes WHERE deleted = false);

-- Populate indicia.recording_schemes - modified schemes
UPDATE indicia.recording_schemes irs
SET title = urs.scheme_name,
	updated_by_id = (SELECT updated_by_user_id FROM uksi.uksi_settings),
	updated_on = now()
FROM uksi.recording_schemes urs
WHERE urs.scheme_key = irs.external_key
AND urs.scheme_name <> irs.title
AND irs.deleted = FALSE;

-- Populate indicia.recording_schemes - deleted schemes
UPDATE indicia.recording_schemes
SET updated_by_id = (SELECT updated_by_user_id FROM uksi.uksi_settings),
	updated_on = now(),
	deleted = TRUE
WHERE external_key NOT IN (SELECT scheme_key FROM uksi.recording_schemes);

-- Populate uksi.recording_scheme_taxa - new scheme taxa
INSERT INTO indicia.recording_scheme_taxa(
  recording_scheme_id,
  organism_key,
  created_on,
  created_by_id,
  updated_on,
  updated_by_id,
  deleted
)
SELECT
  irs.id,
  urst.organism_key,
  now(),
  (SELECT updated_by_user_id FROM uksi.uksi_settings),
  now(),
  (SELECT updated_by_user_id FROM uksi.uksi_settings),
  FALSE
FROM uksi.recording_scheme_taxa urst
JOIN indicia.recording_schemes irs ON irs.external_key = urst.scheme_key AND irs.deleted = FALSE
WHERE NOT EXISTS (
	SELECT TRUE FROM indicia.recording_scheme_taxa irst
	WHERE irst.recording_scheme_id = irs.id
	AND irst.organism_key = urst.organism_key
	AND irst.deleted = false
);

-- Populate indicia.recording_scheme_taxa - deleted scheme taxa
UPDATE indicia.recording_scheme_taxa
SET updated_by_id = (SELECT updated_by_user_id FROM uksi.uksi_settings),
	updated_on = now(),
	deleted = TRUE
FROM indicia.recording_scheme_taxa irst
JOIN indicia.recording_schemes irs ON irs.id = irst.recording_scheme_id
WHERE NOT EXISTS (
	SELECT TRUE FROM uksi.recording_scheme_taxa urst
	WHERE urst.scheme_key = irs.external_key
	AND urst.organism_key = irst.organism_key
);