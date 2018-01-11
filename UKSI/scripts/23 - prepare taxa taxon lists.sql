SET search_path=indicia, public;

-- Build a copy of what the taxa_taxon_lists table should end up like. We'll need to do some key
-- mappings later, e.g. to get the parent_id, taxon_meaning_id and common_taxon_id.
DROP TABLE IF EXISTS uksi.prepared_taxa_taxon_lists;

SELECT DISTINCT null::integer AS id,
  (select uksi_taxon_list_id from uksi.uksi_settings) AS taxon_list_id,
  pt.id::integer AS taxon_id,
  null::integer AS parent_id,
  null::integer AS taxon_meaning_id,
  pn.sort_code AS taxonomic_sort_order,
  pt.search_code=pt.external_key AS preferred,
  null::integer AS common_taxon_id,
  -- not used by Indicia, but will make matching easier.
  pt.search_code AS input_taxon_version_key,
  pt.external_key AS recommended_taxon_version_key,
  pn.parent_tvk AS parent_search_code,
  null::varchar AS common_taxon_tvk,
  false AS is_new,
  false AS changed,
  null::boolean as orig_preferred,
  null::integer AS orig_taxon_meaning_id,
  null::integer AS orig_parent_id,
  null::integer AS orig_common_taxon_id
INTO uksi.prepared_taxa_taxon_lists
FROM uksi.prepared_taxa pt
JOIN uksi.preferred_names pn ON pn.taxon_version_key=pt.external_key;