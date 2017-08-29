
--Replace the following tag with the path to your csv data files
--<csv_nvc_floristic_tables_file_path>
--Path format (on mac) should be like '/users/joebloggs/nvc_floristic_tables.csv'
--Replace the following tag with the taxon_list_id we are importing into
--<taxa_taxon_list_id_to_import_into>

set search_path TO plant_portal_importer, public;

CREATE TABLE tbl_nvc_floristic_tables (
row_number integer,
community_or_sub_community_code varchar,
community_or_sub_community_name varchar,
community_level_code varchar,
species_name_or_special_variable varchar,
species_constancy_value varchar,
maximum_abundance_species integer,
special_variable_value integer,
preferred_tvk varchar
);

COPY tbl_nvc_floristic_tables
FROM <csv_nvc_floristic_tables_file_path>
WITH DELIMITER ','
CSV HEADER;

--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

DO
$do$
DECLARE row_to_import RECORD;
DECLARE community_or_sub_community_name_to_split_array varchar[];
DECLARE community_name_to_use varchar;
DECLARE code_name_to_use varchar;
DECLARE insertion_counter integer;
BEGIN
insertion_counter=0;

set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Community or sub community name','Community or sub community names for Plant Portal',(select id from websites where title='Plant Portal' and deleted=false),now(),1,now(),1,'indicia:community_or_sub_community_name');
  --Loop through the data rows
  FOR row_to_import IN
  (select DISTINCT ppt.community_or_sub_community_name as community_or_sub_community_name_to_split, ppt.community_level_code as community_level_code, ppt.community_or_sub_community_code as community_or_sub_community_code
  from plant_portal_importer.tbl_nvc_floristic_tables ppt
  where ppt.community_or_sub_community_name IS NOT NULL
  ) loop
    --Split up the community and sub-community names for the row
    community_or_sub_community_name_to_split_array = string_to_array(row_to_import.community_or_sub_community_name_to_split, ', ');
    --Cycle through the communities and sub-communities for each row
    FOR i IN array_lower(community_or_sub_community_name_to_split_array, 1) .. array_upper(community_or_sub_community_name_to_split_array, 1)
      LOOP
        insertion_counter=insertion_counter+1;
        --As the Community is the first item in the row, and after that are the sub-communities, it means
        --if i is greater than 1, we are looking at a sub-community
        IF i>1 THEN
          --We need to add a unique number to the end of the sub communities as a limitation of insert_term is it 
          --will try to avoid adding duplicates within the sme termlist, however we want duplicate sub-community names
          --as their parents might be different.
          --This nymber is removed further down the script
          community_name_to_use=(community_or_sub_community_name_to_split_array)[i] || '|' ||insertion_counter;
          code_name_to_use = row_to_import.community_or_sub_community_code;
        ELSE
          community_name_to_use=(community_or_sub_community_name_to_split_array)[i];
          code_name_to_use = row_to_import.community_level_code;
        END IF;
        perform insert_term(community_name_to_use,'eng',null,'indicia:community_or_sub_community_name');
        perform insert_term(code_name_to_use,'eng',null,'indicia:community_or_sub_community_name');
        
        -- Updated the meaning id of the community code to be the same as the community name so it appears as a synonym (must also have preferred set false, but this is set further down script,_
        --see notes there for information about this
        update termlists_terms
        set meaning_id = 
        (select itt.meaning_id
          from indicia.termlists_terms itt 
          join termlists itl on itl.id = itt.termlist_id AND itl.title='Community or sub community name' AND itl.deleted=false
          join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
          join terms t on t.id=itt.term_id AND t.term=community_name_to_use
          order by itt.id desc
          limit 1)
        where id = 
          (select tt.id 
          from termlists_terms tt
          join terms t on t.id = tt.term_id and t.term = code_name_to_use and t.deleted=false
          where tt.deleted=false
          order by id desc
          limit 1);

        --update the parent_id of any sub-communities as appropriate as the community needs to be the parent
        IF i>1 then
          update termlists_terms
          set parent_id = 
            (select itt.id
              from indicia.termlists_terms itt 
              join termlists itl on itl.id = itt.termlist_id AND itl.title='Community or sub community name' AND itl.deleted=false
              join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
              join terms t on t.id=itt.term_id AND t.term=community_or_sub_community_name_to_split_array[1]
              order by itt.id desc
              limit 1)
          where id = 
            (select itt.id
              from indicia.termlists_terms itt 
              join termlists itl on itl.id = itt.termlist_id AND itl.title='Community or sub community name' AND itl.deleted=false
              join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
              join terms t on t.id=itt.term_id AND t.term=community_name_to_use
              order by itt.id desc
              limit 1);
          --Remove the unique number at the end of the sub-community name. See notes on this earlier in the script
          update terms
          set term = trim(substring(term, '^(.*?)\|'||insertion_counter))
          where id = 
          (
            select itt.term_id
            from indicia.termlists_terms itt 
            join termlists itl on itl.id = itt.termlist_id AND itl.title='Community or sub community name' AND itl.deleted=false
            join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
            join terms t on t.id=itt.term_id AND t.term=community_name_to_use
            order by itt.id desc
            limit 1
          );
        ELSE
        END IF;
      END LOOP;         
  END LOOP;

  --Take a second pass of the data and make sure the community codes are not preferred so they appear as synonyms.
  --In theory we could have done this on the first pass, but the insert_term function seems to insert duplicates unless
  --the flag is preferred, so we can only switch the preferred flag off aftwards
  FOR row_to_import IN
  (select DISTINCT ppt.community_level_code as community_level_code, ppt.community_or_sub_community_code as community_or_sub_community_code
  from plant_portal_importer.tbl_nvc_floristic_tables ppt
  where ppt.community_or_sub_community_name IS NOT NULL
  ) loop
    update termlists_terms
    set preferred=false
    where id in
    (
      select tt.id
      from termlists_terms tt
      join terms t on t.id = tt.term_id AND t.deleted=false AND (t.term = row_to_import.community_level_code OR t.term = row_to_import.community_or_sub_community_code)
    );
  END LOOP;

END
$do$;






--Import term attributes for communities
set search_path=indicia, public;
DO
$do$
declare termlists_term_attribute_to_import RECORD;
declare trait_to_import RECORD;
BEGIN
FOR termlists_term_attribute_to_import IN 
(select distinct species_name_or_special_variable from plant_portal_importer.tbl_nvc_floristic_tables 
where species_constancy_value is null
order by species_name_or_special_variable) loop
--Each one is an integer attribute value
insert into termlists_term_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id)
values (
termlists_term_attribute_to_import.species_name_or_special_variable
,'I',now(),1,now(),1);

insert into termlists_termlists_term_attributes (termlists_term_attribute_id,termlist_id,created_on,created_by_id)
values (
(select id from termlists_term_attributes where caption = termlists_term_attribute_to_import.species_name_or_special_variable and deleted=false order by id desc limit 1),
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

  join termlists_term_attributes tta on tta.caption=ppt.species_name_or_special_variable AND tta.deleted=false
  join termlists_termlists_term_attributes ttla on ttla.termlists_term_attribute_id = tta.id AND ttla.termlist_id = itlComm.id AND ttla.deleted=false

  --If we are dealing with a sub-community, then it will have a parent which comes from the front of the community_or_sub_community_name field
  where (ittCommParent.id IS NULL OR iTermCommParent.term = substring(ppt.community_or_sub_community_name, '[^,]*')) AND ppt.special_variable_value IS NOT NULL
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
  select <taxa_taxon_list_id_to_import_into>,id,now(),1
  from taxa_taxon_list_attributes
  where caption='Species constancy value'
  ORDER BY id DESC 
  LIMIT 1;

  insert into taxa_taxon_list_attributes (caption,data_type,created_on,created_by_id,updated_on,updated_by_id,description)
  values 
  ('Maximum abundance of species','I',now(),1,now(),1,'Maximum abundance species for plant portal project');

  insert into taxon_lists_taxa_taxon_list_attributes (taxon_list_id,taxa_taxon_list_attribute_id,created_on,created_by_id)
  select <taxa_taxon_list_id_to_import_into>,id,now(),1
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
    join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<taxa_taxon_list_id_to_import_into> AND ittl.deleted=false
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
    join indicia.taxa_taxon_lists ittl on ittl.taxon_id=it.id AND ittl.taxon_list_id=<taxa_taxon_list_id_to_import_into> AND ittl.deleted=false

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













