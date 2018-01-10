SET search_path=indicia, public;

-- Grab the ID of the parent taxa_taxon_list record accoring to the parent_tvk. Use the orig_parent_id to
-- detect if it's an actual change.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET parent_id=pttlp.id,
  changed=pttl.changed OR pttlp.id<>COALESCE(pttl.orig_parent_id, 0)
FROM taxa tp
JOIN uksi.prepared_taxa_taxon_lists pttlp
  ON pttlp.taxon_id=tp.id
WHERE tp.search_code=pttl.parent_search_code
AND pttlp.taxon_list_id=pttl.taxon_list_id;

-- Ensure the parent ID is clear where it should be.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET parent_id=NULL,
  changed=changed OR orig_parent_id IS NOT NULL
WHERE parent_search_code IS NULL;