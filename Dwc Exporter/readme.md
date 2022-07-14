# Darwin Core Exporter

A small PHP script for extracting data in an Indicia Warehouse Elasticsearch instance into a
Darwin Core archive. Can produce Comma Separated Values (*.csv) files as well.

To run the exporter, it needs to be placed on a machine with visibility of the Elasticsearch server
and with PHP 7.x or higher installed. Run the script from the command line by invoking PHP.exe,
providing the location of the script PHP file (dwc-generate.php) and a configuration file as
parameters.

```bash
$ c:\PHP\php.exe "c:\dwc-generate\dwc-generate.php "config\my export.json"
```

This can be saved as a batch file or shell script and invoked using Windows Task Scheduler or cron.

# Config file

The config file passed as a parameter JSON file containing the following settings:

* elasticsearchHost - the web address or IP address of the server, including the port number. E.g.
  "x.x.x.x:9200" where x.x.x.x is the server IP address.
* index - name of the Elasticsearch alias or index to query.
* query - Elasticsearch query to filter the data to the dataset. For example:
  ```json
  {
    "bool": {
      "must": {
        "term": {"metadata.website.id": 2}
      }
    }
  }
  ```
* outputType - specify either dwca (Darwin Core Archive) or csv.
* options - array of options to extend data with.
  * useGridRefsIfPossible - for NBN Atlas export compatibility, switch to using the gridReference
    field instead of decimalLatitude and decimalLongitude where appropriate.
* outputFile - output file name, relative or absolute file path. Existing CSV files will be
  overwritten and existing Darwin Core Archive zip files will have the occurrences contents
  updated.
* xmlFilesInDir - if creating a new Darwin Core Archive file, then the eml.xml and meta.xml files
  need to be in a sub-directory specified by this setting and they will be added to the DwC-A Zip
  archive file.
* occurrenceIdPrefix - optional, prefix to use when constructing the occurrenceID, e.g. "brc1|".
* defaultLicenceCode - optional, default licence to apply if not specified at the record level.
  e.g. "CC-BY".
* rightsHolder - Darwin Core rightsHolder to specify.
* datasetName - Darwin Core datasetName to specify.
* datasetIdSampleAttrId - ID of the sample attribute which holds the datasetID value.
* basisOfRecord - optional, defaults to "HumanObservation".
* occurrenceStatus - optional, defaults to "present".