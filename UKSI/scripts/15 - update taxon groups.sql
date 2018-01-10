SET search_path=indicia, public;

DROP TABLE IF EXISTS uksi.update_taxon_groups;

-- Now they exist, we can update all parents. Also ensure the titles and descriptions are up to date
-- (as we used the external key to match earlier, the title might not be yet). Grab the changes into
-- a temp table so we can easily apply changes to the cache tables in a moment.
SELECT tg.id, tgp.id as parent_id, tgimpc.taxon_group_name as title, tgimpc.description
INTO uksi.update_taxon_groups
FROM taxon_groups tg
JOIN uksi.taxon_groups tgimpc ON tgimpc.taxon_group_key=tg.external_key
LEFT JOIN (uksi.taxon_groups tgimpp
  JOIN taxon_groups tgp ON tgp.external_key=tgimpp.taxon_group_key AND tgp.deleted=false
) ON tgimpp.taxon_group_key=tgimpc.parent
WHERE (tg.parent_id <> tgp.id OR tg.title <> tgimpc.taxon_group_name OR tg.description <> tgimpc.description)
AND tg.deleted=false;

-- Update the actual table
UPDATE taxon_groups tg
SET parent_id=utg.parent_id,
	title=utg.title,
	description=utg.description,
	updated_on=now(),
	updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM uksi.update_taxon_groups utg
WHERE utg.id=tg.id;