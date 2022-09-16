<?php
/**
 * Indicia, the OPAL Online Recording Toolkit.
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see http://www.gnu.org/licenses/gpl.html.
 *
 * @package	Client
 * @subpackage PrebuiltForms
 * @author	Indicia Team
 * @license	http://www.gnu.org/licenses/gpl.html GPL 3.0
 * @link 	http://code.google.com/p/indicia/
 */

/**
 * Extension class that supplies new controls to support the Pollinator Monitoring project.
 */
class extension_poms_extensions {

  /*
   * Control that inserts a column of textboxes into a report grid. 
   * A submit/save link column must be setup for the grid which calls the submit_corrected_sample_media_name function in the poms_extensions.js file.
   * @param array $options
   * $options Options array with the following possibilities:<ul>
   * <li><b>sampleMediaNameCheckingAttrId</b><br/>
   * ID of the text sample attribute that holds the corrected name of the sample media photo</li>
   */
  public static function sample_media_name_checking_extension($auth, $args, $tabAlias, $options) {
    $r = '';
    if (empty($options['sampleMediaNameCheckingAttrId'])) {
      $r .= '<h4>Please fill in the @sampleMediaNameCheckingAttrId option for the sample_media_name_checking_extension control</h4>';
      return '';
    }
    helper_base::$indiciaData['postUrlForSampleMediaChecking'] = iform_ajaxproxy_url(null, 'sample_attribute_value');
    helper_base::$indiciaData['websiteIdForSampleMediaChecking'] = $args['website_id'];
    helper_base::$indiciaData['sampleMediaNameCheckingAttrId'] = $options['sampleMediaNameCheckingAttrId'];
    return $r; 
  }

  /*
   * Control that inserts a column of species autocompletes into a report grid. 
   * A submit/save link column must be setup for the grid that calls the submit_corrected_occurrence_media_name function in poms_extensions.js.
   * @param array $options
   * $options Options array with the following possibilities:<ul>
   * <li><b>occurrenceMediaNameCheckingAttrId</b><br/>
   * ID of the integer occurrence attribute that holds the taxa_taxon_list_id of the corrected species</li>
   * <li><b>taxonListId</b><br/>
   * ID of the taxon list to limit the species autocomplete to</li>
   * <li><b>taxonGroupIds</b><br/>
   * Comma separated list of taxon group ids to limit the species autocomplete to</li>
   * <li><b>reportRowsPerPageNumber</b><br/>
   * Indicate how many rows are in each report grid page so the function knows how many species_autocompletes to draw</li>
   * <li><b>selectMode</b><br/>
   * True or false, whether the species_autocomplete should include a select drop-down (at the time of writing this doesn't work in report mode).</li>
   * <li><b>useCommonNameInAutocomplete</b><br/>
   * True or false, should the autocomplete items include the common name. Optional, default false</li>
   * <li><b>report</b><br/>
   * Optionally provide report to drive the autocompletes, else drive direct from table. Optional</li>
   */
  public static function occurrence_media_name_checking_extension($auth, $args, $tabAlias, $options) {
    $r = '';
    $extraParams=array();
    if (empty($options['occurrenceMediaNameCheckingAttrId'])) {
      $r .= '<h4>Please fill in the @occurrenceMediaNameCheckingAttrId option for the occurrence_media_name_checking_extension control</h4>';
      return '';
    }
    if (empty($options['reportRowsPerPageNumber'])) {
      $r .= '<h4>Please fill in the @reportRowsPerPageNumber option for the occurrence_media_name_checking_extension control</h4>';
      return '';
    }
    if (!empty($options['taxonListId'])) {
      $extraParams = array_merge($extraParams, array('taxon_list_id' => $options['taxonListId']));
    }
    if (!empty($options['taxonGroupList'])) {
      $extraParams = array_merge($extraParams, array('taxon_group_list' => $options['taxonGroupList']));
    }
    $extraParams = array_merge($extraParams, array('orderby' => 'taxon'));
    if (!empty($options['selectMode']) && $options['selectMode'] == true) {
      $options['selectMode'] = true;
      helper_base::$indiciaData['selectMode'] = true;
    } else {
      $options['selectMode'] = false;
      helper_base::$indiciaData['selectMode'] = false;
    }
    if (empty($options['useCommonNameInAutocomplete'])) {
      $options['useCommonNameInAutocomplete'] = false;
    }
    helper_base::$indiciaData['postUrlForOccurrenceMediaChecking'] = iform_ajaxproxy_url(null, 'occ_attribute_value');
    helper_base::$indiciaData['websiteIdForOccurrenceMediaChecking'] = $args['website_id'];
    helper_base::$indiciaData['occurrenceMediaNameCheckingAttrId'] = $options['occurrenceMediaNameCheckingAttrId'];
    helper_base::$indiciaData['reportRowsPerPageNumber'] = $options['reportRowsPerPageNumber'];

    if ($options['useCommonNameInAutocomplete'] === true) {
      self::build_autocomplete_label_function($args);
    }
    
    // An area we can manipulate the autocompletes in before bringing them to the grid
    $r .= '<div id = "autocomplete-containment-area">';
    
    $autoCompleteOptions = [
      'id' => 'species_correction-'.$idx,
      'fieldname' => 'species_correction-'.$idx,
      'class' => 'species_correction_autocomplete',
      'selectMode' => $options['selectMode'],
      'captionField' => 'taxon',
      'valueField' => 'id',
      'extraParams' => $auth['read'] + $extraParams
    ];
    // Draw each individual species autocomplete that we will move into the report grid using jQuery.
    for ($idx=0; $idx<$options['reportRowsPerPageNumber']; $idx++) {
      // If no report is supplied default is directly from table
      if (!empty($options['report'])) {
        $r .= data_entry_helper::species_autocomplete([
          'id' => 'species_correction-'.$idx,
          'fieldname' => 'species_correction-'.$idx,
          'class' => 'species_correction_autocomplete',
          'selectMode' => $options['selectMode'],
          'captionField' => 'preferred_taxon',
          'valueField' => 'id',
          'extraParams' => $auth['read'] + $extraParams,
          'report' => $options['report']
        ]);
      } else {
        $r .= data_entry_helper::species_autocomplete([
          'id' => 'species_correction-'.$idx,
          'fieldname' => 'species_correction-'.$idx,
          'class' => 'species_correction_autocomplete',
          'selectMode' => $options['selectMode'],
          'extraParams' => $auth['read'] + $extraParams,
          'speciesNameFilterMode' => 'currentLanguage'
        ]);
      }
    }
    $r .= '</div>';
    return $r;
  }

  /**
   * Build a PHP function to format the species autocomplete label
   */
  protected static function build_autocomplete_label_function($args) {
    global $indicia_templates;  
    $fn = "function(item) {\n".
        "    var r;\n".
        "    if (item.common && item.preferred_taxon != item.common) {\n".
        "      r = item.preferred_taxon + ' (' + item.common + ')';\n".
        "    } else {\n".
        "      r = item.preferred_taxon;\n". 
        "    }\n".
        "    return r\n".
        "  }\n";
    // Set it into the indicia templates
    $indicia_templates['format_species_autocomplete_fn'] = $fn;
  }

  /*
   * Allow the user to select a country at the top of the data entry form which then influences the termlist/species lists
   * shown to them.
   * (Note this won't currently work with an extra species drop-down which calls warehouse in realtime, it must be static species grid).
   * 
   * @param array $auth 
   *  
   * @param array $args
   *   List of page argument options available to the extension 
   * 
   * @param array $options
   * $options Options array with the following possibilities:<ul>
   * <li><b>countryTermlistId</b><br/>
   * Limit locations shown to users in the countries drop-down to the terms in the country termlist</li>
   * <li><b>termCountryAttributeId</b><br/>
   * The ID of the attribute that holds the countries a term is associated with</li>
   * <li><b>sampleCountryAttributeId</b><br/>
   * The ID of the attribute that holds the country a sample is associated with</li>
   * <li><b>listOfTermlistsToCheck</b><br/>
   * Comma separated list of attribute termlist IDs on the page (assists code speed))</li>
   * <li><b>ignoreSmpAttrs</b><br/>
   * Comma separated list of sample attribute IDs that are to be ignored (all terms will be returned)</li>
   * <li><b>locationTaxonAttributeId</b><br/>
   * The ID of the attribute that holds the countries a taxon is associated with</li>
   * 
   * @return string $r
   *   HTML generated by the extension.
   */
  public static function limit_termlists_and_species_to_selected_location($auth, $args, $tabAlias, $options) {
    // Allows the javascript to know this extension is being run
    helper_base::$indiciaData['limitTermlistsExtension'] = true;
    $r = '';
    if (empty($options['countryTermlistId'])) {
      $r .= '<h4>Please fill in the @countryTermlistId option for the limit_termlists_and_species_to_selected_location extension</h4>';
      return $r;
    }
    if (empty($options['termCountryAttributeId'])) {
      $r .= '<h4>Please fill in the @termCountryAttributeId option for the limit_termlists_and_species_to_selected_location extension</h4>';
      return $r;
    }
    if (empty($options['sampleCountryAttributeId'])) {
      $r .= '<h4>Please fill in the @sampleCountryAttributeId option for the limit_termlists_and_species_to_selected_location extension</h4>';
      return $r;
    }
    if (empty($options['listOfTermlistsToCheck'])) {
      $r .= '<h4>Please fill in the @listOfTermlistsToCheck option for the limit_termlists_and_species_to_selected_location extension</h4>';
      return $r;
    }
    if (empty($options['locationTaxonAttributeId'])) {
      $r .= '<h4>Please fill in the @locationTaxonAttributeId option for the limit_termlists_and_species_to_selected_location extension</h4>';
      return $r;
    }
    iform_load_helpers(['report_helper']);
    $termlistTermIdsToFilterBy = [];
    $taxaTaxonListIdsToFilterBy = [];
    /* When data entry is initially opened in add mode, display a country drop-down.
       When country selection is made, the page is reloaded with the country selection in the 
       location_termlist_and_species_filter parameter which then limits the species and termlists
       to entries applicable for that country. If it is an existng sample, that filter is held in a sample attribute.*/
    if (!empty($_GET['location_termlist_and_species_filter']) || !empty($_GET['sample_id'])) {
      helper_base::$indiciaData['foundFilterInUrl'] = true;
      // Get allowed termlists_term and taxa_taxon_list ids for a country
      $termlistTermIdsToFilterBy = self::get_terms_to_filter_by($auth, $options);
      $taxaTaxonListIdsToFilterBy = self::get_taxa_to_filter_by($auth, $args, $options);
    } 

    if (empty($_GET['location_termlist_and_species_filter']) || empty($_GET['sample_id'])) {
      $r .= self::create_countries_drop_down($auth['read'], $options['countryTermlistId']);
    }
      
    //}
    // In add mode, once the country selection is made, add a hidden field so this can be saved to the sample
    if (!empty($_GET['location_termlist_and_species_filter'])) {
      $r .= '<input style="display:none" id="smpAttr:'.$options['sampleCountryAttributeId'].'" name="smpAttr:'.$options['sampleCountryAttributeId'].'" value="'.$_GET['location_termlist_and_species_filter'].'">';
    }
    if (!empty($options['ignoreSmpAttrs'])) {
      $options['ignoreSmpAttrs'] = explode(',', $options['ignoreSmpAttrs']);
      helper_base::$indiciaData['ignoreSmpAttrs'] = json_encode($options['ignoreSmpAttrs']);
    } else {
      helper_base::$indiciaData['ignoreSmpAttrs'] = json_encode([]);
    }
    data_entry_helper::$javascript .= "filter_termlists_by_location(".json_encode($termlistTermIdsToFilterBy).");";
    data_entry_helper::$javascript .= "filter_species_by_location(".json_encode($taxaTaxonListIdsToFilterBy).");";
    return $r;
  }

  /** 
   * Convert the SQL results into a basic single dimension array
   * 
   * @param array $dbResult   
   *   Result directly from database
   * 
   * @return array $listToFilterBy
   *   Array for IDs to be used to filter the terms and taxa on the page to a particular country.
   */
  private static function build_allowed_ids_from_db_result($dbResult) {
    $listToFilterBy = [];
    if (!empty($dbResult[0]['id'])) {
      foreach ($dbResult as $idx => $dbRow) {
        $listToFilterBy[$idx] = $dbRow['id'];
      }
    }
    return $listToFilterBy;
  }

  /** 
   * Display the list of countries the user can select from to determine how the terms/species are filtered 
   * on the page.
   * 
   * @return array string
   *   HTML for a location select drop-down.
   */
  private static function create_countries_drop_down($readAuth, $countryTermlistId) {
    $r = '';
    $r .= data_entry_helper::select([
      'fieldname' => 'location_termlist_and_species_filter',
      'id' => 'location_termlist_and_species_filter',
      'label' => lang::get('LANG_Country_Label'),
      'blankText' => '<Please Select>',
      'table' => 'termlists_term',
      'captionField' => 'term',
      'valueField' => 'id',
      'default' => $_GET['location_termlist_and_species_filter'],
		  'extraParams' => $readAuth + array('view' => 'detail', 'termlist_id' => $countryTermlistId, 'preferred' => 't')
    ]);
    $r .= '<br>';
    return $r;
  }

  /** 
   * Return rows to indicate each term which is permitted to be displayed for the selected country 
   * 
   * @param array $auth  
   * 
   * @param array $options
   *   List of extension specific options available to the extension 
   * 
   * @return array $termlistTermIdsToFilterBy
   *   Array of IDs to be used for filtering the terms on the page to a particular country.
   */
  private static function get_terms_to_filter_by($auth, $options) {
    $params = [
      'location_term_attribute_id' => $options['termCountryAttributeId'],
      'list_of_termlists_to_check' => $options['listOfTermlistsToCheck'],
      'sample_country_attribute_id' => $options['sampleCountryAttributeId']
    ];
    // After language selection in add mode, we have a termlists_term ID for a location as a parameter
    if (!empty($_GET['location_termlist_and_species_filter'])) {
      $params = array_merge($params, ['location_termlist_and_species_filter' => $_GET['location_termlist_and_species_filter']]);
    }
    // If in edit mode, filter is held on a sample attribute
    // Ignore the sample_id for filtering if the location_termlist_and_species_filter param is set.
    // This is because the user might open a sample which doesn't have the country set, then sets
    // the country on the page, the empty sample country must then be ignored.
    if (!empty($_GET['sample_id']) && empty($_GET['location_termlist_and_species_filter'])) {
      $params = array_merge($params, ['sample_id' => $_GET['sample_id']]);
    }
    $termlistTermIdsToFilterByResult = report_helper::get_report_data([
      'dataSource' => 'projects/PoMS/location_termlist_filter',
      'readAuth' => $auth['read'],
      'extraParams' => $params
    ]);
    // Convert result into one dimensional array
    $termlistTermIdsToFilterBy = self::build_allowed_ids_from_db_result($termlistTermIdsToFilterByResult);
    return $termlistTermIdsToFilterBy;
  }

  /**
   * Return rows to indicate each taxa which is permitted to be displayed for the selected country.
   * 
   * @param array $auth  
   * 
   * @param array $args
   *   List of page argument options available to the extension 
   * 
   * @param array $options
   *   List of extension specific options available to the extension 
   * 
   */
  private static function get_taxa_to_filter_by($auth, $args, $options) {
    if (empty($args['list_id'])) {
      $args['list_id'] = '';
    }
    $params = [
      'location_taxon_attribute_id' => $options['locationTaxonAttributeId'],
      'list_of_taxon_lists_to_check' => $args['list_id'],
      'sample_country_attribute_id' => $options['sampleCountryAttributeId']
    ];
    // After language selection in add mode, we have a termlists_term ID for a location as a parameter
    if (!empty($_GET['location_termlist_and_species_filter'])) {
      $params = array_merge($params, ['location_termlist_and_species_filter' => $_GET['location_termlist_and_species_filter']]);
    }
    // If in edit mode, that filter is held as sample attribute
    if (!empty($_GET['sample_id'])) {
      $params = array_merge($params, ['sample_id' => $_GET['sample_id']]);
    }
    $taxaTaxonListIdsToFilterByResult = report_helper::get_report_data([
      'dataSource' => 'projects/PoMS/location_species_grid_filter',
      'readAuth' => $auth['read'],
      'extraParams' => $params
    ]);
    // Convert result into one dimensional array
    $taxaTaxonListIdsToFilterBy = self::build_allowed_ids_from_db_result($taxaTaxonListIdsToFilterByResult);
    return $taxaTaxonListIdsToFilterBy;
  }

  /**
   * Draw MVS square selector with an initial country filter. Currently used on the SPRING pan-trap form.
   * 
   * @param array $auth  
   * 
   * @param array $args
   *   List of page argument options available to the extension 
   * 
   * @param array $options
   *   List of extension specific options available to the extension 
   * 
   */
  public static function draw_country_and_square_location_control($auth, $args, $tabAlias, $options) {
    iform_load_helpers(array('report_helper'));
    // Get default to set country in edit mode as this isn't saved directly against the sample
    if (!empty($_GET['sample_id'])) {
      $defaultCountryAndSquareInfo = report_helper::get_report_data(
        array(
          'dataSource'=>'projects/poms/get_default_locations_for_sample',
          'readAuth'=>$auth['read'],
          'mode'=>'report',
          'extraParams' => array(
            'sample_id'=>$_GET['sample_id'],
            'country_location_type_id' => $options['countryLocationTypeId'],
            'square_country_code_loc_attr_id' => $options['squareCountryCodeLocAttrId'])
        )
      );
      $defaultCountrySelection = $defaultCountryAndSquareInfo[0]['country_id'];
      $defaultSquareSelection = $defaultCountryAndSquareInfo[0]['square_id'];
    } else {
      $defaultCountrySelection = '';
      $defaultSquareSelection = '';
    }
    $extraParamsForCountryList = array(
      'location_type_id' => $options['countryLocationTypeId'],
      'sensattr' => 0,
      'exclude_sensitive' => false
    );
    if (!empty($options['limitCountriesById'])) {
      $extraParamsForCountryList = array_merge($extraParamsForCountryList, array('idlist' => $options['limitCountriesById']));
    }
    $r = data_entry_helper::location_select(array(
      'report' =>  'library/locations/locations_list_exclude_sensitive',
      'lockable' => TRUE,
      'reportProvidesOrderBy' => TRUE,
      'id' => 'country-select-list',
      'helpText' => lang::get('Select a country to filter squares to.'),
      'fieldname' => 'country-select-list',
      'blankText' => lang::get('LANG_Blank_Text'),
      'blankText' => '<please select>',
      'default' => $defaultCountrySelection,
      'extraParams' => $auth['read'] + $extraParamsForCountryList
    ));
    // We need to default the square in javascript otherwise the country field is not reaady first
    if (!empty($defaultSquareSelection)) {
      data_entry_helper::$javascript .= 'indiciaData.defaultSquareSelection='.$defaultSquareSelection.";\n";
    }
    // Square location drop-down
    $r .= data_entry_helper::location_select(array(
      'parentControlId' => 'country-select-list',
      'lockable' => TRUE,
      'filterField' => 'country_id',
      'reportProvidesOrderBy' => true,
      'searchUpdatesSref' => false,
      'label' => '1km square',
      'validation' => 'required',
      'report' => 'projects/poms/get_squares_for_country_id',
      'id' => 'imp-location',
      'fieldname' =>  'sample:location_id',
      'extraParams' => $auth['read'] + array(
        'square_location_type_id' => $options['squareLocationTypeId'],
        'square_country_code_loc_attr_id' => $options['squareCountryCodeLocAttrId']
      ) 
    ));
    return $r;
  }

  /**
   * Draw country drop-down and country code for a square.
   *
   * @param array $auth
   *   Auth tokens for reporting.
   * @param array $args
   *   List of page argument options available to the extension.
   * @param array $tabAlias
   *   $tabAlias parameter.
   * @param array $options
   *   List of extension specific options available to the extension.
   */
  public static function drawCountryAndSetCountryCode($auth, $args, $tabAlias, $options) {
    iform_load_helpers(['report_helper']);
    if (empty($options['countryLocationTypeId'])) {
      $r .= '<h4>Please fill in the @countryLocationTypeId option for the draw_country_and_set_country_code control</h4>';
      return $r;
    }
    if (empty($options['limitCountriesById'])) {
      $r .= '<h4>Please fill in the @limitCountriesById option for the draw_country_and_set_country_code control</h4>';
      return $r;
    }
    if (empty($options['countryCodeLocAttrId'])) {
      $r .= '<h4>Please fill in the @countryCodeLocAttrId option for the draw_country_and_set_country_code control</h4>';
      return $r;
    }
    if (!empty($_GET['location_id'])) {
      $defaultCountryInfo = report_helper::get_report_data(
        [
          'dataSource' => 'projects/poms/get_default_country_for_square',
          'readAuth' => $auth['read'],
          'mode' => 'report',
          'extraParams' => [
            'square_id' => $_GET['location_id'],
            'country_location_type_id' => $options['countryLocationTypeId'],
            'country_code_location_attribute_id' => $options['countryCodeLocAttrId'],
          ]
        ]
      );
      $defaultCountrySelection = $defaultCountryInfo[0]['id'];
    }
    else {
      $defaultCountrySelection = '';
    }
    $extraParamsForCountryList = [
      'location_type_id' => $options['countryLocationTypeId'],
      'sensattr' => 0,
      'exclude_sensitive' => FALSE
    ];
    if (!empty($options['limitCountriesById'])) {
      $extraParamsForCountryList = array_merge($extraParamsForCountryList, ['idlist' => $options['limitCountriesById']]);
    }
    $r = data_entry_helper::location_select([
      'report' => 'library/locations/locations_list_exclude_sensitive',
      'reportProvidesOrderBy' => TRUE,
      'id' => 'country-select-list',
      'helpText' => lang::get('Please select a country for the square.'),
      'fieldname' => 'country-select-list',
      'blankText' => lang::get('LANG_Blank_Text'),
      'blankText' => '<please select>',
      'default' => $defaultCountrySelection,
      'extraParams' => $auth['read'] + $extraParamsForCountryList
    ]);
    data_entry_helper::$javascript .= "indiciaData.indiciaSvc = '" . data_entry_helper::$base_url . "';\n";
    data_entry_helper::$javascript .= "indiciaData.readAuth = {nonce: '" . $auth['read']['nonce'] . "', auth_token: '" . $auth['read']['auth_token'] . "'};\n";
    data_entry_helper::$javascript .= "
    $('#country-select-list').on('change', function() {
      $.getJSON(indiciaData.indiciaSvc + 'index.php/services/data/location?id=' + $(this).val() + '&location_type_id=' + " . $options['countryLocationTypeId'] . " +
          '&mode=json&view=detail&callback=?&auth_token=' + indiciaData.readAuth.auth_token + '&nonce=' + indiciaData.readAuth.nonce, 
        function(data) {
          if (data && data[0]) {
            $('#locAttr\\\\:" . $options['countryCodeLocAttrId'] . "').val(data[0].code);
          } else {
            $('#locAttr\\\\:" . $options['countryCodeLocAttrId'] . "').val('');
          }
        }
      );
    });\n";
    return $r;
  }

}
