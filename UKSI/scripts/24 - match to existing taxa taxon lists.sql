SET search_path=indicia, public;

-- Match up all the existing taxa to the updated copies using the search_code|input_taxon_version_key.
-- We'll also grab the meaning ID for which we'll keep AS it is for existing preferred names. We also
-- grab the original taxon_meaning_id and original parent_id for all existing names though update them
-- later - grabbing the here just makes it easier to detect changes.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET id=ttl.id,
  taxon_meaning_id=CASE WHEN t.search_code=t.external_key THEN ttl.taxon_meaning_id ELSE NULL END,
  orig_preferred=ttl.preferred,
  orig_taxon_meaning_id=ttl.taxon_meaning_id,
  orig_parent_id=ttl.parent_id,
  orig_common_taxon_id=ttl.common_taxon_id
FROM taxa t
JOIN taxa_taxon_lists ttl
  ON ttl.taxon_id=t.id
  AND ttl.taxon_list_id=(SELECT uksi_taxon_list_id FROM uksi.uksi_settings)
  AND ttl.deleted=false
  AND ttl.allow_data_entry=true
WHERE t.search_code=pttl.input_taxon_version_key
AND t.deleted=false;