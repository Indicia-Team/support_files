jQuery(document).ready(function () {
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
  }
  
  if (jQuery('#smpAttr\\:1625\\:1:checked').val()) {
    show_braun();
  }
  
  if (jQuery('#smpAttr\\:1625\\:2:checked').val()) {
    show_percentage();
  }
  
  if (jQuery('#smpAttr\\:1625\\:3:checked').val()) {
    show_individual_plant();
  }
  
  if (jQuery('#smpAttr\\:1625\\:4:checked').val()) {
    show_cell_freq();
  }
}

function show_domin() {
  determine_column_to_show_hide('domin','show');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
}

function show_braun() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','show');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
}
  
function show_percentage() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','show');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','hide');
}
  
function show_individual_plant() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','show');
  determine_column_to_show_hide('cell_freq','hide');
}
  
function show_cell_freq() {
  determine_column_to_show_hide('domin','hide');
  determine_column_to_show_hide('braun','hide');
  determine_column_to_show_hide('percentage','hide');
  determine_column_to_show_hide('individual_plant','hide');
  determine_column_to_show_hide('cell_freq','show');
}

function determine_column_to_show_hide(abundanceType, action) {
  var dominAttrId = 214;
  var braunAttrId = 890;
  var percentageAttrId = 891;
  var individualPlantAttrId = 892;
  var cellFreqAttrId = 893;
  var dominCellClass = 'scIndicatorInventoryAbundance';
  var braunCellClass = 'scPlantPortalStandardBraunBlanquetCell';
  var percentageCellClass = 'scPlantPortalStandardPercentageCell';
  var individualPlantCellClass = 'scPlantPortalStandardIndividualPlantCountCell';
  var cellFreqCellClass = 'scPlantPortalStandardCellFrequencyCell';

  if (abundanceType === 'domin') {
    if (action === 'show') {
      set_column_to_show_hide(dominAttrId, dominCellClass, 'show');
    } else {
      set_column_to_show_hide(dominAttrId, dominCellClass, 'hide');
    }
  }

  if (abundanceType === 'braun') {
    if (action === 'show') {
      set_column_to_show_hide(braunAttrId, braunCellClass, 'show');
    } else {
      set_column_to_show_hide(braunAttrId, braunCellClass, 'hide');
    }
  }

  if (abundanceType === 'percentage') {
    if (action === 'show') {
      set_column_to_show_hide(percentageAttrId, percentageCellClass, 'show');
    } else {
      set_column_to_show_hide(percentageAttrId, percentageCellClass, 'hide');
    }
  }

  if (abundanceType === 'individual_plant') {
    if (action === 'show') {
  	  set_column_to_show_hide(individualPlantAttrId, individualPlantCellClass, 'show');
    } else {
      set_column_to_show_hide(individualPlantAttrId, individualPlantCellClass, 'hide');
    }
  }

  if (abundanceType === 'cell_freq') {
    if (action === 'show') {
      set_column_to_show_hide(cellFreqAttrId, cellFreqCellClass, 'show');
    } else {
      set_column_to_show_hide(cellFreqAttrId, cellFreqCellClass, 'hide');
    }
  }
}
  
function set_column_to_show_hide(attrId, inputClass, action) {
  var canopyGridId = 'canopy-grid';
  var groundLayerGridId = 'ground-layer-grid';
  if (action === 'show') {
    jQuery('#'+ canopyGridId + '-attr' + attrId + '-0').show();
    jQuery('#'+ groundLayerGridId + '-attr' + attrId + '-0').show();
    jQuery('.'+ inputClass).show();
  } else {
    jQuery('#'+ canopyGridId + '-attr' + attrId + '-0').hide();
    jQuery('#'+ groundLayerGridId + '-attr' + attrId + '-0').hide();
    jQuery('.'+ inputClass).hide();
  }
}