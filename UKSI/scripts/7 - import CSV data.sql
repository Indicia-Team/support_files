SET SESSION datestyle = 'ISO,DMY';

SET search_path=uksi, public;

TRUNCATE uksi.preferred_names;
COPY preferred_names FROM '{{ data-path }}preferred_names.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

TRUNCATE uksi.all_names;
COPY all_names FROM '{{ data-path }}all_names.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

UPDATE uksi.all_names SET language=lower(language);

TRUNCATE uksi.taxon_groups;
COPY taxon_groups FROM '{{ data-path }}taxon_groups.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

TRUNCATE uksi.tcn_duplicates;
COPY tcn_duplicates FROM '{{ data-path }}tcn_duplicates.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

TRUNCATE uksi.all_designation_kinds;
COPY all_designation_kinds FROM '{{ data-path }}all_designation_kinds.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

TRUNCATE uksi.taxon_designations;
COPY taxon_designations FROM '{{ data-path }}taxon_designations.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

TRUNCATE uksi.taxa_taxon_designations;
COPY taxa_taxon_designations FROM '{{ data-path }}taxa_taxon_designations.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

TRUNCATE uksi.taxon_ranks;
COPY taxon_ranks FROM '{{ data-path }}taxon_ranks.txt' DELIMITERS ',' QUOTE '"' ENCODING 'ISO-8859-1' CSV;

CREATE INDEX ix_all_names_recommended_tvk ON uksi.all_names(recommended_taxon_version_key);
CREATE INDEX ix_all_names_input_tvk ON uksi.all_names(input_taxon_version_key);