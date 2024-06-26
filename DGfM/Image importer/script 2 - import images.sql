-- In order to run this script, the following tags need replacing
-- 1. <csv_filename> (just used for error logging)
-- 2. <taxon_list_id>
  -- Important note: This refers to the number in the row_num column which is the row number from the original spreadsheet,
  -- it is NOT the row number in the table e.g. there could be just two rows left to process, but their row numbers could be 500 & 1000
  -- so you must make sure that range is covered
-- 3. <min_row_to_process>
-- 4. <max_row_to_process>
-- 5. <filename_prefix> (the supplied image files have typically had an extra prefix in the name in comparison to what is in the spreadsheet's
-- bildnummer column. Specify what this prefix is using this tag.
-- e.g Agaricus_altipes_00162_FHampe_hab.jpg is listed in the spreadsheet but the file is actually called Funga_Agaricus_altipes_00162_FHampe_hab.jpg
-- In this case, replace the <filename_prefix> tag with Funga_
-- Note that it is assumed all the files in the import batch have the same prefix)

-- Note: This script assumes all the images provided are jpgs


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
  -- Important note: This refers to the number in the row_num column which is the row number from the original spreadsheet,
  -- it is NOT the row number in the table.
  IF (image_and_details_to_import.row_num >= <min_row_to_process> and image_and_details_to_import.row_num <= <max_row_to_process>) THEN
    -- Insert image if doesn't already exist
    BEGIN
      IF (NOT EXISTS (
        select tm.id
          from taxon_media tm
          join taxa_taxon_lists ttl on 
              ttl.taxon_meaning_id = tm.taxon_meaning_id
              AND ttl.taxon_list_id = <taxon_list_id>
              --AND ttl.preferred = true
              AND ttl.deleted = false
          join indicia.taxa t on t.id = ttl.taxon_id AND t.deleted=false
          -- regexp_replace allows all white space (such as tabs) to be removed, not just space characters
          AND 
          ((regexp_replace(image_and_details_to_import.taxRef_gattung || image_and_details_to_import.art, '\s', '', 'g') = regexp_replace(t.taxon, '\s', '', 'g')) OR 
           (regexp_replace(image_and_details_to_import.taxRef_gattung || image_and_details_to_import.art || 'agg.', '\s', '', 'g')  = regexp_replace(t.taxon, '\s', '', 'g')))
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
          -- regexp_replace allows all white space (such as tabs) to be removed, not just space characters
          (select taxon_meaning_id 
          from indicia.cache_taxa_taxon_lists 
          where taxon_list_id = <taxon_list_id> and 
          ((regexp_replace(taxon, '\s', '', 'g')  = regexp_replace(image_and_details_to_import.taxRef_gattung || image_and_details_to_import.art, '\s', '', 'g')) OR 
           (regexp_replace(taxon, '\s', '', 'g')  = regexp_replace(image_and_details_to_import.taxRef_gattung || image_and_details_to_import.art || 'agg.', '\s', '', 'g')))),
          '<filename_prefix>' || image_and_details_to_import.bildnummer || '.jpg',
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
          WHEN 
            length(
  '             Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '')
              ) < 101 AND image_and_details_to_import.bundesland IS NOT NULL THEN 
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY') || ', ' ||
                  coalesce(image_and_details_to_import.bundesland, '')
          ELSE 
              'Foto: ' || coalesce(image_and_details_to_import.fot, '')  || ', ' ||
                  to_char(cast(image_and_details_to_import.datum_gesammelt as date), 'DD.MM.YYYY')
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
          json_build_object(
            'bildnummer', image_and_details_to_import.bildnummer,
            'taxRef_gattung', image_and_details_to_import.taxRef_gattung,
            'art', image_and_details_to_import.art,
            'taxref_ID', image_and_details_to_import.taxref_ID,
            'bildkategorie', image_and_details_to_import.bildkategorie,
            'TKnr', image_and_details_to_import.TKnr,
            'TKname', image_and_details_to_import.TKname,
            'land', image_and_details_to_import.land,
            'bundesland', image_and_details_to_import.bundesland,
            'regierungsbezirk', image_and_details_to_import.regierungsbezirk,
            'landkreis', image_and_details_to_import.landkreis,
            'fundort_1', image_and_details_to_import.fundort_1,
            'NN_hohe', image_and_details_to_import.NN_hohe,
            'koordinaten_1', image_and_details_to_import.koordinaten_1,
            'koordinaten_2', image_and_details_to_import.koordinaten_2,
            'begleitpflanzen', image_and_details_to_import.begleitpflanzen,
            'datum_gesammelt', image_and_details_to_import.datum_gesammelt,
            'leg', image_and_details_to_import.leg,
            'det', image_and_details_to_import.det,
            'conf', image_and_details_to_import.conf,
            'fot', image_and_details_to_import.fot,
            'herbar', image_and_details_to_import.herbar,
            'herbarbelegnr', image_and_details_to_import.herbarbelegnr,
            'anmerkung', image_and_details_to_import.anmerkung
          )
        );

        -- If the row has previously been logged as failing, then remove the logged failing row as it has now been inserted
        IF (EXISTS (
          select failing_row_num
          from dgfm.tbl_taxon_image_details_failed_rows ttidfr
          where ttidfr.bildnummer::text = image_and_details_to_import.bildnummer::text
        ))
        THEN
          delete from dgfm.tbl_taxon_image_details_failed_rows ttidfr      
          where ttidfr.bildnummer::text = image_and_details_to_import.bildnummer::text;
        ELSE
        END IF;
      ELSE
      END IF;

      EXCEPTION WHEN others THEN
        IF (NOT EXISTS (
          select failing_row_num
          from dgfm.tbl_taxon_image_details_failed_rows ttidfr
          where ttidfr.bildnummer::text = image_and_details_to_import.bildnummer::text
        ))
        THEN
          insert into dgfm.tbl_taxon_image_details_failed_rows(
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
            anmerkung,
            failing_file_name,
            failing_row_num,
            warning_text
          )
          values(
            image_and_details_to_import.bildnummer,
            image_and_details_to_import.taxRef_gattung,
            image_and_details_to_import.art,
            image_and_details_to_import.taxref_ID,
            image_and_details_to_import.bildkategorie,
            image_and_details_to_import.TKnr,
            image_and_details_to_import.TKname,
            image_and_details_to_import.land,
            image_and_details_to_import.bundesland,
            image_and_details_to_import.regierungsbezirk,
            image_and_details_to_import.landkreis,
            image_and_details_to_import.fundort_1,
            image_and_details_to_import.NN_hohe,
            image_and_details_to_import.koordinaten_1,
            image_and_details_to_import.koordinaten_2,
            image_and_details_to_import.begleitpflanzen,
            image_and_details_to_import.datum_gesammelt,
            image_and_details_to_import.leg,
            image_and_details_to_import.det,
            image_and_details_to_import.conf,
            image_and_details_to_import.fot,
            image_and_details_to_import.herbar,
            image_and_details_to_import.herbarbelegnr,
            image_and_details_to_import.anmerkung,
            '<csv_filename>',
            image_and_details_to_import.row_num,
            SQLERRM
          );
        ELSE
        END IF;
    END;
  ELSE
  END IF;
END LOOP;
END
$do$;

-- Strip extra jpg extensions which can occur because bildnummer
-- sometimes include .jpg and sometimes doesn't
update indicia.taxon_media
set path = replace(path,'.jpg.jpg','.jpg')
where path like '%.jpg.jpg%';

update indicia.taxon_media
set path = replace(path,'.JPG.jpg','.jpg')
where path like '%.JPG.jpg%';
