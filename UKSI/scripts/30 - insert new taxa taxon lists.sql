SET search_path=indicia, public;

-- Remember the taxa_taxon_list changes so we can update the cache tables.
INSERT INTO uksi.changed_taxa_taxon_list_ids
SELECT DISTINCT pttl.id
FROM uksi.prepared_taxa_taxon_lists pttl
LEFT JOIN uksi.changed_taxa_taxon_list_ids ttldone ON ttldone.id=pttl.id
WHERE (pttl.changed=true OR pttl.is_new=true)
AND ttldone.id IS NULL;

-- Insert any missing taxa
INSERT INTO taxa_taxon_lists(
  id,
  taxon_list_id,
  taxon_id,
  parent_id,
  taxon_meaning_id,
  taxonomic_sort_order,
  preferred,
  common_taxon_id,
  allow_data_entry,
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
  taxonomic_sort_order,
  preferred,
  common_taxon_id,
  allow_data_entry,
  now(),
  (select updated_by_user_id from uksi.uksi_settings),
  now(),
  (select updated_by_user_id from uksi.uksi_settings)
FROM uksi.prepared_taxa_taxon_lists
WHERE is_new=true;