SET search_path=indicia, public;

-- Match up all the existing taxa to the updated copies using the search_code|input_taxon_version_key.
-- We'll also grab the meaning ID for which we'll keep AS it is for existing preferred names. We also
-- grab the original taxon_meaning_id and original parent_id for all existing names though update them
-- later - grabbing the here just makes it easier to detect changes.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET id=ttl.id,
  taxon_meaning_id=CASE
    -- keep the taxon meaning if it's a preferred name both before and after the update.
    WHEN t.search_code=t.external_key AND ttl.preferred=true THEN ttl.taxon_meaning_id
    ELSE NULL
  END,
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

-- Because there might be mistakes in the old data, we need to make sure any cases where a taxon meaning ID is shared
-- across names which are pointing to different concepts do end up with different taxon meanings IDs. This particularly
-- applies to the agrigultural breed names. So, we clear all but the last taxon meaning ID in groups of names which
-- share the meaning ID but not the recommended TVK. Any cleared will get a new one in a moment.
UPDATE uksi.prepared_taxa_taxon_lists to_clear
SET taxon_meaning_id=NULL
FROM uksi.prepared_taxa_taxon_lists to_keep
ON to_keep.taxon_meaning_id=to_clear.taxon_meaning_id
AND to_keep.recommended_taxon_version_key <> to_clear.recommended_taxon_version_key
AND to_keep.id<to_clear.id;