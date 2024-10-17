# Darwin Core Exporter

A small PHP script for extracting data in an Indicia Warehouse Elasticsearch instance into a
Darwin Core archive. Can produce Comma Separated Values (*.csv) files as well.

To run the exporter, it needs to be placed on a machine with visibility of the Elasticsearch server
and with PHP 8.1 or higher installed. You will also need a config file per export, plus a warehouse
connection configuration file as described below before running the script.

Run the script from the command line by invoking PHP.exe, providing the location of the script PHP
file (dwc-generate.php) and a configuration file as parameters.

```bash
$ c:\PHP\php.exe c:\dwc-generate\dwc-generate.php "config\my export.json"
```

This can be saved as a batch file or shell script and invoked using Windows Task Scheduler or cron.

# Config file

The config file is in JSON format and the file is passed as a parameter to the dwc-generate PHP
script. This file contains the following options:

* elasticsearchHost - the web address or IP address of the server, including the port number. E.g.
  "x.x.x.x:9200" where x.x.x.x is the server IP address.
* index - name of the Elasticsearch alias or index to query.
* eventIndex - if the meta.xml metafile specifies that event data should be output, then provide
  the name of the Elasticsearch alias or index to query. This index should contain event data for
  each document rather than occurrences and should include events that contain zero occurrences.
* query - optional Elasticsearch query to filter the data to the dataset. Either query or filterId
  must be specified. For example:
  ```json
  {
    ...
    "query": {
      "bool": {
        "must": {
          "term": {"metadata.website.id": 2}
        }
      }
    }
    ...
  }
  ```
* filterId - optional, but either query or filterId must be specified and both are applied if both
  are present. ID of the filter record on the warehouse which will be used to dynamically generate
  the query. The list of websites available for data flow (according to the website registration
  configured in warehouse.json) will be automatically applied to the filter.
* surveyId - this is a shortcut to specifying a term filter on the survey ID (`metadata.survey.id`)
  which limits the output to a single survey dataset.
* higherGeographyID - this is a shortcut to specifying a nested term filter on a higher geography
  id which limits the output to records which intersect the provided location ID. The location must
  be indexed by the spatial_index_builder module.
* outputType - specify either dwca (Darwin Core Archive) or csv.
* options - array of options to extend data with.
  * useGridRefsIfPossible - for NBN Atlas export compatibility, switch to using the gridReference
    field instead of decimalLatitude and decimalLongitude where appropriate.
* outputFile - optional output file name, relative or absolute file path. Use when the output type
  is dwca (Darwin Core Archive), or when the output type is csv and only a single output file is
  specified in the meta.xml file. Existing CSV files will be overwritten and existing Darwin Core
  Archive zip files will have the occurrences contents updated. If not specified then uses the
  config file name to default to `exports/<config file name>.<ext>`.

  Note that when 2 or more output files are specified in meta.xml for a CSV export, then the
  outputFile setting is ignored and the filenames of the individual CSV files must be specified in
  the `<files><location>` element within the `<core>` or `<extension>` element that describes the
  file.
* xmlFilesInDir - if creating a Darwin Core Archive file, then the eml.xml and meta.xml files need
  to be in a sub-directory specified by this setting and they will be added to the DwC-A Zip
  archive file. If not specified but a folder exists with the same filename as the json config file
  in a metadata subfolder, then this will be used. E.g. if the config file is called
  `aculeates.json` then the expected location would be `exports/aculeates`. If outputting a CSV
  file the eml.xml file is not required, but you should still provide meta.xml in order to dictate
  whether you are exporting Event or Occurrence data and which columns to include.
* occurrenceIdPrefix - optional, prefix to use when constructing the occurrenceID, e.g. "brc1|".
* eventIdPrefix - optional, prefix to use when constructing the occurrenceID, e.g. "brcevt1|".
* defaultLicenceCode - optional, default licence to apply if not specified at the record level.
  e.g. "CC-BY".
* rightsHolder - Darwin Core rightsHolder to specify if there is a rightsHolder column in the
  meta.xml file.
* datasetName - Darwin Core datasetName to specify if there is a datasetName column in the
  meta.xml file.
* datasetIdSampleAttrId - ID of the sample attribute which holds the datasetID value.
* basisOfRecord - optional, defaults to "HumanObservation".
* repeatExport - optional. Allows a single configuration file to define a set of several similar
  exports, for example you might want to create a series of exports which are identical but divide
  the data by country. Provide an array, containing an object per export file with properties that
  will be merged with the top-level configuration provided in the configuration. E.g. you can
  specify `datasetName` in the `repeatExport` property's objects to define a different dataset name
  per file. You can also use the `surveyId` and `higherGeographyId` filter shortcut options to
  easily divide the files on either survey or location. An example of the `repeatExport`
  configuration is provided in the file `config/export-example-occurrence-bulk.json`.

# Metafile

Additionally you must provide a file called meta.xml which conforms to the Darwin Core metafile
format (https://dwc.tdwg.org/text/) which is in a directory referred to by the xmlFilesInDir config
setting. The meta.xml file describes the output file(s) and the columns you want to include in each
file and is used to describe both Darwin Core Archive and CSV outputs. Options for data files to
include in the Darwin Core Archive or to output as CSV files are limited to the following:

* Core file contains occurrence data with no extension data (see
  metadata/export-example-occurrence/meta.xml).
* Core file contains occurrence data with no extension data (see
  metadata/export-example-event/meta.xml).
* Core file contains event data with occurrence data in an extension (see
  metadata/export-example-event-occurrence/meta.xml).

For event datasets, the following field terms are supported:
* http://rs.tdwg.org/dwc/terms/coordinateUncertaintyInMeters
* http://rs.tdwg.org/dwc/terms/decimalLatitude
* http://rs.tdwg.org/dwc/terms/decimalLongitude
* http://rs.tdwg.org/dwc/terms/eventDate
* http://rs.tdwg.org/dwc/terms/eventID
* http://rs.tdwg.org/dwc/terms/eventRemarks
* http://rs.tdwg.org/dwc/terms/geodeticDatum
* http://data.nbn.org/nbn/terms/gridReference
* http://rs.tdwg.org/dwc/terms/habitat
* http://rs.tdwg.org/dwc/terms/locality
* http://rs.tdwg.org/dwc/terms/month
* http://rs.tdwg.org/dwc/terms/parentEventID
* http://rs.tdwg.org/dwc/terms/samplingProtocol
* http://rs.tdwg.org/dwc/terms/year

For occurrence datasets, the following field terms are supported:

* http://rs.tdwg.org/dwc/terms/basisOfRecord
* http://rs.tdwg.org/dwc/terms/coordinateUncertaintyInMeters
* http://rs.tdwg.org/dwc/terms/collectionCode
* http://rs.tdwg.org/dwc/terms/datasetID
* http://rs.tdwg.org/dwc/terms/datasetName
* http://rs.tdwg.org/dwc/terms/decimalLatitude
* http://rs.tdwg.org/dwc/terms/decimalLongitude
* http://rs.tdwg.org/dwc/terms/eventDate
* http://rs.tdwg.org/dwc/terms/eventID
* http://rs.tdwg.org/dwc/terms/eventRemarks
* http://rs.tdwg.org/dwc/terms/geodeticDatum
* http://data.nbn.org/nbn/terms/gridReference
* http://rs.tdwg.org/dwc/terms/identifiedBy
* http://rs.tdwg.org/dwc/terms/identificationVerificationStatus
* http://rs.tdwg.org/dwc/terms/individualCount
* http://purl.org/dc/terms/license
* http://rs.tdwg.org/dwc/terms/lifeStage
* http://rs.tdwg.org/dwc/terms/locality
* http://rs.tdwg.org/dwc/terms/occurrenceID
* http://rs.tdwg.org/dwc/terms/occurrenceRemarks
* http://rs.tdwg.org/dwc/terms/occurrenceStatus
* http://rs.tdwg.org/dwc/terms/otherCatalogNumbers
* http://rs.tdwg.org/dwc/terms/recordedBy
* http://purl.org/dc/terms/rightsHolder
* http://rs.tdwg.org/dwc/terms/scientificName
* http://rs.tdwg.org/dwc/terms/sex
* http://rs.tdwg.org/dwc/terms/taxonID
* http://rs.tdwg.org/dwc/terms/vernacularName

When your meta.xml file contains a core event file and an extension occurrence file, you should add
an element called `<id>` to the list of fields for the event, plus `<coreid>` to the list of fields
for the occurrence. See https://dwc.tdwg.org/text/#212-elements.

# Warehouse connection config file

In order to configure the connection to the warehouse, create a file `config/warehouse.json` and
paste the following into it, replacing values in `<>` with the appropriate value for your system:

```json
{
  "website_id": <webiste id>,
  "website_password": "<website password>",
  "warehouse_url": "<warehouse root url>",
  "master_checklist_id": <taxon list ID of main list>
}
```