# UKSI synchronisation with an Indicia warehouse

This tool allows the UKSI species dataset to be synchronised with an Indicia
warehouse. You will need to run it on a machine with the warehouse installed
and a taxon list already created, either empty or containing a previous version
of the UKSI dataset.

Usage: php import-uksi.php [options]

 --warehouse-path  The path to the warehouse installation folder.
 --su              PostgreSQL superuser username required for some scripts.
 --supass          PostgreSQL superuser password required for some scripts.
 --taxon\_list\_id   The ID of the existing list in the warehouse which will be updated with UKSI data.
 --user\_id         The ID of the existing user in the warehouse which will be used in the record metadata
                   for changes and new records.
Optional
 --data-path       The path to the folder containing the 8 text files exported from the UKSI MS Access database.
                   When not supplied, the files must be in the same folder as this PHP script.
 --start=n         Start at script numbered n.

For notes on regenerating the text files containing the UKSI data, see the
[documentation on Read the Docs](http://indicia-docs.readthedocs.io/en/latest/administrating/warehouse/importing-uksi.html?highlight=uksi)