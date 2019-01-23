# Using Elasticsearch to report on Indicia records

Elasticsearch (https://www.elastic.co) is a search and analytics engine which
provides high performance and scalability. It stores JSON document objects in
indices where every field value is effectively indexed. This document describes
two approaches for using Elasticsearch with Indicia occurrence records loaded
as document objects.

1. Elasticsearch and Indicia on the same network or where remote access to the
   Indicia PostgreSQL database is possible. In this instance JDBC can be used
   to provide direct access to the Indicia data.
2. Where the Elasticsearch and Indicia warehouse instances are on separate
   networks without the possibility of remote access, the Indicia data are
   accessed remotely via web services.

## Installation

On the server you plan to use as an Elasticsearch server, you will need to
install the following components:

* Java 8
* Elasticsearch
* Logstash
* Kibana

The Elasticsearch documentation online describes installation in various
scenarios so only brief notes are provided below covering 2 scenarios,
installing on Windows 10 using Elastic's zip downloads and installing on a Mac
using the Homebrew package manager (https://brew.sh).

### Install Java

You will need to install Java 8 before installation of Elasticsearch.
See https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html
for more information. Although Elasticsearch itself works with Java versions up
to 10, Logstash requires Java 8 specifically. You only need to install the JRE,
not the full JDK, unless required for other reasons. The Java installation
files can be downloaded at https://www.oracle.com/technetwork/java/javase/downloads/index.html.

Once installed, ensure your JAVA_HOME environment variable correctly points to
your Java installation's root folder.

### Installing the Elastic stack

Installation of the Elastic stack is described in the online documentation at
https://www.elastic.co/guide/en/elastic-stack/current/installing-elastic-stack.html.
For this project, we need to install Elasticsearch, Kibana and Logstash only.

#### On Windows

The installation on Windows can be performed using the zip files of each
application. The installation zip files required are:
* The oss version of Elasticsearch from https://www.elastic.co/guide/en/elasticsearch/reference/current/zip-windows.html
* The oss version of Kibana from https://www.elastic.co/guide/en/kibana/current/windows.html
* Logstash from https://www.elastic.co/guide/en/logstash/current/installing-logstash.html

Because they are Java applications they just need to be unzipped to an
appropriate folder. For this example I created acfolder d:\elastic and
unzipped each of the installation files into there, then renamed them so the
folder matches the application. This resulted in the following folder
structure:
* d:\elastic
  * elasticsearch
    * bin
    * etc...
  * kibana
    * bin
    * etc...
  * logstash
    * bin
    * etc...

#### On a Mac running OS X

If you have the Homebrew package managed installed then
the following commands will install the required compontents from terminal:

```shell
$ brew install elasticsearch
$ brew install kibana
$ brew install logstash
```

### Install a JDBC driver

This step is only required when using connection method 1 - direct access to
the Indicia PostgreSQL database.

We will be using JDBC to provide a connection from Logstash (the tool used to
move data into Elasticsearch) to Indicia. Therefore you will need to download
the latest JDBC driver for PostgreSQL from https://jdbc.postgresql.org/download.html.
and drop into a suitable location in your Java classpath, e.g.
/Library/Java/Extensions. Now, find your Logstash installation's bin folder and
run the following command from a terminal or command prompt inside that folder
(it's not necessary to go to that folder if Logstash is on your environment
path):

```shell
$ logstash-plugin install logstash-input-jdbc
```

### Start Elasticsearch and Kibana

Review your installation instructions for how to start both Elasticsearch and
Kibana. In my example, using Homebrew for the installation means I just need to
run the following commands from 2 different terminal windows:

#### Windows

```shell
$ d:\elastic\elasticsearch\bin\elasticsearch.bat
```

```shell
$ d:\elastic\elasticsearch\bin\kibana.bat
```

#### Mac

```shell
$ elasticsearch
```

```shell
$ kibana
```

Or, if you want it to restart automatically on reboot:

#### Windows

```shell
$ d:\elastic\elasticsearch\bin\elasticsearch-service.bat install
$ d:\elastic\elasticsearch\bin\elasticsearch-service.bat start
```

#### Mac

```shell
$ brew services start elasticsearch
$ brew services start kibana
```

You can now check Elastic Search is working at http://localhost:9200 and Kibana
is working at http://localhost:5601.

### Prepare the index

In Kibana, open the Dev Tools tab then run the following request to ensure that
the various fields in the Elasticsearch document index are configured with the
correct data types, for example the geom field in our index is recognised as a
geometric shape, not simply some generic text field. This request also includes
some default settings for the index you are creating, namely that it will have
2 primary shards and 1 replica shard. This setting allows for a small amount of
scalability, with up to 2 nodes in your Elasticsearch cluster supported should
they be required in future. Read the documentation provided on scaling
Elasticsearch to decide the best settings for your situaion
(https://www.elastic.co/guide/en/elasticsearch/guide/current/scale.html). Also,
note that the index name has a short unique identifier appended to it which
for the individual Indicia warehouse it indexes records from. This approach
allows us to scale an Elasticsearch cluster to support multiple warehouses
easily.

```json
PUT occurrence_brc1
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  },
  "mappings": {
    "doc": {
      "properties": {
        "id": { "type": "integer" },
        "event.date_start": { "type": "date" },
        "event.date_end": { "type": "date" },
        "event.day_of_year": { "type": "short" },
        "event.event_id": { "type": "integer" },
        "event.parent_event_id": { "type": "integer" },
        "event.week": { "type": "byte" },
        "event.ukbms_week": { "type": "byte" },
        "event.month": { "type": "byte" },
        "event.year": { "type": "short" },
        "metadata.created_by_id": { "type": "integer" },
        "metadata.updated_by_id": { "type": "integer" },
        "metadata.created_on": {
          "type": "date",
          "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd HH:mm:ss.SSSS||yyyy-MM-dd"
        },
        "metadata.updated_on": {
          "type": "date",
          "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd HH:mm:ss.SSSS||yyyy-MM-dd"
        },
        "metadata.group.id": { "type": "integer" },
        "metadata.survey.id": { "type": "integer" },
        "metadata.website.id": { "type": "integer" },
        "metadata.sensitive": { "type": "boolean" },
        "metadata.sensitivity_precision": { "type": "integer" },
        "metadata.confidential": { "type": "boolean" },
        "identification.verified_by_id": { "type": "integer" },
        "identification.verified_on": {
          "type": "date",
          "format": "yyyy-MM-dd HH:mm:ss||yyyy-MM-dd HH:mm:ss.SSSS||yyyy-MM-dd"
        },
        "identification.auto_checks.enabled": { "type": "boolean" },
        "identification.auto_checks.result": { "type": "boolean" },
        "location.geom": { "type": "geo_shape" },
        "location.point": { "type": "geo_point" },
        "location.higher_geography_ids": { "type": "integer" },
        "location.location_id": { "type": "integer" },
        "location.parent.location_id": { "type": "integer" },
        "location.coordinate_uncertainty_in_meters": { "type": "integer" },
        "occurrence.individual_count": { "type": "integer" }
      }
    }
  }
}
```

Elasticsearch has an option to create aliases for index names. We can use this
for 2 purposes:
* Allows us to dynamically change the index an incoming query is routed to
  without downtime, making scaling up much simpler. In effect, by adding the
  alias we are giving ourselves an additional option during any future upgrade
  path.
* Allow us to provide pre-filtered aliases, e.g. to access the data in a
  particular website or group using a filter on the alias.

The following request creates 2 aliases, one for a global search and one for
indexing documents into the brc1 index. Note that the search alias has a filter
applied to make it "safe", i.e. don't show the blurred version of records,
confidential or unreleased data.

```json
POST /_aliases
{
  "actions" : [
    { "add" : {
      "index" : "occurrence_brc1",
      "alias" : "occurrence_search",
      "filter" : {
        "bool" : {
          "must" : [
            { "term" : { "metadata.confidential" : false } },
            { "term" : { "metadata.release_status" : "R" } }
          ],
          "should" : [
            { "terms" : { "metadata.ensitivity_blur" : ["B"] } },
            { "bool": { "must_not" : {
              "exists": { "field": "metadata.sensitivity_blur" }
            }}}
          ]
        }
      }
    } },
    { "add" : {
      "index" : "occurrence_brc1",
      "alias" : "occurrence_brc1_index"
    } }
  ]
}
```

Now, if we later add a second warehouse to our Elasticsearch cluster with a
second index called brc2, we can run the same request but replace brc1 with
brc2.

Now, we can index documents from warehouse brc1 into occurrence_brc1_index,
documents from warehouse brc2 into occurrence_brc2_index and search across
both indexes using occurrence_search. We could also then provide a filtered
index for use by a client website, for example:

```json
POST /_aliases
{
  "actions" : [
    { "add" : {
      "index" : "occurrence_brc1",
      "alias" : "occurrence_search_irecord",
      "filter": {
        "query_string": {
          "query": "metadata.website.id:23",
          "analyze_wildcard": false,
          "default_field": "*"
          /* Other filters here - see above. */
        }
      }
    } }
  ]
}
```

Note that we store both a centre point and geometry (e.g. a grid square) for
each record. This is because many of the tools provided with Elasticsearch and
Kibana for mapping only work with point data, such as the heat maps
visualisation.

## Set up the data pipeline

### Logstash configuration

Logstash acts as a data conduit. We’ll use it to pipe data arriving in Indicia into an Elastic Search index.

#### Grab the files from Git

Download the support files repository (or clone it) from Git. To do this open
a command prompt/terminal window in a temporary location then:

```shell
$ git clone https://github.com/Indicia-Team/support_files.git
```

You need just the Elasticsearch folder which we will refer to as our working
folder from now on.

#### Prepare the lookups for taxon data

Normally it will be acceptable to use the taxa.csv and taxon-paths.csv files
provided in the repository. Use the following instructions to regenerate them
if there are taxonomic changes that need to be applied to your imports.

Rather than expect all data sources to provide all the taxonomic information
related to a record in a single consistent format, we will use the UKSI dataset
copied into a CSV file to create a lookup table containing the information,
keyed by external key (i.e. the NBN key of the taxon name). This file is
provided in the Elasticsearch/data/taxa.csv file. Then, during import, sources
can provide just a taxon NBN key and Logstash will be configured to use this
CSV file to populate all the required taxon information to add to the search
index.

A second CSV file is constructed from the UKSI data to provide path information
from the taxon's root through the taxonomic levels down to the taxon itself.
This makes queries based on higher taxa easy and performant. Normally you can
just use the copies of the 2 CSV files provided in the repository, but
instructions for generating or updating them are provided below.

To update the taxa.csv file with a fresh copy of the data:

* Open the queries/prepare-taxa-lookup.sql file in pgAdmin, connecting to an
  Indicia database that has the UKSI dataset loaded.
* Search and replace <taxon_list_id> with the ID of the UKSI list.
* In pgAdmin 3:
  * Ensure that your search_path is set to indicia, public, e.g. by running the
    query below, or ensuring it is your logged in user's default search path:
    ```
    set search_path=indicia, public;
    ```

  * Select the “Execute query, write result to file” toolbutton.
  * On the options dialog, uncheck the Column names option. Set the column
    separator to a colon followed by a space (": ") and the quote char to a
    double quote. Set the output file to Elasticsearch/data/taxa.yml in the
    working folder.
  * Open the resulting file in a text editor and search and replace "" for \".
* In pgAdmin 4:
  * If indicia, public is not your logged in users default search path, then
    edit the query to add "indicia." in front of all the table names (use a
    different prefix if your schema is different).
  * Click the Download as CSV button. Note that I had problems using this under
    Internet Explorer with Enhanced Security Configuration enabled so ending up
    using Chrome instead.
  * Rename the downloaded file to taxa.csv and replace the file in
    Elasticsearch/data in your working folder.
  * Edit the file in a text editor. Remove the first row (column titles) and
    perform the following replacements:
    * "," with ": "
    * "" with "\
    * Regexp \u0084 with ,,
    * Regexp \u0086 search and tidy up (invalid character in some UKSI names)
    * Regexp \u0092 with '
    * Regexp \u0093 with empty string
    * Regexp \u0094 with "
    * Regexp \u008A with Š
    * Regexp \u009A with š
    * Regexp \u0082 with ,
    * Regexp \u0090 with empty string
    * Regexp \u009c with œ and also remove the stray hyphen in the affected
      name.
    * The name for BMSSYS0000533859 should have standard double quotes around
      mauroides with escape \ preceding them, i.e. \"mauroides\".

To update the taxon-paths.yml file with a fresh copy of the data, repeat the
steps above for the prepare-taxon-paths.sql file, saving the results as
taxon-paths.yml.

#### Prepare the lookup for location data

* Open the queries/prepare-locations-lookup.sql file in pgAdmin, connecting to an
  Indicia database that has the UKSI dataset loaded.
* Search and replace <indexed_location_type_ids> with a comma separated list of
  location type IDs that are indexed.
* Repeat the steps described above to save a file called locations.yml in your
  working folder's Elasticsearch/data folder.

#### Prepare the Logstash configuration file (JDBC access)

If you are using JDBC to provide direct access to the Indicia PostgreSQL data,
then follow these steps.

A template is provided for you in your working directory's logstash-config
folder. Copy the occurrences-pgsql-indicia.conf.template file to a new file called
occurrences-pgsql-indicia.conf and edit it in your preferred text editor.
Search and replace the following values:

* {{ DB path }} - replace with the PostgreSQL server host, then a colon, then
  the port number, then a forward slash, then the database name of your Indicia
  installation. For example "localhost:5432/indicia_dev".
* {{ DB user }} - replace with the username used to connect to the database
  (normally the same username as used by the warehouse).
* {{ DB password }} - replace with the password associated with the database
  username.
* {{ JDBC jar file path }} - replace with the file path to your JDBC jar file
  installed earlier.
* {{ Working folder path }} - full path to the elasticsearch folder where you
  have the checked out files. When replacing this in the configuration, check
  that the edits result in valid file paths.
* {{ Elasticsearch address }} - the URI that Elasticsearch is installed on
  (possibly localhost:9200 if you followed these instructions to install
  on a single machine). Specify https:// at the start if using the HTTPS
  protocol.
* {{ Indicia warehouse unique name }} - allocate a simple identifier for the
  warehouse you are extracting the data from, e.g. BRC1. This will be prefixed
  to document IDs generated in Elasticsearch to ensure that if you pull data
  from other sources in future the IDs will not clash. It should match the
  abbreviation you gave for your warehouse when setting up the indexes and
  aliases earlier.

If you are intending to include confidential and/or unreleased records in your
dataset then you will need to review the statement section near the beginning of
your configuration file containing the SQL statement and uncomment the 2
suggested lines as appropriate.

Copy the resulting *.conf file to your logstash/bin folder.

#### Prepare the Logstash configuration file (RESTful access)

This approach uses the Indicia RESTful API to access the records. To do this,
access must be granted on the warehouse by configuring a client user ID, secret
and project ID for the appropriate set of records. Either request this from the
administrator of your warehouse, or if you are the administrator then the
information needed is documented at https://indicia-docs.readthedocs.io/en/latest/administrating/warehouse/modules/rest-api.html?highlight=rest.

Two templates are provided for you in your working directory's logstash-config
folder, one for record inserts and updates and another for deletions. Copy the
occurrences-http-indicia.conf.template file to a new file called
occurrences-http-indicia.conf. Copy the occurrences-http-indicia-deletions.conf.template
file to a new file called occurrences-http-indicia-deletions.conf and edit them
in your preferred text editor. Search and replace the following values:

* {{ Warehouse URL }} - the web address of the warehouse, e.g.
  https://warehouse1.indicia.org.uk.
* {{ User }} - your client user ID.
* {{ Secret }} - your client secret.
* {{ Project ID }} - your client project identifier configured on the warehouse.
* {{ Working folder path }} - full path to the elasticsearch folder where you
  have the checked out files. When replacing this in the configuration, check
  that the edits result in valid file paths.
* {{ Elasticsearch address }} - the URI that Elasticsearch is installed on
  (possibly localhost:9200 if you followed these instructions to install
  on a single machine). Specify https:// at the start if using the HTTPS
  protocol.
* {{ Indicia warehouse unique name }} - allocate a simple identifier for the
  warehouse you are extracting the data from, e.g. BRC1. This will be prefixed
  to document IDs generated in Elasticsearch to ensure that if you pull data
  from other sources in future the IDs will not clash.

You also need to create a new project in the REST API on the warehouse which
has the same configuration as your existing project, but a different ID so that
deleted record syncing can be tracked. Replace this project name in your
deletions config file.

If you are intending to include confidential and/or unreleased records in your
dataset then you will need to review the query section near the beginning of
your configuration file and uncomment the 2 suggested lines as appropriate.

If you are planning to hold sensitive records in your dataset then the
suggested approach is to contain 2 copies of each record, one blurred and one
at full precision. Then we can use a filter on an index alias to limit the
searched records appropriately. To achieve this, copy your occurrences-http-indicia.conf
configuration file to a file called occurrences-http-indicia-sensitive.conf.
You also need to create a new project in the REST API on the warehouse which
has the same configuration as your existing project, but a different ID so that
sensitive record syncing can be tracked. Now, edit your new configuration file
in a text editor and make the following edits:

* Search for your REST API project name and replace it with the new one created
  for sensitive record tracking.
* Change the report requested (in the http_poller url section of the
  configuration) from list_for_elastic.xml to list_for_elastic_sensitive.xml.
* Near the bottom of the config file, find the setting which denotes the
  document_id and add ! to the setting to denote that these records are full
  precision versions of sensitive records, for exammple:
  ```
  document_id => "myindex|%{id}!"
  ```

### Configuring your pipelines

You can run logstash from the command line by specifying a config file as a
parameter, e.g using the following command, replacing <path> with the path to
your working directory's logstash-config folder .

#### Windows

```shell
$ d:\elastic\logstash\bin\logstash -f <path>\occurrences-http-indicia.conf
```

#### Mac

```shell
$ logstash -f <path>/occurrences-http-indicia.conf
```

Because the configuration files contains a cron schedule, Logstash will run
the pipeline in each configuration file every minute. Press Ctrl-C to stop it
from running, which will wait until Logstash is idle before actually stopping.

We need both our configuration files to run permanently in the background, not
just one or the other, so that all inserts, updates and deletes can be
syncronised. This can be done by editing the pipelines.yml file in your
Logstash installation's config folder. This will be d:\elastic\logstash\bin on
Windows or /usr/local/Cellar/logstash/x.x.x/libexec/config on Mac if following
these instructions, where x.x.x is the specific version number.

Edit the pipelines.yml file in a text editor. Add the following to the end of
the file. Skip the 2 lines for sensitive config if you are not including
sensitive records in the dataset:

```
- pipeline.id: indicia_records
  path.config: "<path>/occurrences-http-indicia.config"
- pipeline.id: indicia_records_sensitive
  path.config: "<path>/occurrences-http-indicia-sensitive.config"
- pipeline.id: indicia_records_deletions
  path.config: "<path>/occurrences-http-indicia-deletions.config"
  pipeline.workers: 1
```

Replace <path> with your working directory's logstash-config folder to make a
valid path search string then save the pipelines.yml file. Specifying a single
pipeline worker for the deletions means it won't hog all the cores for the
deletion pipeline, giving it a slightly lower resource usage than the main
inserts/updates pipeline. **Note** - the path must use forward slashes rather
than backslashes as a directory separator (Unxix style) and will need to be on
the same drive letter as Logstash on Windows. Use a relative path if easier, or
'/' to denote the root of the drive Logstash is running from.

### Running Logstash to import the data

To initiate Logstahs run the following command from the terminal/command
prompt:

#### Windows

```shell
$ d:\elastic\logstash\bin\logstash
```

#### Mac

```shell
$ logstash
```

If all is well, Logstash will prepare itself as a process which will
continually restart each of the pipelines according to the schedule. Once all
the records have been transferred the Indicia REST API will switch mode from
initial population to updates, so rather than sequentially loading batches of
records by ID it will detect changes using the updated_on field.

## Using Elasticsearch from within Drupal

Elasticsearch provides a rich and well documented API which allows you to
extract the data and produce report outputs in a very flexible way. The Kibana
tool provides an excellent interface for browsing the data but in our opinion
it is perhaps too flexible and powerful to unleash on end-users. It may be
better to pre-built queries and appropriate outputs then embedd them in your
Indicia website.

So far a simple demo of this approach has been created for Drupal 7. You need
to ensure that you have the latest develop branch of the indicia_features
repository which contains an Elasticsearch proxy module. This module provides
a simple layer of authentication and authorisation, mapping requests to simple
templates describing predefined Elasticsearch queries. This ensures that users
don't get free and unfettered access to the entire dataset in Elasticsearch.

* Enable the Elasticsearch proxy module.
* Go to Configuration > IForm > Settings. Enter your Elasticsearch URL (which
  must be visible from the Drupal server but does not have to be visible from
  the client), e.g. http://example.com:9200 and save the settings.
* Visit the URL path on your Drupal site elasticsearch_proxy/user-summary to
  check it works.
* Optionally, create an empty Indicia report page (customisable) with no
  content in the user interface section. Create a node.nid.js file in
  sites/default/files/indicia/js to declare a script for this page and copy
  the following content in:

  ```js
  jQuery(document).ready(function($) {
    $.ajax({
    url: '/irecord_dev/elasticsearch_proxy/user-summary',
    dataType: 'json',
    success: function(response) {

      function stat(key, type = 'records') {
        var r = '-';
        $.each(response.aggregations.records.buckets, function() {
          if (this.key === key) {
            r = type === 'records' ? this.doc_count : this.species_count.value;
          }
        });
        return r;
      }

      var html = '<table style="font-size: 20px">';
      html += '<thead>';
      html += '<tr><th></th><th>This year</th><th>Total</th></tr>';
      html += '</thead>';
      html += '<tbody>';
      html += '<tr><th scope="row">Total records</th><td>' + stat('yr') + '</td><td>' + stat('total') + '</td></tr>';
      html += '<tr><th scope="row">Total species</th><td>' + stat('yr', 'species') + '</td><td>' + stat('total', 'species') + '</td></tr>';
      html += '<tr><th scope="row">Accepted records</th><td>' + stat('V&yr') + '</td><td>' + stat('V') + '</td></tr>'
      html += '<tr><th scope="row">Accepted species</th><td>' + stat('V&yr', 'species') + '</td><td>' + stat('V', 'species') + '</td></tr>';;
      if (stat('verified_by') !== '-') {
        html += '<tr><th scope="row">Verified by me</th><td>' + stat('verified_by&yr') + '</td><td>' + stat('verified_by') + '</td></tr>';
      }
      html += '<tbody>';
      html += '</table>';
      $('.node-content').append(html);
    }
    });

  });
  ```

  * Save the JS file and reload your Indicia report page. This is just a very
    simple demo designed to show that the data loading work as well as the
    performance of a complex aggregation that PostgreSQL would struggle with.

## Index structure notes

* Sensitive records are stored in the index twice, once for the blurred (metadata.sensitivity_blur:B) and once for the
  full precision record (metadata.sensitivity_precision:F). Non-sensitive records have no value for
  metadata.sensitivity_precision.
* Generally, the search index alias you use should always pre-filter confidential, unreleased and sensitive full
  precision records out as explained in this document. Override these defaults ONLY when you understand the
  implications.