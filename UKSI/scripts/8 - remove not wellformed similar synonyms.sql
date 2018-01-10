SET search_path=uksi, public;

DELETE FROM all_names WHERE input_taxon_version_key IN (
	-- find duplicate names to delete which are not well-formed or preferred
	SELECT DISTINCT l1.input_taxon_version_key
	from all_names l1
	-- look for a matching name which means the name we are about to delete is redundant
	JOIN all_names l2
	  -- that is well-formed
	  ON l2.taxon_version_form='W'
	  -- same type (scientific or vernacular)
	  AND l2.taxon_type=l1.taxon_type
	  -- same language
	  AND l2.language = l1.language
	  -- same taxonomic concept
	  AND l2.recommended_taxon_version_key=l1.recommended_taxon_version_key
	  -- matching name and attribute (fuzzy match)
	  AND lower(replace(l2.item_name || coalesce(' ' || l2.attribute, ''), '-', ' ')) = lower(replace(l1.item_name || coalesce(' ' || l1.attribute, ''), '-', ' '))
	  -- matching authority (fuzzy), or name to delete's authority is missing
	  AND (lower(replace(l2.authority, '-', ' ')) = lower(replace(l1.authority, '-', ' ')) OR l1.authority IS NULL)
	WHERE l1.taxon_version_form IN ('I', 'U')
	AND l1.recommended_taxon_version_key<>l1.input_taxon_version_key
);