SET SESSION datestyle = 'ISO,DMY';

SET search_path=uksi, public;

TRUNCATE preferred_names;
COPY preferred_names FROM '{{ data-path }}preferred_names.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

TRUNCATE all_names;
COPY all_names FROM '{{ data-path }}all_names.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

UPDATE all_names SET language=lower(language);

TRUNCATE taxon_groups;
COPY taxon_groups FROM '{{ data-path }}taxon_groups.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

TRUNCATE tcn_duplicates;
COPY tcn_duplicates FROM '{{ data-path }}tcn_duplicates.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

TRUNCATE all_designation_kinds;
COPY all_designation_kinds FROM '{{ data-path }}all_designation_kinds.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

TRUNCATE taxon_designations;
COPY taxon_designations FROM '{{ data-path }}taxon_designations.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

TRUNCATE taxa_taxon_designations;
COPY taxa_taxon_designations FROM '{{ data-path }}taxa_taxon_designations.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

TRUNCATE taxon_ranks;
COPY taxon_ranks FROM '{{ data-path }}taxon_ranks.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

TRUNCATE all_taxon_version_keys;
COPY all_taxon_version_keys FROM '{{ data-path }}all_taxon_version_keys.txt' DELIMITERS ',' QUOTE '"' ENCODING 'UTF-8' CSV;

CREATE INDEX ix_all_names_recommended_tvk ON all_names(recommended_taxon_version_key);
CREATE INDEX ix_all_names_input_tvk ON all_names(input_taxon_version_key);