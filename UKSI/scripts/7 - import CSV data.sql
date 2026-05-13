-- 7 - import CSV data.sql (psql; simple & portable)
SET SESSION datestyle = 'ISO,DMY';
SET search_path = uksi, public;

BEGIN;

TRUNCATE preferred_names;
\copy preferred_names FROM '{{ data-path }}preferred_names.txt' CSV DELIMITER ',' QUOTE '"'

TRUNCATE all_names;
\copy all_names FROM '{{ data-path }}all_names.txt' CSV DELIMITER ','  QUOTE '"' ENCODING 'UTF8';

UPDATE all_names SET "language" = lower("language");

TRUNCATE taxon_groups;
\copy taxon_groups FROM '{{ data-path }}taxon_groups.txt' CSV DELIMITER ',' QUOTE '"'

TRUNCATE tcn_duplicates;
\copy tcn_duplicates FROM '{{ data-path }}tcn_duplicates.txt' CSV DELIMITER ',' QUOTE '"'

TRUNCATE all_designation_kinds;
\copy all_designation_kinds FROM '{{ data-path }}all_designation_kinds.txt' CSV DELIMITER ',' QUOTE '"'

TRUNCATE taxon_designations;
\copy taxon_designations FROM '{{ data-path }}taxon_designations.txt' CSV DELIMITER ',' QUOTE '"'

TRUNCATE taxa_taxon_designations;
\copy taxa_taxon_designations FROM '{{ data-path }}taxa_taxon_designations.txt' CSV DELIMITER ',' QUOTE '"'

TRUNCATE taxon_ranks;
\copy taxon_ranks FROM '{{ data-path }}taxon_ranks.txt' CSV DELIMITER ',' QUOTE '"'

TRUNCATE all_taxon_version_keys;
\copy all_taxon_version_keys FROM '{{ data-path }}all_taxon_version_keys.txt' CSV DELIMITER ',' QUOTE '"'

-- Indexes (idempotent)
CREATE INDEX IF NOT EXISTS ix_all_names_recommended_tvk ON all_names(recommended_taxon_version_key);
CREATE INDEX IF NOT EXISTS ix_all_names_organism_key     ON all_names(organism_key);
CREATE INDEX IF NOT EXISTS ix_all_names_input_tvk        ON all_names(input_taxon_version_key);

-- Stats refresh
ANALYZE uksi.preferred_names;
ANALYZE uksi.all_names;
ANALYZE uksi.taxon_groups;
ANALYZE uksi.tcn_duplicates;
ANALYZE uksi.all_designation_kinds;
ANALYZE uksi.taxon_designations;
ANALYZE uksi.taxa_taxon_designations;
ANALYZE uksi.taxon_ranks;
ANALYZE uksi.all_taxon_version_keys;

COMMIT;