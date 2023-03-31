SET search_path=indicia, public;

-- Store the original organism key for each search code (input taxon version key).
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET orig_organism_key=t.organism_key
FROM taxa t
JOIN taxa_taxon_lists ttl ON ttl.taxon_id=t.id AND ttl.deleted=false AND ttl.taxon_list_id=(select uksi_taxon_list_id from uksi.uksi_settings)
WHERE t.search_code=pttl.input_taxon_version_key;

-- Match up all the existing taxa to the updated copies using the search_code|input_taxon_version_key.
-- We'll also grab the meaning ID for which we'll keep AS it is for existing preferred names. We also
-- grab the original taxon_meaning_id and original parent_id for all existing names though update them
-- later - grabbing the here just makes it easier to detect changes.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET id=ttl.id,
  taxon_meaning_id=ttl.taxon_meaning_id,
  orig_preferred=ttl.preferred,
  orig_taxon_meaning_id=ttl.taxon_meaning_id,
  orig_parent_id=ttl.parent_id,
  orig_common_taxon_id=ttl.common_taxon_id,
  changed=changed OR ttl.allow_data_entry<>pttl.allow_data_entry
FROM taxa t
JOIN taxa_taxon_lists ttl
  ON ttl.taxon_id=t.id
  AND ttl.deleted=false
WHERE t.search_code=pttl.input_taxon_version_key
AND t.organism_key=pttl.organism_key
AND t.deleted=false
AND ttl.taxon_list_id=pttl.taxon_list_id;