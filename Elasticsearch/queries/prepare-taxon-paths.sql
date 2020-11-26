select '"' || cttl.external_key || '": "' || string_agg(cttlp.external_key, ',' order by cttlp.taxon_rank_sort_order) || '"'
from cache_taxa_taxon_lists cttl
join master_list_paths ctp on ctp.external_key=cttl.external_key
join cache_taxa_taxon_lists cttlp on cttlp.taxon_meaning_id=ANY(ctp.path)
  and cttlp.preferred=true
  and cttlp.taxon_list_id=<taxon_list_id>
where cttl.taxon_list_id=<taxon_list_id>
and cttl.preferred=true
group by cttl.external_key
order by cttl.external_key;
