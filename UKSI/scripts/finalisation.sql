-- Following scripts fix errors due to script 3 & 4 which need debugging.
select
o.id, t.id as taxon_id, t.taxon, t.attribute, t.search_code, o.taxa_taxon_list_id, cttl.id as new_taxa_taxon_list_id
into temporary to_fix
from occurrences o
join taxa_taxon_lists ttl on ttl.id=o.taxa_taxon_list_id
join taxa t on t.id=ttl.taxon_id
join cache_taxa_taxon_lists cttl on cttl.search_code=t.search_code and cttl.taxon_list_id=ttl.taxon_list_id
where o.deleted=false
and (ttl.deleted=true or t.deleted=true)

update cache_occurrences_functional o set taxa_taxon_list_id=tf.new_taxa_taxon_list_id
from to_fix tf where tf.id=o.id;

-- Ensure occurrence cache taxonomy info is correct.
UPDATE cache_occurrences_functional o
SET
  preferred_taxa_taxon_list_id=cttl.preferred_taxa_taxon_list_id,
  taxa_taxon_list_external_key=cttl.external_key,
  taxon_meaning_id=cttl.taxon_meaning_id
FROM cache_taxa_taxon_lists cttl
WHERE cttl.id=o.taxa_taxon_list_id
AND (o.preferred_taxa_taxon_list_id <> cttl.preferred_taxa_taxon_list_id
  OR o.taxa_taxon_list_external_key <> cttl.external_key
  OR o.taxon_meaning_id <> cttl.taxon_meaning_id)
-- Run multiple times in batches of 1 million
AND o.id BETWEEN 0 AND 1000000;

-- Now, after updating all occurrence cache data it should hopefully be safe to clean up old meanings.
DELETE FROM taxon_meanings WHERE id IN (
  SELECT tm.id FROM taxon_meanings tm
  LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id=tm.id
  WHERE ttl.id IS NULL
);