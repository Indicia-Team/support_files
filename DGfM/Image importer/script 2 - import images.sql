-- In order to run this script, the following tags need replacing
-- <taxon_list_id>
-- <min_row_to_process>
-- <max_row_to_process>


set search_path TO indicia, public;

-- Cycle through each image to import
DO
$do$
declare image_and_details_to_import RECORD;
BEGIN 
FOR image_and_details_to_import IN 
(
  select
    dttid.row_num,
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
  from dgfm.tbl_taxon_image_details dttid
) loop
  IF (image_and_details_to_import.row_num >= <min_row_to_process> and image_and_details_to_import.row_num <= <max_row_to_process>) THEN
    -- Insert image if doesn't already exist
    IF (NOT EXISTS (
      select tm.id
        from taxon_media tm
        join taxa_taxon_lists ttl on 
            ttl.taxon_meaning_id = tm.taxon_meaning_id
            AND ttl.taxon_list_id = <taxon_list_id>
            AND ttl.preferred = true
            AND ttl.deleted = false
        join indicia.taxa t on t.id = ttl.taxon_id AND t.deleted=false
        AND t.taxon = image_and_details_to_import.taxRef_gattung || ' ' || image_and_details_to_import.art 
        AND t.search_code = image_and_details_to_import.taxref_ID
        where 
            ((trim('"' from cast(cast(tm.exif as json)->'bildnummer' as text)) IS NULL
            AND
            image_and_details_to_import.bildnummer IS NULL)
            OR
            trim('"' from cast(cast(tm.exif as json)->'bildnummer' as text)) = image_and_details_to_import.bildnummer::text)
            AND tm.deleted=false))
    THEN
      insert into indicia.taxon_media(taxon_meaning_id,path,caption,created_on,created_by_id,updated_on,updated_by_id,external_details,media_type_id,exif)
      values (
          (select taxon_meaning_id from indicia.cache_taxa_taxon_lists where taxon_list_id = <taxon_list_id> and taxon = image_and_details_to_import.taxRef_gattung || ' ' || image_and_details_to_import.art),
          'comp_' || image_and_details_to_import.bildnummer,
          -- Caption must be 100 characters max 
          CASE WHEN 
            length(
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '') || ', ' ||
                  coalesce(image_and_details_to_import.landkreis, '') || ', ' || 
                  coalesce(image_and_details_to_import.anmerkung, '')
            ) < 101 AND image_and_details_to_import.landkreis IS NOT NULL AND image_and_details_to_import.anmerkung IS NOT NULL THEN
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '') || ', ' ||
                  coalesce(image_and_details_to_import.landkreis, '') || ', ' || 
                  coalesce(image_and_details_to_import.anmerkung, '')
          WHEN 
            length(
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '') || ', ' ||
                  coalesce(image_and_details_to_import.landkreis, '') || ', ' || 
                  coalesce(image_and_details_to_import.anmerkung, '')
            ) > 100 AND image_and_details_to_import.landkreis IS NOT NULL AND image_and_details_to_import.anmerkung IS NOT NULL THEN
              LEFT('Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '') || ', ' ||
                  coalesce(image_and_details_to_import.landkreis, '') || ', ' || 
                  coalesce(image_and_details_to_import.anmerkung, ''), 97) || '...'
          WHEN 
            length(
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '') || ', ' ||
                  coalesce(image_and_details_to_import.landkreis, '')
            ) < 101 AND image_and_details_to_import.landkreis IS NOT NULL THEN 
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '') || ', ' ||
                  coalesce(image_and_details_to_import.landkreis, '')
          ELSE 
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                    to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                    coalesce(image_and_details_to_import.bundesland, '')
          END,
          now(),
          1,
          now(),
          1,
          (
            CASE WHEN image_and_details_to_import.bildkategorie = 'det'
              THEN 'Detail'
            WHEN image_and_details_to_import.bildkategorie = 'sto'
              THEN 'Standort'
            WHEN image_and_details_to_import.bildkategorie = 'mik'
              THEN 'Mikrobild'
            else
              'Habitus'
            END
          ),
          123,
          cast(
             '{"bildnummer":"' || coalesce(image_and_details_to_import.bildnummer, '')  || '", ' || 
             '"taxRef_gattung":"' || coalesce(image_and_details_to_import.taxRef_gattung, '') || '", ' || 
             '"art":"' || coalesce(image_and_details_to_import.art, '') || '", ' || 
             '"taxref_ID":"' || coalesce(image_and_details_to_import.taxref_ID , '')|| '", ' || 
             '"bildkategorie":"' || coalesce(image_and_details_to_import.bildkategorie, '') || '", ' || 
             '"TKnr":"' || coalesce(image_and_details_to_import.TKnr, '') || '", ' || 
             '"TKname":"' || coalesce(image_and_details_to_import.TKname, '') || '", ' || 
             '"land":"' || coalesce(image_and_details_to_import.land, '') || '", ' || 
             '"bundesland":"' || coalesce(image_and_details_to_import.bundesland, '') || '", ' || 
             '"regierungsbezirk":"' || coalesce(image_and_details_to_import.regierungsbezirk, '') || '", ' || 
             '"landkreis":"'  || coalesce(image_and_details_to_import.landkreis, '') || '", ' || 
             '"fundort_1":"' || coalesce(image_and_details_to_import.fundort_1, '') || '", ' || 
             '"NN_hohe":"' || coalesce(image_and_details_to_import.NN_hohe, '') || '", ' || 
             '"koordinaten_1":"' || coalesce(image_and_details_to_import.koordinaten_1, '') || '", ' || 
             '"koordinaten_2":"' || coalesce(image_and_details_to_import.koordinaten_2, '') || '", ' || 
             '"begleitpflanzen":"' || coalesce(image_and_details_to_import.begleitpflanzen, '') || '", ' || 
             '"datum_gesammelt":"' || coalesce(image_and_details_to_import.datum_gesammelt, '') || '", ' || 
             '"leg":"' || coalesce(image_and_details_to_import.leg, '') || '", ' || 
             '"det":"' || coalesce(image_and_details_to_import.det, '') || '", ' || 
             '"conf":"' || coalesce(image_and_details_to_import.conf, '') || '", ' || 
             '"fot":"' || coalesce(image_and_details_to_import.fot, '') || '", ' || 
             '"herbar":"' || coalesce(image_and_details_to_import.herbar, '') || '", ' || 
             '"herbarbelegnr":"' || coalesce(image_and_details_to_import.herbarbelegnr, '') || '", ' || 
             '"anmerkung":"' || coalesce(image_and_details_to_import.anmerkung, '') || 
             '"}' as text)::jsonb
      );
    ELSE
    END IF;
  ELSE
  END IF;
END LOOP;
END
$do$;