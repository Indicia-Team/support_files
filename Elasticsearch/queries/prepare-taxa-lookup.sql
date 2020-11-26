DROP TABLE IF EXISTS master_list_paths;

SELECT DISTINCT ON (tp.external_key, tp.taxon_list_id) tp.*
INTO TEMPORARY master_list_paths
FROM cache_taxon_paths tp
JOIN cache_taxa_taxon_lists cttlcheck on cttlcheck.taxon_meaning_id=tp.taxon_meaning_id AND cttlcheck.taxon_list_id=tp.taxon_list_id
WHERE tp.taxon_list_id=<taxon_list_id>
ORDER BY tp.external_key, tp.taxon_list_id, cttlcheck.allow_data_entry DESC;

CREATE INDEX ix_master_list_paths ON master_list_paths(external_key);

SELECT DISTINCT ('"' || t.search_code
    || '": "' || replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(
    t.taxon
    || '~' || coalesce(t.authority, '')
    || '~' || cttl.external_key
    || '~' || cttl.preferred_taxon || '~' || coalesce(cttl.preferred_authority, '')
    || '~' || cttl.taxon_group_id::text
    || '~' || cttl.taxon_group
    || '~' || coalesce(cttl.default_common_name, '')
    || '~' || coalesce(cttl.taxon_rank, '')
    || '~' || coalesce(cttl.taxon_rank_sort_order::text, '')
    || '~' || cttl.marine_flag::text
    || '~' || cttl.freshwater_flag::text
    || '~' || cttl.terrestrial_flag::text
    || '~' || cttl.non_native_flag::text
    || '~' || coalesce(tkingdom.taxon, '')
    || '~' || coalesce(tphylum.taxon, '')
    || '~' || coalesce(tclass.taxon, '')
    || '~' || coalesce(torder.taxon, '')
    || '~' || coalesce(tfamily.taxon, '')
    || '~' || coalesce(tsubfamily.taxon, '')
    || '~' || coalesce(tgenus.taxon, '')
    || '~' || coalesce(tspecies.taxon, '')
    || '~' || coalesce(tspecies.external_key, ''),
  '\', '\\'),
  '"', '\"'),
  E'\u0082', ','),
  E'\u0084', ',,'),
  E'\u0086', '†'),
  E'\u0090', ''),
  E'\u0092', ''''),
  E'\u0096', '-'),
  E'\u008A', 'Š'),
  E'\u009A', 'š'),
  E'\u009C', 'œ'),
  E'\u009E', 'ž') || '"') AS taxon_data
FROM cache_taxa_taxon_lists cttl
JOIN taxa_taxon_lists ttl ON ttl.id=cttl.id AND ttl.deleted=false
JOIN taxa t ON t.id=ttl.taxon_id AND t.deleted=false
JOIN master_list_paths tp ON tp.external_key=cttl.external_key AND tp.taxon_list_id=<taxon_list_id>
LEFT JOIN cache_taxa_taxon_lists tkingdom ON tkingdom.taxon_meaning_id = ANY(tp.path)
  AND tkingdom.taxon_rank='Kingdom' AND tkingdom.preferred=true AND tkingdom.taxon_list_id=<taxon_list_id>
  AND (tkingdom.allow_data_entry=true OR cttl.allow_data_entry=false)
LEFT JOIN cache_taxa_taxon_lists tphylum ON tphylum.taxon_meaning_id = ANY(tp.path)
  AND tphylum.taxon_rank='Phylum' AND tphylum.preferred=true AND tphylum.taxon_list_id=<taxon_list_id>
  AND (tphylum.allow_data_entry=true OR cttl.allow_data_entry=false)
LEFT JOIN cache_taxa_taxon_lists tclass ON tclass.taxon_meaning_id = ANY(tp.path)
  and tclass.taxon_rank='Class' AND tclass.preferred=true AND tclass.taxon_list_id=<taxon_list_id>
  AND (tclass.allow_data_entry=true OR cttl.allow_data_entry=false)
LEFT JOIN cache_taxa_taxon_lists torder ON torder.taxon_meaning_id = ANY(tp.path)
  and torder.taxon_rank='Order' AND torder.preferred=true AND torder.taxon_list_id=<taxon_list_id>
  AND (torder.allow_data_entry=true OR cttl.allow_data_entry=false)
LEFT JOIN cache_taxa_taxon_lists tfamily ON tfamily.taxon_meaning_id = ANY(tp.path)
  and tfamily.taxon_rank='Family' AND tfamily.preferred=true AND tfamily.taxon_list_id=<taxon_list_id>
  AND (tfamily.allow_data_entry=true OR cttl.allow_data_entry=false)
LEFT JOIN cache_taxa_taxon_lists tsubfamily ON tsubfamily.taxon_meaning_id = ANY(tp.path)
  and tsubfamily.taxon_rank='Subfamily' AND tkingdom.preferred=true AND tsubfamily.taxon_list_id=<taxon_list_id>
  AND (tsubfamily.allow_data_entry=true OR cttl.allow_data_entry=false)
LEFT JOIN cache_taxa_taxon_lists tgenus ON tgenus.taxon_meaning_id = ANY(tp.path)
  and tgenus.taxon_rank='Genus' AND tgenus.preferred=true AND tgenus.taxon_list_id=<taxon_list_id>
  AND (tgenus.allow_data_entry=true OR cttl.allow_data_entry=false)
LEFT JOIN cache_taxa_taxon_lists tspecies ON tspecies.taxon_meaning_id = ANY(tp.path)
  AND tspecies.taxon_rank='Species' AND tspecies.preferred=true AND tspecies.taxon_list_id=<taxon_list_id>
  AND (tspecies.allow_data_entry=true OR cttl.allow_data_entry=false)
WHERE cttl.taxon_list_id=<taxon_list_id>
AND cttl.external_key IS NOT NULL
AND t.search_code IS NOT NULL
ORDER BY taxon_data;
