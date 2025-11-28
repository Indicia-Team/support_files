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
 * @license http://www.gnu.org/licenses/gpl.html GPL 3.0
 * @link https://github.com/indicia-team/client_helpers/
 */

/**
 * Prebuilt Indicia data entry form.
 * NB has Drupal specific code.
 */

require_once 'dynamic_sample_occurrence.php';

class iform_earthwormwatch_sample_occurrence extends iform_dynamic_sample_occurrence {
  public static function get_parameters() {
    return array_merge(
      parent::get_parameters(),
      array(
        array(
          'name' => 'pit_1_survey_attr',
          'caption' => 'Survey attribute id for pit 1',
          'description' => 'Attribute to hold the survey ID for pit 1.',
          'type' => 'string',
          'group' => 'Attribute IDs',
          'required'=>true
        ),
        array(
          'name' => 'postcode_attr_id',
          'caption' => 'Post code attribute ID',
          'description' => 'Attribute id for the attribute to hold the Post Code.',
          'type' => 'string',
          'group' => 'Attribute IDs',
          'required'=>true
        ),
        array(
          'name' => 'auto_fill_attrs_for_survey_two',
          'caption' => 'Attribute IDs to auto-fill for survey 2',
          'description' => 'Comma separated list of attribute IDs to auto-fill for survey 2.',
          'type' => 'string',
          'group' => 'Attribute IDs',
          'required'=>true
        ),
        array(
          'name' => 'locking_date',
          'caption' => 'Locking Date',
          'description' => 'The date to lock the form from. Samples "created on" earlier than this date are read-only (use format yyyy-mm-dd)',
          'type' => 'string',
          'group' => 'Locking Date',
          'required'=>false
        ),
        array(
          'name' => 'ignore_grid_sample_dates_before',
          'caption' => 'Ignore grid sample date before',
          'description' => 'Exclude any samples before this date on the initial grid of data.',
          'type' => 'string',
          'group' => 'Other IForm Parameters',
          'required'=>false
        ),
      )
    );
  }

  /**
   * Return the form metadata.
   * @return array The definition of the form.
   */
  public static function get_earthwormwatch_sample_occurrence_definition() {
    return array(
      'title' => 'Sample-occurrence entry form for Earthworm Watch.',
      'category' => 'Forms for specific surveying methods',
      'description' => 'Sample occurrences form for Earthworm Earthwatch project, allows two earthworm pit (samples) to be linked together.'
    );
  }

  protected static function get_form_html($args, $auth, $attributes) {
    global $user;

    data_entry_helper::$javascript .= "
      var sampleCreatedOn;
      var lockingDate;
    ";
    //Test if the sample date is less than the locking date, if it is then lock the form.
    if (!empty($_GET['sample_id'])&&!empty($args['locking_date']) && !(in_array('administrator', $user->roles))) {
      $sampleData = data_entry_helper::get_population_data(array(
        'table' => 'sample',
        'extraParams' => $auth['read'] + array('id' => $_GET['sample_id'], 'view' => 'detail'),
      ));
      //The date also has a time element. However this breaks javascript new date, so just get first part of the date (remove time).
      //(the line below just gets the part of the string before the space).
      $sampleCreatedOn = strtok($sampleData[0]['created_on'],  ' ');
      if (!empty($sampleCreatedOn)) {
        data_entry_helper::$javascript .= "
          sampleCreatedOn = new Date('".$sampleCreatedOn."');
          lockingDate = new Date('".$args['locking_date']."');
        ";
      }
    }
    //If the date the sample was created is less than the threshold date set by the user, then
    //lock the form (put simply, old data cannot be edited by the user).
    data_entry_helper::$javascript .= "
      if (sampleCreatedOn&&lockingDate&&sampleCreatedOn<lockingDate) {
        $('[id*=_lock]').remove();\n $('.remove-row').remove();\n
        $('.scImageLink,.scClonableRow').hide();
        $('.edit-taxon-name,.remove-row').hide();
        $('#disableDiv').find('input, textarea, text, button, select').attr('disabled','disabled');
      }";
    //remove default validation mode of 'message' as species grid goes spazzy
    data_entry_helper::$validation_mode = array('colour');
    //Div that can be used to disable page when required
    $r = '<div id = "disableDiv">';
    $r .= parent::get_form_html($args, $auth, $attributes);
    $r .= '</div>';
    return $r;
  }

  /**
   * Override function to add hidden attribute to store linked sample id
   * When adding a pit/survey 1 record this is given the value 0
   * When adding a pit/survey 2 record this is given the sample_id of the corresponding survey 1 record.
   * @param type $args
   * @param type $auth
   * @param type $attributes
   * @return string The hidden inputs that are added to the start of the form
   */
  protected static function getFormHiddenInputs($args, $auth, &$attributes) {
    $r = parent::getFormHiddenInputs($args, $auth, $attributes);
    $linkAttr = 'smpAttr:' . $args['pit_1_survey_attr'];
    if (array_key_exists('new', $_GET)) {
      if (array_key_exists('sample_id', $_GET)) {
        // Adding a pit 2 record
        $r .= '<input id="' . $linkAttr. '" type="hidden" name="' . $linkAttr. '" value="' . $_GET['sample_id'] . '"/>' . PHP_EOL;
      } else {
        // Adding a pit 1 record
        $r .= '<input id="' . $linkAttr. '" type="hidden" name="' . $linkAttr. '" value="0"/>' . PHP_EOL;
      }
    }
    return $r;
  }

  /**
   * Override function to include actions to add or edit the linked sample
   * Depends upon a report existing, e.g. earthworm_sample_occurrence_samples, that
   * returns the fields done1 and done2 where
   * done1 is true if there is no second sample linked to the first and
   * done2 is true when there is a second sample.
   */
  protected static function getReportActions() {
    return array(array('display' => 'Actions',
                       'actions' => array(array('caption' => lang::get('Edit Data For Pit 1'),
                                                'url' => '{currentUrl}',
                                                'urlParams' => array('edit' => '', 'sample_id' => '{sample_id1}')
                                               ),
                                          array('caption' => lang::get('Input Data For Pit 2'),
                                                'url' => '{currentUrl}',
                                                'urlParams' => array('new' => '', 'sample_id' => '{sample_id1}'),
                                                'visibility_field' => 'done1'
                                               ),
                                          array('caption' => lang::get('Edit Data For Pit 2'),
                                                'url' => '{currentUrl}',
                                                'urlParams' => array('edit' => '', 'sample_id' => '{sample_id2}'),
                                                'visibility_field' => 'done2'
                                               ),
    )));
  }

  /**
   * Override function to add the report parameter for the ID of the custom attribute which holds the linked sample.
   * Depends upon a report existing that uses the parameter e.g. earthworm_sample_occurrence_samples
   */
  protected static function getSampleListGrid($args, $nid, $auth, $attributes) {
    // User must be logged in before we can access their records.
    if (!hostsite_get_user_field('id')) {
      // Return a login link that takes you back to this form when done.
      return lang::get('<br><br><br><br><br><br><p>Before using this facility, please <a href="'.url('user/login', array('query'=>array('destination=node/'.($nid)))).'">Login</a> to the website, or <a href="'.url('user/register', array('query'=>array('destination=node/'.($nid)))).'">Register</a> if you haven’t done so previously.</p><br><br><br><br><br><br>');
    }

    // Get the Indicia User ID to filter on.
    if (function_exists('hostsite_get_user_field')) {
      $iUserId = hostsite_get_user_field('indicia_user_id');
      if (isset($iUserId)) {
        $repOptions=array(
            'survey_id' => $args['survey_id'],
            's1AttrID' => $args['pit_1_survey_attr'],
            'iUserID' => $iUserId);
        if (!empty($args['ignore_grid_sample_dates_before']))
          $repOptions=array_merge($repOptions,array('ignore_dates_before'=>$args['ignore_grid_sample_dates_before']));
        $filter = $repOptions;
      }
    }
    // Return with error message if we cannot identify the user records
    if (!isset($filter)) {
      return lang::get('LANG_No_User_Id');
    }

    // An option for derived classes to add in extra html before the grid
    if(method_exists(self::$called_class, 'getSampleListGridPreamble'))
      $r = call_user_func(array(self::$called_class, 'getSampleListGridPreamble'));
    else
      $r = '';

    iform_load_helpers(['report_helper']);
    $r .= report_helper::report_grid(array(
      'id' => 'samples-grid',
      'dataSource' => $args['grid_report'],
      'mode' => 'report',
      'readAuth' => $auth['read'],
      'columns' => call_user_func(array(self::$called_class, 'getReportActions')),
      'itemsPerPage' =>(isset($args['grid_num_rows']) ? $args['grid_num_rows'] : 10),
      'autoParamsForm' => true,
      'extraParams' => $filter
    ));
    $r .= '<form>';
    if (isset($args['multiple_occurrence_mode']) && $args['multiple_occurrence_mode']=='either') {
      $r .= '<input type="button" value="'.lang::get('LANG_Add_Sample_Single').'" onclick="window.location.href=\''.url('node/'.($nid), array('query' => array('new'))).'\'">';
      $r .= '<input type="button" value="'.lang::get('LANG_Add_Sample_Grid').'" onclick="window.location.href=\''.url('node/'.($nid), array('query' => array('new&gridmode'))).'\'">';
    } else {
      $r .= '<input id="add-new-pit-button" type="button" value="'.lang::get('LANG_Add_Sample').'" onclick="window.location.href=\''.url('node/'.($nid), array('query' => array('new' => ''))).'\'">';
    }
    $r .= '</form>';
    return $r;
  }

  /*
   * Modified to only keep the location/site fields for survey 2. Also don't retain occurrences.
   */
  protected static function cloneEntity($args, $auth, &$attributes) {
    // First modify the sample attribute information in the $attributes array.
    // Set the sample attribute fieldnames as for a new record
    foreach($attributes as $attributeKey => $attributeValue){
      if ($attributeValue['multi_value'] == 't') {
         // Set the attribute fieldname to the attribute id plus brackets for multi-value attributes
        $attributes[$attributeKey]['fieldname'] = $attributeValue['id'] . '[]';
        foreach($attributeValue['default'] as $defaultKey => $defaultValue) {
          $attributes[$attributeKey]['default'][$defaultKey]['fieldname']=null;
        }
      } else {
        // Set the attribute fieldname to the attribute id for single values
        $attributes[$attributeKey]['fieldname'] = $attributeValue['id'];
      }
    }
    //New for Earthworm Watch, only bring accross the location related fields for pit 2.
    if (!empty($args['auto_fill_attrs_for_survey_two']))
      $idsToBringAcross = explode(',',trim($args['auto_fill_attrs_for_survey_two']));
    foreach($attributes as $attributeKey => &$attributeProperties) {
      if (isset($attributeProperties['attributeId'])
        //Only ever bring across the specified attributes from pit 1. Not this does not apply to location_name
        //which comes across regardless
        && (empty($idsToBringAcross)||(!in_array($attributeProperties['attributeId'],$idsToBringAcross)))) {
        $attributeProperties['default']='';
      }
    }
    data_entry_helper::$javascript .= "";
    // Unset the sample and occurrence id from entitiy_to_load as for a new record.
    if (isset(data_entry_helper::$entity_to_load['sample:id']))
      unset(data_entry_helper::$entity_to_load['sample:id']);
    if (isset(data_entry_helper::$entity_to_load['occurrence:id']))
      unset(data_entry_helper::$entity_to_load['occurrence:id']);
  }

  /**
   * Override preload_species_checklist_occurrences so we remove elements that would cause occurrence
   * attributes to be loaded into survey 2.
   */
  public static function preload_species_checklist_occurrences($sampleId, $readAuth, $loadMedia, $extraParams,
       &$subSamples, $useSubSamples, $subSampleMethodID='') {
    $occurrenceIds = [];
    // don't load from the db if there are validation errors, since the $_POST will already contain all the
    // data we need.
    if (is_null(data_entry_helper::$validation_errors)) {
      // strip out any occurrences we've already loaded into the entity_to_load, in case there are other
      // checklist grids on the same page. Otherwise we'd double up the record data.
      foreach(data_entry_helper::$entity_to_load as $key => $value) {
        $parts = explode(':', $key);
        if (count($parts) > 2 && $parts[0] == 'sc' && $parts[1]!='-idx-') {
          unset(data_entry_helper::$entity_to_load[$key]);
        }
      }
      $extraParams += $readAuth + array('view' => 'detail','sample_id'=>$sampleId,'deleted' => 'f', 'orderby' => 'id', 'sortdir' => 'ASC' );
      $sampleCount = 1;

      if($sampleCount>0) {
        $occurrences = data_entry_helper::get_population_data(array(
          'table' => 'occurrence',
          'extraParams' => $extraParams,
          'nocache' => true
        ));
        foreach($occurrences as $idx => $occurrence){
          if($useSubSamples){
            foreach($subSamples as $sidx => $subsample){
              if($subsample['id'] == $occurrence['sample_id'])
                data_entry_helper::$entity_to_load['sc:'.$idx.':'.$occurrence['id'].':occurrence:sampleIDX'] = $sidx;
            }
          }
          data_entry_helper::$entity_to_load['sc:'.$idx.':'.$occurrence['id'].':present'] = $occurrence['taxa_taxon_list_id'];
          data_entry_helper::$entity_to_load['sc:'.$idx.':'.$occurrence['id'].':record_status'] = $occurrence['record_status'];
          data_entry_helper::$entity_to_load['sc:'.$idx.':'.$occurrence['id'].':occurrence:comment'] = $occurrence['comment'];
          data_entry_helper::$entity_to_load['sc:'.$idx.':'.$occurrence['id'].':occurrence:sensitivity_precision'] = $occurrence['sensitivity_precision'];
          // Warning. I observe that, in cases where more than one occurrence is loaded, the following entries in
          // $entity_to_load will just take the value of the last loaded occurrence.
          data_entry_helper::$entity_to_load['occurrence:record_status']=$occurrence['record_status'];
          data_entry_helper::$entity_to_load['occurrence:taxa_taxon_list_id']=$occurrence['taxa_taxon_list_id'];
          data_entry_helper::$entity_to_load['occurrence:taxa_taxon_list_id:taxon']=$occurrence['taxon'];
          // Keep a list of all Ids
          $occurrenceIds[$occurrence['id']] = $idx;
        }
      }
    }
    return $occurrenceIds;
  }

  /*
   * Post Code control to allow the spatial reference to be automatically populated by entering a Post Code.
   */
  protected static function get_control_postcode($auth, $args, $tabalias, $options) {
    if (!empty($args['postcode_attr_id'])) {
      $fieldName='smpAttr:'.$args['postcode_attr_id'];
      //If data exists then load existing data into control
      if (!empty($_GET['sample_id'])) {
        $postCodeData = data_entry_helper::get_population_data(array(
          'table' => 'sample_attribute_value',
          'extraParams'=> $auth['read'] + array('sample_id' => $_GET['sample_id'], 'sample_attribute_id' => $args['postcode_attr_id']),
          'nocache' => true
        ));
        if  (!empty($postCodeData[0]['id']) && !empty($postCodeData[0]['value'])) {
          //Adjust field name to include sample attribute value id when reloading existing data
          //Need to make sure "edit=" is in the URL, as this indicates we aren't adding a second pit, at which point we would actually need
          //a new attribute rather than edit the old one.
          if (array_key_exists('edit',$_GET))
            $fieldName=$fieldName.':'.$postCodeData[0]['id'];
          data_entry_helper::$javascript .= "$(document).ready(function () {
            $('#imp-postcode').val('".$postCodeData[0]['value']."');
          });";
        }
      }
      $r = data_entry_helper::postcode_textbox(array(
        'label' => 'Postcode',
        'fieldname'=>$fieldName,
        'srefField' => 'sample:entered_sref',
        'hiddenFields'=>false,
      ));
    } else {
      $r='<div>Please supply the Post Code attribute ID in the Edit Tab arguments</div>';
    }
    return $r;
  }

  /*
   * A html table that allows the use to select a colour and for it to automatically change the soil colour drop-down
   */
  protected static function get_control_soilcolourselector($auth, $args, $tabalias, $options) {
    if (empty($options['soilDropAttId'])||
            empty($options['A1_tt'])||empty($options['A2_tt'])||empty($options['A3_tt'])||empty($options['A4_tt'])||empty($options['A5_tt'])||empty($options['A6_tt'])||empty($options['A7_tt'])||
            empty($options['B1_tt'])||empty($options['B2_tt'])||empty($options['B3_tt'])||empty($options['B4_tt'])||empty($options['B5_tt'])||empty($options['B6_tt'])||
            empty($options['C1_tt'])||empty($options['C2_tt'])||empty($options['C3_tt'])||empty($options['C4_tt'])||empty($options['C5_tt'])||empty($options['C6_tt'])||
            empty($options['D1_tt'])||empty($options['D2_tt'])||empty($options['D3_tt'])||empty($options['D4_tt'])||empty($options['D5_tt'])||
            empty($options['E2_tt'])||empty($options['E3_tt'])||empty($options['E4_tt'])) {
      return '<div>Please fill in all the options for the soil colour selector control.</div>';
    }

    $r='<div><table>';
    $r.='<tr><td class="soil-select-header-cell"></td><td class="soil-select-header-cell">A</td><td class="soil-select-header-cell">B</td><td class="soil-select-header-cell">C</td><td class="soil-select-header-cell">D</td><td class="soil-colour-header-cell">E</td></tr>';
    $r.='<tr><td class="soil-select-row-title-cell">1</td><td id="colour-cell-A-1" class="soil-select-colour-cell" tt='.$options['A1_tt'].'></td><td  id="colour-cell-B-1" class="soil-select-colour-cell" tt='.$options['B1_tt'].'></td><td id="colour-cell-C-1" class="soil-select-colour-cell" tt='.$options['C1_tt'].'></td><td id="colour-cell-D-1" class="soil-select-colour-cell" tt='.$options['D1_tt'].'></td><td id="colour-cell-E-1" class="soil-select-colour-cell"></td></tr>';
    $r.='<tr><td class="soil-select-row-title-cell">2</td><td id="colour-cell-A-2" class="soil-select-colour-cell" tt='.$options['A2_tt'].'></td><td id="colour-cell-B-2" class="soil-select-colour-cell" tt='.$options['B2_tt'].'></td><td id="colour-cell-C-2" class="soil-select-colour-cell" tt='.$options['C2_tt'].'></td><td id="colour-cell-D-2" class="soil-select-colour-cell" tt='.$options['D2_tt'].'></td><td id="colour-cell-E-2" class="soil-select-colour-cell" tt='.$options['E2_tt'].'></td></tr>';
    $r.='<tr><td class="soil-select-row-title-cell">3</td><td id="colour-cell-A-3" class="soil-select-colour-cell" tt='.$options['A3_tt'].'></td><td id="colour-cell-B-3" class="soil-select-colour-cell" tt='.$options['B3_tt'].'></td><td id="colour-cell-C-3" class="soil-select-colour-cell" tt='.$options['C3_tt'].'></td><td id="colour-cell-D-3" class="soil-select-colour-cell" tt='.$options['D3_tt'].'></td><td id="colour-cell-E-3" class="soil-select-colour-cell" tt='.$options['E3_tt'].'></td></tr>';
    $r.='<tr><td class="soil-select-row-title-cell">4</td><td id="colour-cell-A-4" class="soil-select-colour-cell" tt='.$options['A4_tt'].'></td><td id="colour-cell-B-4" class="soil-select-colour-cell" tt='.$options['B4_tt'].'></td><td id="colour-cell-C-4" class="soil-select-colour-cell" tt='.$options['C4_tt'].'></td><td id="colour-cell-D-4" class="soil-select-colour-cell" tt='.$options['D4_tt'].'></td><td id="colour-cell-E-4" class="soil-select-colour-cell" tt='.$options['E4_tt'].'></td></tr>';
    $r.='<tr><td class="soil-select-row-title-cell">5</td><td id="colour-cell-A-5" class="soil-select-colour-cell" tt='.$options['A5_tt'].'></td><td id="colour-cell-B-5" class="soil-select-colour-cell" tt='.$options['B5_tt'].'></td><td id="colour-cell-C-5" class="soil-select-colour-cell" tt='.$options['C5_tt'].'></td><td id="colour-cell-D-5" class="soil-select-colour-cell" tt='.$options['D5_tt'].'></td><td id="colour-cell-E-5" class="soil-select-colour-cell"></td></tr>';
    $r.='<tr><td class="soil-select-row-title-cell">6</td><td id="colour-cell-A-6" class="soil-select-colour-cell" tt='.$options['A6_tt'].'></td><td id="colour-cell-B-6" class="soil-select-colour-cell" tt='.$options['B6_tt'].'></td><td id="colour-cell-C-6" class="soil-select-colour-cell" tt='.$options['C6_tt'].'></td><td id="colour-cell-D-6" class="soil-select-colour-cell"></td><td id="colour-cell-E-6" class="soil-select-colour-cell"></td></tr>';
    $r.='<tr><td class="soil-select-row-title-cell">7</td><td id="colour-cell-A-7" class="soil-select-colour-cell" tt='.$options['A7_tt'].'></td><td id="colour-cell-B-7" class="soil-select-colour-cell" ></td><td id="colour-cell-C-7" class="soil-select-colour-cell"></td><td id="colour-cell-D-7" class="soil-select-colour-cell"></td><td id="colour-cell-E-7" class="soil-select-colour-cell"></td></tr>';
    $r.='</table></div>';
    //Each colour cell in the table has an attribute called "tt" (termlist term), this hold the id of the termlist term for the colour code
    //e.g. A2. We can then set the colour drop-down to the appropriate value.
    data_entry_helper::$javascript .= "
    $('.soil-select-colour-cell').on('click', function () {
      $('#smpAttr\\\\:".$options['soilDropAttId']."').val($(this).attr('tt'));
      $('#smpAttr\\\\:".$options['soilDropAttId']."').attr('selected', true);
    });\n";
    return $r;
  }

  /*
   * Override the Recorder Names control so that it defaults to the user's chosen Display Name (nickname)
   * @param array $options additional options for the control with the following possibilities
   * <li><b>displayNameProfileFieldName</b><br/>
   * The name of the user profile field that holds the display name</li>
   */
  protected static function get_control_recordernames($auth, $args, $tabAlias, $options) {
    if (empty($_GET['sample_id']) && function_exists('hostsite_get_user_field') && !empty($options['displayNameProfileFieldName'])) {
      $displayName = hostsite_get_user_field($options['displayNameProfileFieldName']);
      //Need to escape characters otherwise a name like O'Brian will break the page HTML
      data_entry_helper::$javascript .= "$('#sample\\\\:recorder_names').val('".addslashes($displayName)."');";
    }
    return data_entry_helper::textarea(array_merge(array(
      'fieldname' => 'sample:recorder_names',
      'label'=>lang::get('Recorder names')
    ), $options));
  }

  /*
   * Display the pit number is a label, also hide the pit distance question for pit 1.
   * Note you may wish to wrap the control with further HTML to change text type.
   * @param array $options additional options for the control with the following possibilities
   * <li><b>label</b><br/>
   * Text to use to the left of the display pit number</li>
   * <li><b>distanceQuestionAttrId</b><br/>
   * Text to use to the left of the display pit number</li>
   * <li><b>distanceQuestionDoNotKnowAttrId</b><br/>
   * ID of the attribute that holds the answer to the Don't Know checkbox on the distance between pits question</li>
   */
  protected static function get_control_pitspecificlabelandquestions($auth, $args, $tabAlias, $options) {
    if (!empty($options['label']))
      $displayLabel=$options['label'].' ';
    else
      $displayLabel='Pit ';
    if (!empty($_GET['sample_id'])) {
      $pit1AttrData = data_entry_helper::get_population_data(array(
        'table' => 'sample_attribute_value',
        'extraParams' => $auth['read'] + array('sample_id' => $_GET['sample_id'], 'sample_attribute_id' => $args['pit_1_survey_attr']),
      ));
    }
    //It is only ever Pit 2 if pit two has been already been saved and as such the Pit 1 attribute has been populated for it
    //OR
    //We detect that there is an existing pit in the params and "new=" is indicated in params (i.e. pit 2 is being created)
    if ((!empty($pit1AttrData[0]['value'])&&$pit1AttrData[0]['value'] != 0)||
            (array_key_exists('new',$_GET)&&!empty($_GET['sample_id']))) {
      $displayLabel=$displayLabel.'2';
    } else {
      $displayLabel=$displayLabel.'1';
      if (!empty($options['distanceQuestionAttrId'])&&!empty($options['distanceQuestionDoNotKnowAttrId'])) {
        data_entry_helper::$javascript .= "$('#ctrl-wrap-smpAttr-".$options['distanceQuestionAttrId']."').hide();\n";
        data_entry_helper::$javascript .= "$('#ctrl-wrap-smpAttr-".$options['distanceQuestionDoNotKnowAttrId']."').hide();\n";
      }
    }
    return $displayLabel;
  }

  protected static function getSampleListGridPreamble() {
    $r = '';
    $r .= '<br><p class="first-pit-help"><b>Completed your Earthworm Watch survey? Submit your data by using this simple form.</b></p>';
    $r .= '<p class="first-pit-help"><b>To get started, first add details about your site, and then input data for each of your soil pits in turn.</b></p>';
    $r .= '<br><p class="edit-pit-help"><b>You are now ready to enter data for pit 2 if you have not already done so.</b></p>';
    $r .= '<p class="edit-pit-help">You can use the links you can see at the right of the data row to edit a pit or enter pit 2 data.</p>';
    $r .= '<p class="edit-pit-help">If you wish to, you can do the survey again at a different site by using the button at the bottom of the grid.</p>';
    return $r;
  }

  /* Custom submission because when changes are made to fields shered between pits, they need to be copied to the other pit */
  public static function get_submission($values, $args, $nid) {
    //To Do: Do we even these "remembered" lines?
    global $remembered;
    $remembered = isset($args['remembered']) ? $args['remembered'] : '';
    //Get submission for the pit we are working on
    $mainSubmission = data_entry_helper::build_sample_occurrences_list_submission($values);
    //Keep the second pit in sync for fields that require syncing.
    if (!empty($values['sample:id'])) {
      $otherPitSubmission=self::get_second_pit_submission($values, $args,$mainSubmission);
    }
    //If there are two pits, do a multi-submission
    if (!empty($otherPitSubmission)) {
      $finalSubmission['submission_list']['entries'][0]=$mainSubmission;
      $finalSubmission['submission_list']['entries'][1]=$otherPitSubmission;
      $finalSubmission['id']='sample';
    } else {
      $finalSubmission=$mainSubmission;
    }
    return $finalSubmission;
  }

  /*
   * Get a submission of the second try only containing fields shared between pits
   */
  protected static function get_second_pit_submission($values, $args,$mainSubmission) {
    $readAuth = data_entry_helper::get_read_auth($args['website_id'], $args['password']);
    //Attempt to get a sample ID for Pit 1 attached to the edited pit (this will only work if pit 2 is the editing pit
    $pit1Data = data_entry_helper::get_population_data(array(
      'table' => 'sample_attribute_value',
      'extraParams'=> $readAuth + array('sample_id' => $values['sample:id'], 'sample_attribute_id' => $args['pit_1_survey_attr']),
      'nocache' => true
    ));
    //If pit 1 is attached to the pit then get sample id from the attribute
    if (!empty($pit1Data[0]['value']) && $pit1Data[0]['value']!='0') {
     $idForOtherPit=$pit1Data[0]['value'];
   } else {
      //If pit 1 isn't attached to the pit, it means we could be dealing with pit 1 and we need to get the sample id for pit 2
      //This is done in a similar, but slightly differently because Pit 1 is attached to Pit 2 in a sample attribute value,
      //so we find Pit 1's sample_id in the sample_attribute_values and then find the sample id storing that.
      $pit2Data = data_entry_helper::get_population_data(array(
        'table' => 'sample_attribute_value',
        'extraParams'=> $readAuth + array('value' => $values['sample:id'], 'sample_attribute_id' => $args['pit_1_survey_attr']),
        'nocache' => true
      ));
      if (!empty($pit2Data[0]['sample_id']))
        $idForOtherPit=$pit2Data[0]['sample_id'];
    }
    //If we can't find a value for the other pit, there might not be one. This would happen in the situation where
    //the user was editing pit 1 and pit 2 didn't exist yet. In that case don't return the other submission.
    if (!empty($idForOtherPit)) {
      $otherPitSubmission=self::build_second_pit_submission($values, $args,$mainSubmission,$idForOtherPit);
      $otherPitSubmission['fields']['id']['value']=$idForOtherPit;
    } else {
      $otherPitSubmission=null;
    }
    return $otherPitSubmission;
  }

  /*
   * Build submission for the other pit
   */
  protected static function build_second_pit_submission($values, $args, $mainSubmission,$idForOtherPit) {
     //When we update the other pit, we are only interested in updating the values which are shared between to the two pits
    if (!empty($args['auto_fill_attrs_for_survey_two']))
      $idsForOtherPitSubmission = explode(',',trim($args['auto_fill_attrs_for_survey_two']));
    //Get the existing sample_attribute_values for the other pit as we need to overwrite them, so need their IDs
    $readAuth = data_entry_helper::get_read_auth($args['website_id'], $args['password']);
    $otherPitExistingData = data_entry_helper::get_population_data(array(
      'table' => 'sample_attribute_value',
      'extraParams'=> $readAuth + array('sample_id' => $idForOtherPit),
      'nocache' => true
    ));
    //Hold each existing Sample Attribute Value ID in an array with the Attribute ID as the key
    $attrValIdsForAttrsToSync=[];
    foreach($otherPitExistingData as $otherPitExistingDataItem) {
      //Split the existing for the other pit into two arrays, one is for attributes we are going to overwrite,
      //the other is ones that are going to stay the same (they need including in the submission, as some are mandatory so system doesn't like them missing)
      if (in_array($otherPitExistingDataItem['sample_attribute_id'],$idsForOtherPitSubmission))
        $attrValIdsForAttrsToSync[$otherPitExistingDataItem['sample_attribute_id']]=$otherPitExistingDataItem['id'];
      else
        $attrsToKeepForOtherPit[$otherPitExistingDataItem['sample_attribute_id']]=array('samp_attr_val_id'=>$otherPitExistingDataItem['id'],'samp_attr_val_value'=>$otherPitExistingDataItem['raw_value']);
    }

    //cycle through all the fields from the main pit submission as this will hold the new data values to place onto the other pit
    $otherPitSubmission=array('id' => 'sample','fields'=>[]);
    foreach ($mainSubmission['fields'] as $mainSubmissionFieldName=>$arrayHoldingValueKey) {
      $explodedMainSubmissionFieldNameBits=explode(':',$mainSubmissionFieldName);
      //$explodedMainSubmissionFieldNameBits[1] is the attribute ID, so we are only interested in these attributes and things like survey ID
      if ((!empty($explodedMainSubmissionFieldNameBits[1]) && in_array($explodedMainSubmissionFieldNameBits[1],$idsForOtherPitSubmission))||
              $mainSubmissionFieldName==='survey_id'||
              $mainSubmissionFieldName==='website_id'||
              $mainSubmissionFieldName==='recorder_names'||
              $mainSubmissionFieldName==='location_name'||
              $mainSubmissionFieldName==='entered_sref'||
              $mainSubmissionFieldName==='entered_sref_system') {
        //When we find a field we are interested in, then the attach it to the other pit submission (including the existing sample attribute value where required).
        //Include the existing attribute value id if we have one (i.e. it is an attribute rather than a field like recorder names)
        if ($explodedMainSubmissionFieldNameBits[0]==='smpAttr'&& (!empty($explodedMainSubmissionFieldNameBits[1])&&array_key_exists($explodedMainSubmissionFieldNameBits[1],$attrValIdsForAttrsToSync)))
          $mainSubmissionFieldName = $explodedMainSubmissionFieldNameBits[0].':'.$explodedMainSubmissionFieldNameBits[1].':'.$attrValIdsForAttrsToSync[$explodedMainSubmissionFieldNameBits[1]];
        $otherPitSubmission['fields'][$mainSubmissionFieldName]=$arrayHoldingValueKey;
      } else {
        //Include attributes that will stay the same as some are mandatory and the system won't like it if they are missing
        if (!empty($explodedMainSubmissionFieldNameBits[1])) {
          if ($explodedMainSubmissionFieldNameBits[0]==='smpAttr'&& array_key_exists($explodedMainSubmissionFieldNameBits[1],$attrsToKeepForOtherPit))
            $mainSubmissionFieldName = $explodedMainSubmissionFieldNameBits[0].':'.$explodedMainSubmissionFieldNameBits[1].':'.$attrsToKeepForOtherPit[$explodedMainSubmissionFieldNameBits[1]]['samp_attr_val_id'];
          $otherPitSubmission['fields'][$mainSubmissionFieldName]['value']=$attrsToKeepForOtherPit[$explodedMainSubmissionFieldNameBits[1]]['samp_attr_val_value'];
        }
      }
    }
    return $otherPitSubmission;
  }
}
?>
