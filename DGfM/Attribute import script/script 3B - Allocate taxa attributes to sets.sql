
--Replace the following tag before running script
--<taxon_list_id>
set search_path TO indicia, public;
update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list=replace(attribute_set_allocation_list, '::', ':0:');
--It is deliberate that this is done twice
update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list=replace(attribute_set_allocation_list, '::', ':0:');

update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list= '0' || attribute_set_allocation_list
where LEFT(attribute_set_allocation_list, 1) = ':';

update dgfm.tbl_attribute_set_allocations
set attribute_set_allocation_list= attribute_set_allocation_list || '0'
where RIGHT(attribute_set_allocation_list, 1) = ':';

DO
$do$
declare attribute_set_allocation_to_import RECORD;
declare attribute_set_allocation_list_array text[];
declare attribute_set_names_array text[];
declare idx integer;
declare attribute_set_allocation_list integer;

BEGIN 
select string_to_array((select attribute_sets from dgfm.tbl_attribute_sets), ':') into attribute_set_names_array;
FOR attribute_set_allocation_to_import IN 
(
--Select all rows (attributes) to import
--select_all_from_dgfm_attributes_tag
select dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area, dta.deu_attribute as attribute_name,
LEFT(TRIM(BOTH from dta.deu_attribute),50) as deu_attribute_name_shortened, 
dta.attribute_set_allocation_list
from dgfm.tbl_attribute_set_allocations dta
) loop
  select string_to_array(attribute_set_allocation_to_import.attribute_set_allocation_list, ':') into attribute_set_allocation_list_array;
  idx := 1;
  FOREACH attribute_set_allocation_list IN ARRAY attribute_set_allocation_list_array LOOP
    if (attribute_set_allocation_list='1') THEN
      IF 
        (EXISTS (
        select ttla.id 
        from taxa_taxon_list_attributes ttla
        join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
        where 
        ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened
        AND ttla.deleted=false 
        AND reporting_category_id in (
          select tt.id
          from termlists_terms tt 
          join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
          join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
          join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
          where tt.deleted=false  
          ORDER BY ID desc limit 1
        )
        order by ttla.id desc limit 1))
      AND 
        (NOT EXISTS(
        select id
        from indicia.attribute_sets_taxa_taxon_list_attributes asttla
        where 
          asttla.attribute_set_id =
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1)
        AND
          asttla.taxa_taxon_list_attribute_id =
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
              where 
              ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            )
        AND
          asttla.deleted=false
        ))
      THEN
        insert into
        indicia.attribute_sets_taxa_taxon_list_attributes
        (
            attribute_set_id,
            taxa_taxon_list_attribute_id,
            created_by_id,
            created_on,
            updated_by_id,
            updated_on
        )
        values (
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1),
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
              where 
              ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            ),
            1,
            now(),
            1,
            now()
        );
      ELSE
      END IF;
    ELSE
    END IF;   
    idx := idx + 1;
  END LOOP;
END LOOP;
END
$do$;



-- The following code removes existing allocations, however it needs further testing.
/*DO
$do$
declare attribute_set_allocation_to_import RECORD;
declare attribute_set_allocation_list_array text[];
declare attribute_set_names_array text[];
declare idx integer;
declare attribute_set_allocation_list integer;

BEGIN 
select string_to_array((select attribute_sets from dgfm.tbl_attribute_sets), ':') into attribute_set_names_array;
FOR attribute_set_allocation_to_import IN 
(
--Select all rows (attributes) to import
--select_all_from_dgfm_attributes_tag
select dta.deu_area as deu_attribute_area, dta.deu_sub_area as deu_attribute_sub_area, dta.deu_attribute as attribute_name,
LEFT(TRIM(BOTH from dta.deu_attribute),50) as deu_attribute_name_shortened, 
dta.attribute_set_allocation_list
from dgfm.tbl_attribute_set_allocations dta
) loop
  select string_to_array(attribute_set_allocation_to_import.attribute_set_allocation_list, ':') into attribute_set_allocation_list_array;
  idx := 1;
  FOREACH attribute_set_allocation_list IN ARRAY attribute_set_allocation_list_array LOOP
    if (attribute_set_allocation_list = '0') THEN
      IF 
        (EXISTS(
        select id
        from indicia.attribute_sets_taxa_taxon_list_attributes asttla
        where 
          asttla.attribute_set_id =
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1)
        AND
          asttla.taxa_taxon_list_attribute_id =
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
              where 
              ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            )
        AND
          asttla.deleted=false
        ))
      THEN
        update indicia.attribute_sets_taxa_taxon_list_attributes
        set deleted=true
        where id in 
        (
          select id
          from indicia.attribute_sets_taxa_taxon_list_attributes asttla
          where 
            asttla.attribute_set_id =
              (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1)
          AND
            asttla.taxa_taxon_list_attribute_id =
              (
                select ttla.id 
                from taxa_taxon_list_attributes ttla
                join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
                where 
                ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened
                AND ttla.deleted=false 
                AND reporting_category_id in (
                  select tt.id
                  from termlists_terms tt 
                  join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                  join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                  join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                  where tt.deleted=false  
                  ORDER BY ID desc limit 1
                )
                order by ttla.id desc limit 1
              )
          AND
            asttla.deleted=false
        );
      ELSE
      END IF;
      /*IF (EXISTS (
        select ttla.id 
          from taxa_taxon_list_attributes ttla
          join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
          where ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (95%)' 
          AND ttla.deleted=false 
          AND reporting_category_id in (
            select tt.id
            from termlists_terms tt 
            join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
            join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
            join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
            where tt.deleted=false  
            ORDER BY ID desc limit 1
          )
          order by ttla.id desc limit 1))
      THEN
       insert into
        indicia.attribute_sets_taxa_taxon_list_attributes
        (
            attribute_set_id,
            taxa_taxon_list_attribute_id,
            created_by_id,
            created_on,
            updated_by_id,
            updated_on
        )
        values (
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1),
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
              where ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (95%)' 
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            ),
            1,
            now(),
            1,
            now()
        );
      ELSE
      END IF;*/
      /*IF (EXISTS (
        select ttla.id 
        from taxa_taxon_list_attributes ttla
        join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
        where 
        (ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (80%)')
        AND ttla.deleted=false 
        AND reporting_category_id in (
          select tt.id
          from termlists_terms tt 
          join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
          join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
          join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
          where tt.deleted=false  
          ORDER BY ID desc limit 1
        )
        order by ttla.id desc limit 1))
      THEN
        insert into
        indicia.attribute_sets_taxa_taxon_list_attributes
        (
            attribute_set_id,
            taxa_taxon_list_attribute_id,
            created_by_id,
            created_on,
            updated_by_id,
            updated_on
        )
        values (
            (select id from indicia.attribute_sets where title = attribute_set_names_array[idx] AND deleted=false order by id desc limit 1),
            (
              select ttla.id 
              from taxa_taxon_list_attributes ttla
              join taxon_lists_taxa_taxon_list_attributes tlttla on tlttla .taxa_taxon_list_attribute_id = ttla.id AND tlttla.taxon_list_id=<taxon_list_id> AND tlttla.deleted=false
              where 
              (ttla.caption = attribute_set_allocation_to_import.deu_attribute_name_shortened || ' (80%)')
              AND ttla.deleted=false 
              AND reporting_category_id in (
                select tt.id
                from termlists_terms tt 
                join terms t on t.id = tt.term_id AND t.term = attribute_set_allocation_to_import.deu_attribute_sub_area AND t.deleted=false
                join termlists_terms tt_parent_area on tt_parent_area.id = tt.parent_id AND tt_parent_area.deleted=false
                join terms t_parent_area on t_parent_area.id = tt_parent_area.term_id AND t_parent_area.term = attribute_set_allocation_to_import.deu_attribute_area AND t_parent_area.deleted=false
                where tt.deleted=false  
                ORDER BY ID desc limit 1
              )
              order by ttla.id desc limit 1
            ),
            1,
            now(),
            1,
            now()
        );
      ELSE
      END IF;
    ELSE
    END IF;   
    idx := idx + 1;
  END LOOP;
END LOOP;
END
$do$;*/

