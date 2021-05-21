/*
 Put some settings into tables, so we can refer to them as we go along.
 Replace
 * taxonListId with the gbif master list ID (15?)
 * updatedByUserId with your warehouse user ID (or create a user ID for gbif updates and use that).
*/

SET search_path=indicia, public;

CREATE SCHEMA IF NOT EXISTS gbif;

DROP TABLE IF EXISTS gbif.all_taxon_lists;
DROP TABLE IF EXISTS gbif.settings;

SELECT id
INTO gbif.all_taxon_lists
FROM taxon_lists
WHERE parent_id={{ taxon_list_id }} or id={{ taxon_list_id }};

CREATE TABLE gbif.settings 
	(key, value)
AS VALUES
	('taxon_list_id', {{ taxon_list_id }} ),
	('updated_by_id' , {{ user_id }} );