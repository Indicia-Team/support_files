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
geometric shape, not simply some generic text field:

```json
PUT occurrence
{
  "mappings": {
    "doc": {
      "properties": {
        "created_by_id": { "type": "integer" },
        "website_id": { "type": "integer" },
        "survey_id": { "type": "integer" },
        "group_id": { "type": "integer" },
        "quality.verified_by_id": { "type": "integer" },
        "locality.geom":    { "type": "geo_shape" },
        "locality.point":    { "type": "geo_point" },
        "date.date_start": { "type": "date" },
        "date.date_end": { "type": "date" },
        "date.day_of_year": { "type": "short" },
        "date.week_of_year": { "type": "byte" },
        "date.month_of_year": { "type": "byte" }
      }
    }
  }
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
  * On the options dialog, uncheck the Column names option. Set the output file
    to Elasticsearch/data/taxa.csv in the working folder.
* In pgAdminn 4:
  * If indicia, public is not your logged in users default search path, then
    edit the query to add "indicia." in front of all the table names (use a
    different prefix if your schema is different).
  * Click the Download as CSV button. Note that I had problems using this under
    Internet Explorer with Enhanced Security Configuration enabled so ending up
    using Chrome instead.
  * Rename the downloaded file to taxa.csv and replace the file in
    Elasticsearch/data in your working folder.

To update the taxon-paths.csv file with a fresh copy of the data, repeat the
steps above for the prepare-taxon-paths.sql file, saving the results as
taxon-paths.csv.

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
  from other sources in future the IDs will not clash.

Copy the resulting *.conf file to your logstash/bin folder.

#### Prepare the Logstash configuration file (RESTful access)

This approach uses the Indicia RESTful API to access the records. To do this,
access must be granted on the warehouse by configuring a client user ID, secret
and project ID for the appropriate set of records. Either request this from the
administrator of your warehouse, or if you are the administrator then the
information needed is documented at https://indicia-docs.readthedocs.io/en/latest/administrating/warehouse/modules/rest-api.html?highlight=rest.

A template is provided for you in your working directory's logstash-config
folder. Copy the occurrences-http-indicia.conf.template file to a new file called
occurrences-http-indicia.conf and edit it in your preferred text editor.
Search and replace the following values:

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

Copy the resulting *.conf file to your logstash/bin folder.

### Running Logstash to import the data

Because the configuration file contains a cron schedule, Logstash will run the
pipeline every minute. To initiate this run the following command from the
terminal/command prompt:

#### Windows

```shell
$ d:\elastic\logstash\bin\logstash -f occurrences-http-indicia.conf
```

#### Mac

```shell
$ logstash -f occurrences-http-indicia.conf
```