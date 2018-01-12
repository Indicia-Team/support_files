SET search_path=uksi, public;

-- Table: uksi.preferred_names

DROP TABLE IF EXISTS preferred_names;

CREATE TABLE preferred_names
(
  organism_key character(16),
  taxon_version_key character(16),
  item_name character varying,
  authority character varying,
  parent_tvk character(16),
  parent_key character(16),
  taxon_rank_key character(16),
  sequence integer, -- Taxon rank sequence
  long_name character varying, -- Taxon rank name
  short_name character varying(10),
  marine_flag boolean,
  terrestrial_freshwater_flag boolean,
  sort_code integer
)
WITH (
  OIDS=FALSE
);

-- Table: all_names

DROP TABLE IF EXISTS all_names;

CREATE TABLE all_names
(
  recommended_taxon_version_key character(16),
  input_taxon_version_key character(16),
  item_name character varying,
  authority character varying,
  taxon_version_form character(1), -- U = unverified, I=irregular, W=well-formed
  taxon_version_status character(1),
  taxon_type character(1),
  "language" character(2),
  output_group_key character(16),
  rank character varying,
  attribute character varying(100),
  short_name character varying
)
WITH (
  OIDS=FALSE
);

-- Table: uksi.taxon_groups

DROP TABLE IF EXISTS taxon_groups;

CREATE TABLE taxon_groups
(
  taxon_group_key character(16),
  taxon_group_name character varying,
  description character varying,
  parent character(16)
)
WITH (
  OIDS=FALSE
);

-- Table: uksi.tcn_duplicates

DROP TABLE IF EXISTS tcn_duplicates;

CREATE TABLE tcn_duplicates
(
  organism_key character(16),
  taxon_version_key character(16)
)
WITH (
  OIDS=FALSE
);

-- Table: uksi.all_designation_kinds

DROP TABLE IF EXISTS all_designation_kinds;

CREATE TABLE all_designation_kinds
(
  taxon_designation_type_kind_key character(16),
  kind character varying
)
WITH (
  OIDS=FALSE
);

-- Table: uksi.taxon_designations

DROP TABLE IF EXISTS taxon_designations;

CREATE TABLE taxon_designations
(
  taxon_designation_type_key character(16),
  short_name character varying,
  long_name character varying,
  description character varying,
  kind character varying,
  status_abbreviation character varying
)
WITH (
  OIDS=FALSE
);

-- Table: uksi.taxa_taxon_designations

DROP TABLE IF EXISTS taxa_taxon_designations;

CREATE TABLE taxa_taxon_designations
(
  short_name character varying,
  date_from date,
  date_to date,
  status_geographic_area character varying,
  detail character varying,
  recommended_taxon_version_key character(16)
)
WITH (
  OIDS=FALSE
);

-- Table: uksi.taxon_ranks

DROP TABLE IF EXISTS taxon_ranks;

CREATE TABLE taxon_ranks
(
  sort_order integer,
  short_name character varying,
  long_name character varying,
  list_font_italic integer -- capture 0 or 1 and convert to bool later
)
WITH (
  OIDS=FALSE
);

-- Table: uksi.all_taxon_version_keys

DROP TABLE IF EXISTS all_taxon_version_keys;

CREATE TABLE all_taxon_version_keys
(
  input_taxon_version_key character(16),
  recommended_taxon_version_key character(16)
)
WITH (
  OIDS=FALSE
);