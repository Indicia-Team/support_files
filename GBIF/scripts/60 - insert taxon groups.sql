
SET search_path=indicia, public;


DROP TABLE IF EXISTS gbif.taxon_groups;

-- GBIF does not use taxon_groups but Indicia requires every taxon to have
-- a group. As a first iteration, try assigning everything to a single group.

CREATE TABLE gbif.taxon_groups 
	(title, description)
AS VALUES (
  'GBIF Backbone',
  'A single taxon group for everything imported from GBIF.');

-- Insert missing groups in to the indicia.taxon_ranks table.
INSERT INTO taxon_groups (
  title, 
  description, 
  created_on, 
  created_by_id, 
  updated_on, 
  updated_by_id)
SELECT  
  gtg.title, 
  gtg.description, 
  now(), 
	(SELECT value FROM gbif.settings WHERE key = 'updated_by_id'),
  now(), 
	(SELECT value FROM gbif.settings WHERE key = 'updated_by_id')
FROM gbif.taxon_groups gtg
LEFT JOIN taxon_groups tg 
  ON tg.title = 'GBIF Backbone'
  AND tg.deleted = false
WHERE tg.id IS NULL;

-- Add taxon_group id to settings.
INSERT INTO gbif.settings (key, value)
SELECT 'taxon_group_id', id
FROM taxon_groups
WHERE title = 'GBIF Backbone' AND deleted = false;