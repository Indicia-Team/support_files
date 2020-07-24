SET search_path=indicia, public;

UPDATE uksi.prepared_taxa
SET id=nextval('indicia.taxa_id_seq'::regclass),
  is_new=true
WHERE id IS NULL;

-- Update existing taxa which have changed
UPDATE taxa t
SET taxon=pt.taxon,
  taxon_group_id=pt.taxon_group_id,
  language_id=pt.language_id,
  external_key=pt.external_key,
  authority=pt.authority,
  search_code=pt.search_code,
  scientific=pt.scientific,
  taxon_rank_id=pt.taxon_rank_id,
  attribute=pt.attribute,
  marine_flag=pt.marine_flag,
  freshwater_flag=pt.freshwater_flag,
  terrestrial_flag=pt.terrestrial_flag,
  non_native_flag=pt.non_native_flag,
  updated_on=now(),
  updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM uksi.prepared_taxa pt
WHERE pt.id=t.id
AND pt.changed=true
AND pt.is_new=false;