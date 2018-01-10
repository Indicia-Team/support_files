SET search_path=uksi, public;

-- Update the parent_tvk since the NHM no longer guarantee this field is maintained.
UPDATE preferred_names c
SET parent_tvk = p.taxon_version_key
FROM uksi.preferred_names p
WHERE COALESCE(c.parent_tvk, '')<>COALESCE(p.taxon_version_key, '')
AND p.organism_key=c.parent_key;