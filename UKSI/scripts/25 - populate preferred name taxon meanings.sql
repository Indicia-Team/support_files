SET search_path=indicia, public;

DROP TABLE IF EXISTS new_taxon_meanings;

-- Because we kept the taxon meaning ID for all names where the organism key hasn't changed, if a name has been added
-- to a taxon concept as a new accepted name, then the accepted name won't have a taxon meaning ID but a synonym might.
-- For consistency we can copy the synonym's taxon meaning ID to the accepted name, but only if the synonym still
-- points to the same organism.
UPDATE uksi.prepared_taxa_taxon_lists pttlpref
SET taxon_meaning_id=pttlsyn.taxon_meaning_id, changed=true
FROM uksi.prepared_taxa_taxon_lists pttlsyn
WHERE pttlpref.preferred=true
AND pttlsyn.preferred=false
AND pttlsyn.organism_key=pttlpref.organism_key
AND pttlsyn.taxon_meaning_id IS NOT NULL
AND pttlpref.taxon_meaning_id IS NULL
AND pttlsyn.organism_key=pttlsyn.orig_organism_key;

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
SET taxon_meaning_id=ntm.taxon_meaning_id,
  changed=true
FROM new_taxon_meanings ntm
WHERE ntm.taxa_taxon_list_id=pttl.id;