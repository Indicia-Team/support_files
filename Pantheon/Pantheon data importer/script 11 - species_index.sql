DROP TABLE IF EXISTS pantheon.species_index2;

select cttl.preferred_taxa_taxon_list_id, 
cttl.preferred_taxon as "species",
cttl.default_common_name as "vernacular",
cttl.family_taxon as "family",
cttl.order_taxon as "order",
rscv.int_value as "rarity_score",
case count(td.*) when 0 then null else array_to_string(array_agg(distinct coalesce(td.code, td.abbreviation, td.title, td.id::varchar)), ';') END as "designations",
string_agg(distinct lguildterm.term,';') as "larval_guild",
string_agg(distinct aguildterm.term,';') as "adult_guild",
array_to_string(array_agg(distinct t_bb.term), '; ') as "broad_biotope",
array_to_string(array_agg(distinct t_sb.term), '; ') as "specific_biotope",
string_agg(distinct 
  case 
    when t_r_child.id is null then 
      case
        when t_r_grandparent.id is not null and t_r_grandparent.parent_id is null then ''
        else t_r_parent.term || ' >> '
      end || t_r.term 
    else null
  end, 
  ', '
) as "resource",
array_to_string(array_agg(distinct '<span>' || t_bb.term || '</span>'), '; ') as "lexicon_broad_biotope",
array_to_string(array_agg(distinct '<span>' || t_sb.term || '</span>'), '; ') as "lexicon_specific_biotope",
string_agg(distinct 
  case 
    when t_r_child.id is null then 
      case
        when t_r_grandparent.id is not null and t_r_grandparent.parent_id is null then ''
        else '<span>' || t_r_parent.term || '</span> >> '
      end || '<span>' || t_r.term || '</span>'
    else null
  end, 
  ', '
) as "lexicon_resource",
string_agg(distinct isissatcode.term, ', ') as "isis_sat_code",
array_to_string(array_agg(distinct coalesce(horusa.caption || ': ' || coalesce(horust.term, horusv.int_value::varchar))), ', ') as "horus_indices",
cttl.taxon_meaning_id as "taxon_meaning_id",
cttl.taxon_list_id as "taxon_list_id",
(select string_agg(distinct cttlto.taxon, ', ')             from taxon_associations ta     left join cache_taxa_taxon_lists cttlto on cttlto.taxon_meaning_id=ta.to_taxon_meaning_id       and cttlto.taxon_list_id=cttl.taxon_list_id       and cttlto.preferred=true     where ta.from_taxon_meaning_id=cttl.taxon_meaning_id) as "associations"
into pantheon.species_index2
from cache_taxa_taxon_lists cttl
join taxa_taxon_lists ttl on ttl.id=cttl.preferred_taxa_taxon_list_id
left join (taxa_taxon_designations ttd
  join taxon_designations td on td.id=ttd.taxon_designation_id and td.deleted=false
    join cache_termlists_terms cat on cat.id=td.category_id and (
       (cat.term='GB Red List' and coalesce(td.code, td.abbreviation) not in ('LC', 'NA', 'pLC', 'pNA', 'NE'))
    or (cat.term='GB Status' and coalesce(td.code, td.abbreviation) not in ('None', 'Not reviewed', 'Not native'))
    or (cat.term not in ('GB Red List', 'GB Status'))
  )
) on ttd.taxon_id=ttl.taxon_id and ttd.deleted=false
left join taxa_taxon_list_attribute_values av_bb on av_bb.taxa_taxon_list_id=ttl.id and av_bb.deleted=false
and av_bb.taxa_taxon_list_attribute_id=15
left join cache_termlists_terms t_bb on t_bb.id=av_bb.int_value
left join taxa_taxon_list_attribute_values av_sb on av_sb.taxa_taxon_list_id=ttl.id and av_sb.deleted=false
and av_sb.taxa_taxon_list_attribute_id=16
left join cache_termlists_terms t_sb on t_sb.id=av_sb.int_value
left join taxa_taxon_list_attribute_values av_sat on av_sat.taxa_taxon_list_id=ttl.id and av_sat.deleted=false
    and av_sat.taxa_taxon_list_attribute_id=20
left join cache_termlists_terms t_sat on t_sat.id=av_sat.int_value
left join cache_termlists_terms isissatcode on isissatcode.meaning_id=t_sat.meaning_id and isissatcode.preferred=false
left join taxa_taxon_list_attribute_values av_r on av_r.taxa_taxon_list_id=ttl.id and av_r.deleted=false
and av_r.taxa_taxon_list_attribute_id=17
left join cache_termlists_terms t_r on t_r.id=av_r.int_value
left join (cache_termlists_terms t_r_child 
  join taxa_taxon_list_attribute_values av_r_child on av_r_child.deleted=false
  and av_r_child.int_value=t_r_child.id
) on t_r_child.parent_id=t_r.id and av_r_child.taxa_taxon_list_id=ttl.id
left join cache_termlists_terms t_r_parent on t_r_parent.id=t_r.parent_id
left join cache_termlists_terms t_r_grandparent on t_r_grandparent.id=t_r_parent.parent_id
left join taxa_taxon_list_attribute_values lguildv on lguildv.taxa_taxon_list_id=ttl.id and lguildv.deleted=false
  and lguildv.taxa_taxon_list_attribute_id=19
left join cache_termlists_terms lguildterm on lguildterm.id=lguildv.int_value  
left join taxa_taxon_list_attribute_values aguildv on aguildv.taxa_taxon_list_id=ttl.id and aguildv.deleted=false
  and aguildv.taxa_taxon_list_attribute_id=18
left join cache_termlists_terms aguildterm on aguildterm.id=aguildv.int_value
left join taxa_taxon_list_attribute_values rscv on rscv.taxa_taxon_list_id=ttl.id and rscv.deleted=false
  and rscv.taxa_taxon_list_attribute_id=24
left join (taxa_taxon_list_attribute_values horusv
    join taxa_taxon_list_attributes horusa on horusa.id=horusv.taxa_taxon_list_attribute_id and horusa.deleted=false
      and horusa.description = 'Pantheon quality indices'
    left join cache_termlists_terms horust on horust.id=horusv.int_value and horusa.data_type='L'
) on horusv.taxa_taxon_list_id=ttl.id and horusv.deleted=false
left join taxon_associations ta on ta.from_taxon_meaning_id=cttl.taxon_meaning_id
left join cache_taxa_taxon_lists cttlto on cttlto.taxon_meaning_id=ta.to_taxon_meaning_id
  and cttlto.taxon_list_id=15
  and cttlto.preferred=true
where cttl.preferred=true
AND (av_bb.id is not null or av_sb.id is not null or av_r.id is not null or av_sat.id is not null
        or lguildv.id is not null or aguildv.id is not null or horusv.id is not null or rscv.id is not null)
GROUP BY cttl.preferred_taxa_taxon_list_id, cttl.preferred_taxon, cttl.default_common_name, cttl.family_taxon, cttl.order_taxon, rscv.int_value, cttl.taxon_meaning_id, cttl.taxon_list_id;

DROP TABLE IF EXISTS pantheon.species_index;
ALTER TABLE pantheon.species_index2 RENAME TO species_index;
GRANT SELECT ON pantheon.species_index TO indicia_report_user;
