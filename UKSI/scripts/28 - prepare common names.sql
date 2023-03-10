SET search_path=indicia, public;

DROP TABLE IF EXISTS uksi.common_name_mappings;

/* Indexes for performance */
CREATE INDEX ix_prepared_taxa_taxon_lists_taxon_id ON uksi.prepared_taxa_taxon_lists(taxon_id);
CREATE INDEX ix_prepared_taxa_id ON uksi.prepared_taxa(id);
CREATE INDEX ix_prepared_taxa_search_code ON uksi.prepared_taxa(search_code);
CREATE INDEX ix_tcn_duplicates_organism_key On uksi.tcn_duplicates(organism_key);

/*
 * Create a mapping from the taxa taxon list ID to a common name's taxon ID.
 * This is done by getting a list of taxa taxon list IDs against all common
 * English names, then sorting in order of preference and using DISTINCT ON
 * to grab only the top name.
 */
SELECT DISTINCT ON (ttl.id) ttl.id AS taxa_taxon_list_id, tc.id AS common_taxon_id
INTO uksi.common_name_mappings
FROM uksi.prepared_taxa_taxon_lists ttl
JOIN uksi.prepared_taxa t on t.id=ttl.taxon_id
-- Find all English vernacular names.
JOIN uksi.all_names an
  ON an.recommended_taxon_version_key=t.external_key
  AND an.organism_key=t.organism_key
  AND an.taxon_type='V' AND an.language='en'
  -- No redundant names.
  AND an.redundant=false
JOIN uksi.prepared_taxa tc on tc.search_code=an.input_taxon_version_key
JOIN uksi.prepared_taxa_taxon_lists ttlc on ttlc.taxon_id=tc.id and ttlc.taxon_list_id=ttl.taxon_list_id
-- Find any common names explicitly determined by tcn_duplicates.
LEFT JOIN uksi.preferred_names pn on pn.taxon_version_key=t.external_key
LEFT JOIN uksi.tcn_duplicates td ON td.organism_key=pn.organism_key
ORDER BY
  ttl.id,
  -- Sort order puts the best candidate first, so DISTINCT ON picks the correct common name.
  -- Explicitly mentioned in tcn_duplicates = 1st priority.
  an.input_taxon_version_key=td.taxon_version_key DESC,
  -- Well formed names priority
  an.taxon_version_form='W' DESC,
  -- Recommended name in taxon version status = 2nd priority.
  an.taxon_version_status='R' DESC,
  -- Ensure result is deterministic
  tc.id;