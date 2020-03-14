
--AVB this removal is new, we keep using the word freetext for the "Other" option
--Cleanup data
--update dgfm.tbl_attributes
--set deu_type = replace(deu_type, 'Freitext', 'Andere')
--where lower(deu_type) like '%freitext%' AND lower(deu_type) != 'freitext';

--AVB make sure deu_type isn't empty and gb_type isn't empty, also deu_attribute and gb_attribute

--Don't set colour wheel to Text type here, as we need to know the type is colour wheel later on
update dgfm.tbl_attributes
set gb_type = 'T', deu_type = 'T', cz_type = 'T'
where lower(TRIM(BOTH FROM deu_type)) in ('freitext', 'Freitext', 'null', '') or lower(TRIM(BOTH FROM deu_type)) IS NULL;

update dgfm.tbl_attributes
set gb_type = 'F', deu_type = 'F', cz_type = 'F'
where lower(TRIM(BOTH FROM deu_type)) = 'numerisch';

update dgfm.tbl_attributes
set colour_attribute_description = 'free colour wheel', gb_type = 'T', deu_type = 'T', cz_type = 'T'
where lower(TRIM(BOTH FROM deu_type)) = 'farbe' AND lower(TRIM(BOTH FROM gb_type)) like '%colour wheel%';

-- Set any over attributes that include the word colour and aren't colour wheels to be a discrete colour termlist
update dgfm.tbl_attributes
set colour_attribute_description = 'discrete colour selector'
where lower(TRIM(BOTH FROM gb_attribute)) like '%colour%' AND colour_attribute_description IS NULL;

-- If terms include both yes and no answers then don't allow multi-value
update dgfm.tbl_attributes
set multi_value = false
where (lower(deu_type) like '%ja%' and lower(deu_type) like '%nein%')
OR (colour_attribute_description = 'free colour wheel')
OR (colour_attribute_description = 'discrete colour selector')
OR deu_type in ('T', 'I', 'F', 'D', 'V', 'B');

update dgfm.tbl_attributes
set deu_area='Mikromerkmale'
where deu_area='MIkromerkmale';

update dgfm.tbl_attribute_set_allocations
set deu_area='Mikromerkmale'
where deu_area='MIkromerkmale';

-- Make any termlists consistent by always separating them with , rather than sometimes with the supplied /
update dgfm.tbl_attributes
set deu_type = replace(deu_type , '/', ',')
where deu_type not like '%,%';

update dgfm.tbl_attributes
set gb_type = replace(gb_type , '/', ',')
where deu_type not like '%,%';

update dgfm.tbl_attributes
set cz_type = replace(cz_type , '/', ',')
where deu_type not like '%,%';

delete from dgfm.tbl_attributes where row_num is null;

update dgfm.tbl_attributes
set deu_area=LEFT(TRIM(BOTH from deu_area),200);

update dgfm.tbl_attributes
set gb_area=LEFT(TRIM(BOTH from gb_area),200);

update dgfm.tbl_attributes
set cz_area=LEFT(TRIM(BOTH from cz_area),200);

update dgfm.tbl_attributes
set deu_sub_area=LEFT(TRIM(BOTH from deu_sub_area),200);

update dgfm.tbl_attributes
set gb_sub_area=LEFT(TRIM(BOTH from gb_sub_area),200);

update dgfm.tbl_attributes
set cz_sub_area=LEFT(TRIM(BOTH from cz_sub_area),200);
