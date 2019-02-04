# Warehouse website content migration scripts

The scripts in this folder provide a mechanism for exporting everything required by a
website registration into a schema, which can then be backed up and restored onto another
warehouse where it can be imported. This allows a website registration, it's surveys and
occurrences, custom attributes, term and taxon lists to be moved from one server to
another.

The steps are:
1. Edit export.sql by searching for the comment /** MODIFY WEBSITE ID HERE **/ and
   altering the website ID or IDs you would like to include in the export.
2. If your main Indicia schema is not called indicia, change this in the
   `set search_path` statement at the start of the script.
3. Run this script on the warehouse that holds the website registration you are moving.
4. This will create a schema called export. Use pgAdmin to backup just this schema.
5. On the destination warehouse, use pgAdmin to restore the backup of the schema into the
   database you are moving the website registration to.
6. If your main Indicia schema is not called indicia, change this in the
   `set search_path` statement at the start of the import.sql script.
7. The import script allows you to use existing termlists, taxon lists and custom
   attributes on the destination warehouse rather than create new copies of everything.
   This should only be used when both warehouses have identical information in the
   item being reused, for example a lookup attribute must have the same term's in its
   termlist or a taxon list must have the same species data. To set up matching items,
   search the import.sql script for comments starting /** which give examples and explain
   how to set up the mappings.
8. Run the import.sql script on the destination warehouse.
9. Assuming this is successful, you will now have a schema called import which contains a
   copy of all the tables and data which need to be merged into the main schema. Also
   each table has a field called old_id which provides the primary key for this record
   from the source warehouse, plus a boolean field called new which is set to true for
   all new records and false for any existing records which are already in the database
   such as the terms or custom attributes you defined in step 7. **Please review the data
   thoroughly at this stage before proceeding!** Note that any existing records (e.g.
   matching attributes, taxa or terms) will be left in their original state on the
   destination warehouse and will not be touched by the merge.
10. Open the merge.sql file. If your main Indicia schema is not called indicia, change
    this in the `set search_path` statement at the start of the import.sql script.
11. Run merge.sql to pull the records from the import schema into the main indicia
    tables.

Note that this script was designed to migrate data for a specific project, so not all
areas of the data model are covered. However the principles used here could be expanded
to include them. The following lists those areas of the data model which are excluded:
* media tables
* surveys.owner_id
* taxon_designations and taxa_taxon_designations
* Attributes in termlists - termlists_term_attributes and termlists_term_attribute_values.
* groups (activities or recording groups etc).
* attribute source ids
* attribute reporting category ids

The script also assumes:
* Both warehouse have same list of licences