SET search_path=indicia, public;

DROP TABLE IF EXISTS uksi.common_name_mappings;

/*
 * Create a mapping from the taxa taxon list ID to a common name's taxon ID.
 * This is done by getting a list of taxa taxon list IDs against all common
 * English names, then sorting in order of preference and using DISTINCT ON
 * to grab only the top name.
 */
SELECT DISTINCT ON (sub.taxa_taxon_list_id) *
INTO uksi.common_name_mappings
FROM (
  SELECT ttl.id AS taxa_taxon_list_id, tc.id AS common_taxon_id
  FROM uksi.prepared_taxa_taxon_lists ttl
  JOIN uksi.prepared_taxa t on t.id=ttl.taxon_id
  -- Find all English vernacular names.
  JOIN uksi.all_names an
    ON an.recommended_taxon_version_key=t.external_key
    AND an.taxon_type='V' AND an.language='en'
  JOIN uksi.prepared_taxa tc on tc.search_code=an.input_taxon_version_key
  -- Find any common names explicitly determined by tcn_duplicates.
  LEFT JOIN uksi.preferred_names pn on pn.taxon_version_key=t.external_key
  LEFT JOIN uksi.tcn_duplicates td ON td.organism_key=pn.organism_key
  ORDER BY
    -- Explicitly mentioned in tcn_duplicates = 1st priority
    an.input_taxon_version_key=td.taxon_version_key DESC,
    -- Recommended name in taxon version status = 2nd priority
    an.taxon_version_status='R' desc
) AS sub;