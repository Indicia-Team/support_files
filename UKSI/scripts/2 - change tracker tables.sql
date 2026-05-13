-- Ensure the correct search path
SET search_path = indicia, public;

-- Make sure the uksi schema exists and is owned by the warehouse DB user (safe if already created)
CREATE SCHEMA IF NOT EXISTS uksi AUTHORIZATION {{ warehouse_db_user }};
GRANT USAGE, CREATE ON SCHEMA uksi TO {{ warehouse_db_user }};

-- Drop existing tracking tables from previous runs
DROP TABLE IF EXISTS uksi.changed_occurrence_ids;
DROP TABLE IF EXISTS uksi.changed_taxa_taxon_list_ids;

-- Create tables to capture changed records for later cache updates
SELECT id
INTO uksi.changed_occurrence_ids
FROM occurrences
LIMIT 0;

-- Transfer ownership so normal warehouse user can read/write these tables
ALTER TABLE uksi.changed_occurrence_ids OWNER TO {{ warehouse_db_user }};

SELECT id
INTO uksi.changed_taxa_taxon_list_ids
FROM taxa_taxon_lists
LIMIT 0;

-- Transfer ownership so normal warehouse user can read/write
ALTER TABLE uksi.changed_taxa_taxon_list_ids OWNER TO {{ warehouse_db_user }};