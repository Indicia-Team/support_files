If you are having problems loading the files in script 0 because PSQL complains about permissions, put the import files into a directory on the Warehouse server, then at the command line run
chmod a+rw <file_path>
e.g.
chmod a+rw /root/backup/mar_import