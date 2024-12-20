SET search_path=indicia, public;

-- left over from previous script.
DROP TABLE IF EXISTS to_process;

-- Build a copy of what the taxa table should end up like.
DROP TABLE IF EXISTS uksi.prepared_taxa;

SELECT DISTINCT NULL::integer AS id,
  uan.item_name AS taxon,
  tg.id AS taxon_group_id,
  l.id AS language_id,
  uan.recommended_taxon_version_key AS external_key,
  uan.authority,
  uan.input_taxon_version_key AS search_code,
  uan.taxon_type='S' AS scientific,
  tr.id AS taxon_rank_id,
  uan.attribute,
  COALESCE(upn.marine_flag, false) AS marine_flag,
  COALESCE(upn.freshwater_flag, false) AS freshwater_flag,
  COALESCE(upn.terrestrial_flag, false) AS terrestrial_flag,
  COALESCE(upn.non_native_flag, false) AS non_native_flag,
  upn.organism_key,
  false AS is_new,
  false AS changed,
  uan.organism_deprecated,
  uan.name_deprecated,
  uan.taxon_version_form as name_form
INTO uksi.prepared_taxa
FROM uksi.all_names uan
JOIN taxon_groups tg ON tg.external_key=uan.output_group_key and tg.deleted=false
JOIN languages l ON substring(l.iso from 1 for 2)=uan.language OR (l.iso='gla' AND uan.language='gd') AND l.deleted=false
JOIN taxon_ranks tr ON COALESCE(tr.short_name, tr.rank)=COALESCE(uan.short_name, uan.rank) AND tr.deleted=false
JOIN uksi.preferred_names upn ON upn.taxon_version_key=uan.recommended_taxon_version_key AND upn.organism_key=uan.organism_key;