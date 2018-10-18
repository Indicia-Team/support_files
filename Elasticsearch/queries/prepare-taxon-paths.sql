select cttl.external_key, string_agg(cttlp.external_key, ',' order by cttlp.taxon_rank_sort_order)
from cache_taxa_taxon_lists cttl
join cache_taxon_paths ctp on ctp.external_key=cttl.external_key
  and ctp.taxon_list_id=<taxon_list_id>
join cache_taxa_taxon_lists cttlp on ctp.path @> ARRAY[cttlp.taxon_meaning_id]
  and cttlp.preferred=true
  AND cttlp.taxon_list_id=<taxon_list_id>
where cttl.taxon_list_id=<taxon_list_id>
group by cttl.external_key
