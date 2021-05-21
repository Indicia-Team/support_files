SET search_path=indicia, public;

-- Build a copy of what the taxa_taxon_lists table should end up like. 
-- We'll need to do some key mappings later, e.g. to get the parent_id, 
-- taxon_meaning_id and common_taxon_id.
DROP TABLE IF EXISTS gbif.prepared_taxa_taxon_lists;

SELECT DISTINCT null::integer AS id,
  (SELECT value FROM gbif.settings WHERE key = 'taxon_list_id') AS taxon_list_id,
  pt.id::integer AS taxon_id,
  null::integer AS parent_id,
  null::integer AS taxon_meaning_id,
  pt.search_code = pt.external_key AS preferred,
  pt.search_code AS gbif_id, -- not used by Indicia, but makes matching easier.
  pt.external_key AS recommended_taxon_version_key,
  gb_accepted.parent_key AS parent_search_code,
  null::boolean AS changed,
  null::boolean as orig_preferred,
  null::integer AS orig_taxon_meaning_id,
  null::integer AS orig_parent_id,
INTO gbif.prepared_taxa_taxon_lists
FROM gbif.prepared_taxa pt
JOIN gbif.backbone gb_accepted ON gb_accepted.id = pt.external_key
JOIN gbif.backbone gb ON gb.id = pt.search_code;

-- Add the existing names from child lists
INSERT INTO gbif.prepared_taxa_taxon_lists
SELECT DISTINCT null::integer AS id,
  child_lists.id AS taxon_list_id,
  pt.id::integer AS taxon_id,
  null::integer AS parent_id,
  null::integer AS taxon_meaning_id,
  pt.search_code = pt.external_key AS preferred,
  pt.search_code AS gbif_id, -- not used by Indicia, but makes matching easier.
  pt.external_key AS recommended_taxon_version_key,
  gb_accepted.parent_key AS parent_search_code,
  null:boolean AS changed,
  null::boolean as orig_preferred,
  null::integer AS orig_taxon_meaning_id,
  null::integer AS orig_parent_id,
FROM gbif.prepared_taxa pt
JOIN gbif.backbone gb_accepted ON gb_accepted.id = pt.external_key
JOIN gbif.backbone gb ON gb.id = pt.search_code;
-- Find names already on each child list
JOIN taxa t ON t.search_code = pt.search_code
JOIN taxa_taxon_lists ttl ON ttl.taxon_id = t.id AND ttl.deleted = false
JOIN gbif.all_taxon_lists child_lists
  ON child_lists.id = ttl.taxon_list_id
  AND child_lists.id <> (SELECT value FROM gbif.settings WHERE key = 'taxon_list_id');