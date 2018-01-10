UPDATE taxa_taxon_list_attribute_values av
SET taxa_taxon_list_id=ttlpref.id
FROM taxa_taxon_lists ttl
JOIN taxa_taxon_lists ttlpref
  ON ttlpref.taxon_meaning_id=ttl.taxon_meaning_id
  AND ttlpref.taxon_list_id=ttl.taxon_list_id
  AND ttlpref.preferred=true
WHERE ttl.id=av.taxa_taxon_list_id
AND ttl.preferred=false
AND ttl.deleted=false
AND av.deleted=false;