select t.search_code as key,
  cttl.external_key || '~' || cttl.preferred_taxon || '~' || coalesce(cttl.preferred_authority, '') || '~' || cttl.taxon_group
  || '~' || coalesce(cttl.default_common_name, '') || '~' ||  coalesce(cttl.taxon_rank, '') || '~' || coalesce(cttl.taxon_rank_sort_order::text, '')
  || '~' || cttl.marine_flag::text
  || '~' || coalesce(tkingdom.taxon, '') || '~' || coalesce(tkingdom.external_key, '')
  || '~' || coalesce(tphylum.taxon, '') || '~' || coalesce(tphylum.external_key, '')
  || '~' || coalesce(tclass.taxon, '') || '~' || coalesce(tclass.external_key, '')
  || '~' || coalesce(torder.taxon, '') || '~' || coalesce(torder.external_key, '')
  || '~' || coalesce(tfamily.taxon, '') || '~' || coalesce(tfamily.external_key, '')
  || '~' || coalesce(tsubfamily.taxon, '') || '~' || coalesce(tsubfamily.external_key, '')
  || '~' || coalesce(tgenus.taxon, '') || '~' || coalesce(tgenus.external_key, '')
from cache_taxa_taxon_lists cttl
join taxa_taxon_lists ttl on ttl.id=cttl.id and ttl.deleted=false
join taxa t on t.id=ttl.taxon_id and t.deleted=false
join cache_taxon_paths tp on tp.external_key=cttl.external_key
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
where cttl.taxon_list_id=<taxon_list_id>
and cttl.external_key is not null
