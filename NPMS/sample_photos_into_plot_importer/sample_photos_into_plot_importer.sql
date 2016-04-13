
--As part of NPMS's initial design, it was decided that samples should hold the plot photos and sketches.
--The plan moving forward is now to only keep the photos on the sample (as these change over time), and attach the sketches to the plot location.
--This means we need to move the sketches onto the plot location. However, as we can't tell the difference between a photo and sketch, we
--are moving all the photos and sketches, then advising users to attach the photos to the sample and sketches to the plot going forward.

--Note to run this file, you need to do a replacement on <survey_ids>, <website_id>

set search_path TO indicia, public;
DO
$do$
declare sample_photo_to_import RECORD;
BEGIN 
FOR sample_photo_to_import IN 
(select smp.location_id as smp_location_id,smp_med.path as smp_med_path,smp_med.caption as smp_med_caption,smp_med.created_on as smp_med_created_on,smp_med.created_by_id as smp_med_created_by_id,smp_med.updated_on as smp_med_updated_on,smp_med.updated_by_id as smp_med_updated_by_id,smp_med.media_type_id as smp_med_media_type_id,smp_med.exif as smp_med_exif,smp_med.id as smp_med_id
from indicia.sample_media smp_med
join samples smp on smp.id = smp_med.sample_id AND smp.survey_id in (<survey_ids>) AND smp.location_id IS NOT NULL AND smp.deleted=false
--Note strictly needed, but best to do a check on the website id too
join surveys surv on surv.id = smp.survey_id AND surv.website_id = <website_id> AND surv.deleted=false
where smp_med.deleted=false
)
loop
--Avoid adding items twice, particularly usefuly if script is accidently run twice
IF (NOT EXISTS (
select loc_med.id
from indicia.location_media loc_med
where loc_med.deleted=false 
AND loc_med.location_id=sample_photo_to_import.smp_location_id
AND loc_med.caption=sample_photo_to_import.smp_med_caption
AND loc_med.path=sample_photo_to_import.smp_med_path
AND loc_med.media_type_id=sample_photo_to_import.smp_med_media_type_id
))
THEN
insert into
indicia.location_media (location_id,path,caption,created_on,created_by_id,updated_on,updated_by_id,deleted,media_type_id,exif)
values (sample_photo_to_import.smp_location_id,sample_photo_to_import.smp_med_path,sample_photo_to_import.smp_med_caption,sample_photo_to_import.smp_med_created_on,sample_photo_to_import.smp_med_created_by_id,sample_photo_to_import.smp_med_updated_on,sample_photo_to_import.smp_med_updated_by_id,false,sample_photo_to_import.smp_med_media_type_id,sample_photo_to_import.smp_med_exif);
--Delete 
update sample_media
set deleted=true
where id = sample_photo_to_import.smp_med_id;

ELSE 
END IF;
END LOOP;
END
$do$;






