SET search_path=indicia, public;


-- Can't drop this in the preceeding script as it is used in the 
-- post-run reporting.
DROP TABLE IF EXISTS new_taxon_meanings;

-- Map the preferred name taxon_meaning_ids back into the non-preferred names. 
-- Use the orig_taxon_meaning_id to detect which are actual changes.
UPDATE gbif.prepared_taxa_taxon_lists pttl
SET taxon_meaning_id = pttlpref.taxon_meaning_id,
  changed = pttlpref.taxon_meaning_id <> pttl.orig_taxon_meaning_id
FROM gbif.prepared_taxa_taxon_lists pttlpref
WHERE pttlpref.recommended_taxon_version_key = pttl.recommended_taxon_version_key
AND pttlpref.preferred = true
AND pttl.preferred = false;