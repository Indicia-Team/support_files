-- Now, after updating all occurrence cache data it should hopefully be safe 
-- to clean up old meanings.
DELETE FROM taxon_meanings WHERE id IN (
  SELECT tm.id FROM taxon_meanings tm
  LEFT JOIN taxa_taxon_lists ttl ON ttl.taxon_meaning_id = tm.id
  WHERE ttl.id IS NULL
);