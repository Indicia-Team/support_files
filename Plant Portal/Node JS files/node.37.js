jQuery(document).ready(function () {
  // Do not allow return to submit the form
  jQuery('#entry_form').keydown(function (e) {
    if (e.keyCode == 13) {
      e.preventDefault();
      return false;
    }
  });

  jQuery('#tab-submit').val('Submit');
  jQuery('#tab-submit').click(function() {
    if (confirm('Are you sure you want to submit this survey?')) {
      jQuery('#tab-submit').trigger();
    } else {
      return false;
    }
  });

  detect_canopy_option();
  jQuery('#smpAttr\\:1624').on('change', function() {
    detect_canopy_option();
  });

  detect_abundance_option();
  jQuery('#smpAttr\\:1625').on('change', function() {
    detect_abundance_option();
  });
});

function detect_canopy_option() {
  if (jQuery('#smpAttr\\:1624').is(':checked')) {
    jQuery('#canopy-container').show()
  } else {
    jQuery('#canopy-container').hide()
  }
}

function detect_abundance_option() {
  if (jQuery('#smpAttr\\:1625\\:0:checked').val()) {
    show_domin();
  } else if (jQuery('#smpAttr\\:1625\\:1:checked').val()) {
    show_braun();
  } else if (jQuery('#smpAttr\\:1625\\:2:checked').val()) {
    show_percentage();
  } else if (jQuery('#smpAttr\\:1625\\:3:checked').val()) {
    show_individual_plant();
  } else if (jQuery('#smpAttr\\:1625\\:4:checked').val()) {
    show_cell_freq();
  } else if (jQuery('#smpAttr\\:1625\\:5:checked').val()) {
    show_present_absent();
  } else {
  	hide_all_abundances();
  }
}

function show_domin() {
  determine_column_to_show_hide('domin','show');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
  determine_column_to_show_hide('present_absent','hide');
}

function show_braun() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','show');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
  determine_column_to_show_hide('present_absent','hide');
}
  
function show_percentage() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','show');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
  determine_column_to_show_hide('present_absent','hide');
}
  
function show_individual_plant() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','show');
  determine_column_to_show_hide('cell_freq','hide');
  determine_column_to_show_hide('present_absent','hide');
}
  
function show_cell_freq() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','show');
  determine_column_to_show_hide('present_absent','hide');
}

function show_present_absent() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
  determine_column_to_show_hide('present_absent','show');
}

function hide_all_abundances() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
  determine_column_to_show_hide('present_absent','hide');
}

function determine_column_to_show_hide(abundanceType, action) {
  var dominAttrId = 214;
  var braunAttrId = 890;
  var percentageAttrId = 891;
  var individualPlantAttrId = 892;
  var cellFreqAttrId = 893;
  var presentAbsentAttrId = 894;
  var dominInputClass = 'scAbundance';
  var braunInputClass = 'scPlantPortalStandardBraunBlanquet';
  var percentageInputClass = 'scPlantPortalStandardPercentage';
  var individualPlantInputClass = 'scPlantPortalStandardIndividualPlantCount';
  var cellFreqInputClass = 'scPlantPortalStandardCellFrequency';
  var presentAbsentInputClass = 'scPlantPortalStandardPresentAbsent';
  
  if (abundanceType === 'domin') {
    if (action === 'show') {
      set_column_to_show_hide(dominAttrId, dominInputClass, 'show');
    } else {
      set_column_to_show_hide(dominAttrId, dominInputClass, 'hide');
    }
  }

  if (abundanceType === 'braun') {
    if (action === 'show') {
      set_column_to_show_hide(braunAttrId, braunInputClass, 'show');
    } else {
      set_column_to_show_hide(braunAttrId, braunInputClass, 'hide');
    }
  }

  if (abundanceType === 'percentage') {
    if (action === 'show') {
      set_column_to_show_hide(percentageAttrId, percentageInputClass, 'show');
    } else {
      set_column_to_show_hide(percentageAttrId, percentageInputClass, 'hide');
    }
  }

  if (abundanceType === 'individual_plant') {
    if (action === 'show') {
  	  set_column_to_show_hide(individualPlantAttrId, individualPlantInputClass, 'show');
    } else {
      set_column_to_show_hide(individualPlantAttrId, individualPlantInputClass, 'hide');
    }
  }

  if (abundanceType === 'cell_freq') {
    if (action === 'show') {
      set_column_to_show_hide(cellFreqAttrId, cellFreqInputClass, 'show');
    } else {
      set_column_to_show_hide(cellFreqAttrId, cellFreqInputClass, 'hide');
    }
  }
  
  if (abundanceType === 'present_absent') {
    if (action === 'show') {
      set_column_to_show_hide(presentAbsentAttrId, presentAbsentInputClass, 'show');
    } else {
      set_column_to_show_hide(presentAbsentAttrId, presentAbsentInputClass, 'hide');
    }
  }
}
  
function set_column_to_show_hide(attrId, inputClass, action) {
  var canopyGridId = 'canopy-grid';
  var groundLayerGridId = 'ground-layer-grid';
  if (action === 'show') {
    jQuery('#'+ canopyGridId + '-attr' + attrId + '-0').show();
    jQuery('#'+ groundLayerGridId + '-attr' + attrId + '-0').show();
    jQuery('.'+ inputClass + 'Cell').show();
  } else {
    jQuery('#'+ canopyGridId + '-attr' + attrId + '-0').hide();
    jQuery('#'+ groundLayerGridId + '-attr' + attrId + '-0').hide();
    jQuery('.'+ inputClass + 'Cell').hide();
    jQuery('.'+ inputClass).val('');
  }
}