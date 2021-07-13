SET search_path=indicia, public;

-- Remember the taxa_taxon_list changes so we can update the cache tables.
INSERT INTO gbif.changed_taxa_taxon_list_ids
SELECT DISTINCT pttl.id
FROM gbif.prepared_taxa_taxon_lists pttl
LEFT JOIN gbif.changed_taxa_taxon_list_ids ttldone ON ttldone.id = pttl.id
WHERE (pttl.changed = true OR pttl.is_new = true)
AND ttldone.id IS NULL;

-- Insert any missing taxa
INSERT INTO taxa_taxon_lists(
  id,
  taxon_list_id,
  taxon_id,
  parent_id,
  taxon_meaning_id,
  preferred,
  created_on,
  created_by_id,
  updated_on,
  updated_by_id
)
SELECT id,
  taxon_list_id,
  taxon_id,
  parent_id,
  taxon_meaning_id,
  preferred,
  now(),
  (SELECT value FROM gbif.settings WHERE key = 'updated_by_id'),
  now(),
  (SELECT value FROM gbif.settings WHERE key = 'updated_by_id')
FROM gbif.prepared_taxa_taxon_lists
WHERE is_new = true;