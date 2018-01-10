SET search_path=indicia, public;

-- All new names will need a taxa_taxon_list_id. Use the sequence to make this simple.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET id=nextval('indicia.taxa_taxon_lists_id_seq'::regclass),
  is_new=true
WHERE id IS NULL;

-- Any preferred names that don't already have a taxon_meaning_id will need one.
SELECT nextval('indicia.taxon_meanings_id_seq'::regclass) AS taxon_meaning_id, pttl.id AS taxa_taxon_list_id
INTO TEMPORARY new_taxon_meanings
FROM uksi.prepared_taxa_taxon_lists pttl
WHERE pttl.preferred=true
AND pttl.taxon_meaning_id IS NULL;

-- Store the new taxon meanings
INSERT INTO taxon_meanings
SELECT taxon_meaning_id FROM new_taxon_meanings;

-- And attach them to the new preferred names which need them.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET taxon_meaning_id=ntm.taxon_meaning_id
FROM new_taxon_meanings ntm
WHERE ntm.taxa_taxon_list_id=pttl.id;