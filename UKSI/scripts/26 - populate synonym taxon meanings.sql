SET search_path=indicia, public;

-- Map the preferred name taxon_meaning_ids back into the non-preferred names
-- and preferred names on child lists. Use the orig_taxon_meaning_id to detect
-- which are actual changes.
UPDATE uksi.prepared_taxa_taxon_lists pttl
SET taxon_meaning_id=pttlpref.taxon_meaning_id,
  changed=pttl.changed OR pttlpref.taxon_meaning_id<>pttl.orig_taxon_meaning_id
FROM uksi.prepared_taxa_taxon_lists pttlpref
WHERE pttlpref.recommended_taxon_version_key=pttl.recommended_taxon_version_key
AND pttlpref.organism_key=pttl.organism_key
AND pttlpref.preferred=true
-- UKSI holds the master copy of taxon meanings, so only update from preferred names on UKSI.
AND pttlpref.is_uksi=true
-- Update synonyms and common names from UKSI. Also update all names in child lists.
AND (pttl.preferred=false OR pttl.is_uksi=false);