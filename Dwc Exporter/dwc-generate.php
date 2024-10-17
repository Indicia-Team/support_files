<?php

use Elastic\Elasticsearch\ClientBuilder;

require 'vendor/autoload.php';

class BuildDwcHelper {

  /**
   * Website ID.
   *
   * @var int
   */
  private $websiteID;

  /**
   * Website password.
   *
   * @var string
   */
  private $websitePassword;

  /**
   * URL for warehouse web-service access.
   *
   * @var string
   */
  private $warehouseUrl;

  /**
   * ID of the main taxonomic checklist.
   *
   * @var int
   */
  private $masterChecklistId;


  /**
   * Configuration for current export.
   *
   * @var object
   */
  private $conf;

  /**
   * Configuration as loaded.
   *
   * @var object
   */
  private $confAsLoaded;

  /**
   * Array of metadata for the output data files.
   *
   * List of files to output, each an array containing type (Occurrence or
   * Event), filename, columns (array of DwC terms). The first file is the core
   * file, any extra files described are extensions.
   */
  private array $dataFiles;

  /**
   * Auth tokens.
   *
   * @var array
   */
  private array $readAuth;

  /**
   * Constructor loads and checks config.
   *
   * @param string $configFileName
   *   Name of the config file name with relative or absolute path.
   */
  public function __construct($configFileName) {
    echo "\n-Starting extraction\n";
    $this->loadServerConfig();
    $this->readAuth = $this->getReadAuth();
    try {
      $this->loadConfig($configFileName);
    }
    catch (Exception $e) {
      die("Error loading \"$configFileName\"\n" . $e->getMessage());
    }
  }

  /**
   * Load the warehouse configuration.
   */
  private function loadServerConfig() {
    if (!file_exists('config/warehouse.json')) {
      throw new Exception('Configuration file config/warehouse.json not found');
    }
    $configFileContents = file_get_contents('config/warehouse.json');
    if (empty(trim($configFileContents))) {
      throw new Exception('Empty configuration file');
    }
    $warehouseConf = json_decode($configFileContents);
    $this->websiteID = $warehouseConf->website_id;
    $this->websitePassword = $warehouseConf->website_password;
    $this->warehouseUrl = $warehouseConf->warehouse_url;
    $this->masterChecklistId = $warehouseConf->master_checklist_id;
  }

  /**
   * Load the export configuration.
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
    $this->confAsLoaded = array_merge([
      'options' => [],
    ], json_decode($configFileContents, TRUE));
    if (empty($this->confAsLoaded)) {
      throw new Exception("Invalid configuration file - JSON parse failure");
    }
    // If repeatExport not configured, set up a default so a single file is
    // export using the base config.
    if (empty($this->confAsLoaded['repeatExport'])) {
      $this->confAsLoaded['repeatExport'] = [
        [],
      ];
    }
    echo "Config file \"$configFileName\" loaded\n";
  }

  private function initConfig($configFileName) {
    // Apply conventional defaults.
    $baseName = pathinfo($configFileName, PATHINFO_FILENAME);
    if (empty($this->conf['xmlFilesInDir']) && is_dir("metadata/$baseName")) {
      $this->conf['xmlFilesInDir'] = "metadata/$baseName";
    }
    $this->conf = array_merge([
      'basisOfRecord' => 'HumanObservation',
      'defaultLicenceCode' => '',
      'eventIdPrefix' => '',
      'occurrenceIdPrefix' => '',
      'outputFile' => 'exports/' . preg_replace('/[^a-z0-9]/', '_', strtolower($baseName)) . '.zip',
    ], $this->conf);
    if (!empty($this->conf['filterId'])) {
      $this->loadFilterIntoConfig();
    }
    // Apply shortcut filters for survey ID and higher geography.
    if (!empty($this->conf['surveyId'])) {
      $this->conf['query']['bool']['must'][] = ['term' => ['metadata.survey.id' => $this->conf['surveyId']]];
    }
    if (!empty($this->conf['higherGeographyId'])) {
      $this->conf['query']['bool']['must'][] = [
        'nested' => [
          'path' => 'location.higher_geography',
          'query' => [
            'term' => ['location.higher_geography.id' => $this->conf['higherGeographyId']],
          ],
        ],
      ];
    }
  }

  /**
   * Validates parameters in the config file.
   *
   * @throw Exception
   *   Throws exceptions where problems found.
   */
  private function validateConfig() {
    if (empty($this->conf['elasticsearchHost'])) {
      throw new Exception("Missing elasticsearchHost setting in configuration");
    }
    if (empty($this->conf['index'])) {
      throw new Exception("Missing index setting in configuration");
    }
    if (empty($this->conf['outputType'])) {
      throw new Exception("Missing outputType setting in configuration");
    }
    if (!in_array($this->conf['outputType'], ['dwca', 'csv'])) {
      throw new Exception("Unsupported outputType setting in configuration");
    }
    if (empty($this->conf['outputFile'])) {
      throw new Exception("Missing outputFile setting in configuration");
    }
    if (empty($this->conf['query']) && empty($this->conf['filterId'])) {
      throw new Exception("Invalid configuration file - either a query or a filterId entry is required.");
    }
    if ($this->conf['outputType'] === 'dwca') {
      if (!file_exists($this->conf['outputFile']) && !isset($this->conf['xmlFilesInDir'])) {
        throw new Exception('Darwin Core Archive output file should already exist, or additional XML files specified in folder identified by xmlFilesInDir setting.');
      }
      if (isset($this->conf['xmlFilesInDir'])) {
        if (!is_dir($this->conf['xmlFilesInDir'])) {
          throw new Exception($this->conf['xmlFilesInDir'] . ' directory specified in xmlFilesInDir config setting does not exist');
        }
        if (!file_exists($this->conf['xmlFilesInDir'] . DIRECTORY_SEPARATOR . 'eml.xml')) {
          throw new exception('EML file missing: ' . $this->conf['xmlFilesInDir'] . DIRECTORY_SEPARATOR . 'eml.xml');
        }
      }
    }
    if (!file_exists($this->conf['xmlFilesInDir'] . DIRECTORY_SEPARATOR . 'meta.xml')) {
      throw new exception('Metadata file missing: ' . $this->conf['xmlFilesInDir'] . DIRECTORY_SEPARATOR . 'meta.xml');
    }
    if (empty($this->conf['rightsHolder'])) {
      throw new Exception("Missing rightsHolder setting in configuration");
    }
    if (empty($this->conf['datasetName'])) {
      throw new Exception("Missing datasetName setting in configuration");
    }
    if (!empty($this->conf['surveyId']) && preg_match('/^\d+$/', $this->conf['surveyId'])) {
      throw new Exception('The surveyId setting should be an integer.');
    }
    if (!empty($this->conf['higherGeographyId']) && !preg_match('/^[0-9]+$/', $this->conf['higherGeographyId'])) {
      throw new Exception('The higherGeographyId setting should be an integer containing a location ID.');
    }
  }

  /**
   * Load the meta.xml file.
   *
   * Loads the file which describes the event and/or occurrence output files
   * required.
   */
  function loadMetafile() {
    $this->dataFiles = [];
    $dom = new DOMDocument();
    $dom->loadXML(file_get_contents($this->conf['xmlFilesInDir'] . DIRECTORY_SEPARATOR . 'meta.xml'));
    $archive = $dom->getElementsByTagName('archive');
    if (count($archive) !== 1) {
      throw new Exception('Meta.xml file must have exactly 1 archive element.');
    }
    $core = $archive->item(0)->getElementsByTagName('core');
    if (count($core) !== 1) {
      throw new Exception('Meta.xml file must have exactly 1 core element in the archive element.');
    }
    $this->dataFiles[] = $this->getFileMetadataFromXml($core->item(0));
    $extensions = $archive->item(0)->getElementsByTagName('extension');
    if (count($extensions) > 0 && !in_array('id', $this->dataFiles[0]['columns'])) {
      throw new Exception('Meta.xml file must describe an id column for the core file when extensions are present.');
    }
    foreach ($extensions as $extension) {
      $extMetadata = $this->getFileMetadataFromXml($extension);
      if (!in_array('coreid', $extMetadata['columns'])) {
        throw new Exception('Meta.xml file must describe a coreid column for each extension.');
      }
      $this->dataFiles[] = $extMetadata;
    }
  }

  /**
   * Read the metadata needed for a data file from it's meta.xml element.
   *
   * @param DOMElement $el
   *   XML file element for the data file (core or extension).
   *
   * @return array
   *   Metadata, including the type (Occurrence or Event), filename and list
   *   of columns.
   */
  private function getFileMetadataFromXml(DOMElement $el): array {
    $rowType = $el->getAttribute('rowType');
    // We currently only support occurrence and event types but this could be
    // extended in future.
    if (!preg_match('/^http(s)?:\/\/rs.tdwg.org\/dwc\/terms\/(?P<type>(Occurrence|Event))$/', $rowType, $matches)) {
      throw new Exception('Unrecognised rowType given for the core element.');
    }
    $r = [
      'type' => $matches['type'],
      'columns' => [],
    ];
    // The filename in the metadata files locations elements are only used for
    // the components of a DwC-A export, or if there are multiple CSV files
    // specified.
    if ($this->conf['outputType'] === 'dwca' || count($this->dataFiles) > 1) {
      $r['filename'] = $el->getElementsByTagName('files')->item(0)->getElementsByTagName('location')->item(0)->textContent;
    }
    foreach ($el->childNodes as $pos => $childEl) {
      if (is_a($childEl, 'DOMElement')) {
        $index = (integer) $childEl->getAttribute('index') === '' ? $pos : $childEl->getAttribute('index');
        if (isset($r['columns'][$index])) {
          throw new Exception("Duplicate index $index in meta.xml list of fields.");
        }
        if ($childEl->nodeName === 'id' || $childEl->nodeName === 'coreid') {
          $r['columns'][$index] = $childEl->nodeName;
        }
        elseif ($childEl->nodeName === 'field') {
          $r['columns'][$index] = basename($childEl->getAttribute('term'));
        }
      }
    }
    ksort($r['columns']);
    return $r;
  }

  /**
   * Return true if an occurrence is valid and complete.
   *
   * Currently this is any occurrence with a taxonID.
   *
   * @param array $source
   *   Occurrence data from ES.
   *
   * @return bool
   *   True if valid and complete.
   */
  private function isOccurrenceValid(array $source): bool {
    return !empty($source['taxon']['taxon_id']);
  }

  /**
   * Performs the task of building an occurrences data file.
   */
  private function buildOccurrenceFile(array $fileMetadata) {
    $client = ClientBuilder::create()->setHosts([$this->conf['elasticsearchHost']])->build();
    $params = [
      // How long between scroll requests. Should be small!
      'scroll' => '30s',
      'size'   => 1000,
      'index'  => $this->conf['index'],
      'body'   => [
        'query' => $this->conf['query'],
      ],
    ];
    // Execute the search.
    // The response will contain the first batch of documents
    // and a scroll_id.
    $response = $client->search($params);
    $file = fopen($this->getOutputCsvFileName($fileMetadata), 'w');
    fputcsv($file, $fileMetadata['columns']);

    // Now we loop until the scroll "cursors" are exhausted.
    while (isset($response['hits']['hits']) && count($response['hits']['hits']) > 0) {
      foreach ($response['hits']['hits'] as $hit) {
        if ($this->isOccurrenceValid($hit['_source'])) {
          fputcsv($file, $this->getOccurrenceRowData($hit['_source'], $fileMetadata));
        }
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
  }

  /**
   * Performs the task of building an events data file.
   */
  private function buildEventFile(array $fileMetadata) {
    if (empty($this->conf['eventIndex'])) {
      throw new Exception("Missing eventIndex setting in configuration");
    }
    $client = ClientBuilder::create()->setHosts([$this->conf['elasticsearchHost']])->build();

    $params = [
      // How long between scroll requests. Should be small!
      'scroll' => '30s',
      'size'   => 1000,
      'index'  => $this->conf['eventIndex'],
      'body'   => [
        'query' => $this->conf['query'],
      ],
    ];
    // Execute the search.
    // The response will contain the first batch of documents
    // and a scroll_id.
    $response = $client->search($params);

    // Execute the search.
    // The response will contain the first batch of documents
    // and a scroll_id.
    $response = $client->search($params);

    $file = fopen($this->getOutputCsvFileName($fileMetadata), 'w');
    fputcsv($file, $fileMetadata['columns']);

    // Now we loop until the scroll "cursors" are exhausted.
    while (isset($response['hits']['hits']) && count($response['hits']['hits']) > 0) {
      foreach ($response['hits']['hits'] as $hit) {
        fputcsv($file, $this->getEventRowData($hit['_source'], $fileMetadata));
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
  }

  /**
   * Build the output dataset files described by meta.xml.
   */
  public function buildFiles($configFileName) {
    foreach ($this->confAsLoaded['repeatExport'] as $exportOverrideInfo) {
      $this->conf = array_merge($this->confAsLoaded, $exportOverrideInfo);
      $this->initConfig($configFileName);
      $this->validateConfig();
      $this->loadMetafile();
      echo 'Metafile ' . $this->conf['xmlFilesInDir'] . "/meta.xml loaded\n";
      foreach ($this->dataFiles as $fileMetadata) {
        if ($fileMetadata['type'] === 'Occurrence') {
          $this->buildOccurrenceFile($fileMetadata);
        }
        else {
          $this->buildEventFile($fileMetadata);
        }
      }
      if ($this->conf['outputType'] === 'dwca') {
        echo "Preparing Darwin Core archive file\n";
        $this->updateDwcaFile();
      }
    }
    echo "OK\n";
  }

  /**
   * If the config specifies a filter ID, convert to an ES query.
   */
  private function loadFilterIntoConfig() {
    $filter = $this->getData([
      'table' => 'filter',
      'id' => $this->conf['filterId'],
    ]);
    $definition = json_decode($filter[0]['definition'], TRUE);
    $bool = [
      'must' => [
        ['term' => ['metadata.confidential' => FALSE]],
        ['term' => ['metadata.trial' => FALSE]],
        ['term' => ['metadata.release_status' => 'R']],
        [
          'query_string' => [
            'query' => '((metadata.sensitivity_blur:B) OR (!metadata.sensitivity_blur:*))',
          ],
        ],
      ],
    ];
    // Grid system if output is to the NBN.
    if (in_array('useGridRefsIfPossible', $this->conf['options'])) {
      $bool['must'][] = [
        'terms' => [
          'location.output_sref_system.keyword' => [
            'OSGB',
            'OSIE',
            'UTM30ED50',
          ],
        ],
      ];
    }
    $this->applyUserFiltersTaxonGroupList($definition, $bool);
    $this->applyUserFiltersTaxaTaxonList($definition, $bool);
    $this->applyUserFiltersTaxonMeaning($definition, $bool);
    $this->applyUserFiltersTaxaTaxonListExternalKey($definition, $bool);
    $this->applyUserFiltersTaxonRankSortOrder($definition, $bool);
    $this->applyFlagFilter('marine', $definition, $bool);
    $this->applyFlagFilter('freshwater', $definition, $bool);
    $this->applyFlagFilter('terrestrial', $definition, $bool);
    $this->applyFlagFilter('non_native', $definition, $bool);
    $this->applyUserFiltersSearchArea($definition, $bool);
    //$this->applyUserFiltersLocationName($definition, $bool);
    $this->applyUserFiltersIndexedLocationList($definition, $bool);
    //$this->applyUserFiltersIndexedLocationTypeList($definition, $bool, $readAuth);
    $this->applyUserFiltersDate($definition, $bool);
    //$this->applyUserFiltersWho($definition, $bool);
    //$this->applyUserFiltersOccId($definition, $bool);
    //$this->applyUserFiltersOccExternalKey($definition, $bool);
    //$this->applyUserFiltersSmpId($definition, $bool);
    $this->applyUserFiltersQuality($definition, $bool);
    $this->applyUserFiltersIdentificationDifficulty($definition, $bool);
    $this->applyUserFiltersRuleChecks($definition, $bool);
    $this->applyUserFiltersAutoCheckRule($definition, $bool);
    $this->applyUserFiltersHasPhotos($definition, $bool);
    $this->applyUserFiltersWebsiteList($definition, $bool);
    $this->applyUserFiltersSurveyList($definition, $bool);
    $this->applyUserFiltersImportGuidList($definition, $bool);
    $this->applyUserFiltersInputFormList($definition, $bool);
    $this->applyUserFiltersGroupId($definition, $bool);
    //$this->applyUserFiltersAccessRestrictions($definition, $bool);
    $this->applyUserFiltersTaxaScratchpadList($definition, $bool);
    $this->applySharingAgreement($bool);
    // Merge filter with any query specified in the config.
    $this->conf['query'] = $this->conf['query'] ?? [];
    $this->conf['query']['bool'] = $this->conf['query']['bool'] ?? [];

    foreach ($bool as $op => $filters) {
      $this->conf['query']['bool'][$op] = $this->conf['query']['bool'][$op] ?? [];
      $this->conf['query']['bool'][$op] = array_merge($this->conf['query']['bool'][$op], $filters);
    }
    unset($this->conf['filterId']);
  }

  /**
   * Works out the filter value and associated operation for a set of params.
   */
  private function getDefinitionFilter($definition, array $params) {
    foreach ($params as $param) {
      if (!empty($definition[$param])) {
        return [
          'value' => $definition[$param],
          'op' => empty($definition[$param . '_op']) ? FALSE : $definition[$param . '_op'],
        ];
      }
    }
    return [];
  }

  /**
   * Converts an Indicia filter definition taxon_group_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersTaxonGroupList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, [
      'taxon_group_list',
      'taxon_group_id',
    ]);
    if (!empty($filter)) {
      $bool['must'][] = [
        'terms' => ['taxon.group_id' => explode(',', $filter['value'])],
      ];
    }
  }

  /**
   * Generic function to apply a taxonomy filter to ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   * @param string $filterField
   *   Name of the field to filter on ('id' or 'taxon_meaning_id').
   * @param string $filterValues
   *   Comma separated list of IDs to filter against.
   */
  private function applyTaxonomyFilter(array $definition, array &$bool, $filterField, $filterValues) {
    // Convert the IDs to external keys, stored in ES as taxon_ids.
    $taxonData = $this->get("$this->warehouseUrl/index.php/services/report/requestReport", [
      'report' => 'library/taxa/convert_ids_to_external_keys.xml',
      'reportSource' => 'local',
      $filterField => $filterValues,
      'master_checklist_id' => $this->masterChecklistId,
    ]);
    $keys = [];
    foreach ($taxonData as $taxon) {
      $keys[] = $taxon['external_key'];
    }
    $keys = array_unique($keys);
    $bool['must'][] = ['terms' => ['taxon.higher_taxon_ids' => $keys]];
  }

  /**
   * Converts an Indicia filter definition taxa_taxon_list_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersTaxaTaxonList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, [
      'taxa_taxon_list_list',
      'higher_taxa_taxon_list_list',
      'taxa_taxon_list_id',
      'higher_taxa_taxon_list_id',
    ]);
    if (!empty($filter)) {
      $this->applyTaxonomyFilter($definition, $bool, 'id', $filter['value']);
    }
  }

  /**
   * Converts an Indicia filter definition taxon_meaning_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersTaxonMeaning(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, [
      'taxon_meaning_list',
      'taxon_meaning_id',
    ]);
    if (!empty($filter)) {
      $this->applyTaxonomyFilter($definition, $bool, 'taxon_meaning_id', $filter['value']);
    }
  }

  /**
   * Converts an filter def taxa_taxon_list_external_key_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersTaxaTaxonListExternalKey(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, [
      'taxa_taxon_list_external_key_list',
    ]);
    if (!empty($filter)) {
      $bool['must'][] = ['terms' => ['taxon.higher_taxon_ids' => explode(',', $filter['value'])]];
    }
  }

  /**
   * Converts a filter definition taxon_rank_sort_order filter to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersTaxonRankSortOrder(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['taxon_rank_sort_order']);
    // Filter op can be =, >= or <=.
    if (!empty($filter)) {
      if ($filter['op'] === '=') {
        $bool['must'][] = [
          'match' => [
            'taxon.taxon_rank_sort_order' => $filter['value'],
          ],
        ];
      }
      else {
        $gte = $filter['op'] === '>=' ? $filter['value'] : NULL;
        $lte = $filter['op'] === '<=' ? $filter['value'] : NULL;
        $bool['must'][] = [
          'range' => [
            'taxon.taxon_rank_sort_order' => [
              'gte' => $gte,
              'lte' => $lte,
            ],
          ],
        ];
      }
    }
  }

  /**
   * Converts a filter definition flag filter to an ES query.
   *
   * @param string $flag
   *   Flag name, e.g. marine, terrestrial, freshwater, non_native.
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyFlagFilter($flag, array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ["{$flag}_flag"]);
    // Filter op can be =, >= or <=.
    if (!empty($filter) && $filter['value'] !== 'all') {
      $bool['must'][] = [
        'match' => [
          "taxon.$flag" => $filter['value'] === 'Y',
        ],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition search_area to an ES query.
   *
   * For ES purposes, any location_list filter is modified to a searchArea
   * filter beforehand.
   *
   * @param string $definition
   *   WKT for the searchArea in EPSG:4326.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersSearchArea($definition, array &$bool) {
    if (!empty($definition['searchArea'])) {
      $bool['must'][] = [
        'geo_shape' => [
          'location.geom' => [
            'shape' => $definition['searchArea'],
            'relation' => 'intersects',
          ],
        ],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition indexed_location_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersIndexedLocationList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, [
      'indexed_location_list',
      'indexed_location_id',
    ]);
    if (!empty($filter)) {
      $boolClause = !empty($filter['op']) && $filter['op'] === 'not in' ? 'must_not' : 'must';
      $bool[$boolClause][] = [
        'nested' => [
          'path' => 'location.higher_geography',
          'query' => [
            'terms' => ['location.higher_geography.id' => explode(',', $filter['value'])],
          ],
        ],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition date filter to an ES query.
   *
   * Date range, year or date age filters supported. Support for recorded
   * (default), input, edited, verified dates. Age is supported as long as
   * format specifies age in minutes, hours, days, weeks, months or years.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersDate(array $definition, array &$bool) {
    $esFields = [
      'recorded' => 'event.date_start',
      'input' => 'metadata.created_on',
      'edited' => 'metadata.updated_on',
      'verified' => 'identification.verified_on',
    ];
    // Default to recorded date.
    $definition['date_type'] = empty($definition['date_type']) ? 'recorded' : $definition['date_type'];
    // Check to see if we have a year filter.
    $fieldName = $definition['date_type'] === 'recorded' ? "date_year" : "$definition[date_type]_date_year";
    if (!empty($definition[$fieldName]) && !empty($definition[$fieldName . '_op'])) {
      if ($definition[$fieldName . '_op'] === '=') {
        $bool['must'][] = [
          'term' => [
            'event.year' => $definition[$fieldName],
          ],
        ];
      }
      else {
        $esOp = $definition[$fieldName . '_op'] === '>=' ? 'gte' : 'lte';
        $bool['must'][] = [
          'range' => [
            'event.year' => [
              $esOp => $definition[$fieldName],
            ],
          ],
        ];
      }
    }
    else {
      // Check for other filters that work off the precise date fields.
      $dateTypes = [
        'from' => 'gte',
        'to' => 'lte',
        'age' => 'gte',
      ];
      foreach ($dateTypes as $type => $esOp) {
        $fieldName = $definition['date_type'] === 'recorded' ? "date_$type" : "$definition[date_type]_date_$type";
        if (!empty($definition[$fieldName])) {
          $value = $definition[$fieldName];
          // Convert date format.
          if (preg_match('/^(?P<d>\d{2})\/(?P<m>\d{2})\/(?P<Y>\d{4})$/', $value, $matches)) {
            $value = "$matches[Y]-$matches[m]-$matches[d]";
          }
          elseif ($type === 'age') {
            $value = 'now-' . str_replace(
              ['minute', 'hour', 'day', 'week', 'month', 'year', 's', ' '],
              ['m', 'H', 'd', 'w', 'M', 'y', '', ''],
              strtolower($value)
            );
          }
          $bool['must'][] = [
            'range' => [
              $esFields[$definition['date_type']] => [
                $esOp => $value,
              ],
            ],
          ];
        }
      }
    }
  }

  /**
   * Converts an Indicia filter definition quality filter to an ES query.
   *
   * Note that option 'OV' (decision by other verifiers) is not supported.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersQuality(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['quality']);
    if (!empty($filter)) {
      $valueList = explode(',', $filter['value']);
      $defs = [];
      foreach ($valueList as $value) {
        switch ($value) {
          // Answered query.
          case 'A':
            $defs[] = [
              'term' => ['identification.query.keyword' => 'A'],
            ];
            break;

          // Plausible.
          case 'C3':
            $defs[] = [
              'bool' => [
                'must' => [
                  ['term' => ['identification.verification_status' => 'C']],
                  ['term' => ['identification.verification_substatus' => 3]],
                ],
              ],
            ];
            break;

          // Queried.
          case 'D':
            $defs[] = [
              'term' => ['identification.query.keyword' => 'Q'],
            ];
            break;

          case 'P':
            $defs[] = [
              'bool' => [
                'must' => [
                  ['term' => ['identification.verification_status' => 'C']],
                  ['term' => ['identification.verification_substatus' => 0]],
                ],
                'must_not' => [
                  ['exists' => ['field' => 'identification.query']],
                ],
              ],
            ];
            break;

          // Not accepted.
          case 'R':
            $defs[] = [
              'term' => ['identification.verification_status' => 'R'],
            ];
            break;

          case 'R4':
            $defs[] = [
              'bool' => [
                'must' => [
                  ['term' => ['identification.verification_status' => 'R']],
                  ['term' => ['identification.verification_substatus' => 4]],
                ],
              ],
            ];
            break;

          case 'R5':
            $defs[] = [
              'bool' => [
                'must' => [
                  ['term' => ['identification.verification_status' => 'R']],
                  ['term' => ['identification.verification_substatus' => 5]],
                ],
              ],
            ];
            break;

          // Accepted.
          case 'V':
            $defs[] = ['term' => ['identification.verification_status' => 'V']];
            break;

          case 'V1':
            $defs[] = [
              'bool' => [
                'must' => [
                  ['term' => ['identification.verification_status' => 'V']],
                  ['term' => ['identification.verification_substatus' => 1]],
                ],
              ],
            ];
            break;

          case 'V2':
            $defs[] = [
              'bool' => [
                'must' => [
                  ['term' => ['identification.verification_status' => 'V']],
                  ['term' => ['identification.verification_substatus' => 2]],
                ],
              ],
            ];
            break;

          // Legacy parameters to support old filters.
          // Accepted or plausible.
          case '-3':
            $defs[] = [
              'bool' => [
                'should' => [
                  // Verified.
                  ['term' => ['identification.verification_status' => 'V']],
                  // Or plausible.
                  [
                    'bool' => [
                      'must' => [
                        ['term' => ['identification.verification_status' => 'C']],
                        ['term' => ['identification.verification_substatus' => 3]],
                      ],
                    ],
                  ],
                ],
              ],
            ];
            break;

          // Not queried or rejected.
          case '!D':
            $defs[] = [
              'bool' => [
                'must_not' => [
                  ['term' => ['identification.verification_status' => 'R']],
                  ['terms' => ['identification.query.keyword' => ['Q', 'A']]],
                ],
              ],
            ];
            break;

          // Not rejected.
          case '!R':
            $defs[] = [
              'bool' => [
                'must_not' => [
                  ['term' => ['identification.verification_status' => 'R']],
                ],
              ],
            ];
            break;

          // Recorder certain.
          case 'C':
            $defs[] = [
              'bool' => [
                'must' => [
                  ['term' => ['identification.recorder_certainty.keyword' => 'Certain']],
                ],
                'must_not' => [
                  ['term' => ['identification.verification_status' => 'R']],
                ],
              ],
            ];
            break;

          // Queried or not accepted.
          case 'DR':
            $defs[] = [
              'bool' => [
                'should' => [
                  ['term' => ['identification.verification_status' => 'R']],
                  ['match' => ['identification.query' => 'Q']],
                ],
              ],
            ];
            break;

          // Recorder thinks record identification is likely.
          case 'L':
            $defs[] = [
              'bool' => [
                'must' => [
                  [
                    'terms' => [
                      'identification.recorder_certainty.keyword' => [
                        'Certain',
                        'Likely',
                      ],
                    ],
                  ],
                ],
                'must_not' => [
                  ['term' => ['identification.verification_status' => 'R']],
                ],
              ],
            ];
            break;

          default:
            // Nothing to do for 'all'.
        }
      }
      if (!empty($defs)) {
        $boolGroup = !empty($filter['op']) && $filter['op'] === 'not in' ? 'must_not' : 'must';
        if (count($defs) === 1) {
          // Single filter can be simplified.
          $bool[$boolGroup][] = [array_keys($defs[0])[0] => array_values($defs[0])[0]];
        }
        else {
          // Join multiple filters with OR.
          $bool[$boolGroup][] = ['bool' => ['should' => $defs]];
        }
      }
    }
  }

  /**
   * Converts an Indicia filter id difficulty filter to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersIdentificationDifficulty(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['identification_difficulty']);
    if (!empty($filter) && !empty($filter['op'])) {
      if (in_array($filter['op'], ['>=', '<='])) {
        $test = $filter['op'] === '>=' ? 'gte' : 'lte';
        $bool['must'][] = [
          'range' => [
            'identification.auto_checks.identification_difficulty' => [
              $test => $filter['value'],
            ],
          ],
        ];
      }
      else {
        $bool['must'][] = ['term' => ['identification.auto_checks.identification_difficulty' => $filter['value']]];
      }
    }
  }

  /**
   * Converts an Indicia filter definition rule checks filter to an ES query.
   *
   * Handles both automatic checks and a user's custom verification rule flags.
   * Note that custom rule checks are not supported.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersRuleChecks(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['autochecks']);
    if (!empty($filter)) {
      if (in_array($filter['value'], ['P', 'F'])) {
        // Pass or Fail options are auto-checks from the Data Cleaner module.
        $bool['must'][] = [
          'match' => [
            'identification.auto_checks.result' => $filter['value'] === 'P',
          ],
        ];
        if ($filter['value'] === 'P') {
          $bool['must'][] = [
            'query_string' => ['query' => '_exists_:identification.auto_checks.verification_rule_types_applied'],
          ];
        }
      }
    }
  }

  /**
   * Converts an Indicia filter definition auto checks filter to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersAutoCheckRule(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['autocheck_rule']);
    if (!empty($filter)) {
      $value = str_replace('_', '', $filter['value']);
      $bool['must'][] = [
        'term' => ['identification.auto_checks.output.rule_type' => $value],
      ];
    }

  }

  /**
   * Converts an Indicia filter definition website_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersWebsiteList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, [
      'website_list',
      'website_id',
    ]);
    if (!empty($filter)) {
      $boolClause = !empty($filter['op']) && $filter['op'] === 'not in' ? 'must_not' : 'must';
      $bool[$boolClause][] = [
        'terms' => ['metadata.website.id' => explode(',', $filter['value'])],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition survey_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersSurveyList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, [
      'survey_list',
      'survey_id',
    ]);
    if (!empty($filter)) {
      $boolClause = !empty($filter['op']) && $filter['op'] === 'not in' ? 'must_not' : 'must';
      $bool[$boolClause][] = [
        'terms' => ['metadata.survey.id' => explode(',', $filter['value'])],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition import_guid_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersImportGuidList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['import_guid_list']);
    if (!empty($filter)) {
      $boolClause = !empty($filter['op']) && $filter['op'] === 'not in' ? 'must_not' : 'must';
      $bool[$boolClause][] = [
        'terms' => [
          'metadata.import_guid' => explode(',', str_replace("'", '', $filter['value'])),
        ],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition input_form_list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersInputFormList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['input_form_list']);
    if (!empty($filter)) {
      $boolClause = !empty($filter['op']) && $filter['op'] === 'not in' ? 'must_not' : 'must';
      $bool[$boolClause][] = [
        'terms' => [
          'metadata.input_form' => explode(',', str_replace("'", '', $filter['value'])),
        ],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition group_id to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersGroupId(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['group_id']);
    if (!empty($filter)) {
      $bool['must'][] = [
        'terms' => ['metadata.group.id' => explode(',', $filter['value'])],
      ];
    }
  }

  /**
   * Converts an Indicia filter definition scratchpad list to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersTaxaScratchpadList(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['taxa_scratchpad_list_id']);
    if (!empty($filter)) {
      // Convert the IDs to external keys, stored in ES as taxon_ids.
      $taxonData = $this->get("$this->warehouseUrl/index.php/services/report/requestReport", [
        'report' => 'library/taxa/external_keys_for_scratchpad.xml',
        'reportSource' => 'local',
        'sharing' => 'data_flow',
        'scratchpad_list_id' => $filter['value'],
      ]);
      $keys = [];
      foreach ($taxonData as $taxon) {
        $keys[] = $taxon['external_key'];
      }
      $bool['must'][] = ['terms' => ['taxon.higher_taxon_ids' => $keys]];
    }
  }

  /**
   * Converts an Indicia filter definition has_photos filter to an ES query.
   *
   * @param array $definition
   *   Definition loaded for the Indicia filter.
   * @param array $bool
   *   Bool clauses that filters can be added to (e.g. $bool['must']).
   */
  private function applyUserFiltersHasPhotos(array $definition, array &$bool) {
    $filter = $this->getDefinitionFilter($definition, ['has_photos']);
    if (!empty($filter)) {
      $boolClause = !empty($filter['op']) && $filter['op'] === 'not in' ? 'must_not' : 'must';
      $bool[$boolClause][] = [
        'nested' => [
          'path' => 'occurrence.media',
          'query' => [
            'bool' => [
              'must' => ['exists' => ['field' => 'occurrence.media']],
            ],
          ],
        ],
      ];
    }
  }

  /**
   * Applies the list of shared data flow websites to the filter.
   */
  private function applySharingAgreement(array &$bool) {
    $websites = $this->get("$this->warehouseUrl/index.php/services/report/requestReport", [
      'report' => 'library/websites/websites_list.xml',
      'reportSource' => 'local',
      'sharing' => 'data_flow',
    ]);
    $websiteIds = [];
    foreach ($websites as $website) {
      $websiteIds[] = (integer) $website['id'];
    }
    sort($websiteIds);
    $bool['must'][] = [
      'terms' => ['metadata.website.id' => $websiteIds],
    ];
  }

  /**
   * Retrieve database records from the Indicia warehouse.
   *
   * @param array $options
   *   Provide the following entries in the options array:
   *   * table - the singular name of the database table to read from.
   *   * id - optional ID of record to load.
   *   * params - array of field/value pairs to provide as a filter to the data
   *     services request. E.g. specify a record ID to load.
   *
   * @return array
   *   Array of records, with each record being defined by an associative array
   *   of field values.
   */
  public function getData(array $options) {
    if (!isset($options['table'])) {
      throw new exception('Please supply the singular name of the table you want to read data from in the options array');
    }
    $request = "$this->warehouseUrl/index.php/services/data/$options[table]";
    if (isset($options['id'])) {
      $request .= "/$options[id]";
    }
    if (!isset($options['params'])) {
      $options['params'] = [];
    }
    return $this->get($request, $options['params']);
  }

  /**
   * A generic internal method for sending a request to the web-services.
   *
   * @param string $request
   *   The URL to request data from.
   * @param array $params
   *   Parameters to add to the URL as a query string.
   *
   * @return array
   *   List of records returned by the request.
   */
  private function get($request, $params) {
    $params = array_merge([
      'mode' => 'json',
      'auth_token' => $this->readAuth['auth_token'],
      'nonce' => $this->readAuth['nonce'],
    ], $params);
    $request .= '?' . http_build_query($params);
    return json_decode($this->http_post($request), TRUE);
  }

  /**
   * Internal method to retrieve auth tokens required for the warehouse.
   *
   * @return array
   *   Read tokens array.
   */
  private function getReadAuth() {
    $postargs = "website_id=" . $this->websiteID;
    $nonce = $this->http_post($this->warehouseUrl . '/index.php/services/security/get_read_nonce', $postargs);
    return [
      'auth_token' => sha1("$nonce:$this->websitePassword"),
      'nonce' => $nonce,
    ];
  }

  /**
   * Internal method which posts data to a specified URL.
   *
   * @param string $url
   *   Web services URL to post data to.
   * @param string $postargs
   *   Query string to include in the post.
   *
   * @return string
   *   Response from the warehouse.
   */
  private function http_post($url, $postargs = NULL) {
    $session = curl_init();
    // Set the POST options.
    curl_setopt($session, CURLOPT_URL, $url);
    if ($postargs !== NULL) {
      curl_setopt($session, CURLOPT_POST, TRUE);
      curl_setopt($session, CURLOPT_POSTFIELDS, $postargs);
    }
    curl_setopt($session, CURLOPT_HEADER, FALSE);
    curl_setopt($session, CURLOPT_RETURNTRANSFER, TRUE);
    // Do the POST.
    $response = curl_exec($session);
    $httpCode = curl_getinfo($session, CURLINFO_HTTP_CODE);
    // Check for an error, or check if the http response was not OK.
    if (curl_errno($session) || $httpCode !== 200) {
      if (curl_errno($session)) {
        throw new exception(curl_errno($session) . ' - ' . curl_error($session));
      }
      else {
        throw new exception($httpCode . ' - ' . $response);
      }
    }
    curl_close($session);
    return $response;
  }

  /**
   * Return the CSV file to output raw data into.
   *
   * @return string
   *   File name.
   */
  private function getOutputCsvFileName(array $fileMetadata) {
    if ($this->conf['outputType'] === 'csv' && count($this->dataFiles) === 1) {
      return $this->conf['outputFile'];
    }
    return $fileMetadata['filename'];
  }

  /**
   * If the file type is DwcA, build the zip file.
   *
   * Adds the occurrences CSV file and the optional XML files.
   */
  private function updateDwcaFile() {
    $zip = new ZipArchive();
    $zip->open($this->conf['outputFile'], ZipArchive::CREATE);
    echo "Zip archive file opened\n";
    echo $this->conf['outputFile'] . "\n";
    foreach ($this->dataFiles as $fileMetadata) {
      $zip->addFile($this->getOutputCsvFileName($fileMetadata));
    }
    // If the EML and metadata files are specified then add them.
    if (!empty($this->conf['xmlFilesInDir'])) {
      $zip->addFile($this->conf['xmlFilesInDir'] . DIRECTORY_SEPARATOR . 'eml.xml', 'eml.xml');
      $zip->addFile($this->conf['xmlFilesInDir'] . DIRECTORY_SEPARATOR . 'meta.xml', 'meta.xml');
    }
    $zip->close();
    foreach ($this->dataFiles as $fileMetadata) {
      // Don't need the CSV file - has to be done after zip close.
      unlink($this->getOutputCsvFileName($fileMetadata));
    }
  }

  /**
   * Return the array to represent an occurrence document as DwcA CSV.
   *
   * @param array $source
   *   ES occurrence document source.
   *
   * @return array
   *   CSV data.
   */
  private function getOccurrenceRowData(array $source, array $fileMetadata) {
    $points = explode(',', $source['location']['point']);
    $sensitiveOrNotPoint = (isset($source['metadata']['sensitive']) && $source['metadata']['sensitive'] === 'true') ||
      (isset($source['location']['input_sref_system']) && !preg_match('/^\d+$/', $source['location']['input_sref_system']));
    $useGridRefsIfPossible = in_array('useGridRefsIfPossible', $this->conf['options']);
    $row = [];
    $mappings = [
      'occurrenceID' => $this->conf['occurrenceIdPrefix'] . $source['id'],
      'id' => $this->conf['occurrenceIdPrefix'] . $source['id'],
      'otherCatalogNumbers' => empty($source['occurrence']['source_system_key']) ? '' : $source['occurrence']['source_system_key'],
      'eventID' => $this->conf['eventIdPrefix'] . $source['event']['event_id'],
      // If an extension, we only support occurrences being an extension of
      // events, so the coreid will always point to an event.
      'coreid' => $this->conf['eventIdPrefix'] . $source['event']['event_id'],
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
      // Tolerate DwC/US English or UK English.
      'licence' => empty($source['metadata']['licence_code']) ? $this->conf['defaultLicenceCode'] : $source['metadata']['licence_code'],
      'license' => empty($source['metadata']['licence_code']) ? $this->conf['defaultLicenceCode'] : $source['metadata']['licence_code'],
      'rightsHolder' => $this->conf['rightsHolder'],
      'coordinateUncertaintyInMeters' => empty($source['location']['coordinate_uncertainty_in_meters']) ? '' : $source['location']['coordinate_uncertainty_in_meters'],
      'gridReference' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? $source['location']['output_sref'] : '',
      'decimalLatitude' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? '' : $points[0],
      'decimalLongitude' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? '' : $points[1],
      'geodeticDatum' => 'WGS84',
      'datasetName' => $this->conf['datasetName'],
      'datasetID' => $this->getDatasetId($source),
      'collectionCode' => $this->getCollectionCode($source),
      'locality' => empty($source['location']['verbatim_locality']) ? '' : $source['location']['verbatim_locality'],
      'basisOfRecord' => $this->conf['basisOfRecord'],
      'identificationVerificationStatus' => $this->getIdentificationVerificationStatus($source),
      'identifiedBy' => empty($source['identification']['identified_by']) ? '' : $source['identification']['identified_by'],
      'occurrenceStatus' => $source['occurrence']['zero_abundance'] === 'true' ? 'absent' : 'present',
      'eventRemarks' => empty($source['event']['event_remarks']) ? '' : $source['event']['event_remarks'],
      'occurrenceRemarks' => empty($source['occurrence']['occurrence_remarks']) ? '' : $source['occurrence']['occurrence_remarks'],
    ];
    foreach ($fileMetadata['columns'] as $dwcTerm) {
      $row[] = $mappings[$dwcTerm] ?? '';
    }
    return $row;
  }

  /**
   * Return the array to represent an event document as DwcA CSV.
   *
   * @param array $source
   *   ES event document source.
   *
   * @return array
   *   CSV data.
   */
  private function getEventRowData(array $source, array $fileMetadata) {
    $points = explode(',', $source['location']['point']);
    $sensitiveOrNotPoint = (isset($source['metadata']['sensitive']) && $source['metadata']['sensitive'] === 'true') ||
      (isset($source['location']['input_sref_system']) && !preg_match('/^\d+$/', $source['location']['input_sref_system']));
    $useGridRefsIfPossible = in_array('useGridRefsIfPossible', $this->conf['options']);
    $row = [];
    $mappings = [
      'eventID' => $this->conf['eventIdPrefix'] . $source['id'],
      'id' => $this->conf['eventIdPrefix'] . $source['id'],
      'parentEventID' => isset($source['event']['parent_event_id']) ? $this->conf['eventIdPrefix'] . $source['event']['parent_event_id'] : NULL,
      'eventDate' => $this->getDate($source),
      'year' => $source['event']['year'],
      'month' => $source['event']['month'],
      'coordinateUncertaintyInMeters' => empty($source['location']['coordinate_uncertainty_in_meters']) ? '' : $source['location']['coordinate_uncertainty_in_meters'],
      'gridReference' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? $source['location']['output_sref'] : '',
      'decimalLatitude' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? '' : $points[0],
      'decimalLongitude' => $useGridRefsIfPossible && $sensitiveOrNotPoint ? '' : $points[1],
      'geodeticDatum' => 'WGS84',
      'habitat' => empty($source['event']['habitat']) ? '' : $source['event']['habitat'],
      'eventRemarks' => empty($source['event']['event_remarks']) ? '' : $source['event']['event_remarks'],
      'samplingProtocol' => empty($source['event']['sampling_protocol']) ? '' : $source['event']['sampling_protocol'],
    ];
    foreach ($fileMetadata['columns'] as $dwcTerm) {
      $row[] = $mappings[$dwcTerm] ?? '';
    }
    return $row;
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
    if (!empty($this->conf['datasetIdSampleAttrId']) && !empty($source['event']['attributes'])) {
      foreach ($source['event']['attributes'] as $attr) {
        if ($attr['id'] == $this->conf['datasetIdSampleAttrId']) {
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
$helper->buildFiles($configFile);
