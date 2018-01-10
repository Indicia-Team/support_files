SET search_path=uksi, public;

DELETE FROM all_names WHERE input_taxon_version_key IN (
	-- find duplicate names to delete which differ only in rank and are a different rank to the preferred name
	SELECT DISTINCT l1.input_taxon_version_key
	FROM all_names l1
	-- look for a matching name which means the name we are about to delete is redundant
	JOIN all_names l2
	  -- same language
	  ON l2.language = l1.language
	  -- same taxonomic concept
	  AND l2.recommended_taxon_version_key=l1.recommended_taxon_version_key
	  -- matching name and attribute (fuzzy match)
	  AND lower(replace(l2.item_name || coalesce(' ' || l2.attribute, ''), '-', ' ')) = lower(replace(l1.item_name || coalesce(' ' || l1.attribute, ''), '-', ' '))
	  -- matching authority (fuzzy), or name to delete's authority is missing
	  AND (lower(replace(l2.authority, '-', ' ')) = lower(replace(l1.authority, '-', ' ')) OR l1.authority IS NULL)
	  -- different rank
	  AND l2.rank<>l1.rank
	-- join to find the rank of the preferred name to make sure it is a different rank to the one we are about to delete
	JOIN all_names pref ON pref.input_taxon_version_key=l1.recommended_taxon_version_key AND pref.rank<>l2.rank
	WHERE l1.recommended_taxon_version_key<>l1.input_taxon_version_key
);