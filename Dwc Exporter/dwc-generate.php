<?php

use Elasticsearch\ClientBuilder;

require 'vendor/autoload.php';

class BuildDwcHelper {

  /**
   * Configuration.
   *
   * @var object
   */
  private $conf;

  /**
   * CSV header row for Darwin Core standard output.
   *
   * @var array
   */
  private $headerRowDwc = [
    'occurrenceID',
    'otherCatalogNumbers',
    'eventID',
    'scientificName',
    'taxonID',
    'lifeStage',
    'sex',
    'individualCount',
    'vernacularName',
    'eventDate',
    'recordedBy',
    'licence',
    'rightsHolder',
    'coordinateUncertaintyInMeters',
    'decimalLatitude',
    'decimalLongitude',
    'geodeticDatum',
    'datasetName',
    'datasetID',
    'collectionCode',
    'locality',
    'basisOfRecord',
    'identificationVerificationStatus',
    'identifiedBy',
    'occurrenceStatus',
    'eventRemarks',
    'occurrenceRemarks',
  ];

  /**
   * CSV header row for Darwin Core NBN variant output.
   *
   * Differs in the way grid references are handled.
   *
   * @var array
   */
  private $headerRowNbn = [
    'occurrenceID',
    'otherCatalogNumbers',
    'eventID',
    'scientificName',
    'taxonID',
    'lifeStage',
    'sex',
    'individualCount',
    'vernacularName',
    'eventDate',
    'recordedBy',
    'licence',
    'rightsHolder',
    'coordinateUncertaintyInMeters',
    'gridReference',
    'decimalLatitude',
    'decimalLongitude',
    'datasetName',
    'datasetID',
    'collectionCode',
    'locality',
    'basisOfRecord',
    'identificationVerificationStatus',
    'identifiedBy',
    'occurrenceStatus',
    'eventRemarks',
    'occurrenceRemarks',
  ];

  /**
   * CSV header row that is in use for the loaded config.
   *
   * @var array
   */
  private $headerRow;

  /**
   * Constructor loads and checks config.
   *
   * @param string $configFileName
   *   Name of the config file name with relative or absolute path.
   */
  public function __construct($configFileName) {
    echo "\n-Starting extraction\n";
    try {
      $this->loadConfig($configFileName);
      $this->validateConfig();
      echo "Config file \"$configFileName\" loaded\n";
    }
    catch (Exception $e) {
      die("Error loading \"$configFileName\"\n" . $e->getMessage());
    }
  }

  /**
   * Load the configuration.
   *
   * @param string $configFileName
   *   Configuration file name.
   */
  private function loadConfig($configFileName) {
    if (!file_exists($configFileName)) {
      throw new Exception("Configuration file $configFileName not found");
    }
    $configFileContents = file_get_contents($configFileName);
    if (empty(trim($configFileContents))) {
      throw new Exception("Empty configuration file");
    }
    $this->conf = json_decode($configFileContents);
    if (empty($this->conf)) {
      throw new Exception("Invalid configuration file - JSON parse failure");
    }
    // Set the appropriate columns list.
    $this->headerRow = in_array('useGridRefsIfPossible', $this->conf->options) ? $this->headerRowNbn : $this->headerRowDwc;
  }

  /**
   * Validates parameters in the config file.
   *
   * @throw Exception
   *   Throws exceptions where problems found.
   */
  public function validateConfig() {
    if (empty($this->conf->elasticsearchHost)) {
      throw new Exception("Missing elasticsearchHost setting in configuration");
    }
    if (empty($this->conf->index)) {
      throw new Exception("Missing index setting in configuration");
    }
    if (empty($this->conf->outputType)) {
      throw new Exception("Missing outputType setting in configuration");
    }
    if (!in_array($this->conf->outputType, ['dwca', 'csv'])) {
      throw new Exception("Unsupported outputType setting in configuration");
    }
    if (empty($this->conf->outputFile)) {
      throw new Exception("Missing outputFile setting in configuration");
    }
    if ($this->conf->outputType === 'dwca') {
      if (!file_exists($this->conf->outputFile) && !isset($this->conf->xmlFilesInDir)) {
        throw new Exception('Darwin Core Archive output file should already exist, or additional XML files specified in folder identified by xmlFilesInDir setting.');
      }
      if (isset($this->conf->xmlFilesInDir)) {
        if (!is_dir($this->conf->xmlFilesInDir)) {
          throw new Exception($this->conf->xmlFilesInDir . ' directory specified in xmlFilesInDir config setting does not exist');
        }
        if (!file_exists($this->conf->xmlFilesInDir . DIRECTORY_SEPARATOR . 'eml.xml')) {
          throw new exception('EML file missing: ' . $this->conf->xmlFilesInDir . DIRECTORY_SEPARATOR . 'eml.xml');
        }
        if (!file_exists($this->conf->xmlFilesInDir . DIRECTORY_SEPARATOR . 'meta.xml')) {
          throw new exception('Metadata file missing: ' . $this->conf->xmlFilesInDir . DIRECTORY_SEPARATOR . 'meta.xml');
        }
      }
    }
    if (empty($this->conf->rightsHolder)) {
      throw new Exception("Missing rightsHolder setting in configuration");
    }
    if (empty($this->conf->datasetName)) {
      throw new Exception("Missing datasetName setting in configuration");
    }
    if (empty($this->conf->basisOfRecord)) {
      $this->conf->basisOfRecord = 'HumanObservation';
    }
    if (empty($this->conf->occurrenceStatus)) {
      $this->conf->occurrenceStatus = 'present';
    }
    if (!isset($this->conf->occurrenceIdPrefix)) {
      $this->conf->occurrenceStatus = '';
    }
    if (empty($this->conf->defaultLicenceCode)) {
      $this->conf->defaultLicenceCode = '';
    }
  }

  /**
   * Performs the task of building the file.
   */
  public function buildFile() {
    $client = ClientBuilder::create()->setHosts([$this->conf->elasticsearchHost])->build();
    $params = [
      // How long between scroll requests. Should be small!
      'scroll' => '30s',
      // How many results *per shard* you want back. Set this too high will
      // cause PHP memory errors.
      'size'   => 1000,
      'index'  => $this->conf->index,
      'body'   => [
        'query' => $this->conf->query,
      ],
    ];

    // Execute the search.
    // The response will contain the first batch of documents
    // and a scroll_id.
    $response = $client->search($params);

    $file = fopen($this->getOutputCsvFileName(), 'w');
    fputcsv($file, $this->headerRow);

    // Now we loop until the scroll "cursors" are exhausted.
    while (isset($response['hits']['hits']) && count($response['hits']['hits']) > 0) {
      foreach ($response['hits']['hits'] as $hit) {
        fputcsv($file, $this->getRowData($hit['_source']));
      }

      // When done, get the new scroll_id in case it changes.
      $scroll_id = $response['_scroll_id'];

      // Execute a Scroll request and repeat.
      $response = $client->scroll([
        'body' => [
          // Using our previously obtained _scroll_id.
          'scroll_id' => $scroll_id,
          // Plus the same timeout window.
          'scroll'    => '30s',
        ],
      ]);
      // Progress.
      echo '.';
    }
    echo "\n";
    fclose($file);
    if ($this->conf->outputType === 'dwca') {
      echo "Preparing Darwin Core archive file\n";
      $this->updateDwcaFile();
    }
    echo "OK\n";
  }

  /**
   * Return the CSV file to output raw data into.
   *
   * Either returns the specified file name, or modifies the extension if the
   * output type is Darwin Core Archive.
   *
   * @return string
   *   File name.
   */
  private function getOutputCsvFileName() {
    if ($this->conf->outputType === 'csv') {
      return $this->conf->outputFile;
    }
    else {
      $info = pathinfo($this->conf->outputFile);
      return $info['dirname'] . DIRECTORY_SEPARATOR . $info['filename'] . '.csv';
    }
  }

  /**
   * If the file type is DwcA, build the zip file.
   *
   * Adds the occurrences CSV file and the optional XML files.
   */
  private function updateDwcaFile() {
    $zip = new ZipArchive();
    $zip->open($this->conf->outputFile, ZipArchive::CREATE);
    echo "Zip archive file opened\n";
    $zip->addFile($this->getOutputCsvFileName(), 'occurrences.csv');
    // If the EML and metadata files are specified then add them.
    if (!empty($this->conf->xmlFilesInDir)) {
      $zip->addFile($this->conf->xmlFilesInDir . DIRECTORY_SEPARATOR . 'eml.xml', 'eml.xml');
      $zip->addFile($this->conf->xmlFilesInDir . DIRECTORY_SEPARATOR . 'meta.xml', 'meta.xml');
    }
    $zip->close();
    // Don't need the CSV file.
    unlink($this->getOutputCsvFileName());
  }

  /**
   * Converts an occurrence data array into the correct row order for CSV.
   *
   * @param array $row
   *   Associative array of occurrence values.
   *
   * @return array
   *   Values array in same order as the header row.
   */
  private function convertToHeaderRowOrder(array $row) {
    $converted = [];
    foreach ($this->headerRow as $column) {
      $converted[] = $row[$column];
    }
    return $converted;
  }

  /**
   * Return the array to represent a document as DwcA CSV.
   *
   * @param array $source
   *   ES document source.
   *
   * @return array
   *   CSV data.
   */
  private function getRowData(array $source) {
    $points = explode(',', $source['location']['point']);
    $sensitiveOrNotPoint = (isset($source['metadata']['sensitive']) && $source['metadata']['sensitive'] === 'true') ||
      (isset($source['location']['input_sref_system']) && !preg_match('/^\d+$/', $source['location']['input_sref_system']));
    $useGridRefsIfPossible = in_array('useGridRefsIfPossible', $this->conf->options);
    $row = [
      'occurrenceID' => $this->conf->occurrenceIdPrefix . $source['id'],
      'otherCatalogNumbers' => empty($source['occurrence']['source_system_key']) ? '' : $source['occurrence']['source_system_key'],
      'eventID' => $source['event']['event_id'],
      'scientificName' => isset($source['taxon']['accepted_name'])
	      ? ($source['taxon']['accepted_name'] . (empty($source['taxon']['accepted_name_authorship']) ? '' : ' ' . $source['taxon']['accepted_name_authorship']))
		    : $source['taxon']['taxon_name'],
      'taxonID' => $source['taxon']['accepted_taxon_id'] ?? $source['taxon']['taxon_id'],
      'lifeStage' => empty($source['occurrence']['life_stage']) ? '' : $source['occurrence']['life_stage'],
      'sex' => empty($source['occurrence']['sex']) ? '' : $source['occurrence']['sex'],
      'individualCount' => empty($source['occurrence']['organism_quantity']) ? '' : $source['occurrence']['organism_quantity'],
      'vernacularName' => empty($source['taxon']['vernacular_name']) ? '' : $source['taxon']['vernacular_name'],
      'eventDate' => $this->getDate($source),
      'recordedBy' => empty($source['event']['recorded_by']) ? '' : $source['event']['recorded_by'],
      'licence' => empty($source['metadata']['licence_code']) ? $this->conf->defaultLicenceCode : $source['metadata']['licence_code'],
      'rightsHolder' => $this->conf->rightsHolder,
      'coordinateUncertaintyInMeters' => empty($source['location']['coordinate_uncertainty_in_meters']) ? '' : $source['location']['coordinate_uncertainty_in_meters'],
      'gridReference' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? $source['location']['output_sref'] : '',
      'decimalLatitude' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? '' : $points[0],
      'decimalLongitude' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? '' : $points[1],
      'geodeticDatum' => 'WGS84',
      'datasetName' => $this->conf->datasetName,
      'datasetID' => $this->getDatasetId($source),
      'collectionCode' => $this->getCollectionCode($source),
      'locality' => empty($source['location']['verbatim_locality']) ? '' : $source['location']['verbatim_locality'],
      'basisOfRecord' => $this->conf->basisOfRecord,
      'identificationVerificationStatus' => $this->getIdentificationVerificationStatus($source),
      'identifiedBy' => empty($source['identification']['identified_by']) ? '' : $source['identification']['identified_by'],
      'occurrenceStatus' => $this->conf->occurrenceStatus,
      'eventRemarks' => empty($source['event']['event_remarks']) ? '' : $source['event']['event_remarks'],
      'occurrenceRemarks' => empty($source['occurrence']['occurrence_remarks']) ? '' : $source['occurrence']['occurrence_remarks'],
    ];

    return $this->convertToHeaderRowOrder($row);
  }

  /**
   * Format date info from ES document as DwC event date.
   *
   * @param array $source
   *   ES Document source.
   *
   * @return string
   *   Date string.
   *
   * @todo Following is simplistic, doesn't handle YYYY, YYYY-MM, YYYY/YYYY or YYYY-MM/YYYY-MM formats.
   */
  private function getDate(array $source) {
    $dateStart = $source['event']['date_start'] ?? '';
    $dateEnd = $source['event']['date_end'] ?? '';
    return $dateStart . ($dateStart === $dateEnd ? '' : '/' . $source['event']['date_end']);
  }

  /**
   * Extract dataset ID from an ES document.
   *
   * @param array $source
   *   ES Document source.
   *
   * @return string
   *   Dataset ID or empty string if not present.
   */
  private function getDatasetId(array $source) {
    if (!empty($this->conf->datasetIdSampleAttrId) && !empty($source['event']['attributes'])) {
      foreach ($source['event']['attributes'] as $attr) {
        if ($attr['id'] == $this->conf->datasetIdSampleAttrId) {
          return $attr['value'];
        }
      }
    }
    return '';
  }

  /**
   * Format website and survey title as CollectionCode.
   *
   * @param array $source
   *   ES Document source.
   *
   * @return string
   *   CollectionCode string.
   */
  private function getCollectionCode(array $source) {
    $website = $source['metadata']['website']['title'];
    $survey = $source['metadata']['survey']['title'];
    $uniquePartOfSurveyName = ucfirst(trim(preg_replace('/^' . $website . '/', '', $survey)));
    return "$website | $uniquePartOfSurveyName";
  }

  /**
   * Format record status as identificationVerificationStatus.
   *
   * @param array $source
   *   ES Document source.
   *
   * @return string
   *   IdentificationVerificationStatus string.
   */
  private function getIdentificationVerificationStatus(array $source) {
    $status = $source['identification']['verification_status'] . $source['identification']['verification_substatus'];
    switch ($status) {
      case 'V0':
        return 'Accepted';

      case 'V1':
        return 'Accepted - correct';

      case 'V2':
        return 'Accepted - considered correct';

      case 'C0':
        return 'Unconfirmed - not reviewed';

      case 'C3':
        return 'Unconfirmed - plausible';

      default:
        return '';
    }
  }

}

// Startup.

if (count($argv) !== 2) {
  die('Supply a single argument which contains the name of the config file to load.');
}
$configFile = $argv[1];
$helper = new BuildDwcHelper($configFile);
$helper->buildFile();
