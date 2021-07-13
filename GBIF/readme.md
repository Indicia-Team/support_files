# GBIF Framework Taxonomy synchronisation with an Indicia warehouse

This tool allows the GBIF Framework Taxonomy to be synchronised with an Indicia
warehouse. You will need to run it on a machine with the warehouse installed
and a taxon list already created, either empty or containing a previous version
of the GBIF dataset.

Preparation:

* **Enable the following modules in application/config/config.php:** taxon_designations, taxon_associations, species_alerts, data_cleaner_ancillary_species, data_cleaner_period_within_year, data_cleaner_period, data_cleaner_identification_difficulty, data_cleaner_without_polygon
* **Before running the script, please ensure that your warehouse scheduled tasks
  have been run and then stopped to ensure everything is up to date.** See the
  [scheduled tasks documentation](http://indicia-docs.readthedocs.io/en/latest/administrating/warehouse/scheduled-tasks.html?highlight=scheduled).
* **Double check all work queue tasks are processed (work_queue table empty). If not, run the 
  scheduled tasks again until they are.
* **Back up your database!**

```
Usage: php import-uksi.php [options]

 --warehouse-path           The path to the warehouse installation folder.
 --su                       PostgreSQL superuser username required for some scripts.
 --supass                   PostgreSQL superuser password required for some scripts.
 --taxon\_list\_id          The ID of the existing list in the warehouse which will be updated with UKSI data.
 --user\_id                 The ID of the existing user in the warehouse which will be used in the record metadata
                            for changes and new records.
Optional
 --data-path                The path to the folder containing the GBIF file, 
                            backbone-current-simple.txt, downloaded from 
                            https://hosted-datasets.gbif.org/datasets/backbone.
                            When not supplied, the files must be in the same folder as this PHP script.
 --start=n                  Start at script numbered n.
 --stop=n                   End at script numbered n.
 --force-cache-rebuild=true Forces all taxa in import to be treated as changed taxa if set to 'true'.  
```

Example:
```
php import-uksi.php --warehouse-path=/Library/WebServer/Documents/warehouse --su=postgres --supass=12345678 --taxon_list_id=123 --user_id=123
```

Notes on running the script:
* If your php executable is not on your path, then you will need to include the
  path in the call, e.g:
  ```
  /path/to/php/php.exe import-uksi.php --warehouse-path=/Library/WebServer/Documents/warehouse --su=postgres --supass=12345678 --taxon_list_id=123 --user_id=123
  ```
* You will need to ensure the php executable is running as a user which has
  read access to the text file containing the GBIF data downloaded from 
  https://hosted-datasets.gbif.org/datasets/backbone/backbone-current-simple.txt.gz.
  One way to do that on Windows is to right click the folder
  containing the text files and select Properties, then use the Security tab
  to grant read access to the Users account.
* If you experience an error whilst running the tool and are able to resolve
  the error, you can restart the tool at a certain script number by adding
  ```start=<script number>``` to the command line parameters and running the tool again.

**Once you have run the script remember to restart your scheduled tasks**.

## Separate database and web server?
The above instructions apply if PostgreSQL is running on the same server as the Warehouse web application. If they are on different servers then 
* Copy the GBIF folder to both servers,
* Run the PHP script on the Warehouse web server with `--data-path=/absolute/path/to/GBIF/on/postgres/server`

If the data-path is incorrect a file not found error will arise.
Postgres must have read permissions to the GBIF files or a permission denied error will occur.
