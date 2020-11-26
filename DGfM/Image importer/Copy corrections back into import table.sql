-- Script allows failing rows which have been corrected to be copied back into the import
-- table ready for re-import

-- In order to run this script, the following tag needs replacing
-- <failing_row_table_name> (The table we are copying errors from might vary, although usually this would be dgfm.tbl_taxon_image_details_failed_rows)
-- <where_statement>

-- Use the where_statement to make sure only rows from the same original file are copied back into the
-- import table as different spreadsheets should be imported separately 
-- (because the name in the failing_file_name column needs to be set)
INSERT INTO dgfm.tbl_taxon_image_details
  (row_num,
  bildnummer,
  taxRef_gattung,
  art,
  taxref_ID,
  bildkategorie,
  TKnr,
  TKname,
  land,
  bundesland,
  regierungsbezirk,
  landkreis,
  fundort_1,
  NN_hohe,
  koordinaten_1,
  koordinaten_2,
  begleitpflanzen,
  datum_gesammelt,
  leg,
  det,
  conf,
  fot,
  herbar,
  herbarbelegnr,
  anmerkung)
SELECT
  failing_row_num,
  bildnummer,
  taxRef_gattung,
  art,
  taxref_ID,
  bildkategorie,
  TKnr,
  TKname,
  land,
  bundesland,
  regierungsbezirk,
  landkreis,
  fundort_1,
  NN_hohe,
  koordinaten_1,
  koordinaten_2,
  begleitpflanzen,
  datum_gesammelt,
  leg,
  det,
  conf,
  fot,
  herbar,
  herbarbelegnr,
  anmerkung
FROM 
<failing_row_table_name>
<where_statement>;