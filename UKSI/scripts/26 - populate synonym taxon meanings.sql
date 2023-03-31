SET search_path=indicia, public;

-- Map the preferred name taxon_meaning_ids back into the non-preferred names. Use the orig_taxon_meaning_id
-- to detect which are actual changes.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET taxon_meaning_id=pttlpref.taxon_meaning_id,
  changed=pttl.changed OR pttlpref.taxon_meaning_id<>pttl.orig_taxon_meaning_id
FROM uksi.prepared_taxa_taxon_lists pttlpref
WHERE pttlpref.recommended_taxon_version_key=pttl.recommended_taxon_version_key
AND pttlpref.organism_key=pttl.organism_key
AND pttlpref.preferred=true
AND pttl.preferred=false;