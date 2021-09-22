# Elastic stack installation

On the server you plan to use as an Elasticsearch server, you will need to install the following components:

* Java
* Elasticsearch
* Logstash
* Kibana

The Elasticsearch documentation online describes installation in various scenarios so only brief
notes are provided below covering 2 scenarios, installing on Windows 10 using Elastic's zip
downloads and installing on a Mac using the Homebrew package manager (https://brew.sh).

Indicia's Elasticsearch integration works with version 6.* or 7.* of the Elasticsearch, so
installing the latest available 7.* release is recommended.

### Install Java

You will need to install Java before installation of Elasticsearch.
See https://www.elastic.co/guide/en/elasticsearch/reference/current/setup.html
for more information. Please check the support matrix to ensure that you are installing a version
of the Java JVM that works with the version of Elasticsearch, Logstash and Kibana you are
installing.

You only need to install the JRE, not the full JDK, unless required for other reasons. The Java
installation files can be downloaded at
https://www.oracle.com/technetwork/java/javase/downloads/index.html.

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
appropriate folder. For this example I created a folder d:\elastic and
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