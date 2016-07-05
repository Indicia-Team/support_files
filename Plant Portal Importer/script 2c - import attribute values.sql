  --Just perform one replacement for this script, mass replace 
  --<plant_portal_taxon_list_id>

  set search_path=indicia, public;
  DO
  $do$
  declare trait_to_import RECORD;
  
  insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id)
  values ('Taxon community attributes','T',now(),1,now(),1);

  insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
  select <plant_portal_taxon_list_id>,id,now(),1
  from taxa_taxon_list_attributes
  where caption='Taxon community attributes'
  ORDER BY id DESC 
  LIMIT 1;

  insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
  values 
  ('Species constancy value','Species constancy value for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false),now(),1,now(),1,'indicia:species_constancy_value');
  
  perform insert_term('I','eng',null,'indicia:species_constancy_value');
  perform insert_term('II','eng',null,'indicia:species_constancy_value');
  perform insert_term('III','eng',null,'indicia:species_constancy_value');
  perform insert_term('IV','eng',null,'indicia:species_constancy_value');
  perform insert_term('V','eng',null,'indicia:species_constancy_value');

  insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
  values 
  ('Maximum abundance species','I',now(),1,now(),1,'Maximum abundance species for plant portal project');

  --We have a taxa_taxon_list_attribute and we want to set a taxon_list for it
  --We need to make sure we set it for the correct taxa_taxon_list_attribute though, it is possible there might be more than one with the same name, so we can order them latest first and just take the most recent one (which is be the one we just created)
  insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
  select <plant_portal_taxon_list_id>,id,now(),1
  from taxa_taxon_list_attributes
  where caption='Maximum abundance species'
  ORDER BY id DESC 
  LIMIT 1;

  --Do the import itself.
  set search_path TO indicia, public;
  FOR trait_to_import IN 
  (select distinct ittl.id as taxa_taxon_list_id, '{"comm_sub_comm_tt_id' || '":' || ittComm.id ||',"species_constancy_val_tt_id":' || ittSCV.id || ',"max_abundance_species_val":'|| ppt.maximum_abundance_species ||'}' as insertion_text,1,now(),1,now()
    from plant_portal.tbl_nvc_floristic_tables ppt
    join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
    join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false

    left join indicia.terms iTermSCV on iTermSCV.term=ppt.species_constancy_value AND itermSCV.deleted=false
    left join indicia.termlists_terms ittSCV on ittSCV.term_id=iTermSCV.id AND ittSCV.deleted=false
    left join termlists itlSCV on itlSCV.id = ittSCV.termlist_id AND itlSCV.title='Species constancy value' AND itlSCV.deleted=false
    left join websites wSCV on wSCV.id = itlSCV.website_id AND wSCV.title='Plant Portal' AND wSCV.deleted=false
    --The community we are dealing with comes from the back end of the community_or_sub_community_name field, here we return everything after the last , and space. If there no sub-community then we just return the main community
    left join indicia.terms iTermComm on iTermComm.term=coalesce(substring(ppt.community_or_sub_community_name, '^.*,\s*(.*)$'),substring(ppt.community_or_sub_community_name, '^.*')) AND itermComm.deleted=false
    left join indicia.termlists_terms ittComm on ittComm.term_id=iTermComm.id AND ittComm.deleted=false
    left join termlists itlComm on itlComm.id = ittComm.termlist_id AND itlComm.title='Community or sub community name' AND itlComm.deleted=false
    left join websites wComm on wComm.id = itlComm.website_id AND wComm.title='Plant Portal' AND wComm.deleted=false
    left join indicia.termlists_terms ittCommParent on ittCommParent.id = ittComm.parent_id AND ittCommParent.deleted = false
    left join indicia.terms iTermCommParent on iTermCommParent.id=ittCommParent.term_id AND ittCommParent.deleted=false

  --If we are dealing with a sub-community, then it will have a parent which comes from the front of the community_or_sub_community_name field
  where (ittCommParent.id IS NULL OR iTermCommParent.term = substring(ppt.community_or_sub_community_name, '[^,]*'))
  ) loop
  IF (NOT EXISTS (
    select ttlav2.id
    from taxa_taxon_list_attribute_values ttlav2
    join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
    --Need to check ttlav2.text_value=trait_to_import.insertion_text, we only don't want to do insertions
    --if the values exactly match. We should allow different values for the same species.
    where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Taxon community attributes' and deleted=false order by id desc limit 1) AND ttlav2.text_value=trait_to_import.insertion_text AND  ttlav2.deleted=false))
  THEN
    insert into
    indicia.taxa_taxon_list_attribute_values 
    (taxa_taxon_list_id,taxa_taxon_list_attribute_id,text_value,created_by_id,created_on,updated_by_id,updated_on)
    values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Taxon community attributes' and deleted=false order by id desc limit 1),trait_to_import.insertion_text,1,now(),1,now());
  ELSE 
  END IF;
  END LOOP;
  END
  $do$;

