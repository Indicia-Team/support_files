SET search_path=indicia, public;

UPDATE uksi.prepared_taxa_taxon_lists pttl
SET common_taxon_id=cn.common_taxon_id,
  changed=pttl.changed OR COALESCE(pttl.orig_common_taxon_id, 0)<>cn.common_taxon_id
FROM uksi.common_name_mappings cn
WHERE pttl.id=cn.taxa_taxon_list_id
AND coalesce(pttl.common_taxon_id, 0)<>cn.common_taxon_id;

UPDATE uksi.prepared_taxa_taxon_lists pttl
SET changed=true
WHERE orig_common_taxon_id IS NOT NULL
AND common_taxon_id IS NULL
AND is_new=false;