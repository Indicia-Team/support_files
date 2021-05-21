SET search_path=indicia, public;

-- Add IDs to the prepared taxa table as we will use them in the following
-- step to prepare taxa_taxon_lists.
UPDATE gbif.prepared_taxa
SET id=nextval('indicia.taxa_id_seq'::regclass),
WHERE id IS NULL;

-- Insert any missing taxa
INSERT INTO taxa(
  id,
  taxon,
  taxon_group_id,
  language_id,
  external_key,
  authority,
  search_code,
  scientific,
  taxon_rank_id,
  created_on,
  created_by_id,
  updated_on,
  updated_by_id
)
SELECT 
  id,
  taxon,
  taxon_group_id,
  language_id,
  external_key,
  authority,
  search_code,
  scientific,
  taxon_rank_id,
  now(),
  (SELECT value FROM gbif.settings WHERE key = 'updated_by_id'),
  now(),
  (SELECT value FROM gbif.settings WHERE key = 'updated_by_id'),
FROM gbif.prepared_taxa
WHERE id IS NULL
