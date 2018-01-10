
SET search_path=indicia, public;

-- Grab all the missing but used taxon group names
INSERT INTO taxon_groups (title, description, external_key, created_on, created_by_id, updated_on, updated_by_id)
SELECT DISTINCT tgimp.taxon_group_name, tgimp.description, tgimp.taxon_group_key,
  now(), (select updated_by_user_id from uksi.uksi_settings),
  now(), (select updated_by_user_id from uksi.uksi_settings)
FROM uksi.taxon_groups tgimp
JOIN uksi.all_names an on an.output_group_key = tgimp.taxon_group_key
LEFT JOIN taxon_groups tg ON tg.external_key=tgimp.taxon_group_key AND tg.deleted=false
WHERE tg.id IS NULL;