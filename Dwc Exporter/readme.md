# Config file 

A JSON file containing the following settings:

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
  need to be in a sub-directory specified by this setting.
* occurrenceIdPrefix - optional, prefix to use when constructing the occurrenceID, e.g. "brc1|".
* defaultLicenceCode - optional, default licence to apply if not specified at the record level. 
  e.g. "CC-BY".
* rightsHolder - Darwin Core rightsHolder to specify.
* datasetName - Darwin Core datasetName to specify.
* datasetIdSampleAttrId - ID of the sample attribute which holds the datasetID value.
* basisOfRecord - optional, defaults to "HumanObservation".
* occurrenceStatus - optional, defaults to "present".