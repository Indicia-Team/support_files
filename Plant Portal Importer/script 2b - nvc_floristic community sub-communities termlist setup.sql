--This script assumes the Plant Portal website is called "Plant Portal", if it is not, then this script will need appropriate alteration.

DO
$do$
DECLARE row_to_import RECORD;
DECLARE community_or_sub_community_name_to_split_array varchar[];
DECLARE code_name_to_use varchar;
BEGIN


set search_path TO indicia, public;
insert into indicia.termlists (title,description,website_id,created_on,created_by_id,updated_on,updated_by_id,external_key)
values 
('Community or sub community name','Community or sub community names for Plant Portal',(select id from websites where title='Plant Portal' and deleted=false),now(),1,now(),1,'indicia:community_or_sub_community_name');

  FOR row_to_import IN
  (select DISTINCT ppt.community_or_sub_community_name as community_or_sub_community_name_to_split, ppt.community_level_code as community_level_code, ppt.community_or_sub_community_code as community_or_sub_community_code
  from plant_portal.tbl_nvc_floristic_tables ppt
  where ppt.community_or_sub_community_name IS NOT NULL
  ) loop
    community_or_sub_community_name_to_split_array = string_to_array(row_to_import.community_or_sub_community_name_to_split, ', ');
    FOR i IN array_lower(community_or_sub_community_name_to_split_array, 1) .. array_upper(community_or_sub_community_name_to_split_array, 1)
      LOOP
        code_name_to_use=null;
        --Insert the community term itself which has been split up from the community, sub-community in the field
        perform insert_term(community_or_sub_community_name_to_split_array[i],'eng',null,'indicia:community_or_sub_community_name');

        --If the community inserted is the first community for a row, then we know it is top level and use the community level code, else use the community_or_sub_community_code
        IF i=1 then
          code_name_to_use = row_to_import.community_level_code;
        ELSE
          code_name_to_use = row_to_import.community_or_sub_community_code;
        END IF;
        --Insert the code we want to use as a term, noting the insert_term functionality automatically stops duplicate insertion
        perform insert_term(code_name_to_use,'eng',null,'indicia:community_or_sub_community_name');


        -- Updated the meaning id of the community code to be the same as the community name so it appears as a synonym (must also have preferred set true, but this is set further down script,
        --see notes there for information about this
        update termlists_terms
        set meaning_id = 
        (select itt.meaning_id
          from indicia.termlists_terms itt 
          join termlists itl on itl.id = itt.termlist_id AND itl.title='Community or sub community name' AND itl.deleted=false
          join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
          join terms t on t.id=itt.term_id AND t.term=community_or_sub_community_name_to_split_array[i]
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
        IF i!=1 then
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
              join terms t on t.id=itt.term_id AND t.term=community_or_sub_community_name_to_split_array[i]
              order by itt.id desc
              limit 1);
        ELSE
        END IF;
      END LOOP;         
  END LOOP;

  --Take a second pass of the data and make sure the community codes are not preferred so they appear as synonyms.
  --In theory we could have done this on the first pass, but the insert_term function seems to insert duplicates unless
  --the flag is preferred, so we can only switch the preferred flag off aftwards
  FOR row_to_import IN
  (select DISTINCT ppt.community_level_code as community_level_code, ppt.community_or_sub_community_code as community_or_sub_community_code
  from plant_portal.tbl_nvc_floristic_tables ppt
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

  --Do a third pass, this time only selecting the "Number of species per sample" rows, this can be put into the sort_order field on the termlist_term as we don't have anywhere else to store it
  FOR row_to_import IN
  (select DISTINCT ppt.community_or_sub_community_name as community_or_sub_community_name_to_split, ppt.special_variable_value as special_variable_value
  from plant_portal.tbl_nvc_floristic_tables ppt
  where ppt.community_or_sub_community_name IS NOT NULL AND preferred_tvk = 'Number of species per sample'
  ) loop
    community_or_sub_community_name_to_split_array = string_to_array(row_to_import.community_or_sub_community_name_to_split, ', ');
    update termlists_terms
    set sort_order=row_to_import.special_variable_value
    where id = 
      (
      select itt.id
      from indicia.termlists_terms itt 
      join termlists itl on itl.id = itt.termlist_id AND itl.title='Community or sub community name' AND itl.deleted=false
      join websites w on w.id = itl.website_id AND w.title='Plant Portal' AND w.deleted=false
      join terms t on t.id=itt.term_id AND t.term=community_or_sub_community_name_to_split_array[array_upper(community_or_sub_community_name_to_split_array, 1)]
      order by itt.id desc
      limit 1
      );
  END LOOP; 
END
$do$;














