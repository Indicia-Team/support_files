jQuery(document).ready(function () {
  detect_abundance_option();
  jQuery('#smpAttr\\:1977').on('change', function() {
    detect_abundance_option();
  });
});

function detect_abundance_option() {
  if (jQuery('#smpAttr\\:1977\\:0:checked').val()) {
    show_count();
  } else if (jQuery('#smpAttr\\:1977\\:1:checked').val()) {
    show_present_absent();
  } else if (jQuery('#smpAttr\\:1977\\:2:checked').val()) {
    show_sacfor();
  } else {
  	hide_all_abundances();
  }
}

function show_count() {
  determine_column_to_show_hide('count','show');
  determine_column_to_show_hide('present_absent','hide');
  determine_column_to_show_hide('sacfor','hide');
}

function show_present_absent() {
  determine_column_to_show_hide('count','hide');
  determine_column_to_show_hide('present_absent','show');
  determine_column_to_show_hide('sacfor','hide');
}
  
function show_sacfor() {
  determine_column_to_show_hide('count','hide');
  determine_column_to_show_hide('present_absent','hide');
  determine_column_to_show_hide('sacfor','show');
}

function hide_all_abundances() {
  determine_column_to_show_hide('count','hide');
  determine_column_to_show_hide('present_absent','hide');
  determine_column_to_show_hide('sacfor','hide');
}

function determine_column_to_show_hide(abundanceType, action) {
  var countAttrId = 16;
  var presentAbsentAttrId = 1181;
  var sacforAttrId = 531;
  var countInputClass = 'scAbundance';
  var presentAbsentInputClass = 'scPA';
  var sacforInputClass = 'scSACFORP';
  
  if (abundanceType === 'count') {
    if (action === 'show') {
      set_column_to_show_hide(countAttrId, countInputClass, 'show');
    } else {
      set_column_to_show_hide(countAttrId, countInputClass, 'hide');
    }
  }

  if (abundanceType === 'present_absent') {
    if (action === 'show') {
      set_column_to_show_hide(presentAbsentAttrId, presentAbsentInputClass, 'show');
    } else {
      set_column_to_show_hide(presentAbsentAttrId, presentAbsentInputClass, 'hide');
    }
  }

  if (abundanceType === 'sacfor') {
    if (action === 'show') {
      set_column_to_show_hide(sacforAttrId, sacforInputClass, 'show');
    } else {
      set_column_to_show_hide(sacforAttrId, sacforInputClass, 'hide');
    }
  }
}

function set_column_to_show_hide(attrId, inputClass, action) {
  if (action === 'show') {
    jQuery('#fulllist-attr' + attrId + '-0').show();
    jQuery('.'+ inputClass + 'Cell').show();
  } else {
    jQuery('#fulllist-attr' + attrId + '-0').hide();
    jQuery('.'+ inputClass + 'Cell').hide();
    jQuery('.'+ inputClass).val('');
  }
}