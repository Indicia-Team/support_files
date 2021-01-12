SET search_path=indicia, public;

-- Update existing taxa which have changed
UPDATE taxa_taxon_lists ttl
SET taxon_list_id=pttl.taxon_list_id,
  taxon_id=pttl.taxon_id,
  parent_id=pttl.parent_id,
  taxon_meaning_id=pttl.taxon_meaning_id,
  taxonomic_sort_order=pttl.taxonomic_sort_order,
  preferred=pttl.preferred,
  common_taxon_id=pttl.common_taxon_id,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings),
  allow_data_entry=pttl.allow_data_entry
FROM uksi.prepared_taxa_taxon_lists pttl
WHERE pttl.id=ttl.id
AND pttl.changed=true
AND pttl.is_new=false;