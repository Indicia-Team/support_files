# Using Elasticsearch to report on Indicia occurrences

This document describes how to setup Elasticsearch with Indicia occurrence records loaded as
document objects. This setup involves a Elasticsearch instance (single machine or cluster) using
Logstash to continuosly copy data updates from the Indicia REST API into Elasticsearch. As data
are accessed via the REST API, the Elasticsearch server and Indicia server do not need to be on the
same network.

## Installation

See [Elastic stack installation](elk-installation.md).

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
easily. Finally, we include a version identifier in the index name, so that we
can use the Elasticsearch REINDEX API to copy the index to a new version if
we need to change mappings.

#### Elasticsearch 6.*

```json
PUT occurrence_brc1_v1?include_type_name=true
{
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 1
  },
  "mappings": {
    "doc": {
      "date_detection": false,
      "properties": {
        "id": { "type": "integer" },
        "@timestamp": { "type": "date"},
        "event.date_start": { "type": "date" },
        "event.date_end": { "type": "date" },
        "event.date_type": { "type": "keyword" },
        "event.day_of_year": { "type": "short" },
        "event.event_id": { "type": "integer" },
        "event.event_remarks": { "type": "text" },
        "event.parent_event_id": { "type": "integer" },
        "event.source_system_key": { "type": "keyword" },
        "event.week": { "type": "byte" },
        "event.ukbms_week": { "type": "byte" },
        "event.month": { "type": "byte" },
        "event.year": { "type": "short" },
        "event.attributes": {
          "type": "nested"
        },
        "event.parent_attributes": {
          "type": "nested"
        },
        "metadata.created_by_id": { "type": "integer" },
        "metadata.updated_by_id": { "type": "integer" },
        "metadata.created_on": {
          "type": "date",
          "format": "8yyyy-MM-dd HH:mm:ss||8yyyy-MM-dd HH:mm:ss.SSSS||8yyyy-MM-dd"
        },
        "metadata.updated_on": {
          "type": "date",
          "format": "8yyyy-MM-dd HH:mm:ss||8yyyy-MM-dd HH:mm:ss.SSSS||8yyyy-MM-dd"
        },
        "metadata.group.id": { "type": "integer" },
        "metadata.input_form": { "type": "keyword" },
        "metadata.survey.id": { "type": "integer" },
        "metadata.website.id": { "type": "integer" },
        "metadata.privacy_precision": { "type": "integer" },
        "metadata.private": { "type": "boolean" },
        "metadata.sensitive": { "type": "boolean" },
        "metadata.sensitivity_precision": { "type": "integer" },
        "metadata.sensitivity_blur": { "type": "keyword" },
        "metadata.confidential": { "type": "boolean" },
        "metadata.release_status": { "type": "keyword" },
        "metadata.trial": { "type": "boolean" },
        "metadata.tracking": { "type": "integer" },
        "identification.verifier.id": { "type": "integer" },
        "identification.verified_on": {
          "type": "date",
          "format": "8yyyy-MM-dd HH:mm:ss||8yyyy-MM-dd HH:mm:ss.SSSS||8yyyy-MM-dd"
        },
        "identification.verification_status": { "type": "keyword" },
        "identification.verification_substatus": { "type": "integer" },
        "identification.verification_decision_source": { "type": "keyword" },
        "identification.auto_checks.enabled": { "type": "boolean" },
        "identification.auto_checks.result": { "type": "boolean" },
        "location.geom": { "type": "geo_shape" },
        "location.point": { "type": "geo_point" },
        "location.grid_square.srid": { "type": "integer" },
        "location.grid_square.1km.centre": { "type": "keyword" },
        "location.grid_square.2km.centre": { "type": "keyword" },
        "location.grid_square.10km.centre": { "type": "keyword" },
        "location.higher_geography": {
          "type": "nested",
          "properties": {
            "id": { "type": "integer" },
            "code": { "type": "keyword" }
          }
        },
        "location.location_id": { "type": "integer" },
        "location.parent.location_id": { "type": "integer" },
        "location.code": { "type": "keyword" },
        "location.parent.code": { "type": "keyword" },
        "location.coordinate_uncertainty_in_meters": { "type": "integer" },
        "occurrence.source_system_key": { "type": "keyword" },
        "occurrence.individual_count": { "type": "integer" },
        "occurrence.zero_abundance": { "type": "boolean" },
        "occurrence.occurrence_remarks": { "type": "text" },
        "occurrence.attributes": {
          "type": "nested"
        },
        "occurrence.media": {
          "type": "nested"
        },
        "occurrence.associations": {
          "type": "nested",
          "properties": {
            "id": { "type": "integer" },
            "association_type": { "type": "keyword" },
            "accepted_name": {
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "text"
                }
              }
            },
            "vernacular_name": {
              "type": "keyword",
              "fields": {
                "text": {
                  "type": "text"
                }
              }
            }
          }
        },
        "taxon.accepted_taxon_id": { "type": "keyword" },
        "taxon.group_id": { "type": "integer" },
        "taxon.input_group_id": { "type": "integer" },
        "taxon.higher_taxon_ids": { "type": "keyword" },
        "taxon.species_taxon_id": { "type": "keyword" },
        "taxon.taxon_id": { "type": "keyword" },
        "taxon.taxon_list.id": { "type": "integer" },
        "taxon.marine": { "type": "boolean" },
        "taxon.freshwater": { "type": "boolean" },
        "taxon.terrestrial": { "type": "boolean" },
        "taxon.non_native": { "type": "boolean" },
        "taxon.taxa_taxon_list_id": { "type": "integer" },
        "taxon.taxon_meaning_id": { "type": "integer" },
        "taxon.taxon_rank_sort_order": { "type": "short" }
      }
    }
  }
}
```

#### Elasticsearch 7.*

```json
PUT occurrence_brc1_v1
{
  "settings": {
    "number_of_shards": 4,
    "number_of_replicas": 1
  },
  "mappings": {
    "date_detection": false,
    "properties": {
      "id": { "type": "integer" },
      "@timestamp": { "type": "date"},
      "event.date_start": { "type": "date" },
      "event.date_end": { "type": "date" },
      "event.date_type": { "type": "keyword" },
      "event.day_of_year": { "type": "short" },
      "event.event_id": { "type": "integer" },
      "event.event_remarks": { "type": "text" },
      "event.parent_event_id": { "type": "integer" },
      "event.source_system_key": { "type": "keyword" },
      "event.week": { "type": "byte" },
      "event.ukbms_week": { "type": "byte" },
      "event.month": { "type": "byte" },
      "event.year": { "type": "short" },
      "event.attributes": {
        "type": "nested"
      },
      "event.parent_attributes": {
        "type": "nested"
      },
      "event.media": {
        "type": "nested"
      },
      "metadata.created_by_id": { "type": "integer" },
      "metadata.updated_by_id": { "type": "integer" },
      "metadata.created_on": {
        "type": "date",
        "format": "uuuu-MM-dd HH:mm:ss||uuuu-MM-dd HH:mm:ss.SSS||uuuu-MM-dd"
      },
      "metadata.updated_on": {
        "type": "date",
        "format": "uuuu-MM-dd HH:mm:ss||uuuu-MM-dd HH:mm:ss.SSS||uuuu-MM-dd"
      },
      "metadata.group.id": { "type": "integer" },
      "metadata.input_form": { "type": "keyword" },
      "metadata.survey.id": { "type": "integer" },
      "metadata.website.id": { "type": "integer" },
      "metadata.privacy_precision": { "type": "integer" },
      "metadata.private": { "type": "boolean" },
      "metadata.sensitive": { "type": "boolean" },
      "metadata.sensitivity_precision": { "type": "integer" },
      "metadata.sensitivity_blur": { "type": "keyword" },
      "metadata.confidential": { "type": "boolean" },
      "metadata.release_status": { "type": "keyword" },
      "metadata.trial": { "type": "boolean" },
      "metadata.tracking": { "type": "integer" },
      "identification.verifier.id": { "type": "integer" },
      "identification.verified_on": {
        "type": "date",
        "format": "uuuu-MM-dd HH:mm:ss||uuuu-MM-dd HH:mm:ss.SSS||uuuu-MM-dd"
      },
      "identification.verification_status": { "type": "keyword" },
      "identification.verification_substatus": { "type": "integer" },
      "identification.verification_decision_source": { "type": "keyword" },
      "identification.auto_checks.enabled": { "type": "boolean" },
      "identification.auto_checks.result": { "type": "boolean" },
      "location.geom": { "type": "geo_shape" },
      "location.point": { "type": "geo_point" },
      "location.grid_square.srid": { "type": "integer" },
      "location.grid_square.1km.centre": { "type": "keyword" },
      "location.grid_square.2km.centre": { "type": "keyword" },
      "location.grid_square.10km.centre": { "type": "keyword" },
      "location.higher_geography": {
        "type": "nested",
        "properties": {
          "id": { "type": "integer" },
          "code": { "type": "keyword" }
        }
      },
      "location.location_id": { "type": "integer" },
      "location.parent.location_id": { "type": "integer" },
      "location.code": { "type": "keyword" },
      "location.parent.code": { "type": "keyword" },
      "location.coordinate_uncertainty_in_meters": { "type": "integer" },
      "occurrence.source_system_key": { "type": "keyword" },
      "occurrence.individual_count": { "type": "integer" },
      "occurrence.zero_abundance": { "type": "boolean" },
      "occurrence.occurrence_remarks": { "type": "text" },
      "occurrence.attributes": {
        "type": "nested"
      },
      "occurrence.media": {
        "type": "nested"
      },
      "occurrence.associations": {
        "type": "nested",
        "properties": {
          "id": { "type": "integer" },
          "association_type": { "type": "keyword" },
          "accepted_name": {
            "type": "keyword",
            "fields": {
              "text": {
                "type": "text"
              }
            }
          },
          "vernacular_name": {
            "type": "keyword",
            "fields": {
              "text": {
                "type": "text"
              }
            }
          }
        }
      },
      "taxon.accepted_taxon_id": { "type": "keyword" },
      "taxon.group_id": { "type": "integer" },
      "taxon.input_group_id": { "type": "integer" },
      "taxon.higher_taxon_ids": { "type": "keyword" },
      "taxon.species_taxon_id": { "type": "keyword" },
      "taxon.taxon_id": { "type": "keyword" },
      "taxon.taxon_list.id": { "type": "integer" },
      "taxon.marine": { "type": "boolean" },
      "taxon.freshwater": { "type": "boolean" },
      "taxon.terrestrial": { "type": "boolean" },
      "taxon.non_native": { "type": "boolean" },
      "taxon.taxa_taxon_list_id": { "type": "integer" },
      "taxon.taxon_meaning_id": { "type": "integer" },
      "taxon.taxon_rank_sort_order": { "type": "short" }
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
      "index" : "occurrence_brc1_v1",
      "alias" : "occurrence_search",
      "filter" : {
        "bool" : {
          "must": [
            {
              "query_string": {
                "query": "metadata.confidential:false AND metadata.release_status:R AND metadata.trial:false AND ((metadata.sensitivity_blur:B) OR (!metadata.sensitivity_blur:*))",
                "analyze_wildcard": true,
                "default_field": "*"
              }
            }
          ]
        }
      }
    } },
    { "add" : {
      "index" : "occurrence_brc1_v1",
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
      "alias" : "occurrence_search_ukbms",
      "filter" : {
        "bool" : {
          "must": [
            {
              "query_string": {
                "query": "metadata.website.id:27 AND metadata.confidential:false AND occurrence.zero_abundance:false AND metadata.release_status:R AND metadata.trial:false AND ((metadata.sensitivity_blur:B) OR (!metadata.sensitivity_blur:*))",
                "analyze_wildcard": true,
                "default_field": "*"
              }
            }
          ]
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

Logstash acts as a data conduit. We’ll use it to pipe data arriving in Indicia into an
Elasticsearch index.

#### Grab the files from Git

Download the support files repository (or clone it) from Git. To do this open
a command prompt/terminal window in a temporary location then:

```shell
$ git clone https://github.com/Indicia-Team/support_files.git
```

You need just the Elasticsearch folder which we will refer to as our working folder from now on.
If you already have other pipelines setup, e.g. for samples, then you only need a single copy
of the support files folder which can be shared between the pipelines.

#### Prepare the lookups for taxon data

Normally it will be acceptable to use the taxa.csv and taxon-paths.csv files
provided in the repository. Use the following instructions to regenerate them
if there are taxonomic changes that need to be applied to your imports.

Rather than expect all data sources to provide all the taxonomic information
related to a record in a single consistent format, we will use the UKSI dataset
copied into a YML file to create a lookup table containing the information,
keyed by external key (i.e. the NBN key of the taxon name). This file is
provided in the Elasticsearch/data/taxa.yml file. Then, during import, sources
can provide just a taxon NBN key and Logstash will be configured to use this
YML file to populate all the required taxon information to add to the search
index.

A second YML file is constructed from the UKSI data to provide path information
from the taxon's root through the taxonomic levels down to the taxon itself.
This makes queries based on higher taxa easy and performant. Normally you can
just use the copies of the 2 YML files provided in the repository, but
instructions for generating or updating them are provided below.

To update the taxa.yml file with a fresh copy of the data:

* Open the queries/prepare-taxa-lookup.sql file in pgAdmin, connecting to an
  Indicia database that has the UKSI dataset loaded.
* Search and replace <taxon_list_id> with the ID of the UKSI list. If there are
  multiple lists then change this filter to an ` IN (...)` clause. For the BRC
  warehouse1 for example, this filter is set to ` IN (15, 251, 258, 260, 261, 265)`
  to support use of the UK Species Inventory and the various lists for ABLE as
  well as the list for MammalNet-Europe.
* In pgAdmin 4, if indicia, public is not your logged in users default search path, then
  edit the query to add "indicia." in front of all the table names (use a
  different prefix if your schema is different).
* In pgAdmin's preferences, set CSV/Text output CSV Quoting option to "None".
* Click the Download as CSV button. Note that I had problems using this under
  Internet Explorer with Enhanced Security Configuration enabled so ending up
  using Chrome instead.
* Rename the downloaded file to taxa.yml and replace the file in
  Elasticsearch/data in your working folder.
* Edit the file in a text editor. Remove the first row (column titles), then
  ensure the line endings are set to LF and save it.

To update the taxon-paths.yml file with a fresh copy of the data, repeat the
steps above to download the output from the prepare-taxon-paths.sql file.
Search and replace "," with ": " then save the results as taxon-paths.yml.

Note that if multiple taxon lists are used to define the taxonomic hierarchy
then you should repeat the extraction for both lists and append the YAML data
together. For example in the BRC warehouse1 there is a list ID 15 for the UKSI
and also list 251 for European Butterflies since not all taxa are on the UK
list.

#### Prepare the lookup for location data

The location data lookup only needs to be prepared once - it can be shared with the samples
pipeline if both are configured.

* Open the queries/prepare-locations-lookup.sql file in pgAdmin, connecting to
  the database being imported into Elasticsearch.
* Search and replace <indexed_location_type_ids> with a comma separated list of
  location type IDs that are indexed. This should include all the types which
  are directly indexed by the spatial index builder
  (`modules/spatial_index_builders/config/spatial_index_builder.php`) as well
  as additional types implied because they hold parent locations for the types
  identified by the `hierarchical_location_types` setting. The following query
  shows how this can be done on the live BRC warehouse at the time of writing:
  ```sql
  select string_agg(id::text, ', ')
  from cache_termlists_terms
  where term in (
    -- The following are directly referenced in the spatial_index_builder's config file.
    'Vice County',
    'LRC Boundary',
    'Country',
    'Cairngorms NP NNR',
    'Miscellaneous indexed boundaries',
    'Butterfly Conservation Branch',
    'National Trust site',
    'NUTS Level 2',
    'RSPB Reserves',
    'Country territorial waters',
    'Woodland Trust site',
    'AONB',
    'National Park',
    'National Nature Reserve',
    -- The following are hold parents of NUTS Level 2 which is hierarchical so must be included.
    'NUTS Level 1',
    'Countries 2016')
  and termlist_id=5
  ```
  * Click the Download as CSV button.
  * Rename the downloaded file to locations.yml and replace the file in
    Elasticsearch/data in your working folder.
  * Edit the file in a text editor. Remove the first row (column titles) and
    perform the following replacements:
    * "," with ": "

There is a real world example of a location data update in the
[Locations Update Detail](locations-update-detail.md) file.

#### Prepare the Logstash configuration file (RESTful access)

This approach uses the Indicia RESTful API to access the records. To do this, access must be
granted on the warehouse by configuring a client user ID, secret and at least 2 project IDs (one
for records and one for deletions) for the appropriate set of records. Either request this from the
administrator of your warehouse, or if you are the administrator then the information needed is
documented at
https://indicia-docs.readthedocs.io/en/latest/administrating/warehouse/modules/rest-api.html. If
you are setting up other pipelines (e.g. for samples), then they can share a single client user ID
but will need their own unique project IDs so that the pipelines can be separately tracked.

Two templates are provided for you in your working directory's logstash-config folder, one for
record inserts and updates and another for deletions. Copy the `occurrences-http-indicia.template`
file to a new file called `occurrences-http-indicia.conf`. Copy the
`occurrences-http-indicia-deletions.template` file to a new file called
`occurrences-http-indicia-deletions.conf` and edit them in your preferred text editor. Search and
replace the following values:

* {{ Warehouse URL }} - the web address of the warehouse, e.g. https://warehouse1.indicia.org.uk.
* {{ User }} - your client user ID.
* {{ Secret }} - your client secret.
* {{ Project ID }} - your client project identifier configured on the warehouse. Make
  sure you set this correctly for the deletion project configuration to the alternative
  project ID.
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

### RESTful access - controlling which records are included

#### Zero abundance records

The default behaviour is for zero abundance records to be included in your search index.
This means you will need to take care not to inadvertantly include zero abundance records
in your reports and analyses if not appropriate. You can do this by configuring your
Elasticsearch aliases to automatically exclude zero abundance records (described below)
or if you prefer, you can change the query sent to the Indicia RESTful API to remove
zero_abundance records from those returned. Find the section in the config file **input**
> **http_poller** > **urls** > **indicia** > **query** and remove the # from the start of
the following line:

```
zero_abundance => "0"
```

#### Confidential records

If you are intending to include confidential records in your dataset then you can change
the query sent to the Indicia RESTful API to include confidential records in those
returned. Find the section in the config file **input** > **http_poller** > **urls** >
**indicia** > **query** and remove the # from the start of the following line:

```
# confidential => "all"
```

**Note that if you do this then please ensure you either filter out confidential records
in your search index aliases or you carefully control who has access to the Elasticsearch
index APIs.**

#### Unreleased records

If you are intending to include unreleased records in your dataset then you can change
the query sent to the Indicia RESTful API to include unreleased records in those
returned. Find the section in the config file **input** > **http_poller** > **urls** >
**indicia** > **query** and remove the # from the start of the following line:

```
# release_status => "A"
```

#### Sensitive records

If you are planning to hold sensitive records in your index then the suggested approach
is to contain 2 copies of each record, one blurred and one at full precision. Then we can
use a filter on an index alias to limit the searched records appropriately. To achieve
this, copy your occurrences-http-indicia.conf configuration file to a file called
occurrences-http-indicia-sensitive.conf. You also need to create a new project in the
REST API on the warehouse which has the same configuration as your existing project, but
a different ID so that sensitive record syncing can be tracked. This project's
configuration needs to be amended to enable access to the sensitive records report since
the report is normally restricted as follows. Edit the configuration in the
modules/rest_api/config/rest.php file for your client's project. In the
`resource_options` section, set the following configuration, removing the line for the
sensitive records report if you are not including sensitive records in the index:

  ```php
  'resource_options' => array(
    'reports' => array(
      'authorise' => [
        'library/occurrences/list_for_elastic_sensitive.xml',
      ],
    ),
  ),
  ```

Now, edit your new
configuration file in a text editor and make the following edits:

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

#### Training records

The default behaviour is for training records to be included in the index and denoted by
the field value `metadata.trial:true`. The Elasticsearch proxy code in Drupal is then
responsible for applying an appropriate filter to the requests depending on the training
field value in the current user's profile. Therefore any use of the Elasticsearch index
which does not go via the Drupal proxy should filter for an appropriate value (normally
`metadata.trial:false`). This includes:

* Direct access via Kibana
* Direct access to the Elasticsearch API
* Access via the Warehouse Proxy.

#### Including all records from any website

Your default RESTful client configuration on the warehouse will limit the records to
those available for reporting from a particular website registration. This website
registration is defined in the config file in the REST APIs module on the warehouse. It
is also possible to configure a situation where the index is populated with all records
from all website registrations, in which case index aliases should be used carefully to
ensure that access to the records in the index is limited appropriately. To do this you
need to enable access to reports which are normally restricted as they don't obey the
normal restrictions on website record access:

1. Edit the configuration in the modules/rest_api/config/rest.php file for your client's
   project. In the `resource_options` section, set the following configuration, removing
   the line for the sensitive records report if you are not including sensitive records
   in the index:

   ```php
   'resource_options' => array(
      'reports' => array(
        'authorise' => [
          'library/occurrences/list_for_elastic_all.xml',
          'library/occurrences/list_for_elastic_sensitive_all.xml',
        ],
      ),
    ),
    ```

    This exposes these reports to just your REST API client.
2. Edit your Logstash configuration file(s) to change the report called in the section
   **input** > **http_poller** > **urls** > **indicia** > **url**, adding `_all` to the
   report file name.

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
synchronised. This can be done by editing the pipelines.yml file in your
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

Replace <path> with the path to your working directory's logstash-config folder to make a
valid path search string then save the pipelines.yml file. Specifying a single pipeline
worker for the deletions means it won't hog all the cores for the deletion pipeline,
giving it a slightly lower resource usage than the main inserts/updates pipeline.

**Note** - the path must use forward
slashes rather than backslashes as a directory separator (Unix style) and will need to
be on the same drive letter as Logstash on Windows. Use a relative path if easier, or '/'
to denote the root of the drive Logstash is running from.

**Note 2** - there seems to be a bug in the current Logstash version on Windows where it only
finds the config file if using a relative path from the current working directory where you run
Logstash from. I found it works if I cd to the folder containing indicia_support_files then
run it from their with a relative path.

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

## Errors

If there is an error in one of the requests such as a timeout, then this results in an
event which contains the error response from Indicia. The document has no id field, so
the configuration provided here is designed to store that event in a 2nd index called
occurrence_<warehouse id>_errors. You can use Kibana to inspect the contents of this
index if it exists.

If errors occur, it is worth inspecting the occurrences on the warehouse that should have
been passed to Elasticsearch around the time of the error to ensure that everything has
been passed through. An error which occurs before the REST API concludes the request will
normally not update the tracking information (stored in the Indicia variables table) so
the next request from Logstash should pick up the missing changes. Indicia's REST API
should also recognise timeouts and will block further autofeed responses to avoid
duplicating query effort causing logjams on the server. However if an error occurs after
the REST API has processed the tracking information, then the batch of records may be
skipped in rare cases. You can modify the variables table on the warehouse to re-submit a
batch. E.g. for a project called BRC5, the following script illustrates this:

```sql
select value from variables where name='rest-autofeed-BRC5';
/*
Response "[{"mode":"initialLoad","last_date":"2019-02-06T10:50:00+00:00","last_id":"6685302"}]"
As we are in initialLoad mode, we can change the last_id in this json object to wind back before
a suspect period.
*/
update variables
set value='[{"mode":"initialLoad","last_date":"2019-02-06T10:50:00+00:00","last_id":"6450000"}]'
where name='rest-autofeed-BRC5';
```

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

## Forcing updates of the Elasticsearch index

Under normal circumstances, any change to an occurrence results in an UPDATE of the `cache_occurrences_functional`
table. This causes a trigger to fire - the `cache_functional_changed` function is triggered by updates on the table and
the function then automatically updates the `tracking` field value to the next higher value using a database sequence.
Therefore it is a simple task for Logstash to filter for all occurrences where the tracking value is higher than the
last received tracking value to ensure that it has picked up the next batch of records. In some circumstances, however,
the update of an occurrence in Elasticsearch needs to be manually triggered, for example if doing a manual database
update on sample data which does not change the actual occurrence raw data. In these circumstances, write an update
query which sets the `tracking` field value to `null` (the trigger will fire and update it to the next correct value)
for all occurrences you need to update. For example the following forces through an update for all records where
survey ID is 123:

```sql
UPDATE cache_occurrences_functional
SET tracking=null
WHERE survey_id=123;
```

An alternative method of re-indexing the whole dataset is to remove the records from the `variables` table which track
the update status of the API feed to Elasticsearch.

## Index structure notes

See [Occurrences Document Structure](occurrences-document-structure.md).