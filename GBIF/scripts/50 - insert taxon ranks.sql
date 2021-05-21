SET search_path=indicia, public;


DROP TABLE IF EXISTS gbif.taxon_ranks;

-- GBIF use a small number of ranks which I don't imagine will change.
-- In addition to the `rank` column there is also 'notho_type` to indicate
-- hybrids.
-- We can be compatible with UKSI if that coexists.

CREATE TABLE gbif.taxon_ranks 
	(sort_order, short_name, rank, list_font_italic)
AS VALUES
	(0,'Unk','Unknown',0),
	(10,'Kng','Kingdom',0),
	(30,'Phl','Phylum',0),
	(60,'Cls','Class',0),
	(100,'Ord','Order',0),
	(180,'Fam','Family',0),
	(230,'Gen','Genus',1),
	(230,'GenHyb','Generic hybrid',1),
	(300,'Spp','Species',1),
	(304,'SppHyb','Species hybrid',1),
	(320,'SubSpp','Subspecies',1),
	(320,'SubSppHyb','Subspecies hybrid',1),
	(330,'Var','Variety',1),
	(330,'VarHyb','Varietal hybrid',1),
	(350,'Frm','Form',1),
	(350,'FrmHyb','Form hybrid',1);

-- Insert missing ranks in to the indicia.taxon_ranks table.
INSERT INTO taxon_ranks (
	sort_order, 
	short_name, 
	rank, 
	italicise_taxon, 
	created_on, 
	created_by_id, 
	updated_on, 
	updated_by_id)
SELECT 
	gtr.sort_order, 
	gtr.short_name, 
	gtr.rank, 
	CASE gtr.list_font_italic WHEN 1 THEN true ELSE false END, 
	now()
	(SELECT value FROM gbif.settings WHERE key = 'updated_by_id'),
	now(),
	(SELECT value FROM gbif.settings WHERE key = 'updated_by_id')
FROM gbif.taxon_ranks gtr
LEFT JOIN  taxon_ranks tr 
	ON tr.short_name = gtr.short_name
	AND tr.deleted = false
WHERE tr.id IS NULL;

DROP TABLE gbif.taxon_ranks;
