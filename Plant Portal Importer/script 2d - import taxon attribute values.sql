  --Just perform one replacement for this script, mass replace 
  --<plant_portal_taxon_list_id>

  set search_path=indicia, public;

  DO
  $do$
  BEGIN

  insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
  values 
  ('Species constancy value','Species constancy value for Plant Portal project',(select id from websites where title='Plant Portal' and deleted=false),now(),1,now(),1,'indicia:species_constancy_value');
  
  perform insert_term('I','eng',null,'indicia:species_constancy_value');
  perform insert_term('II','eng',null,'indicia:species_constancy_value');
  perform insert_term('III','eng',null,'indicia:species_constancy_value');
  perform insert_term('IV','eng',null,'indicia:species_constancy_value');
  perform insert_term('V','eng',null,'indicia:species_constancy_value');

  insert into taxa_taxon_list_attributes (caption,data_type,termlist_id,created_on,created_by_id,updated_on,updated_by_id)
  values ('Species constancy value','T',(select id from termlists where title = 'Species constancy value' order by id desc limit 1),now(),1,now(),1);

  insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
  select <plant_portal_taxon_list_id>,id,now(),1
  from taxa_taxon_list_attributes
  where caption='Species constancy value'
  ORDER BY id DESC 
  LIMIT 1;

  insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
  values 
  ('Maximum abundance of species','I',now(),1,now(),1,'Maximum abundance species for plant portal project');

  insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
  select <plant_portal_taxon_list_id>,id,now(),1
  from taxa_taxon_list_attributes
  where caption='Maximum abundance of species'
  ORDER BY id DESC 
  LIMIT 1;

  END
  $do$;

  --Do the import itself.
  --Note as the attributes are for taxon/community combincations, then we hold the community (or sub-community) in the source_id field of the taxa_taxon_list_attribute_value
  set search_path TO indicia, public;
  DO
  $do$
  declare trait_to_import RECORD;
  BEGIN 
  FOR trait_to_import IN 
  (select distinct ittl.id as taxa_taxon_list_id,ppt.maximum_abundance_species as insertion_int,1,now(),1,now(),ittComm.id as comm_sub_comm_tt_id
    from plant_portal_importer.tbl_nvc_floristic_tables ppt
    join indicia.taxa it on it.external_key=ppt.preferred_tvk AND it.deleted=false
    join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<plant_portal_taxon_list_id> AND ittl.deleted=false
    --The community we are dealing with comes from the back end of the community_or_sub_community_name field, here we return everything after the last , and space. If there no sub-community then we just return the main community
    left join indicia.terms iTermComm on iTermComm.term=coalesce(substring(ppt.community_or_sub_community_name, '^.*,\s*(.*)$'),substring(ppt.community_or_sub_community_name, '^.*')) AND itermComm.deleted=false
    left join indicia.termlists_terms ittComm on ittComm.term_id=iTermComm.id AND ittComm.deleted=false
    left join termlists itlComm on itlComm.id = ittComm.termlist_id AND itlComm.title='Community or sub community name' AND itlComm.deleted=false
    left join websites wComm on wComm.id = itlComm.website_id AND wComm.title='Plant Portal' AND wComm.deleted=false
    left join indicia.termlists_terms ittCommParent on ittCommParent.id = ittComm.parent_id AND ittCommParent.deleted = false
    left join indicia.terms iTermCommParent on iTermCommParent.id=ittCommParent.term_id AND ittCommParent.deleted=false

  --If we are dealing with a sub-community, then it will have a parent which comes from the front of the community_or_sub_community_name field
  where (ittCommParent.id IS NULL OR iTermCommParent.term = substring(ppt.community_or_sub_community_name, '[^,]*')) AND ppt.maximum_abundance_species IS NOT NULL
  ) loop
  IF (NOT EXISTS (
    select ttlav2.id
    from taxa_taxon_list_attribute_values ttlav2
    join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
    --Need to check ttlav2.int_value=trait_to_import.insertion_int, we only don't want to do insertions
    --if the values exactly match. We should allow different values for the same species.
    where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Maximum abundance of species' and deleted=false order by id desc limit 1) AND ttlav2.int_value=trait_to_import.insertion_int AND ttlav2.int_value=trait_to_import.comm_sub_comm_tt_id AND ttlav2.deleted=false))
  THEN
    insert into
    indicia.taxa_taxon_list_attribute_values 
    (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
    values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Maximum abundance of species' and deleted=false order by id desc limit 1),trait_to_import.insertion_int,1,now(),1,now(),trait_to_import.comm_sub_comm_tt_id);
  ELSE 
  END IF;
  END LOOP;
  END
  $do$;

  --Do species constancy value import, difference is this is a termlist so slightly more complex
  set search_path TO indicia, public;
  DO
  $do$
  declare trait_to_import RECORD;
  BEGIN 
  FOR trait_to_import IN 
  (select distinct ittl.id as taxa_taxon_list_id, ittSCV.id as insertion_int,1,now(),1,now(),ittComm.id as comm_sub_comm_tt_id
    from plant_portal_importer.tbl_nvc_floristic_tables ppt
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
  where (ittCommParent.id IS NULL OR iTermCommParent.term = substring(ppt.community_or_sub_community_name, '[^,]*')) AND ittSCV.id IS NOT NULL
  ) loop
  IF (NOT EXISTS (
    select ttlav2.id
    from taxa_taxon_list_attribute_values ttlav2
    join taxa_taxon_lists ttl2 on ttl2.id = ttlav2.taxa_taxon_list_id AND ttl2.id=trait_to_import.taxa_taxon_list_id AND ttl2.deleted=false
    --Need to check ttlav2.int_value=trait_to_import.insertion_int, we only don't want to do insertions
    --if the values exactly match. We should allow different values for the same species.
    where ttlav2.taxa_taxon_list_attribute_id=(select id from taxa_taxon_list_attributes where caption='Species constancy value' and deleted=false order by id desc limit 1) AND ttlav2.int_value=trait_to_import.insertion_int AND ttlav2.int_value=trait_to_import.comm_sub_comm_tt_id AND ttlav2.deleted=false))
  THEN
    insert into
    indicia.taxa_taxon_list_attribute_values 
    (taxa_taxon_list_id,taxa_taxon_list_attribute_id,int_value,created_by_id,created_on,updated_by_id,updated_on,source_id)
    values (trait_to_import.taxa_taxon_list_id,(select id from taxa_taxon_list_attributes where caption='Species constancy value' and deleted=false order by id desc limit 1),trait_to_import.insertion_int,1,now(),1,now(),trait_to_import.comm_sub_comm_tt_id);
  ELSE 
  END IF;
  END LOOP;
  END
  $do$;