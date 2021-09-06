# Using Elasticsearch to report on Indicia data

Elasticsearch (https://www.elastic.co) is a search and analytics engine which provides high
performance and scalability. It stores JSON document objects in indices where every field value is
effectively indexed.

It is possible to automatically create Elasticsearch indexes containing Indicia occurrences and/or
samples records. Since each document in an Elasticsearch index is a self-contained complete set of
information, occurrences documents contain details of the sample they were recorded within.
Therefore in most cases, a separate samples index is not required. However where a project requires
the ability to report on samples that contain no occurrences (e.g. timed counts where nothing was
observed), a separate samples index may be required.

* [Creating an occurrences index](docs/occurrences.md).
* [Creating a samples index](docs/samples.md).