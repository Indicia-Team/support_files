# UKSI synchronisation with an Indicia warehouse

This tool allows the UKSI species dataset to be synchronised with an Indicia
warehouse. You will need to run it on a machine with the warehouse installed
and a taxon list already created, either empty or containing a previous version
of the UKSI dataset.

Preparation:

* **Before running the script, please ensure that your warehouse scheduled tasks
  have been run and then stopped to ensure everything is up to date.** See the
  [scheduled tasks documentation](http://indicia-docs.readthedocs.io/en/latest/administrating/warehouse/scheduled-tasks.html?highlight=scheduled).
* **Back up your database!**

```
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
* If the uksi schema already exists from a previuos UKSI import (using the
  old script method), if the permissions are wrong then an error will be
  generated in step 1 when you run the tool. If this happens, use pgAdmin
  to delete the uksi schema before running the tool again.
* You will need to ensure the php executable is running as a user which has
  read access to the text files containing the UKSI data extracted from
  Microsoft Access. One way to do that on Windows is to right click the folder
  containing the text files and select Properties, then use the Security tab
  to grant read access to the Users account.
* If you experience an error whilst running the tool and are able to resolve
  the error, you can restart the tool at a certain script number by adding
  ```start=<script number>``` to the command line parameters and running the tool again.

**Once you have run the script remember to restart your scheduled tasks**.

For notes on regenerating the text files containing the UKSI data, see the
[documentation on Read the Docs](http://indicia-docs.readthedocs.io/en/latest/administrating/warehouse/importing-uksi.html?highlight=uksi).