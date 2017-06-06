--Import term attributes for communities
set search_path=indicia, public;
DO
$do$
declare termlists_term_attribute_to_import RECORD;
declare trait_to_import RECORD;
BEGIN
FOR termlists_term_attribute_to_import IN 
(select distinct preferred_tvk from plant_portal_importer.tbl_nvc_floristic_tables 
where species_constancy_value is null
order by preferred_tvk) loop
--Each one is an integer attribute value
insert into termlists_term_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id)
values (
termlists_term_attribute_to_import.preferred_tvk
,'I',now(),1,now(),1);

insert into termlists_termlists_term_attributes (termlists_term_attribute_id,termlist_id,created_on,created_by_id)
values (
(select id from termlists_term_attributes where caption = termlists_term_attribute_to_import.preferred_tvk and deleted=false order by id desc limit 1),
(select id from termlists where title = 'Community or sub community name' and deleted=false order by id desc limit 1)
,now(),1);
END LOOP;

--Do the import itself.
FOR trait_to_import IN 
(select ittComm.id as termlists_term_id,tta.id as termlists_term_attribute_id,ppt.special_variable_value as insertion_value,1,now(),1,now()	
 from plant_portal_importer.tbl_nvc_floristic_tables ppt
  --The community we are dealing with comes from the back end of the community_or_sub_community_name field, here we return everything after the last , and space. If there no sub-community then we just return the main community
  join indicia.terms iTermComm on iTermComm.term=coalesce(substring(ppt.community_or_sub_community_name, '^.*,\s*(.*)$'),substring(ppt.community_or_sub_community_name, '^.*')) AND itermComm.deleted=false
  join indicia.termlists_terms ittComm on ittComm.term_id=iTermComm.id AND ittComm.deleted=false
  join termlists itlComm on itlComm.id = ittComm.termlist_id AND itlComm.title='Community or sub community name' AND itlComm.deleted=false
  join websites wComm on wComm.id = itlComm.website_id AND wComm.title='Plant Portal' AND wComm.deleted=false
  left join indicia.termlists_terms ittCommParent on ittCommParent.id = ittComm.parent_id AND ittCommParent.deleted = false
  left join indicia.terms iTermCommParent on iTermCommParent.id=ittCommParent.term_id AND ittCommParent.deleted=false

  join termlists_term_attributes tta on tta.caption=ppt.preferred_tvk AND tta.deleted=false
  join termlists_termlists_term_attributes ttla on ttla.termlists_term_attribute_id = tta.id AND ttla.termlist_id = itlComm.id AND ttla.deleted=false

  --If we are dealing with a sub-community, then it will have a parent which comes from the front of the community_or_sub_community_name field
  where (ittCommParent.id IS NULL OR iTermCommParent.term = substring(ppt.community_or_sub_community_name, '[^,]*')) AND ppt.special_variable_value IS NOT NULL AND ppt.special_variable_value != '888'
) loop
IF (NOT EXISTS (
  select ttav2.id
  from termlists_term_attribute_values ttav2
  where ttav2.termlists_term_id = trait_to_import.termlists_term_id AND
  ttav2.termlists_term_attribute_id = trait_to_import.termlists_term_attribute_id AND 
  ttav2.int_value = trait_to_import.insertion_value AND 
  ttav2.deleted=false))
THEN
  insert into
  indicia.termlists_term_attribute_values 
  (termlists_term_id,termlists_term_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on)
  values (trait_to_import.termlists_term_id,trait_to_import.termlists_term_attribute_id,trait_to_import.insertion_value,1,now(),1,now());
ELSE 
END IF;
END LOOP;
END
$do$;







