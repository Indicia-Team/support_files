SET search_path=indicia, public;

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
  attribute,
  marine_flag,
  created_on,
  created_by_id,
  updated_on,
  updated_by_id
)
SELECT id,
  taxon,
  taxon_group_id,
  language_id,
  external_key,
  authority,
  search_code,
  scientific,
  taxon_rank_id,
  attribute,
  marine_flag,
  now(),
  (select updated_by_user_id from uksi.uksi_settings),
  now(),
  (select updated_by_user_id from uksi.uksi_settings)
FROM uksi.prepared_taxa
WHERE is_new=true;