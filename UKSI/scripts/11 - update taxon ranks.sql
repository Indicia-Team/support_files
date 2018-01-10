SET search_path=indicia, public;

DROP TABLE IF EXISTS uksi.update_taxon_ranks;

-- Ensure existing rank info is correct. First grab a list of the taxon ranks with any changes.
SELECT tr.id, tr.sort_order<>utr.sort_order as sort_order_changed,
  COALESCE(utr.short_name, utr.long_name) as short_name, utr.long_name as rank, utr.sort_order
INTO uksi.update_taxon_ranks
FROM taxon_ranks tr
JOIN uksi.taxon_ranks utr ON tr.short_name=COALESCE(utr.short_name, utr.long_name)
AND (tr.sort_order<>utr.sort_order OR rank<>utr.long_name);

-- Update the actual taxon_ranks table.
UPDATE taxon_ranks tr
SET sort_order=utr.sort_order,
	rank=utr.rank,
	updated_on=now(),
	updated_by_id=(select updated_by_user_id from uksi.uksi_settings)
FROM uksi.update_taxon_ranks utr
WHERE tr.id=utr.id;