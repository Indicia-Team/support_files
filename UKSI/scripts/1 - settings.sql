/*
 Put some settings into tables, so we can refer to them as we go along.
 Replace
 * taxonListId with the UKSI master list ID (15?)
 * updatedByUserId with your warehouse user ID (or create a user ID for UKSI updates and use that).
*/

SET search_path = indicia, public;

-- Ensure schema exists and is owned by the warehouse DB user.
CREATE SCHEMA IF NOT EXISTS uksi AUTHORIZATION {{ warehouse_db_user }};
GRANT USAGE, CREATE ON SCHEMA uksi TO {{ warehouse_db_user }};

-- Drop any existing working tables from previous runs.
DROP TABLE IF EXISTS uksi.all_uksi_taxon_lists;
DROP TABLE IF EXISTS uksi.uksi_settings;

-- Create the all_uksi_taxon_lists table.
SELECT id
INTO uksi.all_uksi_taxon_lists
FROM taxon_lists
WHERE parent_id = {{ taxon_list_id }}
   OR id = {{ taxon_list_id }};

-- Transfer ownership so later scripts (running as warehouse user) have full access.
ALTER TABLE uksi.all_uksi_taxon_lists OWNER TO {{ warehouse_db_user }};

-- Create the uksi_settings table.
SELECT {{ taxon_list_id }} AS uksi_taxon_list_id,
       {{ user_id }}       AS updated_by_user_id
INTO uksi.uksi_settings;

-- Transfer ownership of the settings table.
ALTER TABLE uksi.uksi_settings OWNER TO {{ warehouse_db_user }};
