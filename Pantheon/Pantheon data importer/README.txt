Data version: 3.7.6

Further notes:
- This version of the importer CAN work with a Warehouse that is already populated. 

- Before running script, makes sure the following returns a value
select id from websites where title='Pantheon' and deleted=false;

- When running on an existing warehouse do not run the following scripts unless it is known that they haven’t previously been run before.
script 9 - fix_tree_assoc.sql
script 10 - top level dung.sql
script 11 - species_index.sql
isis_thresholds.sql
habitat_score_values.sql