SELECT smp.id as sample_id, o.id as occurrence_id, o.taxon,o.default_common_name as common_name,o.taxon_group,
  smp.entered_sref as full_precision_spatial_Ref,smp.entered_sref_system, to_char(o.date_start,'DD/MM/YYYY') as date,
  savFirstName.text_value as first_name,savLastName.text_value as last_name,
  savAddress.text_value as address, savPostCode.text_value as post_code, savEmail.text_value as email, 
  case when savContact.int_value IS NULL OR savContact.int_value=0 THEN 'No' else 'Yes' END as happy_to_be_contacted,
  case when savSunsetOrRise.int_value=5968 then 'Sunrise' when savSunsetOrRise.int_value=5967 then 'Sunset' when savSunsetOrRise.int_value IS null then '' else 'Problem with report detected, please contact developer' end as sunset_or_sunrise,
  savSurveyorNum.int_value as Number_of_surveyors, 
  case when savSeeBats.int_value=36 then 'No' when savSeeBats.int_value=35 then 'Yes' when savSeeBats.int_value IS null then '' else 'Problem with report detected, please contact developer' end as did_you_see_bats,
  case when oavBatId.int_value=5974 then 'Visual sighting from a distance' 
     when oavBatId.int_value=5975 then 'Heterodyne bat detector' 
     when oavBatId.int_value=5976 then 'Frequency division bat detector' 
     when oavBatId.int_value=5977 then 'Zero crossing bat detector' 
     when oavBatId.int_value=5978 then 'Time expansion of full spectrum bat detector' 
     when oavBatId.int_value=5979 then 'Unspecified type of bat detector' 
     when oavBatId.int_value=6108 then 'Other'
     when oavBatId.int_value IS null then ''
         else 'Problem with report detected, please contact developer' end as how_did_you_identify_the_bat,
  case when oavSightingType.int_value=5969 then 'In flight' 
     when oavSightingType.int_value=5970 then 'Roost' 
     when oavSightingType.int_value=5971 then 'Swarming' 
     when oavSightingType.int_value=5972 then 'Bat box'
     when oavSightingType.int_value=5973 then 'Display perch'
     when oavSightingType.int_value IS null then ''
         else 'Problem with report detected, please contact developer' end as type_of_sighting,
  case when oavGridId.text_value = 'bat-grid' then 'Bat (grid 1)' 
     when oavGridId.text_value = 'other-pre-loaded-grid' then 'Other (grid 2 pre-populated)' 
     when oavGridId.text_value = 'other-free-text-grid' then 'Other (grid 3 free entry)' 
     when oavGridId.text_value IS null then ''
     else 'Problem with report detected, please contact developer' end as entry_grid
  FROM samples smp
  LEFT JOIN cache_occurrences o on o.sample_id=smp.id
  JOIN surveys surv on surv.id = smp.survey_id AND smp.survey_id=376 AND surv.deleted=false	
  JOIN websites w on w.id=surv.website_id AND w.id = 23 and w.deleted=false
  JOIN sample_attribute_values savFirstName on savFirstName.sample_id = smp.id AND savFirstName.sample_attribute_id = 36 AND savFirstName.deleted=false
  JOIN sample_attribute_values savLastName on savLastName.sample_id = smp.id AND savLastName.sample_attribute_id = 37 AND savLastName.deleted=false
  JOIN sample_attribute_values savEmail on savEmail.sample_id = smp.id AND savEmail.sample_attribute_id = 8 AND savEmail.deleted=false
  JOIN sample_attribute_values savSurveyorNum on savSurveyorNum.sample_id = smp.id AND savSurveyorNum.sample_attribute_id = 763 AND savSurveyorNum.deleted=false
  JOIN sample_attribute_values savSunsetOrRise on savSunsetOrRise.sample_id = smp.id AND savSunsetOrRise.sample_attribute_id = 762 AND savSunsetOrRise.deleted=false
  JOIN sample_attribute_values savSeeBats on savSeeBats.sample_id = smp.id AND savSeeBats.sample_attribute_id = 764 AND savSeeBats.deleted=false
  LEFT JOIN sample_attribute_values savAddress on savAddress.sample_id = smp.id AND savAddress.sample_attribute_id = 9 AND savAddress.deleted=false
  LEFT JOIN sample_attribute_values savPostCode on savPostCode.sample_id = smp.id AND savPostCode.sample_attribute_id = 57 AND savPostCode.deleted=false
  LEFT JOIN sample_attribute_values savContact on savContact.sample_id = smp.id AND savContact.sample_attribute_id = 765 AND savContact.deleted=false
  LEFT JOIN occurrence_attribute_values oavBatId on oavBatId.occurrence_id = o.id AND oavBatId.occurrence_attribute_id = 525 AND oavBatId.deleted=false
  LEFT JOIN occurrence_attribute_values oavSightingType on oavSightingType.occurrence_id = o.id AND oavSightingType.occurrence_attribute_id = 524 AND oavSightingType.deleted=false
  LEFT JOIN occurrence_attribute_values oavGridId on oavGridId.occurrence_id = o.id AND oavGridId.occurrence_attribute_id = 153 AND oavGridId.deleted=false
  WHERE smp.deleted=false
  GROUP by smp.id, oavGridId.text_value, o.id,o.taxon,o.default_common_name,o.taxon_group,o.date_start,savfirstname.text_value,savLastName.text_value,savAddress.text_value,
savPostCode.text_value,savEmail.text_value,savContact.int_value,savsunsetorrise.int_value,savsurveyornum.int_value,savSeeBats.int_value,oavBatId.int_value,oavSightingType.int_value
  order by o.id, entry_grid asc
