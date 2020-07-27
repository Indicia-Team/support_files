DROP TABLE IF EXISTS master_list_paths;

SELECT DISTINCT ON (tp.external_key, tp.taxon_list_id) tp.*
INTO TEMPORARY master_list_paths
FROM cache_taxon_paths tp
JOIN cache_taxa_taxon_lists cttlcheck on cttlcheck.taxon_meaning_id=tp.taxon_meaning_id AND cttlcheck.taxon_list_id=tp.taxon_list_id
WHERE tp.taxon_list_id=<taxon_list_id>
ORDER BY tp.external_key, tp.taxon_list_id, cttlcheck.allow_data_entry DESC;

CREATE INDEX ix_master_list_paths ON master_list_paths(external_key);

select distinct t.search_code as key,
  t.taxon || '~' || coalesce(t.authority, '')
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
  || '~' || coalesce(tspecies.external_key, '')
from cache_taxa_taxon_lists cttl
join taxa_taxon_lists ttl on ttl.id=cttl.id and ttl.deleted=false
join taxa t on t.id=ttl.taxon_id and t.deleted=false
join master_list_paths tp on tp.external_key=cttl.external_key and tp.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists tkingdom on tkingdom.taxon_meaning_id = ANY(tp.path)
  and tkingdom.taxon_rank='Kingdom' and tkingdom.preferred=true and tkingdom.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists tphylum on tphylum.taxon_meaning_id = ANY(tp.path)
  and tphylum.taxon_rank='Phylum' and tphylum.preferred=true and tphylum.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists tclass on tclass.taxon_meaning_id = ANY(tp.path)
  and tclass.taxon_rank='Class' and tclass.preferred=true and tclass.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists torder on torder.taxon_meaning_id = ANY(tp.path)
  and torder.taxon_rank='Order' and torder.preferred=true and torder.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists tfamily on tfamily.taxon_meaning_id = ANY(tp.path)
  and tfamily.taxon_rank='Family' and tfamily.preferred=true and tfamily.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists tsubfamily on tsubfamily.taxon_meaning_id = ANY(tp.path)
  and tsubfamily.taxon_rank='Subfamily' and tkingdom.preferred=true and tsubfamily.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists tgenus on tgenus.taxon_meaning_id = ANY(tp.path)
  and tgenus.taxon_rank='Genus' and tgenus.preferred=true and tgenus.taxon_list_id=<taxon_list_id>
left join cache_taxa_taxon_lists tspecies on tspecies.taxon_meaning_id = ANY(tp.path)
  and tspecies.taxon_rank='Species' and tspecies.preferred=true and tspecies.taxon_list_id=<taxon_list_id>
where cttl.taxon_list_id=<taxon_list_id>
and cttl.external_key is not null
and t.search_code is not null
order by t.search_code;
