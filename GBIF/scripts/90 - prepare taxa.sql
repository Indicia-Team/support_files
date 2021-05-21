SET search_path=indicia, public;

-- Build a copy of what the taxa table should end up like.
DROP TABLE IF EXISTS gbif.prepared_taxa;


CREATE OR REPLACE FUNCTION 
  gbif.truncate_author(authorship text, max_author integer = 5)
  -- Reduces authorships like 'A, B, C, D, E, F & G` to `A et al.`
  -- authorship is the text to examine.
  -- max_author is the maximum number of authors to allow before truncating.
  RETURNS text
  AS $$
    DECLARE
      nr_comma integer;
      nr_ampersand integer;
      nr_author integer;
    BEGIN
      nr_comma := array_length(
	      regexp_split_to_array(authorship, ', '), 1
      );
      nr_ampersand := array_length(
	      regexp_split_to_array(authorship, ' & '), 1
      );
      nr_author := 1 + nr_comma + nr_ampersand;

      IF nr_author > max_author THEN
      -- Try to truncate.
        IF nr_comma = 0 AND nr_ampersand = 0 THEN
          -- Can't truncate.
          RETURN authorship;
        ELSIF nr_comma = 0 AND nr_ampersand > 0 THEN
          -- Take first name before an ampersand.
          RETURN split_part(authorship, ' &', 1) || ' et al.';
        ELSIF nr_comma > 0 AND nr_ampersand = 0 THEN
          -- Take first name before a comma.
          RETURN split_part(authorship, ', ', 1) || ' et al.';
        ELSIF position(', ' in authorship) < position(' & ' in authorship) THEN
          -- Take first name before a comma.
          RETURN split_part(authorship, ', ', 1) || ' et al.';
        ELSE
          -- Take first name before an ampersand.
          RETURN split_part(authorship, ' &', 1) || ' et al.';
        END IF;
      ELSE
        -- No truncation required.
        RETURN authorship;
      END IF;
    END;
  $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION 
  gbif.create_author(
    authorship text, 
    year text,
    bracket_authorship text,
    bracket_year text
  )
  -- Compose authorship from the 4 components
  RETURNS text
  AS $$
    DECLARE
      result text;
    BEGIN
      -- Convert nulls to empty strings.
      IF authorship IS NULL THEN authorship := ''; END IF;
      IF year IS NULL THEN year := ''; END IF;
      IF bracket_authorship IS NULL THEN bracket_authorship := ''; END IF;
      IF bracket_year IS NULL THEN bracket_year := ''; END IF;

      -- Truncate authorships to fit our 100 character limit.
      IF length(authorship || bracket_authorship) > 85 THEN
        -- This is looking too long so truncate authorships of over 5.
        authorship := gbif.truncate_author(authorship);
        bracket_authorship := gbif.truncate_author(bracket_authorship);
        IF length(authorship || bracket_authorship) > 85 THEN
          -- Still too long so truncate authorships of over 3.
          authorship := gbif.truncate_author(authorship, 3);
          bracket_authorship := gbif.truncate_author(bracket_authorship, 3);
          IF length(authorship || bracket_authorship) > 85 THEN
            -- Holy cow, truncate authorships of over 1.
            authorship := gbif.truncate_author(authorship, 1);
            bracket_authorship := gbif.truncate_author(bracket_authorship, 1);
            IF length(authorship || bracket_authorship) > 85 THEN
              -- Madness.
              IF length(authorship) > 39 THEN 
                authorship := substring(authorship for 39) || '...';
              END IF;
              IF length(bracket_authorship) > 39 THEN 
                bracket_authorship := substring(bracket_authorship for 39) || '...';
              END IF;
            END IF;
          END IF;
        END IF;
      END IF; 

      IF (bracket_authorship != '' OR bracket_year != '') THEN
        -- There is something in brackets.
        IF (bracket_authorship != '' AND bracket_year != '') THEN
          -- We have both components.
          result := '(' || bracket_authorship || ', ' || bracket_year || ')';
        ELSE
          -- We only have one component.
          result := '(' || bracket_authorship || bracket_year || ')';
        END IF;

        IF (authorship != '' OR year != '') THEN
          -- There is more to follow the brackets.
          result := result || ' ';
        END IF;
      ELSE 
        result := '';
      END IF;

      IF (authorship != '' AND year != '') THEN
        -- We have both components.
        result := result || authorship || ', ' || year;
      ELSE
        -- We only have one component
        result := result || authorship || year;
      END IF;

      RETURN result;
    END;
  $$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION 
  gbif.create_name(
    rank text, 
    notho_type text,
    genus_or_above text,
    specific_epithet text,
    infra_specific_epithet text, 
    canonical_name text
  )
  -- Compose taxon name from components
  RETURNS text
  AS $$
    DECLARE
      prefix text;
      species_separator text;
      infra_specific_type text;
    BEGIN

      IF notho_type = 'GENERIC' THEN
        prefix := 'x ';
      ELSE
        prefix := '';
      END IF;

      IF notho_type = 'SPECIFIC' THEN
        species_separator := ' x ';
      ELSE
        species_separator := ' ';
      END IF;

      IF notho_type = 'INFRASPECIFIC' THEN
        infra_specific_type := ' notho';
      ELSE
        infra_specific_type := ' ' ;
      END IF;

      CASE WHEN rank = 'SUBSPECIES' THEN
        infra_specific_type := infra_specific_type || 'subsp. ';
      WHEN rank = 'FORM' THEN
        infra_specific_type := infra_specific_type || 'f. ';
      WHEN rank = 'VARIETY' THEN
        infra_specific_type := infra_specific_type || 'var. ';
      ELSE
        infra_specific_type := '';
      END CASE;

      IF rank = 'SUBSPECIES' OR rank = 'FORM' OR rank = 'VARIETY' THEN
        RETURN CONCAT(
          prefix,
          genus_or_above, 
          species_separator, 
          specific_epithet, 
          infra_specific_type,
          infra_specific_epithet
        );
      ELSE
        CASE WHEN notho_type IS NULL THEN
          RETURN canonical_name;
        WHEN notho_type  = 'GENERIC' THEN
          RETURN CONCAT('x ', canonical_name);
        WHEN notho_type = 'SPECIFIC' THEN
          RETURN CONCAT(genus_or_above, ' x ', specific_epithet);
        END CASE;
      END IF;

    END;
  $$ LANGUAGE plpgsql;



SELECT DISTINCT NULL::integer AS id,
  -- taxon has to be built from components depending on rank and notho_type.
  gbif.create_name(
    gb.rank, 
    gb.notho_type,
    gb.genus_or_above,
    gb.specific_epithet,
    gb.infra_specific_epithet, 
    gb.canonical_name
  ) AS taxon,

  -- search_code is unique GBIF key of taxon
  gb.id AS search_code,

  -- external_key is unique GBIF key of preferred taxon for this record.
  CASE WHEN gb.is_synonym = false THEN 
    gb.id ELSE gb.parent_key 
  END AS external_key,

  -- taxon_group_id is currently a single value for all GBIF taxa.
  (SELECT value FROM gbif.settings WHERE key = 'taxon_group_id') AS taxon_group_id,

  -- language_id is always for latin with GBIF taxa.
  (SELECT id FROM languages WHERE iso = 'lat') AS language_id,

  -- authority is built from 4 component fields and may need truncating.
  gbif.create_author(
    gb.authorship, gb.year, gb.bracket_authorship, gb.bracket_year
  ) AS authority,

  -- taxon_rank_id is complicated by hybrids...
  CASE WHEN gb.notho_type IS NULL THEN 
    tr.id
  WHEN gb.notho_type = 'GENERIC' THEN
    (SELECT id from taxon_ranks where rank = 'Generic hybrid')
  WHEN gb.notho_type = 'SPECIFIC' THEN
    (SELECT id from taxon_ranks where rank = 'Species hybrid')
  WHEN gb.notho_type = 'INFRASPECIFIC' THEN
    CASE WHEN gb.rank = 'SUBSPECIES' THEN
      (SELECT id from taxon_ranks where rank = 'Subspecies hybrid')
    WHEN gb.rank = 'VARIETY' THEN
      (SELECT id from taxon_ranks where rank = 'Varietal hybrid')
    WHEN gb.rank = 'FORM' THEN
      (SELECT id from taxon_ranks where rank = 'Form hybrid')
    END
  END
  AS taxon_rank_id,

  -- scientific is always true for GBIF taxa.
  true AS scientific,   

  -- changed flag for on-going processing.
  NULL::boolean AS changed
  
INTO gbif.prepared_taxa
FROM gbif.backbone gb
JOIN taxon_ranks tr 
  ON UPPER(tr.rank) = gb.rank
  AND tr.deleted=false
