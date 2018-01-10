SET search_path=indicia, public;


-- Insert any missing ranks
INSERT INTO taxon_ranks(rank, short_name, italicise_taxon, sort_order, created_on, created_by_id, updated_on, updated_by_id)
SELECT DISTINCT utr.long_name, COALESCE(utr.short_name, utr.long_name), case utr.list_font_italic when 1 then true else false end, utr.sort_order,
  now(), (select updated_by_user_id from uksi.uksi_settings), now(), (select updated_by_user_id from uksi.uksi_settings)
FROM uksi.taxon_ranks utr
LEFT JOIN taxon_ranks tr on tr.short_name=COALESCE(utr.short_name, utr.long_name)
WHERE tr.id IS NULL;