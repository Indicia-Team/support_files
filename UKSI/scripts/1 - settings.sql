/*
 Put some settings into tables, so we can refer to them as we go along.
 Replace
 * taxonListId with the UKSI master list ID (15?)
 * updatedByUserId with your warehouse user ID (or create a user ID for UKSI updates and use that).
*/

SET search_path=indicia, public;

CREATE SCHEMA IF NOT EXISTS uksi;

DROP TABLE IF EXISTS uksi.all_uksi_taxon_lists;
DROP TABLE IF EXISTS uksi.uksi_settings;

SELECT id
INTO uksi.all_uksi_taxon_lists
FROM taxon_lists
WHERE parent_id={{ taxon_list_id }};

SELECT {{ taxon_list_id }} as uksi_taxon_list_id, {{ user_id }} as updated_by_user_id
INTO uksi.uksi_settings;
